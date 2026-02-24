import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../containers/order_container.dart';
import '../screens/item_list.dart';
import '../storage.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
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
          'History',
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
                  width: 169.5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.cyanAccent,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          topLeft: Radius.circular(8))),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Delivered',
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
                  width: 169.5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.deepOrangeAccent,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                          topRight: Radius.circular(8))),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Rejected',
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
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 16,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('det.pid',
                        isEqualTo:
                            Storage.APP_NAME_ + '_' + Storage.APP_LOCATION)
                    .where('det.stage', whereIn: [
                  'Delivered',
                  'Rejected',
                ]).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LinearProgressIndicator();
                  } else {
                    if (!snapshot.hasData)
                      return Text('No Orders');
                    else {
                      var snapl = snapshot.data.documents;
                      snapl.sort((a, b) {
                        if (b
                            .data()['time']['pla']
                            .toDate()
                            .isBefore(a.data()['time']['pla'].toDate()))
                          return -1;
                        else
                          return 1;
                      });
                      return ListView.builder(
                          itemCount: snapl.length,
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (_, index) {
                            var snap = snapl[index].data();
                            String items = '';
                            snap['prods'].forEach((e) {
                              items += Storage.products[e['id']] == null
                                  ? ''
                                  : '${Storage.products[e['id']]['n']},';
                            });
                            return Storage.customers['${snap['det']['cid']}'] ==
                                    null
                                ? Container()
                                : OrderContainer(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(createRoute(ItemList(
                                        snap: snap,
                                      )));
                                    },
                                    time: snap['time']['pla'],
                                    splashColor:
                                        snap['det']['stage'] == 'Delivered'
                                            ? Colors.cyan
                                            : Colors.deepOrange,
                                    color: snap['det']['stage'] == 'Delivered'
                                        ? Colors.cyanAccent
                                        : Colors.deepOrangeAccent,
                                    customerName:
                                        '${Storage.customers['${snap['det']['cid']}']['fn']} ${Storage.customers['${snap['det']['cid']}']['ln']}',
                                    itemnumbers: snap['len'],
                                    items: items);
                          });
                      /*Column(
                        children: List.generate(snapl.length,
                            (index) {
                          var snap = snapl[index].data;
                          return OrderContainer(
                              onTap: () {
                                Navigator.of(context).push(createRoute(ItemList(
                                  snap: snap,
                                )));
                              },
                              splashColor: Colors.orange,
                              color: Color(0xffffaf00),
                              customerName: snap['det']['cid'],
                              itemnumbers: snap['len'],
                              items:
                                  'Small Fresh Fish,Handmade Granite Keyboard,Handmade');
                        }),
                      );*/
                    }
                  }
                },
              ),
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
