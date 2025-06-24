import 'dart:convert';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class DigestAuthClient {
  final String username;
  final String password;

  DigestAuthClient({required this.username, required this.password});

  Future<http.Response> get(Uri uri) async {
    final firstResponse = await http.get(uri);

    if (firstResponse.statusCode != 401 ||
        !firstResponse.headers.containsKey('www-authenticate')) {
      return firstResponse;
    }

    final authHeader = firstResponse.headers['www-authenticate']!;
    final digest = _parseDigestHeader(authHeader);

    final uriPath = uri.path + (uri.hasQuery ? '?${uri.query}' : '');
    final ha1 = md5
        .convert(utf8.encode('$username:${digest['realm']}:$password'))
        .toString();
    final ha2 = md5.convert(utf8.encode('GET:$uriPath')).toString();
    final responseHash =
        md5.convert(utf8.encode('$ha1:${digest['nonce']}:$ha2')).toString();

    final auth = 'Digest username="$username", realm="${digest['realm']}", '
        'nonce="${digest['nonce']}", uri="$uriPath", '
        'response="$responseHash"';

    return http.get(uri, headers: {'Authorization': auth});
  }

  Map<String, String> _parseDigestHeader(String header) {
    final parts = header.replaceFirst('Digest ', '').split(',');
    final Map<String, String> map = {};
    for (var part in parts) {
      final kv = part.trim().split('=');
      if (kv.length == 2) {
        map[kv[0]] = kv[1].replaceAll('"', '');
      }
    }
    return map;
  }
}
