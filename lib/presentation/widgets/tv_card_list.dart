import 'package:cached_network_image/cached_network_image.dart';
import 'package:ditonton/common/constants.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/presentation/pages/tv_detail_page.dart';
import 'package:flutter/material.dart';

class TvHorizontalList extends StatelessWidget {
  const TvHorizontalList(this.items, {super.key});
  final List<TvSeries> items;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 200,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final tv = items[index];
        return Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              TvDetailPage.routeName,
              arguments: tv.id,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _Poster(path: tv.posterPath, width: 120),
            ),
          ),
        );
      },
    ),
  );
}

class TvCardList extends StatelessWidget {
  const TvCardList(this.items, {super.key});
  final List<TvSeries> items;

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final tv = items[index];
      return InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          TvDetailPage.routeName,
          arguments: tv.id,
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _Poster(path: tv.posterPath, width: 100, height: 145),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tv.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tv.overview.isEmpty
                            ? 'No overview available.'
                            : tv.overview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _Poster extends StatelessWidget {
  const _Poster({required this.path, required this.width, this.height});
  final String? path;
  final double width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade800,
        child: const Icon(Icons.tv_off),
      );
    }
    return CachedNetworkImage(
      imageUrl: '$BASE_IMAGE_URL$path',
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => SizedBox(
        width: width,
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (_, __, ___) => SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}
