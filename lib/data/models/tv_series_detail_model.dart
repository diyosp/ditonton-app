import 'package:ditonton/data/models/genre_model.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';

class TvSeriesDetailModel {
  const TvSeriesDetailModel({
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
  final List<GenreModel> genres;
  final List<Season> seasons;
  final int numberOfEpisodes;
  final int numberOfSeasons;

  factory TvSeriesDetailModel.fromJson(Map<String, dynamic> json) =>
      TvSeriesDetailModel(
        id: json['id'] as int,
        name: (json['name'] ?? '') as String,
        overview: (json['overview'] ?? '') as String,
        posterPath: json['poster_path'] as String?,
        backdropPath: json['backdrop_path'] as String?,
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
        genres: ((json['genres'] as List?) ?? const [])
            .map((item) => GenreModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        seasons: ((json['seasons'] as List?) ?? const [])
            .map((item) => _seasonFromJson(item as Map<String, dynamic>))
            .toList(),
        numberOfEpisodes: (json['number_of_episodes'] as int?) ?? 0,
        numberOfSeasons: (json['number_of_seasons'] as int?) ?? 0,
      );

  TvSeriesDetail toEntity() => TvSeriesDetail(
    id: id,
    name: name,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    voteAverage: voteAverage,
    genres: genres.map((genre) => genre.toEntity()).toList(),
    seasons: seasons,
    numberOfEpisodes: numberOfEpisodes,
    numberOfSeasons: numberOfSeasons,
  );

  static Season _seasonFromJson(Map<String, dynamic> json) => Season(
    id: json['id'] as int,
    name: (json['name'] ?? '') as String,
    seasonNumber: (json['season_number'] as int?) ?? 0,
    episodeCount: (json['episode_count'] as int?) ?? 0,
    overview: (json['overview'] ?? '') as String,
    posterPath: json['poster_path'] as String?,
  );
}

class SeasonDetailModel {
  static Season fromJson(Map<String, dynamic> json) => Season(
    id: json['id'] as int,
    name: (json['name'] ?? '') as String,
    seasonNumber: (json['season_number'] as int?) ?? 0,
    episodeCount: ((json['episodes'] as List?) ?? const []).length,
    overview: (json['overview'] ?? '') as String,
    posterPath: json['poster_path'] as String?,
    episodes: ((json['episodes'] as List?) ?? const [])
        .map((item) => _episodeFromJson(item as Map<String, dynamic>))
        .toList(),
  );

  static Episode _episodeFromJson(Map<String, dynamic> json) => Episode(
    id: json['id'] as int,
    name: (json['name'] ?? '') as String,
    episodeNumber: (json['episode_number'] as int?) ?? 0,
    overview: (json['overview'] ?? '') as String,
    airDate: (json['air_date'] ?? '') as String,
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    stillPath: json['still_path'] as String?,
  );
}
