import 'package:flutter/material.dart';

class AppSpacing {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
}

class AppRadius {
  static const small = 10.0;
  static const medium = 14.0;
  static const large = 18.0;
}

class AppShadows {
  static const subtle = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
}
