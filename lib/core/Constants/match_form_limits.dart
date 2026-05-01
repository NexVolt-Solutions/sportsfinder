class MatchFormLimits {
  MatchFormLimits._();

  static const int maxPlayersMin = 3;
  static const int maxPlayersMax = 30;

  static int clampMaxPlayers(int n) => n.clamp(maxPlayersMin, maxPlayersMax);
}
