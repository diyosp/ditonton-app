import 'package:cached_network_image/cached_network_image.dart';
import 'package:ditonton/common/constants.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/injection.dart';
import 'package:flutter/material.dart';

class SeasonArguments {
  const SeasonArguments(this.tvId, this.seasonNumber, this.title);
  final int tvId;
  final int seasonNumber;
  final String title;
}

class SeasonDetailPage extends StatefulWidget {
  const SeasonDetailPage({super.key, required this.arguments});
  static const routeName = '/season-detail';
  final SeasonArguments arguments;

  @override
  State<SeasonDetailPage> createState() => _SeasonDetailPageState();
}

class _SeasonDetailPageState extends State<SeasonDetailPage> {
  late final Future<Season> _season = _load();

  Future<Season> _load() async {
    final result = await locator<GetSeasonDetail>().execute(
      widget.arguments.tvId,
      widget.arguments.seasonNumber,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (value) => value,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.arguments.title)),
    body: FutureBuilder<Season>(
      future: _season,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        final season = snapshot.requireData;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: season.episodes.length,
          itemBuilder: (context, index) {
            final episode = season.episodes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (episode.stillPath != null)
                    CachedNetworkImage(
                      imageUrl: '$BASE_IMAGE_URL${episode.stillPath}',
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${episode.episodeNumber}. ${episode.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${episode.airDate}  •  ★ ${episode.voteAverage.toStringAsFixed(1)}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          episode.overview.isEmpty
                              ? 'No overview available.'
                              : episode.overview,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}
