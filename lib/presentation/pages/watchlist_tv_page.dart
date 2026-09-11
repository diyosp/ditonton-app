import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/common/utils.dart';
import 'package:ditonton/presentation/provider/tv_watchlist_notifier.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    Future.microtask(() => context.read<TvWatchlistNotifier>().fetch());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    context.read<TvWatchlistNotifier>().fetch();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TvWatchlistNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('TV Series Watchlist')),
      body: switch (notifier.state) {
        RequestState.Loading => const Center(
          child: CircularProgressIndicator(),
        ),
        RequestState.Error => Center(child: Text(notifier.message)),
        RequestState.Loaded when notifier.items.isEmpty => const Center(
          child: Text('Your watchlist is empty.'),
        ),
        _ => TvCardList(notifier.items),
      },
    );
  }
}
