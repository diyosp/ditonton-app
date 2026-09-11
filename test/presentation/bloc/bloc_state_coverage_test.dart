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
  test('events expose their values through equality properties', () {
    expect(const MovieDetailRequested(1).props, [1]);
    expect(const MovieWatchlistAdded().props, isEmpty);
    expect(const MovieWatchlistRemoved().props, isEmpty);
    expect(const MovieListsRequested().props, isEmpty);
    expect(const MovieCategoryRequested(MovieCategory.popular).props, [
      MovieCategory.popular,
    ]);
    expect(const MovieSearchQueryChanged('movie').props, ['movie']);
    expect(const MovieWatchlistRequested().props, isEmpty);
    expect(const TvDetailRequested(1).props, [1]);
    expect(const TvWatchlistAdded().props, isEmpty);
    expect(const TvWatchlistRemoved().props, isEmpty);
    expect(const TvListsRequested().props, isEmpty);
    expect(const TvCategoryRequested(TvCategory.popular).props, [
      TvCategory.popular,
    ]);
    expect(const TvSearchQueryChanged('tv').props, ['tv']);
    expect(const TvWatchlistRequested().props, isEmpty);
  });

  test('states copy values without losing existing fields', () {
    final movieDetail = const MovieDetailState().copyWith(
      status: MovieDetailStatus.success,
      recommendationStatus: MovieRecommendationStatus.failure,
      isAddedToWatchlist: true,
      message: 'message',
      watchlistMessage: 'watchlist',
    );
    expect(movieDetail.props, hasLength(7));
    expect(movieDetail.isAddedToWatchlist, isTrue);

    final tvDetail = const TvDetailState().copyWith(
      status: TvDetailStatus.success,
      recommendationStatus: TvRecommendationStatus.failure,
      isAddedToWatchlist: true,
      message: 'message',
    );
    expect(tvDetail.props, hasLength(6));
    expect(tvDetail.isAddedToWatchlist, isTrue);

    final tvWatchlist = const TvWatchlistState().copyWith(
      status: TvWatchlistStatus.failure,
      message: 'failed',
    );
    expect(tvWatchlist.props, hasLength(3));
    expect(tvWatchlist.message, 'failed');

    expect(const MovieCategoryState().props, hasLength(3));
    expect(const MovieListState().props, hasLength(1));
    expect(const MovieSearchState().props, hasLength(3));
    expect(const MovieWatchlistState().props, hasLength(3));
    expect(const TvCategoryState().props, hasLength(3));
    expect(const TvListState().props, hasLength(1));
    expect(const TvSearchState().props, hasLength(3));
  });
}
