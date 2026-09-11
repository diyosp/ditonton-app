import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:equatable/equatable.dart';

sealed class TvDetailEvent extends Equatable {
  const TvDetailEvent();

  @override
  List<Object> get props => [];
}

final class TvDetailRequested extends TvDetailEvent {
  const TvDetailRequested(this.id);

  final int id;

  @override
  List<Object> get props => [id];
}

final class TvWatchlistAdded extends TvDetailEvent {
  const TvWatchlistAdded();
}

final class TvWatchlistRemoved extends TvDetailEvent {
  const TvWatchlistRemoved();
}

enum TvDetailStatus { initial, loading, success, failure }

enum TvRecommendationStatus { initial, loading, success, failure }

final class TvDetailState extends Equatable {
  const TvDetailState({
    this.status = TvDetailStatus.initial,
    this.recommendationStatus = TvRecommendationStatus.initial,
    this.detail,
    this.recommendations = const [],
    this.isAddedToWatchlist = false,
    this.message = '',
  });

  final TvDetailStatus status;
  final TvRecommendationStatus recommendationStatus;
  final TvSeriesDetail? detail;
  final List<TvSeries> recommendations;
  final bool isAddedToWatchlist;
  final String message;

  TvDetailState copyWith({
    TvDetailStatus? status,
    TvRecommendationStatus? recommendationStatus,
    TvSeriesDetail? detail,
    List<TvSeries>? recommendations,
    bool? isAddedToWatchlist,
    String? message,
  }) => TvDetailState(
    status: status ?? this.status,
    recommendationStatus: recommendationStatus ?? this.recommendationStatus,
    detail: detail ?? this.detail,
    recommendations: recommendations ?? this.recommendations,
    isAddedToWatchlist: isAddedToWatchlist ?? this.isAddedToWatchlist,
    message: message ?? this.message,
  );

  @override
  List<Object?> get props => [
    status,
    recommendationStatus,
    detail,
    recommendations,
    isAddedToWatchlist,
    message,
  ];
}

class TvDetailBloc extends Bloc<TvDetailEvent, TvDetailState> {
  TvDetailBloc({
    required GetTvDetail getDetail,
    required GetTvRecommendations getRecommendations,
    required GetTvWatchlistStatus getWatchlistStatus,
    required SaveTvWatchlist saveWatchlist,
    required RemoveTvWatchlist removeWatchlist,
  }) : _getDetail = getDetail,
       _getRecommendations = getRecommendations,
       _getWatchlistStatus = getWatchlistStatus,
       _saveWatchlist = saveWatchlist,
       _removeWatchlist = removeWatchlist,
       super(const TvDetailState()) {
    on<TvDetailRequested>(_onRequested);
    on<TvWatchlistAdded>(_onWatchlistAdded);
    on<TvWatchlistRemoved>(_onWatchlistRemoved);
  }

  final GetTvDetail _getDetail;
  final GetTvRecommendations _getRecommendations;
  final GetTvWatchlistStatus _getWatchlistStatus;
  final SaveTvWatchlist _saveWatchlist;
  final RemoveTvWatchlist _removeWatchlist;

  Future<void> _onRequested(
    TvDetailRequested event,
    Emitter<TvDetailState> emit,
  ) async {
    emit(
      const TvDetailState(
        status: TvDetailStatus.loading,
        recommendationStatus: TvRecommendationStatus.loading,
      ),
    );
    final detailResult = await _getDetail.execute(event.id);
    final detail = detailResult.fold<TvSeriesDetail?>((_) => null, (tv) => tv);
    if (detail == null) {
      emit(
        TvDetailState(
          status: TvDetailStatus.failure,
          message: detailResult.fold((failure) => failure.message, (_) => ''),
        ),
      );
      return;
    }

    final isAdded = await _getWatchlistStatus.execute(event.id);
    emit(
      TvDetailState(
        status: TvDetailStatus.success,
        recommendationStatus: TvRecommendationStatus.loading,
        detail: detail,
        isAddedToWatchlist: isAdded,
      ),
    );

    final recommendationResult = await _getRecommendations.execute(event.id);
    recommendationResult.fold(
      (failure) => emit(
        state.copyWith(
          recommendationStatus: TvRecommendationStatus.failure,
          message: failure.message,
        ),
      ),
      (items) => emit(
        state.copyWith(
          recommendationStatus: TvRecommendationStatus.success,
          recommendations: items,
        ),
      ),
    );
  }

  Future<void> _onWatchlistAdded(
    TvWatchlistAdded event,
    Emitter<TvDetailState> emit,
  ) async {
    final detail = state.detail;
    if (detail == null) return;
    final result = await _saveWatchlist.execute(detail);
    final message = result.fold((failure) => failure.message, (value) => value);
    final isAdded = await _getWatchlistStatus.execute(detail.id);
    emit(state.copyWith(message: message, isAddedToWatchlist: isAdded));
  }

  Future<void> _onWatchlistRemoved(
    TvWatchlistRemoved event,
    Emitter<TvDetailState> emit,
  ) async {
    final detail = state.detail;
    if (detail == null) return;
    final result = await _removeWatchlist.execute(detail);
    final message = result.fold((failure) => failure.message, (value) => value);
    final isAdded = await _getWatchlistStatus.execute(detail.id);
    emit(state.copyWith(message: message, isAddedToWatchlist: isAdded));
  }
}
