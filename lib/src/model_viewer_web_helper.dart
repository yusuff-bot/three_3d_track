// Web helper: no-op, browsers cannot write local files from web builds.
Future<String?> downloadModelToTemp(String url) async {
  // On web we can't create a local file to serve, so return the original
  // network URL so the caller can use it directly.
  return url;
}
