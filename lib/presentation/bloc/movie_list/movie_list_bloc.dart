import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_now_playing_movies.dart';
import 'package:ditonton/domain/usecases/get_popular_movies.dart';
import 'package:ditonton/domain/usecases/get_top_rated_movies.dart';
import 'package:equatable/equatable.dart';

sealed class MovieListEvent extends Equatable {
  const MovieListEvent();

  @override
  List<Object> get props => [];
}

final class MovieListsRequested extends MovieListEvent {
  const MovieListsRequested();
}

final class MovieCategoryRequested extends MovieListEvent {
  const MovieCategoryRequested(this.category);

  final MovieCategory category;

  @override
  List<Object> get props => [category];
}

enum MovieCategory { nowPlaying, popular, topRated }

enum MovieListStatus { initial, loading, success, failure }

final class MovieCategoryState extends Equatable {
  const MovieCategoryState({
    this.status = MovieListStatus.initial,
    this.movies = const [],
    this.message = '',
  });

  final MovieListStatus status;
  final List<Movie> movies;
  final String message;

  @override
  List<Object> get props => [status, movies, message];
}

final class MovieListState extends Equatable {
  const MovieListState({this.categories = const {}});

  final Map<MovieCategory, MovieCategoryState> categories;

  MovieCategoryState category(MovieCategory category) =>
      categories[category] ?? const MovieCategoryState();

  MovieListState update(
    MovieCategory category,
    MovieCategoryState categoryState,
  ) => MovieListState(categories: {...categories, category: categoryState});

  @override
  List<Object> get props => [categories];
}

class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  MovieListBloc({
    required GetNowPlayingMovies getNowPlayingMovies,
    required GetPopularMovies getPopularMovies,
    required GetTopRatedMovies getTopRatedMovies,
  }) : _getNowPlayingMovies = getNowPlayingMovies,
       _getPopularMovies = getPopularMovies,
       _getTopRatedMovies = getTopRatedMovies,
       super(const MovieListState()) {
    on<MovieListsRequested>(_onRequested);
    on<MovieCategoryRequested>(_onCategoryRequested);
  }

  Future<void> _onCategoryRequested(
    MovieCategoryRequested event,
    Emitter<MovieListState> emit,
  ) async {
    emit(
      state.update(
        event.category,
        const MovieCategoryState(status: MovieListStatus.loading),
      ),
    );
    await _load(event.category, emit);
  }

  final GetNowPlayingMovies _getNowPlayingMovies;
  final GetPopularMovies _getPopularMovies;
  final GetTopRatedMovies _getTopRatedMovies;

  Future<void> _onRequested(
    MovieListsRequested event,
    Emitter<MovieListState> emit,
  ) async {
    for (final category in MovieCategory.values) {
      emit(
        state.update(
          category,
          const MovieCategoryState(status: MovieListStatus.loading),
        ),
      );
    }

    await Future.wait([
      _load(MovieCategory.nowPlaying, emit),
      _load(MovieCategory.popular, emit),
      _load(MovieCategory.topRated, emit),
    ]);
  }

  Future<void> _load(
    MovieCategory category,
    Emitter<MovieListState> emit,
  ) async {
    final result = switch (category) {
      MovieCategory.nowPlaying => await _getNowPlayingMovies.execute(),
      MovieCategory.popular => await _getPopularMovies.execute(),
      MovieCategory.topRated => await _getTopRatedMovies.execute(),
    };
    result.fold(
      (failure) => emit(
        state.update(
          category,
          MovieCategoryState(
            status: MovieListStatus.failure,
            message: failure.message,
          ),
        ),
      ),
      (movies) => emit(
        state.update(
          category,
          MovieCategoryState(status: MovieListStatus.success, movies: movies),
        ),
      ),
    );
  }
}
