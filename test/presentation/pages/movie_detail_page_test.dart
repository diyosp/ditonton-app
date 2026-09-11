import 'package:ditonton/presentation/bloc/movie_detail/movie_detail_bloc.dart';
import 'package:ditonton/presentation/pages/movie_detail_page.dart';
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
}
