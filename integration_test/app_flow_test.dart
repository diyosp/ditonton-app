import 'package:ditonton/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('completes the main Movie and TV Series flow', (tester) async {
    app.main();
    await _waitFor(tester, find.text('Ditonton'));

    await tester.tap(find.byKey(const Key('movie_search_action')));
    await _waitFor(tester, find.byKey(const Key('movie_search_field')));
    await tester.enterText(
      find.byKey(const Key('movie_search_field')),
      'Fight Club',
    );
    await _waitFor(tester, find.text('Fight Club'));

    await tester.pageBack();
    await _waitFor(tester, find.text('Ditonton'));
    await tester.tap(find.byTooltip('Open navigation menu'));
    await _waitFor(tester, find.text('Watchlist'));
    await tester.tap(find.text('Watchlist'));
    await _waitFor(tester, find.widgetWithText(AppBar, 'Watchlist'));

    await tester.pageBack();
    await _waitFor(tester, find.text('TV Series'));
    await tester.tap(find.text('TV Series'));
    await _waitFor(tester, find.byKey(const Key('tv_search_action')));

    await tester.tap(find.byKey(const Key('tv_search_action')));
    await _waitFor(tester, find.byKey(const Key('tv_search_field')));
    await tester.enterText(
      find.byKey(const Key('tv_search_field')),
      'Demon Slayer',
    );
    await _waitFor(tester, find.textContaining('Demon Slayer'));

    await tester.pageBack();
    await _waitFor(tester, find.byKey(const Key('tv_watchlist_action')));
    await tester.tap(find.byKey(const Key('tv_watchlist_action')));
    await _waitFor(tester, find.text('TV Series Watchlist'));
  });
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  int attempts = 30,
}) async {
  for (var attempt = 0; attempt < attempts; attempt++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  expect(finder, findsWidgets);
}
