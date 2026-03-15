import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view_model/login_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/gmail_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/splash_background.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginScreenViewModel(),
      child: Consumer<LoginScreenViewModel>(
        builder: (context, model, child) => Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SplashBackground(
              child: Form(
                key: model.formKey,
                child: ListView(
                  padding: context.padSym(h: 20),
                  children: [
                    SizedBox(height: context.h(22)),
                    AppBarWidget(title: AppText.appName),
                    SizedBox(height: context.h(20)),
                    NormalText(
                      titleText: AppText.welcomeBack,
                      titleSize: context.sp(20),
                      titleColor: AppColors.blackcolor,
                      titleWeight: FontWeight.w600,
                      subText: AppText.loginToContinue,
                      subColor: AppColors.greylight60,
                      subSize: context.sp(16),
                      subWeight: FontWeight.w500,
                    ),
                    SizedBox(height: context.h(20)),
                    TextFormFieldWidget(
                      label: AppText.email,
                      hintText: AppText.emailHint,
                      controller: model.emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: context.h(20)),
                    TextFormFieldWidget(
                      label: AppText.createPassword,
                      hintText: AppText.passwordHint,
                      controller: model.emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: context.h(12)),
                    NormalText(
                      titleText: AppText.forgotPassword,
                      titleColor: AppColors.greylight60,
                      titleSize: context.text(14),
                      titleWeight: FontWeight.w400,
                    ),
                    SizedBox(height: context.h(12)),
                    CustomButton(
                      isEnabled: true,
                      onTap: () => Navigator.pushNamed(
                        context,
                        RoutesName.SkillLevelScreen,
                      ),
                      text: AppText.signIn,
                      color: AppColors.bluecolor,
                    ),
                    SizedBox(height: context.h(12)),
                    GmailButton(),
                    SizedBox(height: context.h(12)),
                    AuthFooterText(
                      normalText: AppText.alreadyHaveAccount,
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
        ),
      ),
    );
  }
}
