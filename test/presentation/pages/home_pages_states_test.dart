import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/presentation/bloc/movie_list/movie_list_bloc.dart';
import 'package:ditonton/presentation/bloc/tv_list/tv_list_bloc.dart';
import 'package:ditonton/presentation/pages/home_movie_page.dart';
import 'package:ditonton/presentation/pages/home_tv_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMovieListBloc extends MockBloc<MovieListEvent, MovieListState>
    implements MovieListBloc {}

class MockTvListBloc extends MockBloc<TvListEvent, TvListState>
    implements TvListBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(const MovieListsRequested());
    registerFallbackValue(const TvListsRequested());
  });

  testWidgets('movie home displays category failures', (tester) async {
    final bloc = MockMovieListBloc();
    when(() => bloc.state).thenReturn(
      const MovieListState(
        categories: {
          MovieCategory.nowPlaying: MovieCategoryState(
            status: MovieListStatus.failure,
            message: 'Now failed',
          ),
          MovieCategory.popular: MovieCategoryState(
            status: MovieListStatus.failure,
            message: 'Popular failed',
          ),
          MovieCategory.topRated: MovieCategoryState(
            status: MovieListStatus.failure,
            message: 'Top failed',
          ),
        },
      ),
    );
    await tester.pumpWidget(
      BlocProvider<MovieListBloc>.value(
        value: bloc,
        child: MaterialApp(home: HomeMoviePage()),
      ),
    );
    expect(find.text('Now failed'), findsOneWidget);
    expect(find.text('Popular failed'), findsOneWidget);
    expect(find.text('Top failed'), findsOneWidget);
  });

  testWidgets('TV home displays failures and empty categories', (tester) async {
    final bloc = MockTvListBloc();
    when(() => bloc.state).thenReturn(
      const TvListState(
        categories: {
          TvCategory.onTheAir: TvCategoryState(
            status: TvListStatus.failure,
            message: 'TV failed',
          ),
          TvCategory.popular: TvCategoryState(status: TvListStatus.success),
          TvCategory.topRated: TvCategoryState(status: TvListStatus.loading),
        },
      ),
    );
    await tester.pumpWidget(
      BlocProvider<TvListBloc>.value(
        value: bloc,
        child: const MaterialApp(home: HomeTvPage()),
      ),
    );
    expect(find.text('TV failed'), findsOneWidget);
    expect(find.text('No TV series found.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('movie home navigation callbacks open their routes', (
    tester,
  ) async {
    final bloc = MockMovieListBloc();
    when(() => bloc.state).thenReturn(const MovieListState());

    Future<void> pumpHome() => tester.pumpWidget(
      BlocProvider<MovieListBloc>.value(
        value: bloc,
        child: MaterialApp(
          key: UniqueKey(),
          home: HomeMoviePage(),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            builder: (_) => Text('Route ${settings.name}'),
          ),
        ),
      ),
    );

    await pumpHome();
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.text('Route /search'), findsOneWidget);

    await pumpHome();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TV Series'));
    await tester.pumpAndSettle();
    expect(find.text('Route /home-tv'), findsOneWidget);

    await pumpHome();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watchlist'));
    await tester.pumpAndSettle();
    expect(find.text('Route /watchlist-movie'), findsOneWidget);

    await pumpHome();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Route /about'), findsOneWidget);
  });

  testWidgets('TV home opens search, watchlist, and category routes', (
    tester,
  ) async {
    final bloc = MockTvListBloc();
    when(() => bloc.state).thenReturn(const TvListState());
    Future<void> pumpHome() => tester.pumpWidget(
      BlocProvider<TvListBloc>.value(
        value: bloc,
        child: MaterialApp(
          key: UniqueKey(),
          home: const HomeTvPage(),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            builder: (_) => Text('Route ${settings.name}'),
          ),
        ),
      ),
    );

    await pumpHome();
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.text('Route /search-tv'), findsOneWidget);

    await pumpHome();
    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pumpAndSettle();
    expect(find.text('Route /watchlist-tv'), findsOneWidget);

    await pumpHome();
    await tester.tap(find.text('See More').first);
    await tester.pumpAndSettle();
    expect(find.text('Route /tv-category'), findsOneWidget);
  });
}
