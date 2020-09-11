import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../storage.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 32,
            ),
          ),
          /*actions: <Widget>[
            FlatButton(
              onPressed: () {},
              child: Text(
                'Edit',
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ],*/
          title: Text(
            'Profile',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo/foreground.png',
                      height: 100,
                      width: 100,
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Name',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  Storage.shopDetails['maintainer'],
                  style: TextStyle(fontSize: 24),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),
                Text(
                  'Shop Name',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  Storage.shopDetails['store_name'],
                  style: TextStyle(fontSize: 24),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),
                Text(
                  'Address',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Nandigama,Andhra Pradesh,India',
                  style: TextStyle(fontSize: 24),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),
                Text(
                  'Mobile',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  Storage.shopDetails['mobile'],
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 16),
                Text(
                  'Email',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  Storage.shopDetails['email'] ?? '-',
                  style: TextStyle(fontSize: 24),
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                /*SizedBox(height: 16),
                Text(
                  'Area Name',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Isnapur',
                  style: TextStyle(fontSize: 24),
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),*/
                SizedBox(height: 16),
                Text(
                  'Area Radius',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '20 Km',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ));
  }

  Route createRoute(dest) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => dest,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1, 0);
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
