import 'package:bugin/models/models.dart';

/// AI-поиск. Сейчас разбор запроса и подбор — правила на mock data;
/// позже здесь будет вызов AI-сервиса и движка рекомендаций.
abstract interface class SearchService {
  /// Разбирает свободный текст в параметры.
  Future<SearchIntent> understand(String query);

  /// Подбирает места и события под параметры.
  Future<List<Recommendation>> recommend(SearchIntent intent);

  /// Случайный хороший вариант для «Удиви меня».
  Future<Recommendation> surprise();

  List<String> get recentQueries;

  List<String> get suggestions;

  void remember(String query);

  void clearHistory();
}
