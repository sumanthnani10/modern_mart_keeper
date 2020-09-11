import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formkey = GlobalKey<FormState>();

  TextEditingController email_controller = new TextEditingController();
  TextEditingController password_controller = new TextEditingController();

  String email = '', password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Shopkeeper Login',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: email_controller,
                  maxLines: 1,
                  onFieldSubmitted: (term) {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).nextFocus();
                  },
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  validator: (pname) {
                    Pattern pattern =
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                    RegExp regex = new RegExp(pattern);
                    if (pname.isEmpty) {
                      return "Please enter Email";
                    } else if (!regex.hasMatch(pname))
                      return 'Enter Valid Email';
                    else {
                      email = pname;
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black)),
                      labelStyle: TextStyle(color: Colors.black),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black)),
                      fillColor: Colors.white),
                ),
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: password_controller,
                  maxLines: 1,
                  onFieldSubmitted: (term) {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).nextFocus();
                  },
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  textCapitalization: TextCapitalization.none,
                  validator: (pname) {
                    if (pname.isEmpty) {
                      return "Please enter Password";
                    } else {
                      password = pname;
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black)),
                      labelStyle: TextStyle(color: Colors.black),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black)),
                      fillColor: Colors.white),
                ),
                SizedBox(
                  height: 8,
                ),
                RaisedButton(
                  onPressed: () async {
                    if (formkey.currentState.validate()) {
                      await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: email, password: password)
                          .then((value) {
                        if (value.user != null) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SplashScreen(),
                              ));
                        }
                      });
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  color: Colors.green,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
