import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ditonton/common/exception.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/data/datasources/tv_local_data_source.dart';
import 'package:ditonton/data/datasources/tv_remote_data_source.dart';
import 'package:ditonton/data/models/tv_series_model.dart';
import 'package:ditonton/data/models/tv_series_table.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';

class TvRepositoryImpl implements TvRepository {
  TvRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  final TvRemoteDataSource remoteDataSource;
  final TvLocalDataSource localDataSource;

  Future<Either<Failure, T>> _remote<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } on ServerException {
      return Left(ServerFailure('Server failure'));
    } on SocketException {
      return Left(ConnectionFailure('Failed to connect to the network'));
    }
  }

  Future<Either<Failure, List<TvSeries>>> _list(
    Future<List<TvSeriesModel>> Function() request,
  ) => _remote(
    () async => (await request()).map((model) => model.toEntity()).toList(),
  );

  @override
  Future<Either<Failure, List<TvSeries>>> getOnTheAir() =>
      _list(remoteDataSource.getOnTheAir);

  @override
  Future<Either<Failure, List<TvSeries>>> getPopular() =>
      _list(remoteDataSource.getPopular);

  @override
  Future<Either<Failure, List<TvSeries>>> getTopRated() =>
      _list(remoteDataSource.getTopRated);

  @override
  Future<Either<Failure, TvSeriesDetail>> getDetail(int id) =>
      _remote(() async => (await remoteDataSource.getDetail(id)).toEntity());

  @override
  Future<Either<Failure, List<TvSeries>>> getRecommendations(int id) =>
      _list(() => remoteDataSource.getRecommendations(id));

  @override
  Future<Either<Failure, List<TvSeries>>> search(String query) =>
      _list(() => remoteDataSource.search(query));

  @override
  Future<Either<Failure, Season>> getSeasonDetail(int id, int seasonNumber) =>
      _remote(() => remoteDataSource.getSeasonDetail(id, seasonNumber));

  @override
  Future<Either<Failure, String>> saveWatchlist(TvSeriesDetail tv) async {
    try {
      return Right(
        await localDataSource.insertWatchlist(TvSeriesTable.fromEntity(tv)),
      );
    } on DatabaseException catch (error) {
      return Left(DatabaseFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, String>> removeWatchlist(TvSeriesDetail tv) async {
    try {
      return Right(
        await localDataSource.removeWatchlist(TvSeriesTable.fromEntity(tv)),
      );
    } on DatabaseException catch (error) {
      return Left(DatabaseFailure(error.message));
    }
  }

  @override
  Future<bool> isAddedToWatchlist(int id) async =>
      await localDataSource.getById(id) != null;

  @override
  Future<Either<Failure, List<TvSeries>>> getWatchlist() async {
    try {
      final result = await localDataSource.getWatchlist();
      return Right(result.map((item) => item.toEntity()).toList());
    } on DatabaseException catch (error) {
      return Left(DatabaseFailure(error.message));
    }
  }
}
