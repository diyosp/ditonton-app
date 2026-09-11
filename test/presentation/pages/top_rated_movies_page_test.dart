import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/presentation/bloc/movie_list/movie_list_bloc.dart';
import 'package:ditonton/presentation/pages/top_rated_movies_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMovieListBloc extends MockBloc<MovieListEvent, MovieListState>
    implements MovieListBloc {}

void main() {
  late MockMovieListBloc bloc;

  setUpAll(() => registerFallbackValue(const MovieListsRequested()));
  setUp(() => bloc = MockMovieListBloc());

  Widget makePage(MovieCategoryState categoryState) {
    when(() => bloc.state).thenReturn(
      MovieListState(categories: {MovieCategory.topRated: categoryState}),
    );
    return BlocProvider<MovieListBloc>.value(
      value: bloc,
      child: MaterialApp(home: TopRatedMoviesPage()),
    );
  }

  testWidgets('displays progress indicator while loading', (tester) async {
    await tester.pumpWidget(
      makePage(const MovieCategoryState(status: MovieListStatus.loading)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays list when data is loaded', (tester) async {
    await tester.pumpWidget(
      makePage(const MovieCategoryState(status: MovieListStatus.success)),
    );
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('displays message when loading fails', (tester) async {
    await tester.pumpWidget(
      makePage(
        const MovieCategoryState(
          status: MovieListStatus.failure,
          message: 'Error message',
        ),
      ),
    );
    expect(find.byKey(const Key('error_message')), findsOneWidget);
    expect(find.text('Error message'), findsOneWidget);
  });
}
