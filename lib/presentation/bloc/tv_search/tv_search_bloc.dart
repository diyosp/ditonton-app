import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:equatable/equatable.dart';

sealed class TvSearchEvent extends Equatable {
  const TvSearchEvent();

  @override
  List<Object> get props => [];
}

final class TvSearchQueryChanged extends TvSearchEvent {
  const TvSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

final class _TvSearchSubmitted extends TvSearchEvent {
  const _TvSearchSubmitted(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

enum TvSearchStatus { initial, loading, success, failure }

final class TvSearchState extends Equatable {
  const TvSearchState({
    this.status = TvSearchStatus.initial,
    this.results = const [],
    this.message = '',
  });

  final TvSearchStatus status;
  final List<TvSeries> results;
  final String message;

  @override
  List<Object> get props => [status, results, message];
}

class TvSearchBloc extends Bloc<TvSearchEvent, TvSearchState> {
  TvSearchBloc(this._searchTv) : super(const TvSearchState()) {
    on<TvSearchQueryChanged>(_onQueryChanged);
    on<_TvSearchSubmitted>(_onSubmitted);
  }

  final SearchTv _searchTv;
  Timer? _debounce;

  void _onQueryChanged(
    TvSearchQueryChanged event,
    Emitter<TvSearchState> emit,
  ) {
    _debounce?.cancel();
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const TvSearchState());
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => add(_TvSearchSubmitted(query)),
    );
  }

  Future<void> _onSubmitted(
    _TvSearchSubmitted event,
    Emitter<TvSearchState> emit,
  ) async {
    emit(const TvSearchState(status: TvSearchStatus.loading));
    final result = await _searchTv.execute(event.query);
    result.fold(
      (failure) => emit(
        TvSearchState(status: TvSearchStatus.failure, message: failure.message),
      ),
      (items) =>
          emit(TvSearchState(status: TvSearchStatus.success, results: items)),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
