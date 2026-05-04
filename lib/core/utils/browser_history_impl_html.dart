// Web-only. Clears OAuth hash/query from the visible URL after in-app navigation.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// Updates the address bar without navigation (hides OAuth tokens in URL).
void implReplaceBrowserPath(String path) {
  html.window.history.replaceState(null, '', path);
}
