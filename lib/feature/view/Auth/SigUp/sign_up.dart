// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sport_finding/core/Constants/app_assets.dart';
// import 'package:sport_finding/core/Constants/app_theme.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';
// import 'package:sport_finding/core/Routes/routes_name.dart';
// import 'package:sport_finding/feature/view/Auth/SigUp/signup_viewmodel.dart';
// import 'package:sport_finding/feature/widget/app_bar_widget.dart';
// import 'package:sport_finding/feature/widget/auth_footer_text.dart';
// import 'package:sport_finding/feature/widget/custom_button.dart';
// import 'package:sport_finding/feature/widget/mainframe.dart';
// import 'package:sport_finding/feature/widget/normal_text.dart';
// import 'package:sport_finding/feature/widget/profile_avatar_picker.dart';
// import 'package:sport_finding/feature/widget/social_button_widget.dart';
// import 'package:sport_finding/feature/widget/terms_check_box.dart';
// import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

// class SignUp extends StatelessWidget {
//   const SignUp({super.key});

//   Future<void> _onPickAvatar(BuildContext context) async {
//     final vm = context.read<SignUpViewModel>();
//     final message = await vm.pickProfileImageFromGallery();
//     if (!context.mounted || message == null) return;
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SignUpViewModel>(
//       builder: (context, model, _) {
//         return Scaffold(
//           body: MainFrame(
//             child: Form(
//               key: model.formKey,
//               child: ListView(
//                 padding: context.padSym(h: 20),
//                 children: [
//                   AppBarWidget(
//                     onTapFirst: () => Navigator.pop(context),
//                     title: AppText.sportFinding,
//                   ),
//                   NormalText(
//                     titleText: AppText.createAccount,
//                     subText: AppText.joinSportFindingToday,
//                   ),
//                   SizedBox(height: context.h(16)),
//                   Center(
//                     child: Selector<SignUpViewModel, String?>(
//                       selector: (_, m) => m.profileImagePath,
//                       builder: (context, imagePath, _) {
//                         return ProfileAvatarPicker(
//                           radius: context.radiusR(50),
//                           imagePath: imagePath,
//                           onPickPressed: () => _onPickAvatar(context),
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(height: context.h(12)),
//                   NormalText(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     titleText: AppText.uploadYourPicture,
//                     titleStyle: context.appText.text18W600,
//                     titleColor: context.appColors.primary,
//                   ),
//                   SizedBox(height: context.h(16)),
//                   TextFormFieldWidget(
//                     label: AppText.fullName,
//                     hintText: AppText.fullNameHit,
//                     controller: model.fullNameController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return AppText.fullNameValidation;
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: context.h(16)),
//                   TextFormFieldWidget(
//                     label: AppText.email,
//                     hintText: AppText.email,
//                     controller: model.emailController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return AppText.emailValidation;
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: context.h(16)),
//                   // TextFormFieldWidget(
//                   //   label: AppText.phoneNumber,
//                   //   hintText: AppText.phoneNumberHit,
//                   //   controller: model.phoneNumberController,
//                   //   validator: (value) {
//                   //     if (value == null || value.isEmpty) {
//                   //       return AppText.phoneNumberValidation;
//                   //     }
//                   //     return null;
//                   //   },
//                   // ),
//                   TextFormFieldWidget(
//                     label: AppText.password,
//                     hintText: AppText.passwordHit,
//                     controller: model.passwordController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return AppText.passwordValidation;
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: context.h(16)),
//                   TextFormFieldWidget(
//                     label: AppText.confirmPassword,
//                     hintText: AppText.passwordHit,
//                     controller: model.confirmPasswordController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return AppText.confirmPasswordValidation;
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: context.h(8)),
//                   const TermsCheckbox(),
//                   SizedBox(height: context.h(8)),
//                   CustomButton(
//                     onTap: () async {
//                       final vm = context.read<SignUpViewModel>();

//                       final error = await vm.registerUser();

//                       if (!context.mounted) return;

//                       if (error == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Registration Successful"),
//                           ),
//                         );

//                         Navigator.pushNamed(
//                           context,
//                           RoutesName.otpVerificationScreen,
//                         );
//                       } else {
//                         ScaffoldMessenger.of(
//                           context,
//                         ).showSnackBar(SnackBar(content: Text(error)));
//                       }
//                     },
//                     text: AppText.signIn,
//                     color: context.appColors.primary,
//                   ),
//                   // CustomButton(
//                   //   onTap: () => Navigator.pushNamed(
//                   //     context,
//                   //     RoutesName.skillLevelScreen,
//                   //   ),
//                   //   text: AppText.signIn,
//                   //   color: context.appColors.primary,
//                   // ),
//                   SizedBox(height: context.h(12)),
//                   SocialButtonWidget(
//                     imagePath: AppAssets.gmailIcon,
//                     text: AppText.continueWithGoogle,
//                     onTap: () {},
//                   ),
//                   SizedBox(height: context.h(12)),
//                   Center(
//                     child: AuthFooterText(
//                       normalText: AppText.alreadyHaveAnAccountSignIn,
//                       actionText: AppText.signIn,
//                       onTap: () {
//                         Navigator.pushNamed(context, RoutesName.LoginScreen);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
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
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/profile_avatar_picker.dart';
import 'package:sport_finding/feature/widget/social_button_widget.dart';
import 'package:sport_finding/feature/widget/terms_check_box.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

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
                  NormalText(
                    titleText: AppText.createAccount,
                    subText: AppText.joinSportFindingToday,
                  ),
                  SizedBox(height: context.h(16)),
                  Center(
                    // ✅ FIXED: Using XFile? instead of String?
                    child: Selector<SignUpViewModel, XFile?>(
                      selector: (_, m) => m.pickedXFile,
                      builder: (context, xFile, _) {
                        return ProfileAvatarPicker(
                          radius: context.radiusR(50),
                          xFile: xFile, // ✅ pass XFile
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
                          RoutesName
                              .otpVerificationScreen, // ← check this route name
                          arguments: vm.emailController.text
                              .trim(), // ✅ must pass email
                        );
                      } else {
                        AppSnackBar.show(error);
                      }
                    },
                    text: AppText.signIn,
                    color: context.appColors.primary,
                  ),
                  SizedBox(height: context.h(12)),
                  SocialButtonWidget(
                    imagePath: AppAssets.gmailIcon,
                    text: AppText.continueWithGoogle,
                    onTap: () {},
                  ),
                  SizedBox(height: context.h(12)),
                  Center(
                    child: AuthFooterText(
                      normalText: AppText.alreadyHaveAnAccountSignIn,
                      actionText: AppText.signIn,
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.LoginScreen);
                      },
                    ),
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
