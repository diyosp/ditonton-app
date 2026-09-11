import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist.dart';
import 'package:ditonton/domain/usecases/save_watchlist.dart';
import 'package:equatable/equatable.dart';

sealed class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();
  @override
  List<Object> get props => [];
}

final class MovieDetailRequested extends MovieDetailEvent {
  const MovieDetailRequested(this.id);
  final int id;
  @override
  List<Object> get props => [id];
}

final class MovieWatchlistAdded extends MovieDetailEvent {
  const MovieWatchlistAdded();
}

final class MovieWatchlistRemoved extends MovieDetailEvent {
  const MovieWatchlistRemoved();
}

enum MovieDetailStatus { initial, loading, success, failure }

enum MovieRecommendationStatus { initial, loading, success, failure }

final class MovieDetailState extends Equatable {
  const MovieDetailState({
    this.status = MovieDetailStatus.initial,
    this.recommendationStatus = MovieRecommendationStatus.initial,
    this.movie,
    this.recommendations = const [],
    this.isAddedToWatchlist = false,
    this.message = '',
    this.watchlistMessage = '',
  });
  final MovieDetailStatus status;
  final MovieRecommendationStatus recommendationStatus;
  final MovieDetail? movie;
  final List<Movie> recommendations;
  final bool isAddedToWatchlist;
  final String message;
  final String watchlistMessage;
  MovieDetailState copyWith({
    MovieDetailStatus? status,
    MovieRecommendationStatus? recommendationStatus,
    MovieDetail? movie,
    List<Movie>? recommendations,
    bool? isAddedToWatchlist,
    String? message,
    String? watchlistMessage,
  }) => MovieDetailState(
    status: status ?? this.status,
    recommendationStatus: recommendationStatus ?? this.recommendationStatus,
    movie: movie ?? this.movie,
    recommendations: recommendations ?? this.recommendations,
    isAddedToWatchlist: isAddedToWatchlist ?? this.isAddedToWatchlist,
    message: message ?? this.message,
    watchlistMessage: watchlistMessage ?? this.watchlistMessage,
  );
  @override
  List<Object?> get props => [
    status,
    recommendationStatus,
    movie,
    recommendations,
    isAddedToWatchlist,
    message,
    watchlistMessage,
  ];
}

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  MovieDetailBloc({
    required GetMovieDetail getMovieDetail,
    required GetMovieRecommendations getMovieRecommendations,
    required GetWatchListStatus getWatchlistStatus,
    required SaveWatchlist saveWatchlist,
    required RemoveWatchlist removeWatchlist,
  }) : _getDetail = getMovieDetail,
       _getRecommendations = getMovieRecommendations,
       _getStatus = getWatchlistStatus,
       _save = saveWatchlist,
       _remove = removeWatchlist,
       super(const MovieDetailState()) {
    on<MovieDetailRequested>(_requested);
    on<MovieWatchlistAdded>(_added);
    on<MovieWatchlistRemoved>(_removed);
  }
  final GetMovieDetail _getDetail;
  final GetMovieRecommendations _getRecommendations;
  final GetWatchListStatus _getStatus;
  final SaveWatchlist _save;
  final RemoveWatchlist _remove;
  Future<void> _requested(
    MovieDetailRequested event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(
      const MovieDetailState(
        status: MovieDetailStatus.loading,
        recommendationStatus: MovieRecommendationStatus.loading,
      ),
    );
    final result = await _getDetail.execute(event.id);
    final movie = result.fold<MovieDetail?>((_) => null, (value) => value);
    if (movie == null) {
      emit(
        MovieDetailState(
          status: MovieDetailStatus.failure,
          message: result.fold((failure) => failure.message, (_) => ''),
        ),
      );
      return;
    }
    emit(
      MovieDetailState(
        status: MovieDetailStatus.success,
        recommendationStatus: MovieRecommendationStatus.loading,
        movie: movie,
        isAddedToWatchlist: await _getStatus.execute(event.id),
      ),
    );
    final recommendation = await _getRecommendations.execute(event.id);
    recommendation.fold(
      (failure) => emit(
        state.copyWith(
          recommendationStatus: MovieRecommendationStatus.failure,
          message: failure.message,
        ),
      ),
      (items) => emit(
        state.copyWith(
          recommendationStatus: MovieRecommendationStatus.success,
          recommendations: items,
        ),
      ),
    );
  }

  Future<void> _added(
    MovieWatchlistAdded event,
    Emitter<MovieDetailState> emit,
  ) => _change(_save.execute, emit);
  Future<void> _removed(
    MovieWatchlistRemoved event,
    Emitter<MovieDetailState> emit,
  ) => _change(_remove.execute, emit);
  Future<void> _change(
    Future<Either<Failure, String>> Function(MovieDetail) action,
    Emitter<MovieDetailState> emit,
  ) async {
    final movie = state.movie;
    if (movie == null) return;
    final result = await action(movie);
    emit(
      state.copyWith(
        watchlistMessage: result.fold(
          (failure) => failure.message,
          (value) => value,
        ),
        isAddedToWatchlist: await _getStatus.execute(movie.id),
      ),
    );
  }
}
