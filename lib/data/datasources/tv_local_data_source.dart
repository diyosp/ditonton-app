import 'package:ditonton/common/exception.dart';
import 'package:ditonton/data/datasources/db/database_helper.dart';
import 'package:ditonton/data/models/tv_series_table.dart';

abstract class TvLocalDataSource {
  Future<String> insertWatchlist(TvSeriesTable tv);
  Future<String> removeWatchlist(TvSeriesTable tv);
  Future<TvSeriesTable?> getById(int id);
  Future<List<TvSeriesTable>> getWatchlist();
}

class TvLocalDataSourceImpl implements TvLocalDataSource {
  TvLocalDataSourceImpl({required this.databaseHelper});
  final DatabaseHelper databaseHelper;

  @override
  Future<String> insertWatchlist(TvSeriesTable tv) async {
    try {
      await databaseHelper.insertTvWatchlist(tv);
      return 'Added to Watchlist';
    } catch (error) {
      throw DatabaseException(error.toString());
    }
  }

  @override
  Future<String> removeWatchlist(TvSeriesTable tv) async {
    try {
      await databaseHelper.removeTvWatchlist(tv);
      return 'Removed from Watchlist';
    } catch (error) {
      throw DatabaseException(error.toString());
    }
  }

  @override
  Future<TvSeriesTable?> getById(int id) async {
    final result = await databaseHelper.getTvById(id);
    return result == null ? null : TvSeriesTable.fromMap(result);
  }

  @override
  Future<List<TvSeriesTable>> getWatchlist() async {
    final result = await databaseHelper.getTvWatchlist();
    return result.map(TvSeriesTable.fromMap).toList();
  }
}
