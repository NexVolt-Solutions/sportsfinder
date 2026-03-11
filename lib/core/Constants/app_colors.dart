import 'package:flutter/material.dart';

class AppColors {
  static const Color pimaryColor = Color(0xFF3A3559);
  static const Color seconderyColor = Color(0xFF433C4E);

  //BackGround Color
  static const Color backGroundColor = Color(0xFFF0F0F3);

  //Text Colors
  static const Color headingColor = Color(0xFF1E1A24);
  static const Color subHeadingColor = Color(0xFF1E1A24);
  static const Color notSelectedColor = Color(0xFF6D6D6D);
  static const Color redColor = Colors.red;

  //Default Color
  static const Color blackColor = Colors.black;
  static const Color white = Colors.white;

  //Icon Color
  static const Color iconColor = Color(0xFF798499);
  static const Color fireColor = Color(0xFFEDAF29);

  //Used for BoxShawdow blur colors
  static const Color blurTopColor = Color(0xFFFAFBFF);
  static const Color blurBottomColor = Color(0xFFA6ABBD);
  static const Color arrowBlurColor = Color(0xFF6F8CB0);
  static const Color subBlur1Color = Color(0xFFAEAEC0);
  static const Color subBlur2Color = Color(0xFFDBE6F2);

  //Button Color
  static const Color buttonColor = Color(0xFF3A3559);

  static const Color black = Color(0x1A000000);
  static const Color customContinerColorDown = Color(0xFFFFFFFF);
  static const Color customContainerColorUp = Color(0xFFAEAEC0);
  static const Color grey = Colors.grey;

  static const LinearGradient blackWhiteGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [white, customContinerColorDown],
  );
  static const LinearGradient containerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [black, white],
  );
}
