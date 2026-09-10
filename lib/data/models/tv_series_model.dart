import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:equatable/equatable.dart';

class TvSeriesModel extends Equatable {
  const TvSeriesModel({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.firstAirDate,
  });

  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String firstAirDate;

  factory TvSeriesModel.fromJson(Map<String, dynamic> json) => TvSeriesModel(
    id: json['id'] as int,
    name: (json['name'] ?? '') as String,
    overview: (json['overview'] ?? '') as String,
    posterPath: json['poster_path'] as String?,
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    firstAirDate: (json['first_air_date'] ?? '') as String,
  );

  TvSeries toEntity() => TvSeries(
    id: id,
    name: name,
    overview: overview,
    posterPath: posterPath,
    voteAverage: voteAverage,
    firstAirDate: firstAirDate,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    overview,
    posterPath,
    voteAverage,
    firstAirDate,
  ];
}

class TvSeriesResponse {
  const TvSeriesResponse(this.results);
  final List<TvSeriesModel> results;

  factory TvSeriesResponse.fromJson(Map<String, dynamic> json) =>
      TvSeriesResponse(
        ((json['results'] as List?) ?? const [])
            .map((item) => TvSeriesModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
