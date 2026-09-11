import 'package:ditonton/data/datasources/movie_remote_data_source.dart';
import 'package:ditonton/data/datasources/tv_remote_data_source.dart';
import 'package:ditonton/injection.dart';
import 'package:ditonton/presentation/bloc/movie_detail/movie_detail_bloc.dart';
import 'package:ditonton/presentation/bloc/movie_list/movie_list_bloc.dart';
import 'package:ditonton/presentation/bloc/movie_search/movie_search_bloc.dart';
import 'package:ditonton/presentation/bloc/movie_watchlist/movie_watchlist_bloc.dart';
import 'package:ditonton/presentation/bloc/tv_detail/tv_detail_bloc.dart';
import 'package:ditonton/presentation/bloc/tv_list/tv_list_bloc.dart';
import 'package:ditonton/presentation/bloc/tv_search/tv_search_bloc.dart';
import 'package:ditonton/presentation/bloc/tv_watchlist/tv_watchlist_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registers application dependencies', () async {
    await locator.reset();
    await init();

    expect(locator<MovieRemoteDataSource>(), isNotNull);
    expect(locator<TvRemoteDataSource>(), isNotNull);
    expect(locator<MovieListBloc>(), isNotNull);
    expect(locator<MovieDetailBloc>(), isNotNull);
    expect(locator<MovieSearchBloc>(), isNotNull);
    expect(locator<MovieWatchlistBloc>(), isNotNull);
    expect(locator<TvListBloc>(), isNotNull);
    expect(locator<TvDetailBloc>(), isNotNull);
    expect(locator<TvSearchBloc>(), isNotNull);
    expect(locator<TvWatchlistBloc>(), isNotNull);

    await locator.reset(dispose: true);
  });
}
