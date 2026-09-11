import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:equatable/equatable.dart';

sealed class TvWatchlistEvent extends Equatable {
  const TvWatchlistEvent();

  @override
  List<Object> get props => [];
}

final class TvWatchlistRequested extends TvWatchlistEvent {
  const TvWatchlistRequested();
}

enum TvWatchlistStatus { initial, loading, success, failure }

final class TvWatchlistState extends Equatable {
  const TvWatchlistState({
    this.status = TvWatchlistStatus.initial,
    this.items = const [],
    this.message = '',
  });

  final TvWatchlistStatus status;
  final List<TvSeries> items;
  final String message;

  TvWatchlistState copyWith({
    TvWatchlistStatus? status,
    List<TvSeries>? items,
    String? message,
  }) => TvWatchlistState(
    status: status ?? this.status,
    items: items ?? this.items,
    message: message ?? this.message,
  );

  @override
  List<Object> get props => [status, items, message];
}

class TvWatchlistBloc extends Bloc<TvWatchlistEvent, TvWatchlistState> {
  TvWatchlistBloc(this._getWatchlist) : super(const TvWatchlistState()) {
    on<TvWatchlistRequested>(_onRequested);
  }

  final GetTvWatchlist _getWatchlist;

  Future<void> _onRequested(
    TvWatchlistRequested event,
    Emitter<TvWatchlistState> emit,
  ) async {
    emit(state.copyWith(status: TvWatchlistStatus.loading));
    final result = await _getWatchlist.execute();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TvWatchlistStatus.failure,
          message: failure.message,
        ),
      ),
      (items) => emit(
        state.copyWith(
          status: TvWatchlistStatus.success,
          items: items,
          message: '',
        ),
      ),
    );
  }
}
