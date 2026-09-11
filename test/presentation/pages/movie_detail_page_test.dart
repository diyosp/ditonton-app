import 'package:ditonton/presentation/bloc/movie_detail/movie_detail_bloc.dart';
import 'package:ditonton/presentation/pages/movie_detail_page.dart';
import 'package:ditonton/domain/entities/movie_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import '../../dummy_data/dummy_objects.dart';

class MockMovieDetailBloc extends MockBloc<MovieDetailEvent, MovieDetailState>
    implements MovieDetailBloc {}

void main() {
  setUpAll(() => registerFallbackValue(const MovieDetailRequested(1)));

  Future<MockMovieDetailBloc> pumpState(
    WidgetTester tester,
    MovieDetailState state,
  ) async {
    final bloc = MockMovieDetailBloc();
    when(() => bloc.state).thenReturn(state);
    await tester.pumpWidget(
      BlocProvider<MovieDetailBloc>.value(
        value: bloc,
        child: MaterialApp(home: MovieDetailPage(id: 1)),
      ),
    );
    return bloc;
  }

  testWidgets('displays loaded detail and add watchlist icon', (tester) async {
    final bloc = MockMovieDetailBloc();
    when(() => bloc.state).thenReturn(
      MovieDetailState(
        status: MovieDetailStatus.success,
        recommendationStatus: MovieRecommendationStatus.success,
        movie: testMovieDetail,
      ),
    );
    await tester.pumpWidget(
      BlocProvider<MovieDetailBloc>.value(
        value: bloc,
        child: MaterialApp(home: MovieDetailPage(id: 1)),
      ),
    );
    expect(find.text('title'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('displays loading and detail failure states', (tester) async {
    await pumpState(
      tester,
      const MovieDetailState(status: MovieDetailStatus.loading),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await pumpState(
      tester,
      const MovieDetailState(
        status: MovieDetailStatus.failure,
        message: 'Detail failed',
      ),
    );
    expect(find.text('Detail failed'), findsOneWidget);
  });

  testWidgets('displays check icon and recommendation failure', (tester) async {
    await pumpState(
      tester,
      MovieDetailState(
        status: MovieDetailStatus.success,
        recommendationStatus: MovieRecommendationStatus.failure,
        movie: testMovieDetail,
        isAddedToWatchlist: true,
        message: 'Recommendation failed',
      ),
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Recommendation failed'), findsOneWidget);
  });

  testWidgets('dispatches add and remove watchlist events', (tester) async {
    final addBloc = await pumpState(
      tester,
      MovieDetailState(
        status: MovieDetailStatus.success,
        recommendationStatus: MovieRecommendationStatus.success,
        movie: testMovieDetail,
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    verify(() => addBloc.add(const MovieWatchlistAdded())).called(1);

    final removeBloc = await pumpState(
      tester,
      MovieDetailState(
        status: MovieDetailStatus.success,
        recommendationStatus: MovieRecommendationStatus.success,
        movie: testMovieDetail,
        isAddedToWatchlist: true,
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    verify(() => removeBloc.add(const MovieWatchlistRemoved())).called(1);
  });

  testWidgets('displays recommendation and opens its detail', (tester) async {
    await pumpState(
      tester,
      MovieDetailState(
        status: MovieDetailStatus.success,
        recommendationStatus: MovieRecommendationStatus.success,
        movie: testMovieDetail,
        recommendations: testMovieList,
      ),
    );
    expect(find.text('Recommendations'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('shows snackbar for successful watchlist action', (tester) async {
    final bloc = MockMovieDetailBloc();
    final initial = MovieDetailState(
      status: MovieDetailStatus.success,
      recommendationStatus: MovieRecommendationStatus.success,
      movie: testMovieDetail,
    );
    final success = initial.copyWith(
      watchlistMessage: 'Added to Watchlist',
      isAddedToWatchlist: true,
    );
    whenListen(bloc, Stream.value(success), initialState: initial);
    await tester.pumpWidget(
      BlocProvider<MovieDetailBloc>.value(
        value: bloc,
        child: MaterialApp(home: MovieDetailPage(id: 1)),
      ),
    );
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('shows dialog for failed watchlist action', (tester) async {
    final bloc = MockMovieDetailBloc();
    final initial = MovieDetailState(
      status: MovieDetailStatus.success,
      recommendationStatus: MovieRecommendationStatus.success,
      movie: testMovieDetail,
    );
    whenListen(
      bloc,
      Stream.value(initial.copyWith(watchlistMessage: 'Failed')),
      initialState: initial,
    );
    await tester.pumpWidget(
      BlocProvider<MovieDetailBloc>.value(
        value: bloc,
        child: MaterialApp(home: MovieDetailPage(id: 1)),
      ),
    );
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
  });

  testWidgets('handles short duration, empty genres, and recommendation tap', (
    tester,
  ) async {
    final bloc = MockMovieDetailBloc();
    final shortMovie = MovieDetail(
      adult: false,
      backdropPath: null,
      genres: const [],
      id: 1,
      originalTitle: 'Short',
      overview: 'Overview',
      posterPath: '',
      releaseDate: '',
      runtime: 45,
      title: 'Short',
      voteAverage: 8,
      voteCount: 1,
    );
    when(() => bloc.state).thenReturn(
      MovieDetailState(
        status: MovieDetailStatus.success,
        recommendationStatus: MovieRecommendationStatus.success,
        movie: shortMovie,
        recommendations: testMovieList,
      ),
    );
    await tester.pumpWidget(
      BlocProvider<MovieDetailBloc>.value(
        value: bloc,
        child: MaterialApp(
          home: MovieDetailPage(id: 1),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            builder: (_) => Text('Movie ${settings.arguments}'),
          ),
        ),
      ),
    );
    expect(find.text('45m'), findsOneWidget);
    final recommendation = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(InkWell),
    );
    expect(recommendation, findsOneWidget);
  });
}
