import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/presentation/provider/tv_search_notifier.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchTvPage extends StatelessWidget {
  const SearchTvPage({super.key});
  static const routeName = '/search-tv';

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TvSearchNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('Search TV Series')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const Key('tv_search_field'),
              onChanged: notifier.search,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: switch (notifier.state) {
              RequestState.Loading => const Center(
                child: CircularProgressIndicator(),
              ),
              RequestState.Error => Center(child: Text(notifier.message)),
              RequestState.Loaded when notifier.results.isEmpty => const Center(
                child: Text('No TV series found.'),
              ),
              RequestState.Loaded => TvCardList(notifier.results),
              _ => const Center(child: Text('Find your favorite TV series.')),
            },
          ),
        ],
      ),
    );
  }
}
