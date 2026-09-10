import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';

class GetOnTheAirTv {
  const GetOnTheAirTv(this.repository);
  final TvRepository repository;
  Future<Either<Failure, List<TvSeries>>> execute() => repository.getOnTheAir();
}

class GetPopularTv {
  const GetPopularTv(this.repository);
  final TvRepository repository;
  Future<Either<Failure, List<TvSeries>>> execute() => repository.getPopular();
}

class GetTopRatedTv {
  const GetTopRatedTv(this.repository);
  final TvRepository repository;
  Future<Either<Failure, List<TvSeries>>> execute() => repository.getTopRated();
}

class GetTvDetail {
  const GetTvDetail(this.repository);
  final TvRepository repository;
  Future<Either<Failure, TvSeriesDetail>> execute(int id) =>
      repository.getDetail(id);
}

class GetTvRecommendations {
  const GetTvRecommendations(this.repository);
  final TvRepository repository;
  Future<Either<Failure, List<TvSeries>>> execute(int id) =>
      repository.getRecommendations(id);
}

class SearchTv {
  const SearchTv(this.repository);
  final TvRepository repository;
  Future<Either<Failure, List<TvSeries>>> execute(String query) =>
      repository.search(query);
}

class GetSeasonDetail {
  const GetSeasonDetail(this.repository);
  final TvRepository repository;
  Future<Either<Failure, Season>> execute(int id, int seasonNumber) =>
      repository.getSeasonDetail(id, seasonNumber);
}

class SaveTvWatchlist {
  const SaveTvWatchlist(this.repository);
  final TvRepository repository;
  Future<Either<Failure, String>> execute(TvSeriesDetail tv) =>
      repository.saveWatchlist(tv);
}

class RemoveTvWatchlist {
  const RemoveTvWatchlist(this.repository);
  final TvRepository repository;
  Future<Either<Failure, String>> execute(TvSeriesDetail tv) =>
      repository.removeWatchlist(tv);
}

class GetTvWatchlistStatus {
  const GetTvWatchlistStatus(this.repository);
  final TvRepository repository;
  Future<bool> execute(int id) => repository.isAddedToWatchlist(id);
}

class GetTvWatchlist {
  const GetTvWatchlist(this.repository);
  final TvRepository repository;
  Future<Either<Failure, List<TvSeries>>> execute() =>
      repository.getWatchlist();
}
