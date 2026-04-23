/// Configuration for [GoogleSignIn] on Android (Credential Manager / Sign in with Google).
///
/// **You must set a Web application OAuth 2.0 client ID** — not the Android client and
/// not the iOS client. `GetSignInWithGoogleOption` rejects the wrong client type and
/// surfaces errors like `[16] Account reauth failed` / `GoogleSignInExceptionCode.canceled`.
///
/// Where to find it:
/// - **Firebase:** Build → Authentication → Sign-in method → Google → *Web client ID*
///   (under Web SDK configuration), or
/// - **Google Cloud:** APIs & Services → Credentials → OAuth 2.0 Client IDs → *Web client*
///
/// Alternatively, add a **Web app** to the Firebase project, re-download
/// `google-services.json`, and rebuild; the Gradle plugin can then provide
/// `default_web_client_id` and you may leave [kGoogleOauth2WebClientId] empty if
/// that string resource is present.
///
/// Also register your **debug SHA-1** (and SHA-256) for `com.sportfinding.app`
/// under Project settings → Your apps → Android, or OAuth will fail.
///
/// From Firebase → Authentication → Google → Web client ID (Web SDK configuration).
const String kGoogleOauth2WebClientId =
    '147032468406-cj792ti9lqaldlonhl93p04vuui6rufv.apps.googleusercontent.com';
