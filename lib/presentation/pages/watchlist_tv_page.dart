import 'package:ditonton/common/utils.dart';
import 'package:ditonton/presentation/bloc/tv_watchlist/tv_watchlist_bloc.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WatchlistTvPage extends StatefulWidget {
  const WatchlistTvPage({super.key});
  static const routeName = '/watchlist-tv';

  @override
  State<WatchlistTvPage> createState() => _WatchlistTvPageState();
}

class _WatchlistTvPageState extends State<WatchlistTvPage> with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<TvWatchlistBloc>().add(const TvWatchlistRequested());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    context.read<TvWatchlistBloc>().add(const TvWatchlistRequested());
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TV Series Watchlist')),
      body: BlocBuilder<TvWatchlistBloc, TvWatchlistState>(
        builder: (context, state) => switch (state.status) {
          TvWatchlistStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          TvWatchlistStatus.failure => Center(child: Text(state.message)),
          TvWatchlistStatus.success when state.items.isEmpty => const Center(
            child: Text('Your watchlist is empty.'),
          ),
          TvWatchlistStatus.success => TvCardList(state.items),
          TvWatchlistStatus.initial => const SizedBox.shrink(),
        },
      ),
    );
  }
}
