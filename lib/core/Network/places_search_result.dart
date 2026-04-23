/// Outcome of a Google Places Autocomplete (or local config) call.
class PlacesSearchResult {
  const PlacesSearchResult({
    this.suggestions = const <String>[],
    this.userMessage,
    this.missingApiKey = false,
  });

  final List<String> suggestions;
  /// Shown when [suggestions] is empty or the request failed; null = no error (e.g. no matches).
  final String? userMessage;
  final bool missingApiKey;

  bool get hasFailureMessage =>
      (userMessage != null && userMessage!.trim().isNotEmpty) || missingApiKey;
}
