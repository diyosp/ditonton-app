import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/repositories/movie_repository.dart';
import 'package:ditonton/domain/usecases/search_movies.dart';
import 'package:ditonton/presentation/bloc/movie_search/movie_search_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const movie = Movie(
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
);

class SearchRepository implements MovieRepository {
  Either<Failure, List<Movie>> result = const Right([movie]);
  String? receivedQuery;

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query) async {
    receivedQuery = query;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late SearchRepository repository;

  setUp(() => repository = SearchRepository());

  test('starts with the initial state', () async {
    final bloc = MovieSearchBloc(SearchMovies(repository));
    expect(bloc.state, const MovieSearchState());
    await bloc.close();
  });

  blocTest<MovieSearchBloc, MovieSearchState>(
    'debounces the query and emits API results',
    build: () => MovieSearchBloc(SearchMovies(repository)),
    act: (bloc) => bloc.add(const MovieSearchQueryChanged('  spider  ')),
    wait: const Duration(milliseconds: 550),
    expect: () => const [
      MovieSearchState(status: MovieSearchStatus.loading),
      MovieSearchState(status: MovieSearchStatus.success, results: [movie]),
    ],
    verify: (_) => expect(repository.receivedQuery, 'spider'),
  );

  blocTest<MovieSearchBloc, MovieSearchState>(
    'emits failure when the API search fails',
    setUp: () => repository.result = Left(ServerFailure('Search failed')),
    build: () => MovieSearchBloc(SearchMovies(repository)),
    act: (bloc) => bloc.add(const MovieSearchQueryChanged('spider')),
    wait: const Duration(milliseconds: 550),
    expect: () => const [
      MovieSearchState(status: MovieSearchStatus.loading),
      MovieSearchState(
        status: MovieSearchStatus.failure,
        message: 'Search failed',
      ),
    ],
  );

  blocTest<MovieSearchBloc, MovieSearchState>(
    'clears the result when the query is empty',
    seed: () => const MovieSearchState(
      status: MovieSearchStatus.success,
      results: [movie],
    ),
    build: () => MovieSearchBloc(SearchMovies(repository)),
    act: (bloc) => bloc.add(const MovieSearchQueryChanged('  ')),
    expect: () => const [MovieSearchState()],
  );
}
