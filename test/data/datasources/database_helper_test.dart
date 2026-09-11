import 'package:ditonton/data/datasources/db/database_helper.dart';
import 'package:ditonton/data/datasources/tv_local_data_source.dart';
import 'package:ditonton/data/models/movie_table.dart';
import 'package:ditonton/data/models/tv_series_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('creates and manages movie and TV watchlist tables', () async {
    final path = '${await getDatabasesPath()}/ditonton.db';
    await deleteDatabase(path);
    final helper = DatabaseHelper();

    final movie = MovieTable(
      id: 1,
      title: 'Movie',
      posterPath: null,
      overview: 'Overview',
    );
    expect(await helper.insertWatchlist(movie), 1);
    expect((await helper.getMovieById(1))?['title'], 'Movie');
    expect(await helper.getMovieById(2), isNull);
    expect(await helper.getWatchlistMovies(), hasLength(1));
    expect(await helper.removeWatchlist(movie), 1);

    const tv = TvSeriesTable(
      id: 2,
      name: 'TV Series',
      overview: 'Overview',
      posterPath: null,
    );
    expect(await helper.insertTvWatchlist(tv), 2);
    expect((await helper.getTvById(2))?['name'], 'TV Series');
    expect(await helper.getTvById(3), isNull);
    expect(await helper.getTvWatchlist(), hasLength(1));
    expect(await helper.removeTvWatchlist(tv), 1);

    final source = TvLocalDataSourceImpl(databaseHelper: helper);
    expect(await source.insertWatchlist(tv), 'Added to Watchlist');
    expect((await source.getById(2))?.name, 'TV Series');
    expect(await source.getById(3), isNull);
    expect(await source.getWatchlist(), hasLength(1));
    expect(await source.removeWatchlist(tv), 'Removed from Watchlist');

    await (await helper.database)?.close();
    await deleteDatabase(path);
  });
}
