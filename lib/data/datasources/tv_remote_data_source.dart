import 'dart:convert';

import 'package:ditonton/common/exception.dart';
import 'package:ditonton/data/models/tv_series_detail_model.dart';
import 'package:ditonton/data/models/tv_series_model.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:http/http.dart' as http;

abstract class TvRemoteDataSource {
  Future<List<TvSeriesModel>> getOnTheAir();
  Future<List<TvSeriesModel>> getPopular();
  Future<List<TvSeriesModel>> getTopRated();
  Future<TvSeriesDetailModel> getDetail(int id);
  Future<List<TvSeriesModel>> getRecommendations(int id);
  Future<List<TvSeriesModel>> search(String query);
  Future<Season> getSeasonDetail(int id, int seasonNumber);
}

class TvRemoteDataSourceImpl implements TvRemoteDataSource {
  TvRemoteDataSourceImpl({required this.client});

  static const _apiKey = '2174d146bb9c0eab47529b2e77d6b526';
  static const _baseUrl = 'https://api.themoviedb.org/3';
  final http.Client client;

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String> query = const {},
  ]) async {
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: {'api_key': _apiKey, ...query});
    final response = await client.get(uri);
    if (response.statusCode != 200) throw ServerException();
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<List<TvSeriesModel>> _getList(
    String path, [
    Map<String, String> query = const {},
  ]) async => TvSeriesResponse.fromJson(await _get(path, query)).results;

  @override
  Future<List<TvSeriesModel>> getOnTheAir() => _getList('/tv/on_the_air');

  @override
  Future<List<TvSeriesModel>> getPopular() => _getList('/tv/popular');

  @override
  Future<List<TvSeriesModel>> getTopRated() => _getList('/tv/top_rated');

  @override
  Future<TvSeriesDetailModel> getDetail(int id) async =>
      TvSeriesDetailModel.fromJson(await _get('/tv/$id'));

  @override
  Future<List<TvSeriesModel>> getRecommendations(int id) =>
      _getList('/tv/$id/recommendations');

  @override
  Future<List<TvSeriesModel>> search(String query) =>
      _getList('/search/tv', {'query': query});

  @override
  Future<Season> getSeasonDetail(int id, int seasonNumber) async =>
      SeasonDetailModel.fromJson(await _get('/tv/$id/season/$seasonNumber'));
}
