import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/search_movies.dart';
import 'package:equatable/equatable.dart';

sealed class MovieSearchEvent extends Equatable {
  const MovieSearchEvent();

  @override
  List<Object> get props => [];
}

final class MovieSearchQueryChanged extends MovieSearchEvent {
  const MovieSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

final class _MovieSearchSubmitted extends MovieSearchEvent {
  const _MovieSearchSubmitted(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

enum MovieSearchStatus { initial, loading, success, failure }

final class MovieSearchState extends Equatable {
  const MovieSearchState({
    this.status = MovieSearchStatus.initial,
    this.results = const [],
    this.message = '',
  });

  final MovieSearchStatus status;
  final List<Movie> results;
  final String message;

  @override
  List<Object> get props => [status, results, message];
}

class MovieSearchBloc extends Bloc<MovieSearchEvent, MovieSearchState> {
  MovieSearchBloc(this._searchMovies) : super(const MovieSearchState()) {
    on<MovieSearchQueryChanged>(_onQueryChanged);
    on<_MovieSearchSubmitted>(_onSubmitted);
  }

  final SearchMovies _searchMovies;
  Timer? _debounce;

  void _onQueryChanged(
    MovieSearchQueryChanged event,
    Emitter<MovieSearchState> emit,
  ) {
    _debounce?.cancel();
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const MovieSearchState());
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => add(_MovieSearchSubmitted(query)),
    );
  }

  Future<void> _onSubmitted(
    _MovieSearchSubmitted event,
    Emitter<MovieSearchState> emit,
  ) async {
    emit(const MovieSearchState(status: MovieSearchStatus.loading));
    final result = await _searchMovies.execute(event.query);
    result.fold(
      (failure) => emit(
        MovieSearchState(
          status: MovieSearchStatus.failure,
          message: failure.message,
        ),
      ),
      (movies) => emit(
        MovieSearchState(status: MovieSearchStatus.success, results: movies),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
