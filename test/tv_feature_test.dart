import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:ditonton/common/exception.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/data/datasources/tv_local_data_source.dart';
import 'package:ditonton/data/datasources/tv_remote_data_source.dart';
import 'package:ditonton/data/models/tv_series_detail_model.dart';
import 'package:ditonton/data/models/tv_series_model.dart';
import 'package:ditonton/data/models/tv_series_table.dart';
import 'package:ditonton/data/repositories/tv_repository_impl.dart';
import 'package:ditonton/domain/entities/genre.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/presentation/provider/tv_detail_notifier.dart';
import 'package:ditonton/presentation/provider/tv_list_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

const tv = TvSeries(
  id: 1399,
  name: 'Game of Thrones',
  overview: 'Seven kingdoms compete for the throne.',
  posterPath: '/poster.jpg',
  voteAverage: 8.4,
  firstAirDate: '2011-04-17',
);

const detail = TvSeriesDetail(
  id: 1399,
  name: 'Game of Thrones',
  overview: 'Seven kingdoms compete for the throne.',
  posterPath: '/poster.jpg',
  backdropPath: '/backdrop.jpg',
  voteAverage: 8.4,
  genres: [Genre(id: 18, name: 'Drama')],
  seasons: [
    Season(
      id: 1,
      name: 'Season 1',
      seasonNumber: 1,
      episodeCount: 10,
      overview: 'First season',
      posterPath: '/season.jpg',
    ),
  ],
  numberOfEpisodes: 73,
  numberOfSeasons: 8,
);

class FakeTvRepository implements TvRepository {
  Either<Failure, List<TvSeries>> listResult = const Right([tv]);
  Either<Failure, TvSeriesDetail> detailResult = const Right(detail);
  Either<Failure, Season> seasonResult = const Right(
    Season(
      id: 1,
      name: 'Season 1',
      seasonNumber: 1,
      episodeCount: 1,
      overview: '',
      posterPath: null,
    ),
  );
  Either<Failure, String> mutationResult = const Right('Added to Watchlist');
  bool watchlistStatus = false;

  @override
  Future<Either<Failure, List<TvSeries>>> getOnTheAir() async => listResult;
  @override
  Future<Either<Failure, List<TvSeries>>> getPopular() async => listResult;
  @override
  Future<Either<Failure, List<TvSeries>>> getTopRated() async => listResult;
  @override
  Future<Either<Failure, TvSeriesDetail>> getDetail(int id) async =>
      detailResult;
  @override
  Future<Either<Failure, List<TvSeries>>> getRecommendations(int id) async =>
      listResult;
  @override
  Future<Either<Failure, List<TvSeries>>> search(String query) async =>
      listResult;
  @override
  Future<Either<Failure, Season>> getSeasonDetail(
    int id,
    int seasonNumber,
  ) async => seasonResult;
  @override
  Future<Either<Failure, String>> saveWatchlist(TvSeriesDetail tv) async {
    watchlistStatus = mutationResult.isRight();
    return mutationResult;
  }

  @override
  Future<Either<Failure, String>> removeWatchlist(TvSeriesDetail tv) async {
    watchlistStatus = false;
    return const Right('Removed from Watchlist');
  }

  @override
  Future<bool> isAddedToWatchlist(int id) async => watchlistStatus;
  @override
  Future<Either<Failure, List<TvSeries>>> getWatchlist() async => listResult;
}

class StubClient extends http.BaseClient {
  StubClient(this.statusCode, this.body);
  final int statusCode;
  final String body;
  Uri? requestedUri;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestedUri = request.url;
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      statusCode,
      request: request,
    );
  }
}

class FakeRemoteDataSource implements TvRemoteDataSource {
  bool throwsServerException = false;
  final model = const TvSeriesModel(
    id: 1399,
    name: 'Game of Thrones',
    overview: 'Overview',
    posterPath: '/poster.jpg',
    voteAverage: 8.4,
    firstAirDate: '2011-04-17',
  );

  Future<T> resolve<T>(T value) async {
    if (throwsServerException) throw ServerException();
    return value;
  }

  @override
  Future<TvSeriesDetailModel> getDetail(int id) =>
      resolve(TvSeriesDetailModel.fromJson(detailJson));
  @override
  Future<List<TvSeriesModel>> getOnTheAir() => resolve([model]);
  @override
  Future<List<TvSeriesModel>> getPopular() => resolve([model]);
  @override
  Future<List<TvSeriesModel>> getRecommendations(int id) => resolve([model]);
  @override
  Future<Season> getSeasonDetail(int id, int seasonNumber) =>
      resolve(detail.seasons.first);
  @override
  Future<List<TvSeriesModel>> getTopRated() => resolve([model]);
  @override
  Future<List<TvSeriesModel>> search(String query) => resolve([model]);
}

class FakeLocalDataSource implements TvLocalDataSource {
  bool exists = false;
  bool throwsDatabaseException = false;

  void checkError() {
    if (throwsDatabaseException) throw DatabaseException('database error');
  }

  @override
  Future<TvSeriesTable?> getById(int id) async {
    checkError();
    return exists ? TvSeriesTable.fromEntity(detail) : null;
  }

  @override
  Future<List<TvSeriesTable>> getWatchlist() async {
    checkError();
    return [TvSeriesTable.fromEntity(detail)];
  }

  @override
  Future<String> insertWatchlist(TvSeriesTable tv) async {
    checkError();
    exists = true;
    return 'Added to Watchlist';
  }

  @override
  Future<String> removeWatchlist(TvSeriesTable tv) async {
    checkError();
    exists = false;
    return 'Removed from Watchlist';
  }
}

final detailJson = <String, dynamic>{
  'id': 1399,
  'name': 'Game of Thrones',
  'overview': 'Overview',
  'poster_path': '/poster.jpg',
  'backdrop_path': '/backdrop.jpg',
  'vote_average': 8.4,
  'genres': [
    {'id': 18, 'name': 'Drama'},
  ],
  'seasons': [
    {
      'id': 1,
      'name': 'Season 1',
      'season_number': 1,
      'episode_count': 10,
      'overview': 'First season',
      'poster_path': '/season.jpg',
    },
  ],
  'number_of_episodes': 73,
  'number_of_seasons': 8,
};

void main() {
  group('TV models', () {
    test('parses list, detail, season, episode, and table models', () {
      final response = TvSeriesResponse.fromJson({
        'results': [
          {
            'id': 1399,
            'name': 'Game of Thrones',
            'overview': 'Overview',
            'poster_path': '/poster.jpg',
            'vote_average': 8.4,
            'first_air_date': '2011-04-17',
          },
        ],
      });
      expect(response.results.single.toEntity().id, 1399);
      expect(
        TvSeriesDetailModel.fromJson(detailJson).toEntity(),
        detail.copyWithOverview('Overview'),
      );

      final season = SeasonDetailModel.fromJson({
        'id': 1,
        'name': 'Season 1',
        'season_number': 1,
        'overview': '',
        'poster_path': null,
        'episodes': [
          {
            'id': 11,
            'name': 'Winter Is Coming',
            'episode_number': 1,
            'overview': 'Episode overview',
            'air_date': '2011-04-17',
            'vote_average': 8.1,
            'still_path': '/still.jpg',
          },
        ],
      });
      expect(season.episodes.single.name, 'Winter Is Coming');

      final table = TvSeriesTable.fromEntity(detail);
      expect(
        TvSeriesTable.fromMap(table.toJson()).toEntity().name,
        detail.name,
      );
    });
  });

  group('TV remote data source', () {
    test(
      'calls list, detail, recommendations, search, and season endpoints',
      () async {
        final listClient = StubClient(
          200,
          jsonEncode({
            'results': [tvJson],
          }),
        );
        final source = TvRemoteDataSourceImpl(client: listClient);
        expect(await source.getOnTheAir(), hasLength(1));
        expect(await source.getPopular(), hasLength(1));
        expect(await source.getTopRated(), hasLength(1));
        expect(await source.getRecommendations(1399), hasLength(1));
        expect(await source.search('game of thrones'), hasLength(1));
        expect(
          listClient.requestedUri!.queryParameters['query'],
          'game of thrones',
        );

        expect(
          (await TvRemoteDataSourceImpl(
            client: StubClient(200, jsonEncode(detailJson)),
          ).getDetail(1399)).id,
          1399,
        );
        final seasonClient = StubClient(200, jsonEncode(seasonJson));
        expect(
          (await TvRemoteDataSourceImpl(
            client: seasonClient,
          ).getSeasonDetail(1399, 1)).episodes,
          hasLength(1),
        );
      },
    );

    test('throws ServerException for unsuccessful response', () {
      final source = TvRemoteDataSourceImpl(client: StubClient(404, '{}'));
      expect(source.getPopular(), throwsA(isA<ServerException>()));
    });
  });

  group('TV use cases and notifiers', () {
    late FakeTvRepository repository;
    setUp(() => repository = FakeTvRepository());

    test('all use cases delegate to repository', () async {
      expect(await GetOnTheAirTv(repository).execute(), const Right([tv]));
      expect(await GetPopularTv(repository).execute(), const Right([tv]));
      expect(await GetTopRatedTv(repository).execute(), const Right([tv]));
      expect(await GetTvDetail(repository).execute(1399), const Right(detail));
      expect(
        await GetTvRecommendations(repository).execute(1399),
        const Right([tv]),
      );
      expect(await SearchTv(repository).execute('game'), const Right([tv]));
      expect(
        (await GetSeasonDetail(repository).execute(1399, 1)).isRight(),
        isTrue,
      );
      expect(
        (await SaveTvWatchlist(repository).execute(detail)).isRight(),
        isTrue,
      );
      expect(await GetTvWatchlistStatus(repository).execute(1399), isTrue);
      expect(
        (await RemoveTvWatchlist(repository).execute(detail)).isRight(),
        isTrue,
      );
      expect((await GetTvWatchlist(repository).execute()).isRight(), isTrue);
    });

    test(
      'list notifier handles success and failure for every category',
      () async {
        final notifier = TvListNotifier(
          getOnTheAir: GetOnTheAirTv(repository),
          getPopular: GetPopularTv(repository),
          getTopRated: GetTopRatedTv(repository),
        );
        await notifier.fetchAll();
        for (final category in TvCategory.values) {
          expect(notifier.stateOf(category), RequestState.Loaded);
          expect(notifier.itemsOf(category), [tv]);
        }
        repository.listResult = Left(ServerFailure('failed'));
        await notifier.fetch(TvCategory.popular);
        expect(notifier.stateOf(TvCategory.popular), RequestState.Error);
        expect(notifier.messageOf(TvCategory.popular), 'failed');
      },
    );

    test('detail notifier loads and updates watchlist', () async {
      final notifier = TvDetailNotifier(
        getDetail: GetTvDetail(repository),
        getRecommendations: GetTvRecommendations(repository),
        getWatchlistStatus: GetTvWatchlistStatus(repository),
        saveWatchlist: SaveTvWatchlist(repository),
        removeWatchlist: RemoveTvWatchlist(repository),
      );
      await notifier.fetch(1399);
      expect(notifier.state, RequestState.Loaded);
      expect(notifier.recommendations, [tv]);
      await notifier.addWatchlist();
      expect(notifier.isAddedToWatchlist, isTrue);
      await notifier.removeFromWatchlist();
      expect(notifier.isAddedToWatchlist, isFalse);

      repository.detailResult = Left(ServerFailure('failed'));
      await notifier.fetch(1399);
      expect(notifier.state, RequestState.Error);
    });
  });

  group('TV repository', () {
    test('maps remote and local data', () async {
      final local = FakeLocalDataSource();
      final repository = TvRepositoryImpl(
        remoteDataSource: FakeRemoteDataSource(),
        localDataSource: local,
      );
      expect((await repository.getOnTheAir()).isRight(), isTrue);
      expect((await repository.getPopular()).isRight(), isTrue);
      expect((await repository.getTopRated()).isRight(), isTrue);
      expect((await repository.getDetail(1399)).isRight(), isTrue);
      expect((await repository.getRecommendations(1399)).isRight(), isTrue);
      expect((await repository.search('game')).isRight(), isTrue);
      expect((await repository.getSeasonDetail(1399, 1)).isRight(), isTrue);
      expect((await repository.saveWatchlist(detail)).isRight(), isTrue);
      expect(await repository.isAddedToWatchlist(1399), isTrue);
      expect((await repository.getWatchlist()).isRight(), isTrue);
      expect((await repository.removeWatchlist(detail)).isRight(), isTrue);
    });

    test('maps server and database exceptions to failures', () async {
      final remote = FakeRemoteDataSource()..throwsServerException = true;
      final local = FakeLocalDataSource()..throwsDatabaseException = true;
      final repository = TvRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );
      expect((await repository.getPopular()).isLeft(), isTrue);
      expect((await repository.saveWatchlist(detail)).isLeft(), isTrue);
      expect((await repository.removeWatchlist(detail)).isLeft(), isTrue);
      expect((await repository.getWatchlist()).isLeft(), isTrue);
    });
  });
}

final tvJson = <String, dynamic>{
  'id': 1399,
  'name': 'Game of Thrones',
  'overview': 'Overview',
  'poster_path': '/poster.jpg',
  'vote_average': 8.4,
  'first_air_date': '2011-04-17',
};

final seasonJson = <String, dynamic>{
  'id': 1,
  'name': 'Season 1',
  'season_number': 1,
  'overview': '',
  'poster_path': null,
  'episodes': [
    {
      'id': 11,
      'name': 'Episode 1',
      'episode_number': 1,
      'overview': '',
      'air_date': '2011-04-17',
      'vote_average': 8,
      'still_path': null,
    },
  ],
};

extension on TvSeriesDetail {
  TvSeriesDetail copyWithOverview(String value) => TvSeriesDetail(
    id: this.id,
    name: name,
    overview: value,
    posterPath: posterPath,
    backdropPath: backdropPath,
    voteAverage: voteAverage,
    genres: genres,
    seasons: seasons,
    numberOfEpisodes: numberOfEpisodes,
    numberOfSeasons: numberOfSeasons,
  );
}
