import 'package:ditonton/common/constants.dart';
import 'package:ditonton/presentation/bloc/tv_list/tv_list_bloc.dart';
import 'package:ditonton/presentation/pages/search_tv_page.dart';
import 'package:ditonton/presentation/pages/tv_category_page.dart';
import 'package:ditonton/presentation/pages/watchlist_tv_page.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    context.read<TvListBloc>().add(const TvListsRequested());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('TV Series'),
      actions: [
        IconButton(
          key: const Key('tv_search_action'),
          icon: const Icon(Icons.search),
          onPressed: () => Navigator.pushNamed(context, SearchTvPage.routeName),
        ),
        IconButton(
          key: const Key('tv_watchlist_action'),
          icon: const Icon(Icons.bookmark),
          onPressed: () =>
              Navigator.pushNamed(context, WatchlistTvPage.routeName),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<TvListBloc>();
        bloc.add(const TvListsRequested());
        await bloc.stream.firstWhere(
          (state) => TvCategory.values.every(
            (category) =>
                state.category(category).status != TvListStatus.loading,
          ),
        );
      },
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
    return BlocBuilder<TvListBloc, TvListState>(
      buildWhen: (previous, current) =>
          previous.category(category) != current.category(category),
      builder: (context, state) {
        final categoryState = state.category(category);
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
            if (categoryState.status == TvListStatus.loading)
              const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (categoryState.status == TvListStatus.failure)
              SizedBox(
                height: 100,
                child: Center(child: Text(categoryState.message)),
              )
            else if (categoryState.status == TvListStatus.success &&
                categoryState.items.isEmpty)
              const SizedBox(
                height: 100,
                child: Center(child: Text('No TV series found.')),
              )
            else
              TvHorizontalList(categoryState.items),
          ],
        );
      },
    );
  }
}
