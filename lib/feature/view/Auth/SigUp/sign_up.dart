import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/Auth/SigUp/signup_viewmodel.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/profile_avatar_picker.dart';
import 'package:sport_finding/feature/widget/social_button_widget.dart';
import 'package:sport_finding/feature/widget/terms_check_box.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';
import 'package:sport_finding/feature/webwidget/web_auth_shell.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  Future<void> _onPickAvatar(BuildContext context) async {
    final vm = context.read<SignUpViewModel>();
    final message = await vm.pickProfileImageFromGallery();
    if (!context.mounted || message == null) return;
    AppSnackBar.show(message);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpViewModel>(
      builder: (context, model, _) {
        final form = Form(
          key: model.formKey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              if (!kIsWeb)
                AppBarWidget(
                  onTapFirst: () => Navigator.pop(context),
                  title: AppText.sportFinding,
                ),
              NormalText(
                titleText: kIsWeb
                    ? 'Sign Up to your Account'
                    : AppText.createAccount,
                subText: kIsWeb
                    ? 'Please enter your details to get started'
                    : AppText.joinSportFindingToday,
                crossAxisAlignment: kIsWeb
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                subAlign: kIsWeb ? TextAlign.center : TextAlign.start,
              ),
              SizedBox(height: context.h(16)),
              if (!kIsWeb) ...[
                Center(
                  child: Selector<SignUpViewModel, XFile?>(
                    selector: (_, m) => m.pickedXFile,
                    builder: (context, xFile, _) {
                      return ProfileAvatarPicker(
                        radius: context.radius(50),
                        xFile: xFile,
                        onPickPressed: () => _onPickAvatar(context),
                      );
                    },
                  ),
                ),
                SizedBox(height: context.h(12)),
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  titleText: AppText.uploadYourPicture,
                  titleStyle: context.appText.text18W600,
                  titleColor: context.appColors.primary,
                ),
                SizedBox(height: context.h(16)),
              ],
              TextFormFieldWidget(
                label: AppText.fullName,
                hintText: AppText.fullNameHit,
                controller: model.fullNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppText.fullNameValidation;
                  }
                  return null;
                },
              ),
              SizedBox(height: context.h(16)),
              TextFormFieldWidget(
                label: AppText.email,
                hintText: AppText.email,
                controller: model.emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppText.emailValidation;
                  }
                  return null;
                },
              ),
              SizedBox(height: context.h(16)),
              TextFormFieldWidget(
                label: AppText.password,
                hintText: AppText.passwordHit,
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
                hintText: AppText.passwordHit,
                controller: model.confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppText.confirmPasswordValidation;
                  }
                  return null;
                },
              ),
              SizedBox(height: context.h(8)),
              const TermsCheckbox(),
              SizedBox(height: context.h(8)),
              CustomButton(
                onTap: () async {
                  final vm = context.read<SignUpViewModel>();
                  final error = await vm.registerUser();
                  if (!context.mounted) return;
                  if (error == null) {
                    AppSnackBar.show('Registration Successful');
                    Navigator.pushNamed(
                      context,
                      RoutesName.otpVerificationScreen,
                      arguments: vm.emailController.text.trim(),
                    );
                  } else {
                    AppSnackBar.show(error);
                  }
                },
                text: AppText.signUp,
                isLoading: model.isLoading,
                color: context.appColors.primary,
              ),
              SizedBox(height: context.h(12)),
              SocialButtonWidget(
                imagePath: AppAssets.gmailIcon,
                text: AppText.continueWithGoogle,
                isLoading: model.isGoogleLoading,
                onTap: () async {
                  final result = await model.loginWithGoogle();
                  if (!context.mounted || result == null) return;
                  if (result == "SKILL_LEVEL") {
                    Navigator.pushReplacementNamed(
                      context,
                      RoutesName.skillLevelScreen,
                    );
                  } else if (result == "HOME") {
                    Navigator.pushReplacementNamed(
                      context,
                      RoutesName.bottomBarScreen,
                      arguments: BottomBarScreenViewModel.homeIndex,
                    );
                  } else {
                    AppSnackBar.show(
                      result,
                      behavior: SnackBarBehavior.floating,
                    );
                  }
                },
              ),
              SizedBox(height: context.h(12)),
              Center(
                child: AuthFooterText(
                  normalText: kIsWeb
                      ? 'Already have account yet? '
                      : AppText.alreadyHaveAnAccountSignIn,
                  actionText: AppText.signIn,
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.LoginScreen);
                  },
                ),
              ),
            ],
          ),
        );

        if (kIsWeb) {
          return WebAuthSplitShell(child: form);
        }

        return Scaffold(
          body: MainFrame(
            child: Padding(padding: context.padSym(h: 20), child: form),
          ),
        );
      },
    );
  }
}
