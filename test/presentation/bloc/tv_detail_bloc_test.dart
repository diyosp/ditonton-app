import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/genre.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/presentation/bloc/tv_detail/tv_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const testDetail = TvSeriesDetail(
  id: 1399,
  name: 'Game of Thrones',
  overview: 'Overview',
  posterPath: null,
  backdropPath: null,
  voteAverage: 8.4,
  genres: [Genre(id: 18, name: 'Drama')],
  seasons: [],
  numberOfEpisodes: 73,
  numberOfSeasons: 8,
);

const recommendation = TvSeries(
  id: 1402,
  name: 'The Walking Dead',
  overview: 'Overview',
  posterPath: null,
  voteAverage: 8.1,
  firstAirDate: '2010-10-31',
);

class DetailRepository implements TvRepository {
  Either<Failure, TvSeriesDetail> detailResult = const Right(testDetail);
  Either<Failure, List<TvSeries>> recommendationResult = const Right([
    recommendation,
  ]);
  Either<Failure, String> mutationResult = const Right('Added to Watchlist');
  bool watchlistStatus = false;

  @override
  Future<Either<Failure, TvSeriesDetail>> getDetail(int id) async =>
      detailResult;
  @override
  Future<Either<Failure, List<TvSeries>>> getRecommendations(int id) async =>
      recommendationResult;
  @override
  Future<bool> isAddedToWatchlist(int id) async => watchlistStatus;
  @override
  Future<Either<Failure, String>> saveWatchlist(TvSeriesDetail tv) async {
    if (mutationResult.isRight()) watchlistStatus = true;
    return mutationResult;
  }

  @override
  Future<Either<Failure, String>> removeWatchlist(TvSeriesDetail tv) async {
    if (mutationResult.isRight()) watchlistStatus = false;
    return mutationResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TvDetailBloc createBloc(DetailRepository repository) => TvDetailBloc(
  getDetail: GetTvDetail(repository),
  getRecommendations: GetTvRecommendations(repository),
  getWatchlistStatus: GetTvWatchlistStatus(repository),
  saveWatchlist: SaveTvWatchlist(repository),
  removeWatchlist: RemoveTvWatchlist(repository),
);

void main() {
  late DetailRepository repository;

  setUp(() => repository = DetailRepository());

  test('starts with the initial state', () async {
    final bloc = createBloc(repository);
    expect(bloc.state, const TvDetailState());
    await bloc.close();
  });

  blocTest<TvDetailBloc, TvDetailState>(
    'loads detail, watchlist status, and recommendations',
    setUp: () => repository.watchlistStatus = true,
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const TvDetailRequested(1399)),
    expect: () => const [
      TvDetailState(
        status: TvDetailStatus.loading,
        recommendationStatus: TvRecommendationStatus.loading,
      ),
      TvDetailState(
        status: TvDetailStatus.success,
        recommendationStatus: TvRecommendationStatus.loading,
        detail: testDetail,
        isAddedToWatchlist: true,
      ),
      TvDetailState(
        status: TvDetailStatus.success,
        recommendationStatus: TvRecommendationStatus.success,
        detail: testDetail,
        recommendations: [recommendation],
        isAddedToWatchlist: true,
      ),
    ],
  );

  blocTest<TvDetailBloc, TvDetailState>(
    'emits failure when detail cannot be loaded',
    setUp: () => repository.detailResult = Left(ServerFailure('failed')),
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const TvDetailRequested(1399)),
    expect: () => const [
      TvDetailState(
        status: TvDetailStatus.loading,
        recommendationStatus: TvRecommendationStatus.loading,
      ),
      TvDetailState(status: TvDetailStatus.failure, message: 'failed'),
    ],
  );

  blocTest<TvDetailBloc, TvDetailState>(
    'keeps detail visible when recommendations fail',
    setUp: () => repository.recommendationResult = Left(
      ServerFailure('recommendation failed'),
    ),
    build: () => createBloc(repository),
    act: (bloc) => bloc.add(const TvDetailRequested(1399)),
    skip: 2,
    expect: () => const [
      TvDetailState(
        status: TvDetailStatus.success,
        recommendationStatus: TvRecommendationStatus.failure,
        detail: testDetail,
        message: 'recommendation failed',
      ),
    ],
  );

  blocTest<TvDetailBloc, TvDetailState>(
    'adds and removes the TV series from watchlist',
    build: () => createBloc(repository),
    seed: () =>
        const TvDetailState(status: TvDetailStatus.success, detail: testDetail),
    act: (bloc) async {
      bloc.add(const TvWatchlistAdded());
      await Future<void>.delayed(Duration.zero);
      repository.mutationResult = const Right('Removed from Watchlist');
      bloc.add(const TvWatchlistRemoved());
    },
    expect: () => const [
      TvDetailState(
        status: TvDetailStatus.success,
        detail: testDetail,
        isAddedToWatchlist: true,
        message: 'Added to Watchlist',
      ),
      TvDetailState(
        status: TvDetailStatus.success,
        detail: testDetail,
        message: 'Removed from Watchlist',
      ),
    ],
  );
}
