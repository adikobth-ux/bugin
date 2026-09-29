import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/models/models.dart';

/// Ошибка запроса к серверу Bugin.
///
/// [code] — код из тела ошибки (`not_found`, `bad_request`, `internal`,
/// см. docs/api.md в bugin-backend) или свой, если ответа не было
/// ([network], [timeout]) или он не разобрался ([badResponse]).
class ApiException implements Exception {
  const ApiException(this.statusCode, this.code, this.message);

  static const notFound = 'not_found';
  static const badRequest = 'bad_request';
  static const internal = 'internal';

  /// Нет связи с сервером.
  static const network = 'network';

  /// Сервер не ответил за отведённое время.
  static const timeout = 'timeout';

  /// Ответ пришёл, но это не JSON.
  static const badResponse = 'bad_response';

  /// HTTP-статус; 0 — ответа нет (нет сети или истёк таймаут).
  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

/// HTTP-клиент сервера Bugin: JSON в UTF-8, язык ответа — в `Accept-Language`,
/// где пользователь — в `X-Bugin-Location` (если он разрешил геолокацию).
class ApiClient {
  ApiClient(
    Uri baseUrl,
    CurrentLanguage language, {
    http.Client? client,
    GeoPoint? Function()? location,
    // Бесплатный сервер засыпает без запросов и просыпается около минуты:
    // первый запрос после паузы не должен обрываться раньше времени.
    this.timeout = const Duration(seconds: 75),
  })  : baseUrl = _serverRoot(baseUrl),
        _language = language,
        _location = location,
        _client = client ?? http.Client();

  /// Адрес сервера без `/` и `/v1` на конце: пути запросов (`/v1/places`)
  /// начинаются с `/`.
  final Uri baseUrl;
  final Duration timeout;
  final CurrentLanguage _language;
  final GeoPoint? Function()? _location;
  final http.Client _client;

  /// GET [path] (например, `/v1/places/nearby`). Возвращает разобранный JSON.
  Future<Object?> get(String path, {Map<String, String>? query}) => _send(
        () => _client.get(_uri(path, query), headers: _headers()),
      );

  /// POST [path] с телом [body] в JSON. Возвращает разобранный JSON.
  Future<Object?> post(String path, Object? body) => _send(
        () => _client.post(
          _uri(path, null),
          headers: {
            ..._headers(),
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: utf8.encode(jsonEncode(body)),
        ),
      );

  /// Язык и точка берутся при каждом запросе: после смены языка или
  /// включения геолокации сервер сразу отвечает по-новому.
  /// Точка — в заголовке, а не в адресе: адреса попадают в журналы сервера.
  Map<String, String> _headers() {
    final point = _location?.call();
    return {
      'Accept': 'application/json',
      'Accept-Language': _language().code,
      if (point != null)
        'X-Bugin-Location':
            '${point.lat.toStringAsFixed(3)},${point.lng.toStringAsFixed(3)}',
    };
  }

  Uri _uri(String path, Map<String, String>? query) => baseUrl.replace(
        path: '${baseUrl.path}$path',
        queryParameters: query == null || query.isEmpty ? null : query,
      );

  Future<Object?> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      return _decode(response);
    } on TimeoutException {
      throw ApiException(
        0,
        ApiException.timeout,
        'Сервер не ответил за ${timeout.inSeconds} с',
      );
    } on http.ClientException catch (error) {
      throw ApiException(0, ApiException.network, error.message);
    }
  }

  static Object? _decode(http.Response response) {
    final status = response.statusCode;
    // Тело всегда в UTF-8, даже если сервер не указал charset.
    final text = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (status < 200 || status >= 300) {
      throw _error(status, text);
    }
    if (text.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(text);
    } on FormatException catch (error) {
      throw ApiException(
        status,
        ApiException.badResponse,
        'Ответ сервера — не JSON: ${error.message}',
      );
    }
  }

  /// Разбирает `{"error": {"code": "…", "message": "…"}}`. Если тела нет
  /// или оно другое (например, страница прокси), код — по статусу.
  static ApiException _error(int status, String text) {
    Object? body;
    try {
      body = jsonDecode(text);
    } on FormatException {
      body = null;
    }
    final error = body is Map<String, dynamic> ? body['error'] : null;
    final code = error is Map<String, dynamic> ? error['code'] : null;
    final message = error is Map<String, dynamic> ? error['message'] : null;
    return ApiException(
      status,
      code is String && code.isNotEmpty ? code : _codeForStatus(status),
      message is String ? message : 'HTTP $status',
    );
  }

  static String _codeForStatus(int status) {
    if (status == 404) {
      return ApiException.notFound;
    }
    if (status == 400 || status == 422) {
      return ApiException.badRequest;
    }
    if (status >= 500) {
      return ApiException.internal;
    }
    return 'http_$status';
  }

  /// Адрес можно задать и с `/v1`, как базовый адрес в контракте:
  /// пути запросов уже содержат `/v1`, поэтому здесь он отрезается.
  static Uri _serverRoot(Uri url) {
    var path = url.path;
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    if (path.endsWith('/v1')) {
      path = path.substring(0, path.length - 3);
    }
    return url.replace(path: path);
  }
}

/// Ответ-объект `{…}`, иначе — [FormatException].
Map<String, dynamic> jsonObject(Object? json) {
  if (json is Map<String, dynamic>) {
    return json;
  }
  throw FormatException('Ожидался объект JSON, пришло: ${json.runtimeType}');
}

/// Ответ-массив объектов `[{…}, …]`, иначе — [FormatException].
List<Map<String, dynamic>> jsonList(Object? json) {
  if (json is List) {
    return [for (final item in json) jsonObject(item)];
  }
  throw FormatException('Ожидался массив JSON, пришло: ${json.runtimeType}');
}
