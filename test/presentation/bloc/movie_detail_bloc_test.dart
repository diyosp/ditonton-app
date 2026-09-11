import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/movie_detail.dart';
import 'package:ditonton/domain/repositories/movie_repository.dart';
import 'package:ditonton/domain/usecases/get_movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist.dart';
import 'package:ditonton/domain/usecases/save_watchlist.dart';
import 'package:ditonton/presentation/bloc/movie_detail/movie_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../dummy_data/dummy_objects.dart';

class DetailRepository implements MovieRepository {
  Either<Failure, MovieDetail> detail = Right(testMovieDetail);
  Either<Failure, List<Movie>> recommendations = Right(testMovieList);
  Either<Failure, String> mutation = const Right('Added to Watchlist');
  bool added = false;
  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int id) async => detail;
  @override
  Future<Either<Failure, List<Movie>>> getMovieRecommendations(int id) async =>
      recommendations;
  @override
  Future<bool> isAddedToWatchlist(int id) async => added;
  @override
  Future<Either<Failure, String>> saveWatchlist(MovieDetail movie) async {
    if (mutation.isRight()) added = true;
    return mutation;
  }

  @override
  Future<Either<Failure, String>> removeWatchlist(MovieDetail movie) async {
    if (mutation.isRight()) added = false;
    return mutation;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MovieDetailBloc createBloc(DetailRepository repository) => MovieDetailBloc(
  getMovieDetail: GetMovieDetail(repository),
  getMovieRecommendations: GetMovieRecommendations(repository),
  getWatchlistStatus: GetWatchListStatus(repository),
  saveWatchlist: SaveWatchlist(repository),
  removeWatchlist: RemoveWatchlist(repository),
);

void main() {
  late DetailRepository repository;
  setUp(() => repository = DetailRepository());
  blocTest<MovieDetailBloc, MovieDetailState>(
    'loads detail and recommendations',
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const MovieDetailRequested(1)),
    verify: (bloc) {
      expect(bloc.state.status, MovieDetailStatus.success);
      expect(bloc.state.movie, testMovieDetail);
      expect(bloc.state.recommendations, testMovieList);
    },
  );
  blocTest<MovieDetailBloc, MovieDetailState>(
    'emits failure for detail error',
    setUp: () => repository.detail = Left(ServerFailure('failed')),
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const MovieDetailRequested(1)),
    verify: (bloc) {
      expect(bloc.state.status, MovieDetailStatus.failure);
      expect(bloc.state.message, 'failed');
    },
  );
  blocTest<MovieDetailBloc, MovieDetailState>(
    'adds movie to watchlist',
    build: () => createBloc(repository),
    seed: () => MovieDetailState(
      status: MovieDetailStatus.success,
      movie: testMovieDetail,
    ),
    act: (bloc) => bloc.add(const MovieWatchlistAdded()),
    verify: (bloc) {
      expect(bloc.state.isAddedToWatchlist, isTrue);
      expect(bloc.state.watchlistMessage, 'Added to Watchlist');
    },
  );
  blocTest<MovieDetailBloc, MovieDetailState>(
    'keeps detail visible when recommendations fail',
    setUp: () => repository.recommendations = Left(ServerFailure('failed')),
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const MovieDetailRequested(1)),
    verify: (bloc) {
      expect(bloc.state.status, MovieDetailStatus.success);
      expect(
        bloc.state.recommendationStatus,
        MovieRecommendationStatus.failure,
      );
    },
  );
  blocTest<MovieDetailBloc, MovieDetailState>(
    'removes movie from watchlist',
    setUp: () {
      repository.added = true;
      repository.mutation = const Right('Removed from Watchlist');
    },
    build: () => createBloc(repository),
    seed: () => MovieDetailState(
      status: MovieDetailStatus.success,
      movie: testMovieDetail,
      isAddedToWatchlist: true,
    ),
    act: (bloc) => bloc.add(const MovieWatchlistRemoved()),
    verify: (bloc) {
      expect(bloc.state.isAddedToWatchlist, isFalse);
      expect(bloc.state.watchlistMessage, 'Removed from Watchlist');
    },
  );
  blocTest<MovieDetailBloc, MovieDetailState>(
    'does nothing when watchlist action has no loaded movie',
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const MovieWatchlistAdded()),
    expect: () => const <MovieDetailState>[],
  );
  blocTest<MovieDetailBloc, MovieDetailState>(
    'keeps status and exposes watchlist failure message',
    setUp: () => repository.mutation = Left(DatabaseFailure('Save failed')),
    build: () => createBloc(repository),
    seed: () => MovieDetailState(
      status: MovieDetailStatus.success,
      movie: testMovieDetail,
    ),
    act: (bloc) => bloc.add(const MovieWatchlistAdded()),
    verify: (bloc) {
      expect(bloc.state.isAddedToWatchlist, isFalse);
      expect(bloc.state.watchlistMessage, 'Save failed');
    },
  );
}
