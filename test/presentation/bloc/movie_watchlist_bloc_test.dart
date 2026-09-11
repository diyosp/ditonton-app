import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/repositories/movie_repository.dart';
import 'package:ditonton/domain/usecases/get_watchlist_movies.dart';
import 'package:ditonton/presentation/bloc/movie_watchlist/movie_watchlist_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../dummy_data/dummy_objects.dart';

class WatchlistRepository implements MovieRepository {
  Either<Failure, List<Movie>> result = Right([testWatchlistMovie]);
  @override
  Future<Either<Failure, List<Movie>>> getWatchlistMovies() async => result;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late WatchlistRepository repository;
  setUp(() => repository = WatchlistRepository());

  blocTest<MovieWatchlistBloc, MovieWatchlistState>(
    'loads locally stored movies',
    build: () => MovieWatchlistBloc(GetWatchlistMovies(repository)),
    act: (bloc) => bloc.add(const MovieWatchlistRequested()),
    expect: () => [
      const MovieWatchlistState(status: MovieWatchlistStatus.loading),
      MovieWatchlistState(
        status: MovieWatchlistStatus.success,
        items: [testWatchlistMovie],
      ),
    ],
  );

  blocTest<MovieWatchlistBloc, MovieWatchlistState>(
    'emits failure when local storage fails',
    setUp: () => repository.result = Left(DatabaseFailure("Can't get data")),
    build: () => MovieWatchlistBloc(GetWatchlistMovies(repository)),
    act: (bloc) => bloc.add(const MovieWatchlistRequested()),
    expect: () => const [
      MovieWatchlistState(status: MovieWatchlistStatus.loading),
      MovieWatchlistState(
        status: MovieWatchlistStatus.failure,
        message: "Can't get data",
      ),
    ],
  );
}
