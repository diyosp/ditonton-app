import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/presentation/pages/movie_detail_page.dart';
import 'package:ditonton/presentation/pages/tv_detail_page.dart';
import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const movie = Movie.watchlist(
  id: 1,
  overview: null,
  posterPath: null,
  title: null,
);
const tv = TvSeries(
  id: 2,
  name: 'TV',
  overview: '',
  posterPath: null,
  voteAverage: 0,
  firstAirDate: '',
);

MaterialApp app(Widget home) => MaterialApp(
  home: Scaffold(body: home),
  onGenerateRoute: (settings) => MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Text('Detail ${settings.arguments}'),
  ),
);

void main() {
  testWidgets('movie card displays fallbacks and opens detail', (tester) async {
    await tester.pumpWidget(app(MovieCard(movie)));
    expect(find.text('-'), findsNWidgets(2));
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    expect(find.text('Detail 1'), findsOneWidget);
    expect(MovieDetailPage.ROUTE_NAME, '/detail');
  });

  testWidgets('TV card displays fallback and opens detail', (tester) async {
    await tester.pumpWidget(app(const TvCardList([tv])));
    expect(find.text('No overview available.'), findsOneWidget);
    expect(find.byIcon(Icons.tv_off), findsOneWidget);
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    expect(find.text('Detail 2'), findsOneWidget);
    expect(TvDetailPage.routeName, '/tv-detail');
  });

  testWidgets('horizontal TV list opens detail', (tester) async {
    await tester.pumpWidget(app(const TvHorizontalList([tv])));
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    expect(find.text('Detail 2'), findsOneWidget);
  });

  testWidgets('TV posters with paths use network images', (tester) async {
    const item = TvSeries(
      id: 3,
      name: 'Poster TV',
      overview: 'Overview',
      posterPath: '/poster.jpg',
      voteAverage: 8,
      firstAirDate: '',
    );
    await tester.pumpWidget(
      app(
        const Column(
          children: [
            Expanded(child: TvCardList([item])),
            TvHorizontalList([item]),
          ],
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
