import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/presentation/provider/tv_list_notifier.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TvCategoryPage extends StatefulWidget {
  const TvCategoryPage({super.key, required this.category});
  static const routeName = '/tv-category';
  final TvCategory category;

  @override
  State<TvCategoryPage> createState() => _TvCategoryPageState();
}

class _TvCategoryPageState extends State<TvCategoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TvListNotifier>().fetch(widget.category),
    );
  }

  String get title => switch (widget.category) {
    TvCategory.onTheAir => 'On The Air TV Series',
    TvCategory.popular => 'Popular TV Series',
    TvCategory.topRated => 'Top Rated TV Series',
  };

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TvListNotifier>();
    final state = notifier.stateOf(widget.category);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: switch (state) {
        RequestState.Loading => const Center(
          child: CircularProgressIndicator(),
        ),
        RequestState.Error => Center(
          child: Text(notifier.messageOf(widget.category)),
        ),
        RequestState.Loaded when notifier.itemsOf(widget.category).isEmpty =>
          const Center(child: Text('No TV series found.')),
        _ => TvCardList(notifier.itemsOf(widget.category)),
      },
    );
  }
}
