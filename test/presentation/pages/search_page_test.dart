import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/repositories/movie_repository.dart';
import 'package:ditonton/domain/usecases/search_movies.dart';
import 'package:ditonton/presentation/bloc/movie_search/movie_search_bloc.dart';
import 'package:ditonton/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class SearchRepository implements MovieRepository {
  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query) async =>
      const Right([
        Movie(
          adult: false,
          backdropPath: null,
          genreIds: [],
          id: 557,
          originalTitle: 'Spider-Man',
          overview: 'Overview',
          popularity: 60,
          posterPath: null,
          releaseDate: '2002-05-01',
          title: 'Spider-Man',
          video: false,
          voteAverage: 7.2,
          voteCount: 100,
        ),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('displays initial copy and API search results', (tester) async {
    final bloc = MovieSearchBloc(SearchMovies(SearchRepository()));
    addTearDown(bloc.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(home: SearchPage()),
      ),
    );

    expect(find.text('Find your favorite movie.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('movie_search_field')),
      'spider',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Spider-Man'), findsOneWidget);
  });
}
