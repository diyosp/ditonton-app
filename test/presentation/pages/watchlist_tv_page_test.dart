import 'package:dartz/dartz.dart';
import 'package:ditonton/common/utils.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';
import 'package:ditonton/domain/usecases/tv_use_cases.dart';
import 'package:ditonton/presentation/pages/watchlist_tv_page.dart';
import 'package:ditonton/presentation/provider/tv_watchlist_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakeGetTvWatchlist extends GetTvWatchlist {
  FakeGetTvWatchlist() : super(_UnusedTvRepository());

  int callCount = 0;

  @override
  Future<Either<Failure, List<TvSeries>>> execute() async {
    callCount++;
    return const Right(<TvSeries>[]);
  }
}

class _UnusedTvRepository implements TvRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('refreshes the TV watchlist after returning from detail', (
    tester,
  ) async {
    final getWatchlist = FakeGetTvWatchlist();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TvWatchlistNotifier(getWatchlist),
        child: MaterialApp(
          navigatorObservers: [routeObserver],
          home: const WatchlistTvPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(getWatchlist.callCount, 1);

    final context = tester.element(find.byType(WatchlistTvPage));
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const Scaffold()));
    await tester.pumpAndSettle();
    Navigator.of(context).pop();
    await tester.pumpAndSettle();

    expect(getWatchlist.callCount, 2);
  });
}
