import 'package:ditonton/presentation/bloc/movie_list/movie_list_bloc.dart';
import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopRatedMoviesPage extends StatefulWidget {
  static const ROUTE_NAME = '/top-rated-movie';

  @override
  _TopRatedMoviesPageState createState() => _TopRatedMoviesPageState();
}

class _TopRatedMoviesPageState extends State<TopRatedMoviesPage> {
  @override
  void initState() {
    super.initState();
    context.read<MovieListBloc>().add(
      const MovieCategoryRequested(MovieCategory.topRated),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Top Rated Movies')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<MovieListBloc, MovieListState>(
          buildWhen: (previous, current) =>
              previous.category(MovieCategory.topRated) !=
              current.category(MovieCategory.topRated),
          builder: (context, state) {
            final categoryState = state.category(MovieCategory.topRated);
            return switch (categoryState.status) {
              MovieListStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              MovieListStatus.success => ListView.builder(
                itemBuilder: (context, index) {
                  final movie = categoryState.movies[index];
                  return MovieCard(movie);
                },
                itemCount: categoryState.movies.length,
              ),
              MovieListStatus.failure => Center(
                key: const Key('error_message'),
                child: Text(categoryState.message),
              ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}
