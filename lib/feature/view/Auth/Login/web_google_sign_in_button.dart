import 'package:flutter/widgets.dart';

import 'web_google_sign_in_button_stub.dart'
    if (dart.library.html) 'web_google_sign_in_button_web.dart';

/// Returns a web-only Google Sign-In button widget.
///
/// On non-web platforms this returns an empty widget so the mobile build
/// never compiles/transitively pulls in `dart:ui_web`.
Widget buildWebGoogleSignInButton() => buildWebGoogleSignInButtonImpl();

