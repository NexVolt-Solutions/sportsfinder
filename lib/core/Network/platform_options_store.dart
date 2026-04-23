import 'package:sport_finding/Data/model/Option/options_model.dart';
import 'package:sport_finding/Data/Repositories/options_repository.dart';

/// In-memory cache for [GET /api/v1/options/] so onboarding, match forms,
/// and filters share one request per session.
class PlatformOptionsStore {
  PlatformOptionsStore._();
  static final PlatformOptionsStore instance = PlatformOptionsStore._();

  final OptionsRepository _repo = OptionsRepository();

  OptionsModel? _cached;
  Future<OptionsModel>? _inFlight;
  String? _lastError;

  String? get lastError => _lastError;

  void clear() {
    _cached = null;
    _inFlight = null;
    _lastError = null;
  }

  /// Returns cached options, or a single in-flight or new network request.
  Future<OptionsModel> load() async {
    if (_cached != null) {
      return _cached!;
    }
    if (_inFlight != null) {
      return _inFlight!;
    }
    _inFlight = _fetch();
    try {
      return await _inFlight!;
    } finally {
      _inFlight = null;
    }
  }

  Future<OptionsModel> _fetch() async {
    _lastError = null;
    try {
      final model = await _repo.getOptions();
      _cached = model;
      return model;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    }
  }
}
