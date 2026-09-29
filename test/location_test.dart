// Геолокация: разрешение только по нажатию, округление точки, заголовок
// X-Bugin-Location в запросах к серверу, карточка на главной и строка в профиле.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:bugin/app.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_tab.dart';
import 'package:bugin/services/api/api_client.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/external_links.dart';
import 'package:bugin/services/location.dart';
import 'package:bugin/services/storage/key_value_store.dart';

const _here = GeoPoint(51.12834, 71.43049);

Object? _fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync());

/// Сервер-заглушка: образцы из test/fixtures/api, запросы запоминаются.
class _Server {
  final List<http.Request> requests = [];

  late final MockClient client = MockClient((request) async {
    requests.add(request);
    final path = request.url.path;
    Object? body = _fixture('error_not_found');
    var status = 404;
    if (path == '/v1/places/nearby' || path == '/v1/places') {
      body = [_fixture('place')];
      status = 200;
    } else if (path == '/v1/evening/featured') {
      body = _fixture('scenario');
      status = 200;
    }
    return http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });

  Iterable<String?> locationsOf(String path) => requests
      .where((r) => r.url.path == path)
      .map((r) => r.headers['X-Bugin-Location']);
}

Future<void> _loadAppFont() async {
  final loader = FontLoader('Onest');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    loader.addFont(rootBundle.load('assets/fonts/Onest-$weight.ttf'));
  }
  await loader.load();
}

AppServices _services(
  _Server server,
  FixedLocationSource source, {
  KeyValueStore? storage,
  AppLanguage language = AppLanguage.ru,
}) =>
    AppServices.api(
      baseUrl: Uri.parse('https://example.kz'),
      httpClient: server.client,
      links: RecordingLinks(),
      storage: storage,
      deviceLanguage: language,
      locationSource: source,
    );

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(_loadAppFont);

  group('LocationState', () {
    test('при запуске не спрашивает, а точку округляет до ~100 м', () async {
      final source = FixedLocationSource(point: _here);
      final state = LocationState(source);
      await state.start();
      expect(source.requests, 0);
      expect(state.isOn, isTrue);
      expect(state.point!.lat, 51.128);
      expect(state.point!.lng, 71.43);
      expect(state.shouldPrompt, isFalse);
    });

    test('«Не сейчас» запоминается', () async {
      final storage = MemoryKeyValueStore();
      final source = FixedLocationSource(point: _here, access: LocationAccess.canAsk);
      final state = LocationState(source, storage: storage);
      await state.start();
      expect(state.shouldPrompt, isTrue);
      state.dismissPrompt();
      expect(state.shouldPrompt, isFalse);

      final again = LocationState(source, storage: storage);
      await again.start();
      expect(again.shouldPrompt, isFalse);
      expect(again.supported, isTrue);
    });

    test('отказ прячет карточку, запрет навсегда ведёт в настройки', () async {
      final source = FixedLocationSource(
        point: _here,
        access: LocationAccess.canAsk,
        afterRequest: LocationAccess.blocked,
      );
      final state = LocationState(source);
      await state.start();
      await state.enable();
      expect(source.requests, 1);
      expect(state.isOn, isFalse);
      expect(state.point, isNull);
      expect(state.shouldPrompt, isFalse);

      await state.enable();
      expect(source.requests, 1);
      expect(source.settingsOpened, 1);

      // Разрешили в настройках и вернулись в приложение.
      source.accessNow = LocationAccess.granted;
      await state.recheck();
      expect(state.isOn, isTrue);
      expect(state.point, isNotNull);
    });

    test('без геолокации настройки нет', () async {
      final state = LocationState(const NoLocationSource());
      await state.start();
      expect(state.supported, isFalse);
      expect(state.shouldPrompt, isFalse);
    });
  });

  test('ApiClient отправляет точку в заголовке, а не в адресе', () async {
    final server = _Server();
    GeoPoint? point;
    final api = ApiClient(
      Uri.parse('https://example.kz'),
      () => AppLanguage.ru,
      client: server.client,
      location: () => point,
    );
    await api.get('/v1/places/nearby');
    point = const GeoPoint(51.128, 71.43);
    await api.get('/v1/places/nearby');
    expect(server.locationsOf('/v1/places/nearby'), [null, '51.128,71.430']);
    expect(server.requests.last.url.query, isEmpty);
  });

  testWidgets('главная: «Разрешить» → «Сейчас рядом» от пользователя', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final server = _Server();
    final source = FixedLocationSource(point: _here, access: LocationAccess.canAsk);
    await tester.pumpWidget(BuginApp(services: _services(server, source)));
    await _settle(tester);

    expect(find.text('Показать, что рядом с тобой?'), findsOneWidget);
    expect(server.locationsOf('/v1/places/nearby'), [null]);

    await tester.tap(find.text('Разрешить'));
    await _settle(tester);

    expect(source.requests, 1);
    expect(find.text('Показать, что рядом с тобой?'), findsNothing);
    expect(server.locationsOf('/v1/places/nearby').last, '51.128,71.430');
    expect(tester.takeException(), isNull);
  });

  testWidgets('главная: «Не сейчас» и строка в профиле', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final server = _Server();
    final source = FixedLocationSource(point: _here, access: LocationAccess.canAsk);
    final services = _services(server, source);
    await tester.pumpWidget(BuginApp(services: services));
    await _settle(tester);

    await tester.tap(find.text('Не сейчас'));
    await _settle(tester);
    expect(find.text('Показать, что рядом с тобой?'), findsNothing);
    expect(source.requests, 0);

    services.state.tab.value = AppTab.profile;
    await _settle(tester);
    expect(find.text('Геолокация'), findsOneWidget);
    expect(find.text('Выключена — считаем от центра Астаны'), findsOneWidget);

    await tester.tap(find.text('Геолокация'));
    await _settle(tester);
    expect(source.requests, 1);
    expect(find.text('Включена — расстояния от тебя'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final language in AppLanguage.values) {
    testWidgets('карточка помещается на узком экране (${language.code})', (tester) async {
      // Ширина узкого телефона; высота с запасом, чтобы карточка точно построилась.
      await tester.binding.setSurfaceSize(const Size(320, 1400));
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(() {
        tester.binding.setSurfaceSize(null);
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });
      final source = FixedLocationSource(point: _here, access: LocationAccess.canAsk);
      await tester.pumpWidget(
        BuginApp(services: _services(_Server(), source, language: language)),
      );
      await _settle(tester);
      expect(find.byIcon(Icons.near_me_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
