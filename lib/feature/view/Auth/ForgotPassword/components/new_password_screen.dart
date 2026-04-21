import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/ViewModel/new_password_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool _didBindResetToken = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBindResetToken) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.trim().isNotEmpty) {
      context.read<NewPasswordScreenViewModel>().setResetToken(args.trim());
      _didBindResetToken = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewPasswordScreenViewModel>(
      builder: (context, model, _) {
        return Scaffold(
          body: MainFrame(
            child: Form(
              key: model.formKey,
              child: ListView(
                padding: context.padSym(h: 20),
                children: [
                  AppBarWidget(
                    onTapFirst: () => Navigator.pop(context),
                    title: AppText.sportFinding,
                  ),
                  SizedBox(height: context.h(242)),
                  NormalText(
                    maxLines: 3,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: AppText.resetPasswordTitle,
                    subText: AppText.resetPasswordSubText,
                    sizeBoxheight: context.h(4),
                    subAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(20)),
                  TextFormFieldWidget(
                    label: AppText.newPassword,
                    hintText: AppText.passwordNewHit,
                    controller: model.passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppText.passwordValidation;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.h(16)),
                  TextFormFieldWidget(
                    label: AppText.confirmPassword,
                    hintText: AppText.confirmPasswordHint,
                    controller: model.confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppText.confirmPasswordValidation;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.h(20)),
                  CustomButton(
                    onTap: model.isLoading
                        ? null
                        : () async {
                            final errorMessage = await model.resetPassword();

                            if (!context.mounted) return;

                            if (errorMessage == null) {
                              AppSnackBar.show(
                                'Password reset successfully! Please log in with your new password.',
                              );

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                RoutesName.LoginScreen,
                                (route) => false,
                              );
                            } else {
                              AppSnackBar.show(errorMessage);
                            }
                          },
                    text: model.isLoading
                        ? "Please wait..."
                        : AppText.resetPasswordButton,
                    color: context.appColors.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
