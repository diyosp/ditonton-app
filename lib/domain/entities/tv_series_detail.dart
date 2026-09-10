import 'package:ditonton/domain/entities/genre.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:equatable/equatable.dart';

class TvSeriesDetail extends Equatable {
  const TvSeriesDetail({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.genres,
    required this.seasons,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
  });

  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final List<Genre> genres;
  final List<Season> seasons;
  final int numberOfEpisodes;
  final int numberOfSeasons;

  @override
  List<Object?> get props => [
    id,
    name,
    overview,
    posterPath,
    backdropPath,
    voteAverage,
    genres,
    seasons,
    numberOfEpisodes,
    numberOfSeasons,
  ];
}
