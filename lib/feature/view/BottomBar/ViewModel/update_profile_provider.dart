import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sport_finding/Data/Repositories/UpdateProfileRepo/update_profile_repo.dart';
import 'package:sport_finding/Data/model/UpdateProfile/update_profile_model.dart';
import 'package:sport_finding/core/Network/profile_service.dart';

class EditProfileScreenViewModel extends ChangeNotifier {
  EditProfileScreenViewModel(this._repo);

  final UpdateProfileRepo _repo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UpdateProfileModel? _updatedProfile;
  UpdateProfileModel? get updatedProfile => _updatedProfile;

  File? _pickedImageFile;
  List<int>? _pickedImageBytes;
  String? _pickedImageFileName;

  File? get pickedImageFile => _pickedImageFile;
  List<int>? get pickedImageBytes => _pickedImageBytes;

  void setPickedImage({File? file, List<int>? bytes, String? fileName}) {
    _pickedImageFile = file;
    _pickedImageBytes = bytes;
    _pickedImageFileName = fileName;

    debugPrint(
      '🖼️ [EditProfileScreenViewModel] Image picked:'
      '\n   mobile file : ${file?.path}'
      '\n   web fileName: $fileName'
      '\n   web bytes   : ${bytes?.length} bytes',
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
      '🚀 [EditProfileScreenViewModel] update:'
      '\n   fullName  : $fullName'
      '\n   bio       : $bio'
      '\n   sport     : $sport'
      '\n   skillLevel: $skillLevel'
      '\n   hasImage  : ${_pickedImageFile != null || _pickedImageBytes != null}',
    );

    try {
      final result = await _repo.updateMyProfile(
        fullName: fullName,
        bio: bio,
        sportUi: sport,
        skillUi: skillLevel,
        imageFile: _pickedImageFile,
        imageBytes: _pickedImageBytes,
        imageFileName: _pickedImageFileName,
      );

      _updatedProfile = result;
      _pickedImageFile = null;
      _pickedImageBytes = null;
      _pickedImageFileName = null;

      try {
        await ProfileService().fetchMyProfile(forceRefresh: true);
      } catch (_) {}

      ProfileService().applySuccessfulProfileUpdate(result);

      debugPrint(
        '✅ [EditProfileScreenViewModel] Profile updated: ${result.fullName}',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      debugPrint('❌ [EditProfileScreenViewModel] Failed: $e');
      notifyListeners();
      return false;
    }
  }
}
