import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'src/model_viewer_native_helper.dart'
    if (dart.library.html) 'src/model_viewer_web_helper.dart'
    as model_helper;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

// Optional WebView fallback. To enable this, add `webview_flutter` to your
// pubspec.yaml:
//   flutter pub add webview_flutter
// Then rebuild the app. If you don't want to add the dependency, the code
// will still compile on web but the native WebView fallback requires the
// package at build time.
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

class ModelViewerScreen extends StatelessWidget {
  final String modelUrl;
  final String title;

  const ModelViewerScreen({
    super.key,
    required this.modelUrl,
    this.title = '3D Model',
  });

  bool _looksLikeHttp(String url) =>
      url.startsWith('http://') || url.startsWith('https://');

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    if (!_looksLikeHttp(modelUrl)) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Model URL is not an HTTP(S) URL and cannot be displayed here.\n\nPlease ensure the model has a public HTTPS download URL (Firebase Storage download URL).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // If this is Android and the URL is cleartext (http://) the platform
    // WebView/embedded viewer may refuse to load it by default (ERR_CLEARTEXT_NOT_PERMITTED).
    // In that case show actionable instructions and offer to open externally or copy the URL.
    if (_isAndroid && modelUrl.startsWith('http://')) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Android blocked loading a cleartext (HTTP) URL.\n\nThis is the cause of ERR_CLEARTEXT_NOT_PERMITTED when trying to load http://127.0.0.1 or other http:// addresses from inside the app.',
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              SelectableText('URL: ' + modelUrl),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open in external browser'),
                onPressed: () async {
                  final uri = Uri.parse(modelUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy URL'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: modelUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('URL copied to clipboard')),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'To allow cleartext traffic while debugging, add one of the following to your Android app:',
              ),
              const SizedBox(height: 8),
              const Text(
                '1) Quick (debug): set android:usesCleartextTraffic="true" on the <application> tag in android/app/src/main/AndroidManifest.xml',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '2) Recommended: create res/xml/network_security_config.xml and reference it from the <application> with android:networkSecurityConfig="@xml/network_security_config". Example config allows cleartext only for localhost/127.0.0.1.',
              ),
              const SizedBox(height: 12),
              SelectableText('''
<network-security-config>
  <domain-config cleartextTrafficPermitted="true">
    <domain>127.0.0.1</domain>
    <domain>localhost</domain>
  </domain-config>
</network-security-config>
'''),
            ],
          ),
        ),
      );
    }

    // Otherwise, attempt to render the model normally. On native platforms
    // we attempt to download the model to a temporary local file and load
    // that file (file:///) which circumvents CORS and Content-Disposition
    // download behavior. On web we just use the network URL.
    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: FutureBuilder<String?>(
          future: model_helper.downloadModelToTemp(modelUrl),
          builder: (context, snapshot) {
            Widget viewerChild;
            if (snapshot.connectionState == ConnectionState.waiting) {
              viewerChild = const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Show the error so the developer can copy/paste logs
              final err = snapshot.error.toString();
              viewerChild = Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text('Failed to download model:'),
                    const SizedBox(height: 8),
                    SelectableText(err),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: err));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error copied to clipboard'),
                          ),
                        );
                      },
                      child: const Text('Copy error'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              // Use local HTTP URL when available. Prefer a native WebView
              // wrapper (loads a small HTML page with <model-viewer>) because
              // the model_viewer_plus plugin may proxy requests and cause
              // mismatched ports. This WebView approach loads our local URL
              // directly.
              final localUrl = snapshot.data!;
              final html =
                  '''
<!doctype html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"></script>
    <style>html,body,model-viewer{width:100%;height:100%;margin:0;padding:0}</style>
  </head>
  <body>
    <model-viewer src="$localUrl" alt="$title" camera-controls auto-rotate crossorigin="anonymous"></model-viewer>
  </body>
</html>
''';

              final dataUrl = Uri.dataFromString(
                html,
                mimeType: 'text/html',
                encoding: utf8,
              ).toString();

              final controller = WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(dataUrl));

              viewerChild = WebViewWidget(controller: controller);
            } else {
              // Fallback to network URL if download failed
              viewerChild = ModelViewer(
                src: modelUrl,
                alt: title,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: Colors.white,
                ar: false,
              );
            }

            final launchTarget = (snapshot.hasData && snapshot.data != null)
                ? snapshot.data!
                : modelUrl;

            return Column(
              children: [
                Expanded(child: viewerChild),
                if (snapshot.hasData && snapshot.data != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Local URL (served by app):',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SelectableText(snapshot.data!),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy URL'),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: launchTarget),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('URL copied to clipboard'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open externally'),
                        onPressed: () async {
                          final uri = Uri.parse(launchTarget);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open URL externally'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Web: just render with network URL
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ModelViewer(
                src: modelUrl,
                alt: title,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: Colors.white,
                ar: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy URL'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: modelUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('URL copied to clipboard'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open externally'),
                  onPressed: () async {
                    final uri = Uri.parse(modelUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open URL externally'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
