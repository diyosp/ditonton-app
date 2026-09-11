import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/presentation/bloc/movie_watchlist/movie_watchlist_bloc.dart';
import 'package:ditonton/presentation/pages/watchlist_movies_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../dummy_data/dummy_objects.dart';

class MockWatchlistBloc
    extends MockBloc<MovieWatchlistEvent, MovieWatchlistState>
    implements MovieWatchlistBloc {}

void main() {
  setUpAll(() => registerFallbackValue(const MovieWatchlistRequested()));

  testWidgets('displays movies from watchlist', (tester) async {
    final bloc = MockWatchlistBloc();
    when(() => bloc.state).thenReturn(
      MovieWatchlistState(
        status: MovieWatchlistStatus.success,
        items: [testWatchlistMovie],
      ),
    );
    await tester.pumpWidget(
      BlocProvider<MovieWatchlistBloc>.value(
        value: bloc,
        child: MaterialApp(home: WatchlistMoviesPage()),
      ),
    );
    expect(find.text('title'), findsOneWidget);
  });
}
