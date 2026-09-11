import 'package:ditonton/data/network/ssl_pinning_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('creates a client from the bundled TMDB certificate', () async {
    final client = await SslPinningClient.create();
    expect(client, isNotNull);
    client.close();
  });
}
