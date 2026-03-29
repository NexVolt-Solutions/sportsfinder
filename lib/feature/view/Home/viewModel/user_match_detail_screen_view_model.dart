import 'package:flutter/foundation.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';

class UserMatchDetailScreenViewModel extends ChangeNotifier {
  DiscoveryMatch? _match;
  DiscoveryMatch? get match => _match;

  void setMatch(DiscoveryMatch? value) {
    if (_match?.id == value?.id) return;
    _match = value;
    notifyListeners();
  }
}
