import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:bugin/models/models.dart';
import 'package:bugin/services/storage/key_value_store.dart';

/// Доступ к геолокации — как его видит приложение.
enum LocationAccess {
  /// Можно спросить: ещё не спрашивали или один раз отказали.
  canAsk,

  /// Разрешено.
  granted,

  /// Отказано насовсем — включить можно только в настройках телефона.
  blocked,

  /// На телефоне выключена геолокация — включить в настройках.
  serviceOff,

  /// Нет на устройстве или не нужна (прототип на тестовых данных).
  unavailable,
}

/// Откуда берётся местоположение: телефон, выключено или точка для тестов.
abstract interface class LocationSource {
  /// Текущий доступ — без вопросов пользователю.
  Future<LocationAccess> access();

  /// Системный вопрос «Разрешить доступ к геопозиции?».
  Future<LocationAccess> request();

  /// Где сейчас пользователь; null — не удалось узнать.
  Future<GeoPoint?> current();

  /// Настройки телефона: приложения или геолокации — смотря что выключено.
  Future<void> openSettings(LocationAccess access);
}

/// Геолокация не используется (тестовые данные внутри приложения, тесты).
class NoLocationSource implements LocationSource {
  const NoLocationSource();

  @override
  Future<LocationAccess> access() async => LocationAccess.unavailable;

  @override
  Future<LocationAccess> request() async => LocationAccess.unavailable;

  @override
  Future<GeoPoint?> current() async => null;

  @override
  Future<void> openSettings(LocationAccess access) async {}
}

/// Геолокация телефона или браузера (пакет geolocator).
class DeviceLocationSource implements LocationSource {
  const DeviceLocationSource();

  @override
  Future<LocationAccess> access() => _guard(() async {
        if (!await Geolocator.isLocationServiceEnabled()) {
          return LocationAccess.serviceOff;
        }
        return _map(await Geolocator.checkPermission());
      });

  @override
  Future<LocationAccess> request() => _guard(() async {
        if (!await Geolocator.isLocationServiceEnabled()) {
          return LocationAccess.serviceOff;
        }
        return _map(await Geolocator.requestPermission());
      });

  @override
  Future<GeoPoint?> current() async {
    try {
      // Средней точности хватает, чтобы понять «рядом», и она быстрее GPS.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return GeoPoint(position.latitude, position.longitude);
    } catch (error) {
      debugPrint('Не удалось узнать местоположение: $error');
      return null;
    }
  }

  @override
  Future<void> openSettings(LocationAccess access) async {
    try {
      if (access == LocationAccess.serviceOff) {
        await Geolocator.openLocationSettings();
      } else {
        await Geolocator.openAppSettings();
      }
    } catch (error) {
      debugPrint('Настройки не открылись: $error');
    }
  }

  static Future<LocationAccess> _guard(Future<LocationAccess> Function() check) async {
    try {
      return await check();
    } catch (error) {
      debugPrint('Геолокация недоступна: $error');
      return LocationAccess.unavailable;
    }
  }

  static LocationAccess _map(LocationPermission permission) {
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return LocationAccess.granted;
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationAccess.blocked;
    }
    return LocationAccess.canAsk;
  }
}

/// Точка и доступ задаются в тесте.
class FixedLocationSource implements LocationSource {
  FixedLocationSource({
    this.point,
    LocationAccess access = LocationAccess.granted,
    this.afterRequest = LocationAccess.granted,
  }) : accessNow = access;

  GeoPoint? point;
  LocationAccess accessNow;

  /// Что ответит пользователь на системный вопрос.
  LocationAccess afterRequest;

  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<LocationAccess> access() async => accessNow;

  @override
  Future<LocationAccess> request() async {
    requests++;
    return accessNow = afterRequest;
  }

  @override
  Future<GeoPoint?> current() async =>
      accessNow == LocationAccess.granted ? point : null;

  @override
  Future<void> openSettings(LocationAccess access) async => settingsOpened++;
}

/// Где пользователь — для расстояний, «Сейчас рядом», поиска и планов вечера.
///
/// Разрешение не спрашивается при запуске: на главной есть карточка
/// «Показать, что рядом?», в профиле — строка «Геолокация». Точка округляется
/// до ~100 м: для «рядом» точнее не нужно, а на сервер уходит меньше лишнего.
class LocationState extends ChangeNotifier {
  LocationState(this._source, {KeyValueStore? storage}) : _storage = storage {
    _promptDismissed = storage?.readJson(StorageKeys.location)?['promptDismissed'] == true;
  }

  final LocationSource _source;
  final KeyValueStore? _storage;

  LocationAccess _access = LocationAccess.unavailable;
  GeoPoint? _point;
  bool _promptDismissed = false;
  bool _busy = false;

  LocationAccess get access => _access;

  /// Округлённая точка пользователя; null — считаем от центра города.
  GeoPoint? get point => _point;

  bool get isOn => _access == LocationAccess.granted;
  bool get busy => _busy;

  /// Есть ли смысл показывать настройку (на тестовых данных — нет).
  bool get supported => _access != LocationAccess.unavailable;

  /// Карточка на главной: спросить можно, а человек ещё не сказал «Не сейчас».
  bool get shouldPrompt => _access == LocationAccess.canAsk && !_promptDismissed;

  /// При запуске: узнать доступ и, если он уже есть, — точку. Без вопросов.
  Future<void> start() async {
    _access = await _source.access();
    if (isOn) {
      await _locate();
    }
    notifyListeners();
  }

  /// «Разрешить» на главной или в профиле. Если телефон запретил насовсем или
  /// выключена геолокация — открываем настройки: вернёмся через [recheck].
  Future<void> enable() async {
    if (_busy) {
      return;
    }
    _busy = true;
    notifyListeners();
    try {
      if (_access == LocationAccess.blocked || _access == LocationAccess.serviceOff) {
        await _source.openSettings(_access);
        return;
      }
      _access = await _source.request();
      if (isOn) {
        await _locate();
      } else {
        // Отказал — больше не предлагаем на главной; включить можно в профиле.
        _dismissPrompt();
      }
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Открыть настройки телефона (например, чтобы выключить геолокацию).
  Future<void> openSettings() => _source.openSettings(_access);

  /// «Не сейчас» на главной.
  void dismissPrompt() {
    _dismissPrompt();
    notifyListeners();
  }

  /// После возврата в приложение: вдруг доступ включили или выключили в настройках.
  Future<void> recheck() async {
    final accessBefore = _access;
    final pointBefore = _point;
    _access = await _source.access();
    if (isOn) {
      await _locate();
    } else {
      _point = null;
    }
    if (_access != accessBefore || !samePoint(_point, pointBefore)) {
      notifyListeners();
    }
  }

  Future<void> _locate() async {
    final found = await _source.current();
    _point = found == null ? null : GeoPoint(_round(found.lat), _round(found.lng));
  }

  void _dismissPrompt() {
    _promptDismissed = true;
    _storage?.writeJson(StorageKeys.location, {'promptDismissed': true});
  }

  static double _round(double value) => (value * 1000).roundToDouble() / 1000;
}

/// Та же точка? (у [GeoPoint] нет сравнения по значению)
bool samePoint(GeoPoint? a, GeoPoint? b) =>
    a == null || b == null ? a == b : a.lat == b.lat && a.lng == b.lng;
