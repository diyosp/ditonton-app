import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:flutter/foundation.dart';

class TvDetailNotifier extends ChangeNotifier {
  TvDetailNotifier({
    required this.getDetail,
    required this.getRecommendations,
    required this.getWatchlistStatus,
    required this.saveWatchlist,
    required this.removeWatchlist,
  });

  final GetTvDetail getDetail;
  final GetTvRecommendations getRecommendations;
  final GetTvWatchlistStatus getWatchlistStatus;
  final SaveTvWatchlist saveWatchlist;
  final RemoveTvWatchlist removeWatchlist;

  RequestState state = RequestState.Empty;
  RequestState recommendationState = RequestState.Empty;
  TvSeriesDetail? tv;
  List<TvSeries> recommendations = [];
  String message = '';
  bool isAddedToWatchlist = false;

  Future<void> fetch(int id) async {
    state = RequestState.Loading;
    recommendationState = RequestState.Loading;
    notifyListeners();
    final detailResult = await getDetail.execute(id);
    detailResult.fold(
      (failure) {
        state = RequestState.Error;
        message = failure.message;
      },
      (detail) {
        tv = detail;
        state = RequestState.Loaded;
      },
    );
    if (state == RequestState.Loaded) {
      final recommendationResult = await getRecommendations.execute(id);
      recommendationResult.fold(
        (failure) {
          recommendationState = RequestState.Error;
          message = failure.message;
        },
        (items) {
          recommendationState = RequestState.Loaded;
          recommendations = items;
        },
      );
      isAddedToWatchlist = await getWatchlistStatus.execute(id);
    }
    notifyListeners();
  }

  Future<void> addWatchlist() async {
    final detail = tv;
    if (detail == null) return;
    final result = await saveWatchlist.execute(detail);
    result.fold(
      (failure) => message = failure.message,
      (value) => message = value,
    );
    await _refreshStatus();
  }

  Future<void> removeFromWatchlist() async {
    final detail = tv;
    if (detail == null) return;
    final result = await removeWatchlist.execute(detail);
    result.fold(
      (failure) => message = failure.message,
      (value) => message = value,
    );
    await _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    isAddedToWatchlist = await getWatchlistStatus.execute(tv!.id);
    notifyListeners();
  }
}
