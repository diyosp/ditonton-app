import 'dart:async';

import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:flutter/foundation.dart';

class TvSearchNotifier extends ChangeNotifier {
  TvSearchNotifier(this.searchTv);
  final SearchTv searchTv;
  Timer? _debounce;
  RequestState state = RequestState.Empty;
  List<TvSeries> results = [];
  String message = '';

  void search(String query) {
    _debounce?.cancel();
    final value = query.trim();
    if (value.isEmpty) {
      state = RequestState.Empty;
      results = [];
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _execute(value));
  }

  Future<void> _execute(String query) async {
    state = RequestState.Loading;
    notifyListeners();
    final result = await searchTv.execute(query);
    result.fold(
      (failure) {
        state = RequestState.Error;
        message = failure.message;
      },
      (items) {
        state = RequestState.Loaded;
        results = items;
      },
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
