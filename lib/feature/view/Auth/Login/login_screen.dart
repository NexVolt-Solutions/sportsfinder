import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view_model/login_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/gmail_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginScreenViewModel>(
      builder: (context, model, child) => MainFrame(
        child: Form(
          key: model.formKey,
          child: ListView(
            padding: context.padSym(h: 20),
            children: [
              AppBarWidget(
                title: AppText.appName,
                onLeadingTap: () => Navigator.pop(context),
              ),
              NormalText(
                titleText: AppText.welcomeBack,
                titleStyle: context.appText.text18W600,
                subText: AppText.loginToContinue,
                subStyle: context.appText.text16W400,
                subColor: context.appColors.greyLight60,
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
                controller: model.passwordController,
                validator: (value) =>
                    value == null || value.isEmpty ? "Password required" : null,
              ),
              SizedBox(height: context.h(12)),
              NormalText(
                titleText: AppText.forgotPassword,
                titleStyle: context.appText.text14W400,
                titleColor: context.appColors.greyLight60,
              ),
              SizedBox(height: context.h(12)),
              CustomButton(
                onTap: () =>
                    Navigator.pushNamed(context, RoutesName.SkillLevelScreen),
                text: AppText.signIn,
                color: context.appColors.primary,
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
    );
  }
}
