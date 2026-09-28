// Работа с сервером: разбор ответов по контракту (docs/api.md в bugin-backend),
// заголовки, ошибки и запуск приложения на данных «с сервера».
//
// Образцы ответов в test/fixtures/api — те же файлы, что tests/contract на сервере.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:bugin/app.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/screens/home/home_screen.dart';
import 'package:bugin/services/api/api_client.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/external_links.dart';

Object? fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync());

Map<String, dynamic> fixtureObject(String name) =>
    fixture(name)! as Map<String, dynamic>;

http.Response jsonResponse(Object? body, {int status = 200}) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

/// Сервер-заглушка: отвечает образцами из test/fixtures/api и запоминает запросы.
class FakeServer {
  final List<http.Request> requests = [];

  late final MockClient client = MockClient((request) async {
    requests.add(request);
    final path = request.url.path;
    final place = fixtureObject('place');
    final event = fixtureObject('event');
    final scenario = fixtureObject('scenario');
    if (request.method == 'GET') {
      if (path == '/v1/places/nearby' || path == '/v1/places') {
        return jsonResponse([place]);
      }
      if (path == '/v1/places/${place['id']}') {
        return jsonResponse(place);
      }
      if (path == '/v1/events' ||
          path == '/v1/events/featured' ||
          path.endsWith('/similar')) {
        return jsonResponse([event]);
      }
      if (path == '/v1/events/${event['id']}') {
        return jsonResponse(event);
      }
      if (path == '/v1/evening/featured') {
        return jsonResponse(scenario);
      }
    }
    if (request.method == 'POST') {
      if (path == '/v1/search/understand') {
        return jsonResponse(fixture('search_intent'));
      }
      if (path == '/v1/search/recommend') {
        return jsonResponse([
          {
            'kind': 'place',
            'place': place,
            'event': null,
            'reason': place['pitch'],
            'details': <String>[],
            'score': 58.0,
          },
        ]);
      }
      if (path == '/v1/evening/plan' || path == '/v1/evening/localize') {
        return jsonResponse(scenario);
      }
    }
    return jsonResponse(fixture('error_not_found'), status: 404);
  });
}

void main() {
  group('Модели по контракту', () {
    test('место', () {
      final place = Place.fromJson(fixtureObject('place'));
      expect(place.id, 'the_garden');
      expect(place.category, PlaceCategory.cafe);
      expect(place.openingHours.closesAt, 23 * 60);
      expect(place.amenities.first.type, AmenityType.wifi);
      expect(place.goodFor, contains(Occasion.date));
      expect(place.reviews.single.date, DateTime(2026, 9, 27, 12));
      expect(place.bookingUrl, isNull);
    });

    test('событие: местное время без смещения и ссылка на билеты', () {
      final event = Event.fromJson(fixtureObject('event'));
      expect(event.startsAt, DateTime(2026, 10, 3, 20));
      expect(event.startsAt.isUtc, isFalse);
      expect(event.ticketUrl, 'https://ticketon.kz/astana');
      expect(event.tickets.single.price, 12000);
      expect(event.isFeatured, isTrue);
    });

    test('разбор запроса и рекомендация туда и обратно', () {
      final intent = SearchIntent.fromJson(fixtureObject('search_intent'));
      expect(intent.param(ParamType.budget)?.budgetValue, 10000);
      expect(intent.param(ParamType.location)?.inferred, isTrue);
      expect(SearchIntent.fromJson(intent.toJson()).params.length, intent.params.length);

      final recommendation = Recommendation.place(
        Place.fromJson(fixtureObject('place')),
        reason: 'Уютно',
        details: const ['a'],
        score: 58,
      );
      final back = Recommendation.fromJson(
        jsonDecode(jsonEncode(recommendation.toJson())) as Map<String, dynamic>,
      );
      expect(back.kind, RecommendationKind.place);
      expect(back.place?.id, 'the_garden');
      expect(back.score, 58);
    });

    test('неизвестный тип параметра пропускается', () {
      final intent = SearchIntent.fromJson({
        'query': 'q',
        'params': [
          {'type': 'weather', 'code': 'sun'},
          {'type': 'time', 'code': 'evening'},
        ],
      });
      expect(intent.params.single.type, ParamType.time);
    });

    test('план вечера', () {
      final scenario = Scenario.fromJson(fixtureObject('scenario'));
      expect(scenario.stops, hasLength(3));
      expect(scenario.legs.first.mode, TravelMode.walk);
      expect(scenario.stops[1].rating, isNull);
      expect(scenario.request?.budget, 15000);
      expect(scenario.totalCost, 10500);
    });
  });

  group('ApiClient', () {
    test('язык запроса и адрес с /v1 на конце', () async {
      final server = FakeServer();
      var language = AppLanguage.ru;
      final api = ApiClient(
        Uri.parse('https://example.kz/v1/'),
        () => language,
        client: server.client,
      );
      await api.get('/v1/places/nearby', query: {'limit': '3'});
      language = AppLanguage.kk;
      await api.get('/v1/places/nearby');

      expect(server.requests.first.url.toString(), 'https://example.kz/v1/places/nearby?limit=3');
      expect(server.requests.first.headers['Accept-Language'], 'ru');
      expect(server.requests.last.headers['Accept-Language'], 'kk');
    });

    test('ошибка сервера превращается в ApiException с кодом', () async {
      final api = ApiClient(
        Uri.parse('https://example.kz'),
        () => AppLanguage.ru,
        client: FakeServer().client,
      );
      await expectLater(
        api.get('/v1/places/nope'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.code, 'code', ApiException.notFound),
        ),
      );
    });

    test('ответ не JSON', () async {
      final api = ApiClient(
        Uri.parse('https://example.kz'),
        () => AppLanguage.ru,
        client: MockClient((_) async => http.Response('<html>', 502)),
      );
      await expectLater(
        api.get('/v1/places/nearby'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', ApiException.internal)),
      );
    });
  });

  group('Сервисы через API', () {
    test('места, поиск и вечер ходят в нужные адреса', () async {
      final server = FakeServer();
      final services = AppServices.api(
        baseUrl: Uri.parse('https://example.kz'),
        httpClient: server.client,
        links: RecordingLinks(),
      );

      final places = await services.places.nearby(limit: 3);
      expect(places.single.id, 'the_garden');
      expect(await services.places.byIds(const []), isEmpty);

      final intent = await services.search.understand('Свидание вечером до 10 000');
      expect(intent.param(ParamType.occasion)?.code, 'date');
      final items = await services.search.recommend(intent);
      expect(items.single.place?.id, 'the_garden');

      final plan = await services.planner.plan(const EveningRequest());
      expect(plan.stops, hasLength(3));

      final understand = server.requests.firstWhere(
        (r) => r.url.path == '/v1/search/understand',
      );
      expect(jsonDecode(understand.body), {'query': 'Свидание вечером до 10 000'});
      final recommend = server.requests.firstWhere(
        (r) => r.url.path == '/v1/search/recommend',
      );
      expect((jsonDecode(recommend.body) as Map)['intent'], isA<Map<String, dynamic>>());
    });
  });

  testWidgets('приложение запускается на данных с сервера', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final server = FakeServer();
    await tester.pumpWidget(
      BuginApp(
        services: AppServices.api(
          baseUrl: Uri.parse('https://example.kz'),
          httpClient: server.client,
          links: RecordingLinks(),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('The Garden'), findsWidgets);
    expect(server.requests.map((r) => r.url.path), contains('/v1/places/nearby'));
    expect(tester.takeException(), isNull);
  });
}
