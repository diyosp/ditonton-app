import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/presentation/bloc/tv_search/tv_search_bloc.dart';
import 'package:ditonton/presentation/pages/search_tv_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class SearchRepository implements TvRepository {
  @override
  Future<Either<Failure, List<TvSeries>>> search(String query) async =>
      const Right([
        TvSeries(
          id: 1399,
          name: 'Game of Thrones',
          overview: 'Overview',
          posterPath: null,
          voteAverage: 8.4,
          firstAirDate: '2011-04-17',
        ),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('shows initial copy and API search results', (tester) async {
    final bloc = TvSearchBloc(SearchTv(SearchRepository()));
    addTearDown(bloc.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(home: SearchTvPage()),
      ),
    );

    expect(find.text('Find your favorite TV series.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('tv_search_field')), 'game');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Game of Thrones'), findsOneWidget);
  });
}
