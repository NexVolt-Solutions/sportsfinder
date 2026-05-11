/// True for errors that often clear when the radio / DNS comes up seconds later.
bool isTransientNetworkError(Object e) {
  final s = e.toString().toLowerCase();
  return s.contains('socketexception') ||
      s.contains('failed host lookup') ||
      s.contains('no address associated with hostname') ||
      s.contains('network is unreachable') ||
      s.contains('connection refused') ||
      s.contains('connection reset') ||
      s.contains('broken pipe') ||
      s.contains('timed out') ||
      s.contains('connection timed out') ||
      s.contains('errno = 7') ||
      s.contains('errno = 101') ||
      s.contains('errno = 110');
}
