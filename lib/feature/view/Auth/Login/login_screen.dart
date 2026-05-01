import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/Auth/Login/login_viewmodel.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/social_button_widget.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';
import 'package:sport_finding/feature/webwidget/web_auth_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _submitLogin(
    BuildContext context,
    LoginScreenViewModel model,
  ) async {
    final result = await model.loginUser();

    if (!context.mounted) return;

    if (result == "SKILL_LEVEL") {
      Navigator.pushReplacementNamed(context, RoutesName.skillLevelScreen);
    } else if (result == "HOME") {
      Navigator.pushReplacementNamed(
        context,
        RoutesName.bottomBarScreen,
        arguments: BottomBarScreenViewModel.homeIndex,
      );
    } else {
      AppSnackBar.show(
        result ?? 'Login failed',
        behavior: SnackBarBehavior.floating,
      );
    }
  }

  Future<void> _submitGoogle(
    BuildContext context,
    LoginScreenViewModel model,
  ) async {
    final result = await model.loginWithGoogle();

    if (!context.mounted || result == null) return;

    if (result == "SKILL_LEVEL") {
      Navigator.pushReplacementNamed(context, RoutesName.skillLevelScreen);
    } else if (result == "HOME") {
      Navigator.pushReplacementNamed(
        context,
        RoutesName.bottomBarScreen,
        arguments: BottomBarScreenViewModel.homeIndex,
      );
    } else {
      AppSnackBar.show(result, behavior: SnackBarBehavior.floating);
    }
  }

  Widget _buildForm(BuildContext context, LoginScreenViewModel model) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        if (!kIsWeb) AppBarWidget(title: AppText.sportFinding),
        NormalText(
          titleText: kIsWeb ? 'Sign In to your Account' : AppText.welcomeBack,
          titleStyle: context.appText.text28W500,
          subText: kIsWeb
              ? 'Welcome back! please enter your details'
              : AppText.loginToContinue,
          subStyle: context.appText.text16W400,
          subColor: context.appColors.greylight,
          crossAxisAlignment: kIsWeb
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          subAlign: kIsWeb ? TextAlign.center : TextAlign.start,
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
          label: AppText.password,
          hintText: AppText.passwordHit,
          controller: model.passwordController,
          validator: (value) => value == null || value.isEmpty
              ? AppText.passwordValidation
              : null,
        ),
        SizedBox(height: context.h(12)),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, RoutesName.forgotPasswordScreen);
            },
            child: NormalText(
              titleText: AppText.forgotPassword,
              titleStyle: context.appText.text14W400,
              titleColor: context.appColors.greylight,
            ),
          ),
        ),
        SizedBox(height: context.h(12)),
        CustomButton(
          text: "Login",
          isLoading: model.isLoading,
          onTap: () => _submitLogin(context, model),
        ),
        SizedBox(height: context.h(12)),
        SocialButtonWidget(
          imagePath: AppAssets.gmailIcon,
          text: AppText.continueWithGoogle,
          isLoading: model.isGoogleLoading,
          onTap: () => _submitGoogle(context, model),
        ),
        SizedBox(height: context.h(12)),
        AuthFooterText(
          normalText: kIsWeb
              ? 'Don’t have an account? '
              : AppText.alreadyHaveAnAccountSignIn,
          actionText: AppText.signUp,
          onTap: () {
            Navigator.pushNamed(context, RoutesName.SignUp);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginScreenViewModel>(
      builder: (context, model, child) {
        final form = Form(
          key: model.formKey,
          child: _buildForm(context, model),
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
