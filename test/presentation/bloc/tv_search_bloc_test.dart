import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/presentation/bloc/tv_search/tv_search_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const testTv = TvSeries(
  id: 1399,
  name: 'Game of Thrones',
  overview: 'Overview',
  posterPath: null,
  voteAverage: 8.4,
  firstAirDate: '2011-04-17',
);

class StubTvRepository implements TvRepository {
  Either<Failure, List<TvSeries>> result = const Right([testTv]);
  String? receivedQuery;

  @override
  Future<Either<Failure, List<TvSeries>>> search(String query) async {
    receivedQuery = query;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late StubTvRepository repository;

  setUp(() => repository = StubTvRepository());

  test('starts with the initial state', () async {
    final bloc = TvSearchBloc(SearchTv(repository));
    expect(bloc.state, const TvSearchState());
    await bloc.close();
  });

  blocTest<TvSearchBloc, TvSearchState>(
    'debounces the query and emits search results',
    build: () => TvSearchBloc(SearchTv(repository)),
    act: (bloc) => bloc.add(const TvSearchQueryChanged('  game  ')),
    wait: const Duration(milliseconds: 550),
    expect: () => const [
      TvSearchState(status: TvSearchStatus.loading),
      TvSearchState(status: TvSearchStatus.success, results: [testTv]),
    ],
    verify: (_) => expect(repository.receivedQuery, 'game'),
  );

  blocTest<TvSearchBloc, TvSearchState>(
    'emits failure when the search fails',
    setUp: () => repository.result = Left(ServerFailure('Search failed')),
    build: () => TvSearchBloc(SearchTv(repository)),
    act: (bloc) => bloc.add(const TvSearchQueryChanged('game')),
    wait: const Duration(milliseconds: 550),
    expect: () => const [
      TvSearchState(status: TvSearchStatus.loading),
      TvSearchState(status: TvSearchStatus.failure, message: 'Search failed'),
    ],
  );

  blocTest<TvSearchBloc, TvSearchState>(
    'clears previous results when the query is empty',
    seed: () =>
        const TvSearchState(status: TvSearchStatus.success, results: [testTv]),
    build: () => TvSearchBloc(SearchTv(repository)),
    act: (bloc) => bloc.add(const TvSearchQueryChanged('  ')),
    expect: () => const [TvSearchState()],
  );
}
