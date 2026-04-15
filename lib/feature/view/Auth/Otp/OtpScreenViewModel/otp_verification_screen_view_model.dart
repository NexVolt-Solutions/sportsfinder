import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/otp_verification_repository.dart';

class OtpVerificationScreenViewModel extends ChangeNotifier {
  final OtpVerificationRepository repository;

  OtpVerificationScreenViewModel({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  Future<String?> verfyOtp({required String email, required String otp}) async {
    try {
      _isLoading = true;
      _errorMessage = "";
      notifyListeners();
      await repository.verifyOtp(email: email, otp: otp);
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Resend OTP
  Future<String?> resendOtp({required String email}) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await repository.resendOtp(email: email);

      return null; // ✅ success
    } catch (e) {
      _errorMessage = e.toString();
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
  // Iams0rry11

