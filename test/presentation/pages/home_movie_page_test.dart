import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/repositories/movie_repository.dart';
import 'package:ditonton/domain/usecases/get_now_playing_movies.dart';
import 'package:ditonton/domain/usecases/get_popular_movies.dart';
import 'package:ditonton/domain/usecases/get_top_rated_movies.dart';
import 'package:ditonton/presentation/bloc/movie_list/movie_list_bloc.dart';
import 'package:ditonton/presentation/pages/home_movie_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class PageRepository implements MovieRepository {
  static const item = Movie(
    adult: false,
    backdropPath: null,
    genreIds: [],
    id: 1,
    originalTitle: 'A Movie',
    overview: 'Overview',
    popularity: 1,
    posterPath: null,
    releaseDate: '2020-01-01',
    title: 'A Movie',
    video: false,
    voteAverage: 8,
    voteCount: 10,
  );

  @override
  Future<Either<Failure, List<Movie>>> getNowPlayingMovies() async =>
      const Right([item]);
  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies() async =>
      const Right([item]);
  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies() async =>
      const Right([item]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('home displays all movie sections', (tester) async {
    final repository = PageRepository();
    final bloc = MovieListBloc(
      getNowPlayingMovies: GetNowPlayingMovies(repository),
      getPopularMovies: GetPopularMovies(repository),
      getTopRatedMovies: GetTopRatedMovies(repository),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          home: HomeMoviePage(),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            builder: (_) => Text('Route ${settings.name}'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);
    expect(find.text('See More'), findsNWidgets(2));

    await tester.tap(find.text('See More').first);
    await tester.pumpAndSettle();
    expect(find.text('Route /popular-movie'), findsOneWidget);

    Navigator.of(tester.element(find.text('Route /popular-movie'))).pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('See More').last);
    await tester.pumpAndSettle();
    expect(find.text('Route /top-rated-movie'), findsOneWidget);
  });

  testWidgets('movie poster opens its detail route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MovieList(const [PageRepository.item])),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          builder: (_) => Text('Movie ${settings.arguments}'),
        ),
      ),
    );
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    expect(find.text('Movie 1'), findsOneWidget);
  });
}
