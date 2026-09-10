import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';

class TvSeriesTable {
  const TvSeriesTable({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
  });

  final int id;
  final String name;
  final String overview;
  final String? posterPath;

  factory TvSeriesTable.fromEntity(TvSeriesDetail tv) => TvSeriesTable(
    id: tv.id,
    name: tv.name,
    overview: tv.overview,
    posterPath: tv.posterPath,
  );

  factory TvSeriesTable.fromMap(Map<String, dynamic> map) => TvSeriesTable(
    id: map['id'] as int,
    name: map['name'] as String,
    overview: map['overview'] as String,
    posterPath: map['posterPath'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'overview': overview,
    'posterPath': posterPath,
  };

  TvSeries toEntity() => TvSeries(
    id: id,
    name: name,
    overview: overview,
    posterPath: posterPath,
    voteAverage: 0,
    firstAirDate: '',
  );
}
