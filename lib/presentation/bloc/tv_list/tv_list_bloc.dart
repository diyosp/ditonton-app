import 'package:bloc/bloc.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:equatable/equatable.dart';

enum TvCategory { onTheAir, popular, topRated }

sealed class TvListEvent extends Equatable {
  const TvListEvent();

  @override
  List<Object> get props => [];
}

final class TvListsRequested extends TvListEvent {
  const TvListsRequested();
}

final class TvCategoryRequested extends TvListEvent {
  const TvCategoryRequested(this.category);

  final TvCategory category;

  @override
  List<Object> get props => [category];
}

enum TvListStatus { initial, loading, success, failure }

final class TvCategoryState extends Equatable {
  const TvCategoryState({
    this.status = TvListStatus.initial,
    this.items = const [],
    this.message = '',
  });

  final TvListStatus status;
  final List<TvSeries> items;
  final String message;

  @override
  List<Object> get props => [status, items, message];
}

final class TvListState extends Equatable {
  const TvListState({this.categories = const {}});

  final Map<TvCategory, TvCategoryState> categories;

  TvCategoryState category(TvCategory value) =>
      categories[value] ?? const TvCategoryState();

  TvListState update(TvCategory category, TvCategoryState value) =>
      TvListState(categories: {...categories, category: value});

  @override
  List<Object> get props => [categories];
}

class TvListBloc extends Bloc<TvListEvent, TvListState> {
  TvListBloc({
    required this.getOnTheAir,
    required this.getPopular,
    required this.getTopRated,
  }) : super(const TvListState()) {
    on<TvListsRequested>(_onListsRequested);
    on<TvCategoryRequested>(_onCategoryRequested);
  }

  final GetOnTheAirTv getOnTheAir;
  final GetPopularTv getPopular;
  final GetTopRatedTv getTopRated;

  Future<void> _onListsRequested(
    TvListsRequested event,
    Emitter<TvListState> emit,
  ) async {
    var nextState = state;
    for (final category in TvCategory.values) {
      nextState = nextState.update(
        category,
        const TvCategoryState(status: TvListStatus.loading),
      );
    }
    emit(nextState);

    for (final category in TvCategory.values) {
      await _load(category, emit);
    }
  }

  Future<void> _onCategoryRequested(
    TvCategoryRequested event,
    Emitter<TvListState> emit,
  ) => _load(event.category, emit);

  Future<void> _load(TvCategory category, Emitter<TvListState> emit) async {
    emit(
      state.update(
        category,
        const TvCategoryState(status: TvListStatus.loading),
      ),
    );
    final result = switch (category) {
      TvCategory.onTheAir => await getOnTheAir.execute(),
      TvCategory.popular => await getPopular.execute(),
      TvCategory.topRated => await getTopRated.execute(),
    };
    result.fold(
      (Failure failure) => emit(
        state.update(
          category,
          TvCategoryState(
            status: TvListStatus.failure,
            message: failure.message,
          ),
        ),
      ),
      (items) => emit(
        state.update(
          category,
          TvCategoryState(status: TvListStatus.success, items: items),
        ),
      ),
    );
  }
}
