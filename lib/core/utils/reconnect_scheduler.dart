import 'dart:async';

typedef DelayForAttempt = Duration Function(int attempt);

class ReconnectScheduler {
  ReconnectScheduler({required DelayForAttempt delayForAttempt})
    : _delayForAttempt = delayForAttempt;

  final DelayForAttempt _delayForAttempt;
  Timer? _timer;
  int _attempt = 0;
  bool _isScheduled = false;

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _isScheduled = false;
  }

  void resetAttempts() {
    _attempt = 0;
  }

  void schedule({
    required bool Function() canSchedule,
    required void Function() onFire,
    /// When set (e.g. shared network cooldown), used instead of the normal
    /// backoff curve and does not advance [_attempt].
    Duration? overrideDelay,
  }) {
    if (_isScheduled || !canSchedule()) return;
    _isScheduled = true;
    late final Duration delay;
    if (overrideDelay != null) {
      delay = overrideDelay;
    } else {
      _attempt += 1;
      delay = _delayForAttempt(_attempt);
    }
    _timer = Timer(delay, () {
      _isScheduled = false;
      if (!canSchedule()) return;
      onFire();
    });
  }
}
