import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view_model/sign_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/gmail_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/splash_background.dart';
import 'package:sport_finding/feature/widget/terms_check_box.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignScreenViewModel(),
      child: Consumer<SignScreenViewModel>(
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
                    AppBarWidget(
                      onTap: () => Navigator.pop(context),
                      title: AppText.appName,
                    ),
                    SizedBox(height: context.h(20)),
                    NormalText(
                      titleText: AppText.createAccount,
                      titleSize: context.sp(20),
                      titleColor: AppColors.blackcolor,
                      titleWeight: FontWeight.w600,
                      subText: AppText.joinSportFinding,
                      subColor: AppColors.greylight60,
                      subSize: context.sp(16),
                      subWeight: FontWeight.w500,
                    ),
                    SizedBox(height: context.h(20)),
                    TextFormFieldWidget(
                      label: AppText.fullName,
                      hintText: "Enter your name",
                      controller: model.fullNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name required";
                        }
                        return null;
                      },
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
                      label: AppText.phoneNumber,
                      hintText: AppText.phoneHint,
                      controller: model.phoneNumberController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone number required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: context.h(20)),
                    TextFormFieldWidget(
                      label: AppText.createPassword,
                      hintText: "Enter your password",
                      controller: model.emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: context.h(20)),
                    TextFormFieldWidget(
                      label: AppText.confirmPassword,
                      hintText: "Enter your confirm password",
                      controller: model.confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm Password required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: context.h(10)),
                    TermsCheckbox(),
                    SizedBox(height: context.h(10)),
                    CustomButton(
                      isEnabled: true,
                      text: AppText.signIn,
                      color: AppColors.bluecolor,
                    ),
                    SizedBox(height: context.h(12)),
                    GmailButton(),
                    SizedBox(height: context.h(12)),

                    AuthFooterText(
                      normalText: "Don’t have an account? ",
                      actionText: "Sign In",
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.LoginScreen);
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
