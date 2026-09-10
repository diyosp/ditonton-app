import 'package:equatable/equatable.dart';

class Season extends Equatable {
  const Season({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodeCount,
    required this.overview,
    required this.posterPath,
    this.episodes = const [],
  });

  final int id;
  final String name;
  final int seasonNumber;
  final int episodeCount;
  final String overview;
  final String? posterPath;
  final List<Episode> episodes;

  @override
  List<Object?> get props => [
    id,
    name,
    seasonNumber,
    episodeCount,
    overview,
    posterPath,
    episodes,
  ];
}

class Episode extends Equatable {
  const Episode({
    required this.id,
    required this.name,
    required this.episodeNumber,
    required this.overview,
    required this.airDate,
    required this.voteAverage,
    required this.stillPath,
  });

  final int id;
  final String name;
  final int episodeNumber;
  final String overview;
  final String airDate;
  final double voteAverage;
  final String? stillPath;

  @override
  List<Object?> get props => [
    id,
    name,
    episodeNumber,
    overview,
    airDate,
    voteAverage,
    stillPath,
  ];
}
