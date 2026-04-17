import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sport_finding/Data/Repositories/UpdateProfileRepo/update_profile_repo.dart';
import 'package:sport_finding/Data/model/UpdateProfile/update_profile_model.dart';

class EditProfileScreenViewModel extends ChangeNotifier {
  final UpdateProfileRepo _repo = UpdateProfileRepo();
  EditProfileScreenViewModel(UpdateProfileRepo repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UpdateProfileModel? _updatedProfile;
  UpdateProfileModel? get updatedProfile => _updatedProfile;

  // ── Holds the picked image before saving ──────────────────────────────
  File? _pickedImageFile; // mobile
  List<int>? _pickedImageBytes; // web
  String? _pickedImageFileName; // web

  File? get pickedImageFile => _pickedImageFile;
  List<int>? get pickedImageBytes => _pickedImageBytes;

  /// Call this when the user picks a photo (before saving)
  void setPickedImage({File? file, List<int>? bytes, String? fileName}) {
    _pickedImageFile = file;
    _pickedImageBytes = bytes;
    _pickedImageFileName = fileName;

    debugPrint(
      "🖼️ [UpdateProfileProvider] Image picked:"
      "\n   mobile file : ${file?.path}"
      "\n   web fileName: $fileName"
      "\n   web bytes   : ${bytes?.length} bytes",
    );

    notifyListeners();
  }

  Future<bool> updateProfile({
    required String fullName,
    required String bio,
    String? sport,
    String? skillLevel,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint(
      "🚀 [UpdateProfileProvider] Starting update:"
      "\n   fullName  : $fullName"
      "\n   bio       : $bio"
      "\n   sport     : $sport"
      "\n   skillLevel: $skillLevel"
      "\n   hasImage  : ${_pickedImageFile != null || _pickedImageBytes != null}",
    );

    try {
      final result = await _repo.updateMyProfile(
        fullName: fullName,
        bio: bio,
        sport: sport,
        skillLevel: skillLevel,
        imageFile: _pickedImageFile,
        imageBytes: _pickedImageBytes,
        imageFileName: _pickedImageFileName,
      );

      _updatedProfile = result;
      _isLoading = false;

      // Clear picked image after successful upload
      _pickedImageFile = null;
      _pickedImageBytes = null;
      _pickedImageFileName = null;

      debugPrint(
        "✅ [UpdateProfileProvider] Profile updated!"
        "\n   ➤ fullName  : ${result.fullName}"
        "\n   ➤ bio       : ${result.bio}"
        "\n   ➤ avatarUrl : ${result.avatarUrl}"
        "\n   ➤ sports    : ${result.sports.map((s) => '${s.sport}(${s.skillLevel})').join(', ')}",
      );

      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();

      debugPrint("❌ [UpdateProfileProvider] Failed: $e");

      notifyListeners();
      return false;
    }
  }
}
