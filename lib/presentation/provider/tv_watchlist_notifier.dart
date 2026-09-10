import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:flutter/foundation.dart';

class TvWatchlistNotifier extends ChangeNotifier {
  TvWatchlistNotifier(this.getWatchlist);
  final GetTvWatchlist getWatchlist;
  RequestState state = RequestState.Empty;
  List<TvSeries> items = [];
  String message = '';

  Future<void> fetch() async {
    state = RequestState.Loading;
    notifyListeners();
    final result = await getWatchlist.execute();
    result.fold(
      (failure) {
        state = RequestState.Error;
        message = failure.message;
      },
      (value) {
        state = RequestState.Loaded;
        items = value;
      },
    );
    notifyListeners();
  }
}
