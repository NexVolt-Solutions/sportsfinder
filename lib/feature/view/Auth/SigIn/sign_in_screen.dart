import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Auth/SigIn/SignInViewModel/sign_in_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/social_button_widget.dart';
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
    return Consumer<SignInScreenViewModel>(
      builder: (context, model, child) => Scaffold(
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
                NormalText(
                  titleText: AppText.createAccount,
                  titleStyle: context.appText.text18W600,
                  subText: AppText.joinSportFindingToday,
                  subStyle: context.appText.text16W400,
                  subColor: context.appColors.greylight,
                ),
                SizedBox(height: context.h(20)),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: context.radiusR(50),
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),

                    Transform.translate(
                      offset: const Offset(55, 40),
                      child: Container(
                        padding: EdgeInsets.all(context.radiusR(6)),
                        decoration: BoxDecoration(
                          color: context.appColors.onPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.appColors.greyDark,
                              offset: const Offset(0, 4),
                              blurRadius: 80,
                              blurStyle: BlurStyle.inner,
                            ),
                          ],
                        ),
                        child: Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.h(12)),

                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  titleText: AppText.uploadYourPicture,
                  titleStyle: context.appText.text18W600,
                  titleColor: context.appColors.primary,
                ),

                SizedBox(height: context.h(20)),

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
                SizedBox(height: context.h(20)),
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
                SizedBox(height: context.h(20)),
                TextFormFieldWidget(
                  label: AppText.phoneNumber,
                  hintText: AppText.phoneNumberHit,
                  controller: model.phoneNumberController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppText.phoneNumberValidation;
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.h(20)),
                TextFormFieldWidget(
                  label: AppText.createPassword,
                  hintText: AppText.passwordHit,
                  controller: model.emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppText.passwordValidation;
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.h(20)),
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
                SizedBox(height: context.h(10)),
                TermsCheckbox(),
                SizedBox(height: context.h(10)),
                CustomButton(
                  onTap: () =>
                      Navigator.pushNamed(context, RoutesName.skillLevelScreen),
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
                  actionText: AppText.signIn,
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.signUpScreen);
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
