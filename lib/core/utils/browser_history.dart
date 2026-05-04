import 'package:flutter/foundation.dart' show kIsWeb;

import 'browser_history_impl_stub.dart'
    if (dart.library.html) 'browser_history_impl_html.dart';

/// After OAuth, replace `/auth-callback#tokens...` with a clean path (web only).
void replaceBrowserPathAfterOAuth(String path) {
  if (!kIsWeb) return;
  if (path.isEmpty) return;
  implReplaceBrowserPath(path);
}
