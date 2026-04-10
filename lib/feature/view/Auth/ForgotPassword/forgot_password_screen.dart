import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/forgot_password_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ForgotPasswordScreenViewModel>(
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
                    titleText: AppText.forgotPassword,
                    subText: AppText.forgotPasswordSubText,
                    sizeBoxheight: context.h(4),
                    subAlign: TextAlign.center,
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
                  CustomButton(
                    onTap: () async {
                      final result = await model.forgotPassword();
                      if (result == null) {
                        Navigator.pushNamed(
                          context,
                          RoutesName.verificationScreen,
                          arguments: model.emailController.text.trim(),
                        );
                      } else {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(result)));
                      }
                    },
                    text: AppText.sendResetCode,
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
