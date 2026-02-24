import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import './screens/splash_screen.dart';

void main() {
  runApp(OverlaySupport(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: SplashScreen(),
    ),
  ));
}
