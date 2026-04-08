import 'package:flutter/material.dart';

class ForgotPasswordScreenViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
}
