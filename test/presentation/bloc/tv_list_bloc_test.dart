import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/presentation/bloc/tv_list/tv_list_bloc.dart';
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

  @override
  Future<Either<Failure, List<TvSeries>>> getOnTheAir() async => result;
  @override
  Future<Either<Failure, List<TvSeries>>> getPopular() async => result;
  @override
  Future<Either<Failure, List<TvSeries>>> getTopRated() async => result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TvListBloc createBloc(StubTvRepository repository) => TvListBloc(
  getOnTheAir: GetOnTheAirTv(repository),
  getPopular: GetPopularTv(repository),
  getTopRated: GetTopRatedTv(repository),
);

void main() {
  late StubTvRepository repository;
  setUp(() => repository = StubTvRepository());

  test('starts with empty category states', () async {
    final bloc = createBloc(repository);
    expect(bloc.state.category(TvCategory.popular), const TvCategoryState());
    await bloc.close();
  });

  blocTest<TvListBloc, TvListState>(
    'loads one requested category',
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const TvCategoryRequested(TvCategory.popular)),
    verify: (bloc) {
      final state = bloc.state.category(TvCategory.popular);
      expect(state.status, TvListStatus.success);
      expect(state.items, [testTv]);
    },
  );

  blocTest<TvListBloc, TvListState>(
    'loads all TV categories',
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const TvListsRequested()),
    verify: (bloc) {
      for (final category in TvCategory.values) {
        expect(bloc.state.category(category).status, TvListStatus.success);
      }
    },
  );

  blocTest<TvListBloc, TvListState>(
    'stores the failure for a requested category',
    setUp: () => repository.result = Left(ServerFailure('Load failed')),
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const TvCategoryRequested(TvCategory.topRated)),
    verify: (bloc) {
      final state = bloc.state.category(TvCategory.topRated);
      expect(state.status, TvListStatus.failure);
      expect(state.message, 'Load failed');
    },
  );
}
