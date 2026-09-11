import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/repositories/movie_repository.dart';
import 'package:ditonton/domain/usecases/get_now_playing_movies.dart';
import 'package:ditonton/domain/usecases/get_popular_movies.dart';
import 'package:ditonton/domain/usecases/get_top_rated_movies.dart';
import 'package:ditonton/presentation/bloc/movie_list/movie_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const movie = Movie(
  adult: false,
  backdropPath: null,
  genreIds: [],
  id: 1,
  originalTitle: 'A Movie',
  overview: 'Overview',
  popularity: 1,
  posterPath: null,
  releaseDate: '2020-01-01',
  title: 'A Movie',
  video: false,
  voteAverage: 8,
  voteCount: 10,
);

class ListRepository implements MovieRepository {
  Either<Failure, List<Movie>> nowPlayingResult = const Right([movie]);
  Either<Failure, List<Movie>> popularResult = const Right([movie]);
  Either<Failure, List<Movie>> topRatedResult = const Right([movie]);

  @override
  Future<Either<Failure, List<Movie>>> getNowPlayingMovies() async =>
      nowPlayingResult;
  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies() async =>
      popularResult;
  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies() async =>
      topRatedResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MovieListBloc createBloc(ListRepository repository) => MovieListBloc(
  getNowPlayingMovies: GetNowPlayingMovies(repository),
  getPopularMovies: GetPopularMovies(repository),
  getTopRatedMovies: GetTopRatedMovies(repository),
);

void main() {
  late ListRepository repository;

  setUp(() => repository = ListRepository());

  test('starts with the initial state', () async {
    final bloc = createBloc(repository);
    expect(bloc.state, const MovieListState());
    await bloc.close();
  });

  blocTest<MovieListBloc, MovieListState>(
    'loads all movie categories',
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const MovieListsRequested()),
    verify: (bloc) {
      for (final category in MovieCategory.values) {
        expect(bloc.state.category(category).status, MovieListStatus.success);
        expect(bloc.state.category(category).movies, const [movie]);
      }
    },
  );

  blocTest<MovieListBloc, MovieListState>(
    'keeps failures isolated to their category',
    setUp: () => repository.popularResult = Left(ServerFailure('failed')),
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const MovieListsRequested()),
    verify: (bloc) {
      expect(
        bloc.state.category(MovieCategory.nowPlaying).status,
        MovieListStatus.success,
      );
      expect(
        bloc.state.category(MovieCategory.popular),
        const MovieCategoryState(
          status: MovieListStatus.failure,
          message: 'failed',
        ),
      );
      expect(
        bloc.state.category(MovieCategory.topRated).status,
        MovieListStatus.success,
      );
    },
  );
}
