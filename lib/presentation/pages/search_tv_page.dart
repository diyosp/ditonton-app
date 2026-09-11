import 'package:ditonton/presentation/bloc/tv_search/tv_search_bloc.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchTvPage extends StatelessWidget {
  const SearchTvPage({super.key});
  static const routeName = '/search-tv';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search TV Series')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const Key('tv_search_field'),
              onChanged: (query) =>
                  context.read<TvSearchBloc>().add(TvSearchQueryChanged(query)),
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TvSearchBloc, TvSearchState>(
              builder: (context, state) => switch (state.status) {
                TvSearchStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                TvSearchStatus.failure => Center(child: Text(state.message)),
                TvSearchStatus.success when state.results.isEmpty =>
                  const Center(child: Text('No TV series found.')),
                TvSearchStatus.success => TvCardList(state.results),
                TvSearchStatus.initial => const Center(
                  child: Text('Find your favorite TV series.'),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
