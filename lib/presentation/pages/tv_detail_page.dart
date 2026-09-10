import 'package:cached_network_image/cached_network_image.dart';
import 'package:ditonton/common/constants.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';
import 'package:ditonton/presentation/pages/season_detail_page.dart';
import 'package:ditonton/presentation/provider/tv_detail_notifier.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class TvDetailPage extends StatefulWidget {
  const TvDetailPage({super.key, required this.id});
  static const routeName = '/tv-detail';
  final int id;

  @override
  State<TvDetailPage> createState() => _TvDetailPageState();
}

class _TvDetailPageState extends State<TvDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TvDetailNotifier>().fetch(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TvDetailNotifier>();
    return Scaffold(
      body: switch (notifier.state) {
        RequestState.Loading => const Center(
          child: CircularProgressIndicator(),
        ),
        RequestState.Error => Center(child: Text(notifier.message)),
        RequestState.Loaded => _DetailContent(
          detail: notifier.tv!,
          notifier: notifier,
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail, required this.notifier});
  final TvSeriesDetail detail;
  final TvDetailNotifier notifier;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverAppBar(
        pinned: true,
        expandedHeight: 280,
        flexibleSpace: FlexibleSpaceBar(
          background: detail.backdropPath == null
              ? const Center(child: Icon(Icons.tv, size: 72))
              : CachedNetworkImage(
                  imageUrl: '$BASE_IMAGE_URL${detail.backdropPath}',
                  fit: BoxFit.cover,
                ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList.list(
          children: [
            Text(detail.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: const Key('tv_watchlist_button'),
              onPressed: () async {
                if (notifier.isAddedToWatchlist) {
                  await notifier.removeFromWatchlist();
                } else {
                  await notifier.addWatchlist();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(notifier.message)));
                }
              },
              icon: Icon(notifier.isAddedToWatchlist ? Icons.check : Icons.add),
              label: const Text('Watchlist'),
            ),
            const SizedBox(height: 12),
            Text(detail.genres.map((genre) => genre.name).join(', ')),
            Text(
              '${detail.numberOfSeasons} seasons • ${detail.numberOfEpisodes} episodes',
            ),
            Row(
              children: [
                RatingBarIndicator(
                  rating: detail.voteAverage / 2,
                  itemCount: 5,
                  itemSize: 20,
                  itemBuilder: (_, __) =>
                      const Icon(Icons.star, color: kMikadoYellow),
                ),
                const SizedBox(width: 8),
                Text(detail.voteAverage.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 18),
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              detail.overview.isEmpty
                  ? 'No overview available.'
                  : detail.overview,
            ),
            const SizedBox(height: 18),
            Text(
              'Seasons & Episodes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...detail.seasons.map(
              (season) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(season.name),
                subtitle: Text('${season.episodeCount} episodes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(
                  context,
                  SeasonDetailPage.routeName,
                  arguments: SeasonArguments(
                    detail.id,
                    season.seasonNumber,
                    season.name,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (notifier.recommendationState == RequestState.Loading)
              const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (notifier.recommendations.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No recommendations available.'),
              )
            else
              TvHorizontalList(notifier.recommendations),
          ],
        ),
      ),
    ],
  );
}
