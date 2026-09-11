import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/genre.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/presentation/bloc/tv_detail/tv_detail_bloc.dart';
import 'package:ditonton/presentation/pages/tv_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const detail = TvSeriesDetail(
  id: 1399,
  name: 'Game of Thrones',
  overview: 'Seven kingdoms compete for the throne.',
  posterPath: null,
  backdropPath: null,
  voteAverage: 8.4,
  genres: [Genre(id: 18, name: 'Drama')],
  seasons: [],
  numberOfEpisodes: 73,
  numberOfSeasons: 8,
);

class PageRepository implements TvRepository {
  bool watchlistStatus = false;

  @override
  Future<Either<Failure, TvSeriesDetail>> getDetail(int id) async =>
      const Right(detail);
  @override
  Future<Either<Failure, List<TvSeries>>> getRecommendations(int id) async =>
      const Right([]);
  @override
  Future<bool> isAddedToWatchlist(int id) async => watchlistStatus;
  @override
  Future<Either<Failure, String>> saveWatchlist(TvSeriesDetail tv) async {
    watchlistStatus = true;
    return const Right('Added to Watchlist');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('displays TV detail and updates the watchlist button', (
    tester,
  ) async {
    final repository = PageRepository();
    final bloc = TvDetailBloc(
      getDetail: GetTvDetail(repository),
      getRecommendations: GetTvRecommendations(repository),
      getWatchlistStatus: GetTvWatchlistStatus(repository),
      saveWatchlist: SaveTvWatchlist(repository),
      removeWatchlist: RemoveTvWatchlist(repository),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(home: TvDetailPage(id: 1399)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Game of Thrones'), findsOneWidget);
    expect(find.text('Seven kingdoms compete for the throne.'), findsOneWidget);
    expect(find.text('8.4'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byKey(const Key('tv_watchlist_button')));
    await tester.pump();

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Added to Watchlist'), findsOneWidget);
  });
}
