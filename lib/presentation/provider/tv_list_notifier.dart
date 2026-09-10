import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:flutter/foundation.dart';

enum TvCategory { onTheAir, popular, topRated }

class TvListNotifier extends ChangeNotifier {
  TvListNotifier({
    required this.getOnTheAir,
    required this.getPopular,
    required this.getTopRated,
  });

  final GetOnTheAirTv getOnTheAir;
  final GetPopularTv getPopular;
  final GetTopRatedTv getTopRated;

  final Map<TvCategory, RequestState> _states = {
    for (final category in TvCategory.values) category: RequestState.Empty,
  };
  final Map<TvCategory, List<TvSeries>> _items = {
    for (final category in TvCategory.values) category: [],
  };
  final Map<TvCategory, String> _messages = {
    for (final category in TvCategory.values) category: '',
  };

  RequestState stateOf(TvCategory category) => _states[category]!;
  List<TvSeries> itemsOf(TvCategory category) => _items[category]!;
  String messageOf(TvCategory category) => _messages[category]!;

  Future<void> fetch(TvCategory category) async {
    _states[category] = RequestState.Loading;
    notifyListeners();
    final result = switch (category) {
      TvCategory.onTheAir => await getOnTheAir.execute(),
      TvCategory.popular => await getPopular.execute(),
      TvCategory.topRated => await getTopRated.execute(),
    };
    result.fold(
      (failure) {
        _states[category] = RequestState.Error;
        _messages[category] = failure.message;
      },
      (items) {
        _states[category] = RequestState.Loaded;
        _items[category] = items;
      },
    );
    notifyListeners();
  }

  Future<void> fetchAll() => Future.wait([
    fetch(TvCategory.onTheAir),
    fetch(TvCategory.popular),
    fetch(TvCategory.topRated),
  ]);
}
