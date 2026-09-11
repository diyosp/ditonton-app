import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/presentation/bloc/tv_list/tv_list_bloc.dart';
import 'package:ditonton/presentation/pages/home_tv_page.dart';
import 'package:ditonton/presentation/pages/tv_category_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class ListRepository implements TvRepository {
  static const item = TvSeries(
    id: 1399,
    name: 'Game of Thrones',
    overview: 'Overview',
    posterPath: null,
    voteAverage: 8.4,
    firstAirDate: '2011-04-17',
  );

  @override
  Future<Either<Failure, List<TvSeries>>> getOnTheAir() async =>
      const Right([item]);
  @override
  Future<Either<Failure, List<TvSeries>>> getPopular() async =>
      const Right([item]);
  @override
  Future<Either<Failure, List<TvSeries>>> getTopRated() async =>
      const Right([item]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TvListBloc createBloc() {
  final repository = ListRepository();
  return TvListBloc(
    getOnTheAir: GetOnTheAirTv(repository),
    getPopular: GetPopularTv(repository),
    getTopRated: GetTopRatedTv(repository),
  );
}

void main() {
  testWidgets('home displays all TV sections', (tester) async {
    final bloc = createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(home: HomeTvPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('On The Air'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);
    expect(find.text('See More'), findsNWidgets(3));
  });

  testWidgets('category page displays loaded TV series', (tester) async {
    final bloc = createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(
          home: TvCategoryPage(category: TvCategory.popular),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Popular TV Series'), findsOneWidget);
    expect(find.text('Game of Thrones'), findsOneWidget);
  });
}
