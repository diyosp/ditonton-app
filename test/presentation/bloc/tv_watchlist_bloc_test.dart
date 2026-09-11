import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/presentation/bloc/tv_watchlist/tv_watchlist_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const testTv = TvSeries(
  id: 1399,
  name: 'Game of Thrones',
  overview: 'Overview',
  posterPath: '/poster.jpg',
  voteAverage: 8.4,
  firstAirDate: '2011-04-17',
);

class StubTvRepository implements TvRepository {
  Either<Failure, List<TvSeries>> result = const Right([testTv]);

  @override
  Future<Either<Failure, List<TvSeries>>> getWatchlist() async => result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late StubTvRepository repository;

  setUp(() => repository = StubTvRepository());

  test('starts with the initial state', () async {
    final bloc = TvWatchlistBloc(GetTvWatchlist(repository));
    expect(bloc.state, const TvWatchlistState());
    await bloc.close();
  });

  blocTest<TvWatchlistBloc, TvWatchlistState>(
    'emits loading and success when watchlist is available',
    build: () => TvWatchlistBloc(GetTvWatchlist(repository)),
    act: (bloc) => bloc.add(const TvWatchlistRequested()),
    expect: () => const [
      TvWatchlistState(status: TvWatchlistStatus.loading),
      TvWatchlistState(status: TvWatchlistStatus.success, items: [testTv]),
    ],
  );

  blocTest<TvWatchlistBloc, TvWatchlistState>(
    'emits loading and failure when loading watchlist fails',
    setUp: () => repository.result = Left(DatabaseFailure('Database failure')),
    build: () => TvWatchlistBloc(GetTvWatchlist(repository)),
    act: (bloc) => bloc.add(const TvWatchlistRequested()),
    expect: () => const [
      TvWatchlistState(status: TvWatchlistStatus.loading),
      TvWatchlistState(
        status: TvWatchlistStatus.failure,
        message: 'Database failure',
      ),
    ],
  );
}
