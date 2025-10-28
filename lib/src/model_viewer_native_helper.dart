// Native helper: download the remote model and serve it via a tiny
// local HTTP server. Returns an http://127.0.0.1:<port>/filename URL that
// can be loaded by model_viewer in a WebView without CORS or attachment issues.
import 'dart:io';
import 'dart:async';

// Keep a reference to running servers to prevent them being GC'd and to
// allow multiple requests for the same URL to reuse the same server.
final Map<String, HttpServer> _runningServers = {};

Future<String?> downloadModelToTemp(String url) async {
  try {
    // If we already started a server for this URL, return its address.
    if (_runningServers.containsKey(url)) {
      final s = _runningServers[url]!;
      final port = s.port;
      final filename = Uri.parse(url).pathSegments.isNotEmpty
          ? Uri.parse(url).pathSegments.last
          : 'model.glb';
      return 'http://127.0.0.1:$port/$filename';
    }

    final uri = Uri.parse(url);
    final client = HttpClient();
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode} while downloading model');
    }

    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
    }

    final filename = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'model.glb';

    // Start local server on ephemeral port bound to loopback
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.autoCompress = false;
    final port = server.port;

    server.listen((HttpRequest req) async {
      try {
        // Always add CORS headers on responses so cross-origin fetches succeed.
        req.response.headers.set('Access-Control-Allow-Origin', '*');
        req.response.headers.set(
          'Access-Control-Allow-Methods',
          'GET, OPTIONS, HEAD',
        );
        req.response.headers.set(
          'Access-Control-Allow-Headers',
          'Origin, X-Requested-With, Content-Type, Accept',
        );

        // Respond to preflight OPTIONS requests immediately
        if (req.method == 'OPTIONS') {
          req.response.statusCode = HttpStatus.noContent;
          await req.response.close();
          return;
        }

        // Support HEAD requests (respond with headers only)
        final requestedPath = req.uri.path;
        // ignore: avoid_print
        print(
          'Local model server received request for: $requestedPath (method=${req.method})',
        );

        if (req.method == 'HEAD') {
          req.response.headers.contentType = ContentType(
            'model',
            'gltf-binary',
          );
          req.response.headers.set(
            'Content-Disposition',
            'inline; filename="$filename"',
          );
          req.response.statusCode = HttpStatus.ok;
          await req.response.close();
          return;
        }

        // Serve the model bytes for any GET path. This makes the server robust
        // to plugin proxying or mismatched request paths/ports that previously
        // caused 404 responses.
        req.response.headers.contentType = ContentType('model', 'gltf-binary');
        req.response.headers.set(
          'Content-Disposition',
          'inline; filename="$filename"',
        );
        req.response.add(bytes);
        await req.response.close();
      } catch (e) {
        try {
          req.response.statusCode = HttpStatus.internalServerError;
          await req.response.close();
        } catch (_) {}
      }
    });

    _runningServers[url] = server;
    final localUrl = 'http://127.0.0.1:$port/$filename';
    // ignore: avoid_print
    print('Started local model server at $localUrl');
    return localUrl;
  } catch (e, st) {
    // ignore: avoid_print
    print('downloadModelToTemp failed: $e\n$st');
    throw Exception('downloadModelToTemp failed: $e');
  }
}
