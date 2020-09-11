import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:modern_mart_keeper/service/notification_handler.dart';

import '../screens/home.dart';
import '../screens/login.dart';
import '../storage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool gotDetails = false;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    await Firebase.initializeApp();
    if (FirebaseAuth.instance.currentUser != null) {
      String t = await NotificationHandler.instance.init(context);
      await FirebaseFirestore.instance
          .collection('shop')
          .doc(Storage.APP_NAME_ + '_' + Storage.APP_LOCATION)
          .update({
        'nts': FieldValue.arrayUnion([t])
      });
      Navigator.of(context).pushReplacement(createRoute(Home()));
    } else {
      Navigator.of(context).pushReplacement(createRoute(LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: /*Color(0xffffaf00)*/ Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Container(
                height: 300,
                child: Image.asset(
                  'assets/logo/logo.jpg',
                  width: 300,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xffffaf00)),
                  )),
              Spacer(),
              Image.asset(
                'assets/logo/ftd_logo.png',
                width: 100,
              ),
              SizedBox(
                height: 8,
              )
            ],
          ),
        ),
      ),
    );
  }

  Route createRoute(dest) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => dest,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0, 1);
        var end = Offset.zero;
        var curve = Curves.fastOutSlowIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
