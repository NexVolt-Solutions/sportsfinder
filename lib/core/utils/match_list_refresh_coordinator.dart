/// Lets screens that mutate match state (e.g. host completes match) trigger a
/// refetch on mounted [AllUpcommingMatchesViewModel] instances so list UIs stay
/// in sync with the server.
class MatchListRefreshCoordinator {
  MatchListRefreshCoordinator._();

  static final List<void Function()> _listeners = <void Function()>[];

  static void register(void Function() onRefresh) {
    if (_listeners.contains(onRefresh)) return;
    _listeners.add(onRefresh);
  }

  static void unregister(void Function() onRefresh) {
    _listeners.remove(onRefresh);
  }

  static void requestRefresh() {
    for (final fn in List<void Function()>.from(_listeners)) {
      try {
        fn();
      } catch (_) {
        // Stale callback or disposed VM; ignore.
      }
    }
  }
}
