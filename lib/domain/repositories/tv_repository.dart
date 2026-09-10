import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';

abstract class TvRepository {
  Future<Either<Failure, List<TvSeries>>> getOnTheAir();
  Future<Either<Failure, List<TvSeries>>> getPopular();
  Future<Either<Failure, List<TvSeries>>> getTopRated();
  Future<Either<Failure, TvSeriesDetail>> getDetail(int id);
  Future<Either<Failure, List<TvSeries>>> getRecommendations(int id);
  Future<Either<Failure, List<TvSeries>>> search(String query);
  Future<Either<Failure, Season>> getSeasonDetail(int id, int seasonNumber);
  Future<Either<Failure, String>> saveWatchlist(TvSeriesDetail tv);
  Future<Either<Failure, String>> removeWatchlist(TvSeriesDetail tv);
  Future<bool> isAddedToWatchlist(int id);
  Future<Either<Failure, List<TvSeries>>> getWatchlist();
}
