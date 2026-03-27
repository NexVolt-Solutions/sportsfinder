import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Auth/Signup/SignUpViewModel/sign_up_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/gmail_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/social_button_widget.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpScreenViewModel>(
      builder: (context, model, child) => Scaffold(
        body: MainFrame(
          child: Form(
            key: model.formKey,
            child: ListView(
              padding: context.padSym(h: 20),
              children: [
                AppBarWidget(title: AppText.sportFinding),
                NormalText(
                  titleText: AppText.welcomeBack,
                  titleStyle: context.appText.text18W600,
                  subText: AppText.loginToContinue,
                  subStyle: context.appText.text16W400,
                  subColor: context.appColors.greylight,
                ),
                SizedBox(height: context.h(20)),
                TextFormFieldWidget(
                  label: AppText.email,
                  hintText: AppText.emailHit,
                  controller: model.emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppText.emailValidation;
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.h(20)),
                TextFormFieldWidget(
                  label: AppText.createPassword,
                  hintText: AppText.passwordHit,
                  controller: model.passwordController,
                  validator: (value) => value == null || value.isEmpty
                      ? AppText.passwordValidation
                      : null,
                ),
                SizedBox(height: context.h(12)),
                NormalText(
                  titleText: AppText.forgotPassword,
                  titleStyle: context.appText.text14W400,
                  titleColor: context.appColors.greylight,
                ),
                SizedBox(height: context.h(12)),
                CustomButton(
                  onTap: () => Navigator.pushNamed(
                    context,
                    RoutesName.OtpVerificationScreen,
                  ),
                  text: AppText.signIn,
                  color: context.appColors.primary,
                ),
                SizedBox(height: context.h(12)),
                SocialButtonWidget(
                  imagePath: AppAssets.gmailIcon,
                  text: AppText.continueWithGoogle,
                  onTap: () {
                    print("Google Login");
                  },
                ),
                SizedBox(height: context.h(12)),
                AuthFooterText(
                  normalText: AppText.alreadyHaveAnAccountSignIn,
                  actionText: AppText.signUp,
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.SignInScreen);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
