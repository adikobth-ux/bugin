import 'package:flutter/foundation.dart';

import 'package:bugin/models/models.dart';
import 'package:bugin/services/storage/key_value_store.dart';

/// Недавние запросы. Живут на устройстве, даже когда поиск уйдёт на backend.
class SearchHistory extends ChangeNotifier {
  SearchHistory({
    KeyValueStore? storage,
    Iterable<String> initial = const [],
    this.limit = 8,
  }) : _storage = storage {
    final saved = storage?.readJson(StorageKeys.searchHistory);
    _queries.addAll(saved != null ? parseStringList(saved['queries']) : initial);
  }

  final KeyValueStore? _storage;
  final int limit;
  final List<String> _queries = [];

  List<String> get queries => List.unmodifiable(_queries);

  void remember(String query) {
    final q = query.trim();
    if (q.isEmpty) {
      return;
    }
    _queries
      ..remove(q)
      ..insert(0, q);
    if (_queries.length > limit) {
      _queries.removeRange(limit, _queries.length);
    }
    _changed();
  }

  void clear() {
    _queries.clear();
    _changed();
  }

  void reset(Iterable<String> initial) {
    _queries
      ..clear()
      ..addAll(initial);
    _changed();
  }

  void _changed() {
    notifyListeners();
    _storage?.writeJson(StorageKeys.searchHistory, {'queries': _queries});
  }
}
