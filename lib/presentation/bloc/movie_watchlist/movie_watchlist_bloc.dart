import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_watchlist_movies.dart';
import 'package:equatable/equatable.dart';

sealed class MovieWatchlistEvent extends Equatable {
  const MovieWatchlistEvent();
  @override
  List<Object> get props => [];
}

final class MovieWatchlistRequested extends MovieWatchlistEvent {
  const MovieWatchlistRequested();
}

enum MovieWatchlistStatus { initial, loading, success, failure }

final class MovieWatchlistState extends Equatable {
  const MovieWatchlistState({
    this.status = MovieWatchlistStatus.initial,
    this.items = const [],
    this.message = '',
  });
  final MovieWatchlistStatus status;
  final List<Movie> items;
  final String message;
  @override
  List<Object> get props => [status, items, message];
}

class MovieWatchlistBloc
    extends Bloc<MovieWatchlistEvent, MovieWatchlistState> {
  MovieWatchlistBloc(this._getWatchlist) : super(const MovieWatchlistState()) {
    on<MovieWatchlistRequested>(_onRequested);
  }
  final GetWatchlistMovies _getWatchlist;

  Future<void> _onRequested(
    MovieWatchlistRequested event,
    Emitter<MovieWatchlistState> emit,
  ) async {
    emit(const MovieWatchlistState(status: MovieWatchlistStatus.loading));
    final result = await _getWatchlist.execute();
    result.fold(
      (failure) => emit(
        MovieWatchlistState(
          status: MovieWatchlistStatus.failure,
          message: failure.message,
        ),
      ),
      (items) => emit(
        MovieWatchlistState(status: MovieWatchlistStatus.success, items: items),
      ),
    );
  }
}
