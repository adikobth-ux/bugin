import 'package:bugin/data/mock_profile.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/services/api/api_client.dart';
import 'package:bugin/services/search_history.dart';
import 'package:bugin/services/search_service.dart';

/// AI-поиск на сервере: разбор запроса и подбор — `/v1/search/…`.
/// Недавние запросы остаются на устройстве, как и в mock.
class ApiSearchService implements SearchService {
  ApiSearchService(
    this._api, {
    required CurrentLanguage language,
    required SearchHistory history,
  })  : _language = language,
        _history = history;

  final ApiClient _api;
  final CurrentLanguage _language;
  final SearchHistory _history;

  @override
  Future<SearchIntent> understand(String query) async => SearchIntent.fromJson(
        jsonObject(await _api.post('/v1/search/understand', {'query': query})),
      );

  @override
  Future<List<Recommendation>> recommend(SearchIntent intent) async => jsonList(
        await _api.post('/v1/search/recommend', {'intent': intent.toJson()}),
      ).map(Recommendation.fromJson).toList();

  @override
  Future<Recommendation> surprise() async => Recommendation.fromJson(
        jsonObject(await _api.get('/v1/search/surprise')),
      );

  @override
  List<String> get recentQueries => _history.queries;

  /// Примеры запросов пока те же, что в прототипе.
  @override
  List<String> get suggestions => MockProfile.suggestions(_language());

  @override
  void remember(String query) => _history.remember(query);

  @override
  void clearHistory() => _history.clear();
}
