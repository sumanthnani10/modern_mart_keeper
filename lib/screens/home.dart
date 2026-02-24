import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modern_mart_keeper/screens/offers.dart';

import '../containers/order_container.dart';
import '../screens/categories.dart';
import '../screens/history.dart';
import '../screens/profile.dart';
import '../screens/send_notification.dart';
import '../screens/splash_screen.dart';
import '../service/notification_handler.dart';
import '../storage.dart';
import 'item_list.dart';
import 'products.dart';
import 'sliders.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Color> colors = [
    Color(0xffffaf00),
    Color(0xfffff700),
    Color(0xff00fd5d)
  ];
  List<Color> splashColors = [Colors.orange, Colors.yellow, Colors.green];
  NotificationHandler notificationHandler = new NotificationHandler();
  bool loaded = false;

  @override
  void initState() {
    getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          'Orders',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Container(
                  width: 113,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Color(0xffffaf00),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          topLeft: Radius.circular(8))),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'New Order',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  width: 113,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xfffff700),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Accepted Order',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  width: 113,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Color(0xff00fd5d),
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                          topRight: Radius.circular(8))),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Packed Order',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: loaded
              ? Column(
                  children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .where('det.pid',
                              isEqualTo: Storage.APP_NAME_ +
                                  '_' +
                                  Storage.APP_LOCATION)
                          .where('det.stage', whereIn: [
                        'Order Placed',
                        'Accepted',
                        'Packed'
                      ]).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return LinearProgressIndicator();
                        } else {
                          if (!snapshot.hasData)
                            return Text('No Orders');
                          else {
                            if (snapshot.data.documents.length > 0) {
                              snapshot.data.documents.sort((a, b) {
                                if (b
                                    .data()['time']['pla']
                                    .toDate()
                                    .isBefore(a.data()['time']['pla'].toDate()))
                                  return -1;
                                else
                                  return 1;
                              });
                              return ListView.builder(
                                  itemCount: snapshot.data.documents.length,
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(0),
                                  itemBuilder: (_, index) {
                                    var snap =
                                        snapshot.data.documents[index].data();
                                    int c = 0;
                                    switch (snap['det']['stage']) {
                                      case 'Order Placed':
                                        c = 0;
                                        break;
                                      case 'Accepted':
                                        c = 1;
                                        break;
                                      case 'Packed':
                                        c = 2;
                                        break;
                                    }
                                    String items = '';
                                    snap['prods'].forEach((e) {
                                      items +=
                                          '${Storage.products[e['id']]['n']},';
                                    });
                                    return OrderContainer(
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(createRoute(ItemList(
                                            snap: snap,
                                          )));
                                        },
                                        splashColor: splashColors[c],
                                        color: colors[c],
                                        time: snap['time']['pla'],
                                        customerName:
                                            '${Storage.customers['${snap['det']['cid']}']['fn']} ${Storage.customers['${snap['det']['cid']}']['ln']}',
                                        itemnumbers: snap['len'],
                                        items: items);
                                  });
                            } else {
                              return Text('No Orders');
                            }
                          }
                        }
                      },
                    ),
                  ],
                )
              : LinearProgressIndicator(),
        ),
      ),
      drawer: Drawer(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/logo/foreground.png',
                        height: 70,
                      )),
                  Text(Storage.shopDetails['maintainer'] ?? ''),
                  Text(Storage.shopDetails['store_name'] ?? ''),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.home),
                  label: Text(
                    'Home',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, createRoute(Products()));
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, createRoute(Products()));
                  },
                  icon: Icon(Icons.shopping_basket),
                  label: Text(
                    'Products',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, createRoute(Categories()));
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, createRoute(Categories()));
                  },
                  icon: Icon(Icons.category),
                  label: Text(
                    'Categories',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, createRoute(Sliders()));
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, createRoute(Sliders()));
                  },
                  icon: Icon(Icons.slideshow),
                  label: Text(
                    'Banners',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, createRoute(Offers()));
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, createRoute(Offers()));
                  },
                  icon: Icon(Icons.local_offer),
                  label: Text(
                    'Offers',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, createRoute(History()));
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, createRoute(History()));
                  },
                  icon: Icon(Icons.history),
                  label: Text(
                    'History',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, createRoute(SendNotification()));
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, createRoute(SendNotification()));
                  },
                  icon: Icon(Icons.send),
                  label: Text(
                    'Send Notification',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, createRoute(Profile()));
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, createRoute(Profile()));
                  },
                  icon: Icon(Icons.account_circle),
                  label: Text(
                    'Profile',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, createRoute(SplashScreen()));
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                        context, createRoute(SplashScreen()));
                  },
                  icon: Icon(Icons.person),
                  label: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ),
          ])),
    );
  }

  getProducts() async {
    await FirebaseFirestore.instance
        .collection('shop')
        .doc(Storage.APP_NAME_ + '_' + Storage.APP_LOCATION)
        .snapshots()
        .listen((event) {
      Storage.shopDetails = event.data();
      Storage.categories = [];
      event.data()['categories'].forEach((e) {
        Storage.categories.add(e.toString());
      });
      // print(event.data());
      Storage.sliders = event.data()['sliders'];
    });
    FirebaseFirestore.instance
        .collection('shop')
        .doc(Storage.APP_NAME_ + '_' + Storage.APP_LOCATION)
        .collection('prods')
        .orderBy('n')
        .snapshots()
        .listen((event) {
      if (mounted) {
        setState(() {
          Storage.productsList = event.docs;
          Storage.products.clear();
          Storage.productsList.forEach((element) async {
            Storage.products[element.id] = element.data();
          });
        });
      }
    });
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      if (mounted) {
        setState(() {
          Storage.customers.clear();
          event.docs.forEach((element) {
            Storage.customers[element.id] = element.data();
          });
        });
      }
    });
    setState(() {
      loaded = true;
    });
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
