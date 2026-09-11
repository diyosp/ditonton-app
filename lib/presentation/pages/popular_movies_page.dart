import 'package:ditonton/presentation/bloc/movie_list/movie_list_bloc.dart';
import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PopularMoviesPage extends StatefulWidget {
  static const ROUTE_NAME = '/popular-movie';

  @override
  _PopularMoviesPageState createState() => _PopularMoviesPageState();
}

class _PopularMoviesPageState extends State<PopularMoviesPage> {
  @override
  void initState() {
    super.initState();
    context.read<MovieListBloc>().add(
      const MovieCategoryRequested(MovieCategory.popular),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Popular Movies')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<MovieListBloc, MovieListState>(
          buildWhen: (previous, current) =>
              previous.category(MovieCategory.popular) !=
              current.category(MovieCategory.popular),
          builder: (context, state) {
            final categoryState = state.category(MovieCategory.popular);
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
