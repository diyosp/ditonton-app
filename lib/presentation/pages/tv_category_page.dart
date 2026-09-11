import 'package:ditonton/presentation/bloc/tv_list/tv_list_bloc.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    context.read<TvListBloc>().add(TvCategoryRequested(widget.category));
  }

  String get title => switch (widget.category) {
    TvCategory.onTheAir => 'On The Air TV Series',
    TvCategory.popular => 'Popular TV Series',
    TvCategory.topRated => 'Top Rated TV Series',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<TvListBloc, TvListState>(
        builder: (context, state) {
          final categoryState = state.category(widget.category);
          return switch (categoryState.status) {
            TvListStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            TvListStatus.failure => Center(child: Text(categoryState.message)),
            TvListStatus.success when categoryState.items.isEmpty =>
              const Center(child: Text('No TV series found.')),
            TvListStatus.success => TvCardList(categoryState.items),
            TvListStatus.initial => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
