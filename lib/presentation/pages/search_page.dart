import 'package:ditonton/common/constants.dart';
import 'package:ditonton/presentation/bloc/movie_search/movie_search_bloc.dart';
import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatelessWidget {
  static const ROUTE_NAME = '/search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('movie_search_field'),
              onChanged: (query) => context.read<MovieSearchBloc>().add(
                MovieSearchQueryChanged(query),
              ),
              decoration: InputDecoration(
                hintText: 'Search title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
            ),
            SizedBox(height: 16),
            Text('Search Result', style: kHeading6),
            BlocBuilder<MovieSearchBloc, MovieSearchState>(
              builder: (context, state) => switch (state.status) {
                MovieSearchStatus.loading => const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
                MovieSearchStatus.success => Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final movie = state.results[index];
                      return MovieCard(movie);
                    },
                    itemCount: state.results.length,
                  ),
                ),
                MovieSearchStatus.failure => Expanded(
                  child: Center(child: Text(state.message)),
                ),
                _ => const Expanded(
                  child: Center(child: Text('Find your favorite movie.')),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
