import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/injection.dart';
import 'package:ditonton/presentation/pages/season_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SeasonRepository implements TvRepository {
  Either<Failure, Season> result = const Right(
    Season(
      id: 1,
      name: 'Season 1',
      seasonNumber: 1,
      episodeCount: 1,
      overview: '',
      posterPath: null,
      episodes: [
        Episode(
          id: 10,
          name: 'Pilot',
          episodeNumber: 1,
          overview: 'Episode overview',
          airDate: '2020-01-01',
          voteAverage: 8.5,
          stillPath: null,
        ),
      ],
    ),
  );
  @override
  Future<Either<Failure, Season>> getSeasonDetail(int id, int number) async =>
      result;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late SeasonRepository repository;
  setUp(() async {
    await locator.reset();
    repository = SeasonRepository();
    locator.registerSingleton(GetSeasonDetail(repository));
  });
  tearDown(() => locator.reset());

  testWidgets('displays season episodes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SeasonDetailPage(arguments: SeasonArguments(1, 1, 'Season 1')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1. Pilot'), findsOneWidget);
    expect(find.text('Episode overview'), findsOneWidget);
    expect(find.textContaining('8.5'), findsOneWidget);
  });

  testWidgets('displays an error when season loading fails', (tester) async {
    repository.result = Left(ServerFailure('Season failed'));
    await tester.pumpWidget(
      const MaterialApp(
        home: SeasonDetailPage(arguments: SeasonArguments(1, 1, 'Season 1')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Season failed'), findsOneWidget);
  });
}
