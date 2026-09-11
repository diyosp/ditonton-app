import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class SslPinningClient {
  const SslPinningClient._();

  static Future<http.Client> create() async {
    final certificate = await rootBundle.load('assets/certificates/tmdb.pem');
    final context = SecurityContext(withTrustedRoots: false)
      ..setTrustedCertificatesBytes(certificate.buffer.asUint8List());
    final client = HttpClient(context: context)
      ..badCertificateCallback = (_, _, _) => false;
    return IOClient(client);
  }
}
