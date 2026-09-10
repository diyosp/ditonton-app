import 'package:ditonton/common/constants.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/presentation/pages/search_tv_page.dart';
import 'package:ditonton/presentation/pages/tv_category_page.dart';
import 'package:ditonton/presentation/pages/watchlist_tv_page.dart';
import 'package:ditonton/presentation/provider/tv_list_notifier.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeTvPage extends StatefulWidget {
  const HomeTvPage({super.key});
  static const routeName = '/home-tv';

  @override
  State<HomeTvPage> createState() => _HomeTvPageState();
}

class _HomeTvPageState extends State<HomeTvPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TvListNotifier>().fetchAll());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('TV Series'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => Navigator.pushNamed(context, SearchTvPage.routeName),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark),
          onPressed: () =>
              Navigator.pushNamed(context, WatchlistTvPage.routeName),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: context.read<TvListNotifier>().fetchAll,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: TvCategory.values
            .map((category) => _Section(category: category))
            .toList(),
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.category});
  final TvCategory category;

  String get title => switch (category) {
    TvCategory.onTheAir => 'On The Air',
    TvCategory.popular => 'Popular',
    TvCategory.topRated => 'Top Rated',
  };

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TvListNotifier>();
    final state = notifier.stateOf(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: kHeading6),
            TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                TvCategoryPage.routeName,
                arguments: category,
              ),
              child: const Row(
                children: [
                  Text('See More'),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ],
        ),
        if (state == RequestState.Loading)
          const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state == RequestState.Error)
          SizedBox(
            height: 100,
            child: Center(child: Text(notifier.messageOf(category))),
          )
        else if (state == RequestState.Loaded &&
            notifier.itemsOf(category).isEmpty)
          const SizedBox(
            height: 100,
            child: Center(child: Text('No TV series found.')),
          )
        else
          TvHorizontalList(notifier.itemsOf(category)),
      ],
    );
  }
}
