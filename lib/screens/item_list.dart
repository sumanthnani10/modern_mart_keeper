import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../containers/order_container.dart';
import '../service/notification_handler.dart';
import '../storage.dart';

class ItemList extends StatefulWidget {
  final snap;

  ItemList({@required this.snap});

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  GlobalKey globalKey = GlobalKey();
  List<Color> colors = [
    Color(0xfffff700),
    Color(0xff00fd5d),
    Colors.cyanAccent,
    Colors.redAccent,
  ];
  List<Color> splashColors = [
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.red
  ];

  Future<void> _capturePng() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    await Share.file('esys image', 'esys.png', pngBytes, 'image/png',
        text:
            'https://www.google.com/maps/dir/?api=1&destination=${Storage.customers['${widget.snap['det']['cid']}']['lt']},${Storage.customers['${widget.snap['det']['cid']}']['lg']}');
  }

  @override
  Widget build(BuildContext context) {
    int c = 0;
    switch (widget.snap['det']['stage']) {
      case 'Order Placed':
        c = 0;
        break;
      case 'Accepted':
        c = 1;
        break;
      case 'Packed':
        c = 2;
        break;
      case 'Delivered':
        c = 2;
        break;
      case 'Rejected':
        c = 3;
        break;
    }
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
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
                _capturePng();
              },
              icon: Icon(Icons.share),
              label: Text('Share'))
        ],
        title: Text(
          'Order',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: RepaintBoundary(
              key: globalKey,
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 8),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: OrderContainer(
                        fullAddress: true,
                        color: colors[c],
                        splashColor: splashColors[c],
                        customerName:
                            '${Storage.customers['${widget.snap['det']['cid']}']['fn']} ${Storage.customers['${widget.snap['det']['cid']}']['ln']}',
                        itemnumbers: widget.snap['len'],
                        items: '',
                        onTap: () {},
                        time: widget.snap['time']['pla'],
                        address:
                            '${Storage.customers['${widget.snap['det']['cid']}']['a']}',
                        phone:
                            '${Storage.customers['${widget.snap['det']['cid']}']['m']}',
                        total:
                            '${widget.snap['price']['tot'] + widget.snap['price']['del']}',
                      ),
                    ),
                    DataTable(
                        dataRowHeight: 36,
                        dividerThickness: 0.5,
                        horizontalMargin: 4,
                        columns: [
                          DataColumn(
                            label: Text(
                              'Product',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          )
                        ],
                        rows: widget.snap['prods'].map<DataRow>((e) {
                              return DataRow(cells: <DataCell>[
                                DataCell(
                                  Container(
                                      width: 96,
                                      child: Text(
                                        '${Storage.products[e['id']]['n']}',
                                        maxLines: 2,
                                      )),
                                ),
                                DataCell(Center(
                                    child: Text(Storage.products[e['id']]
                                                ['q${e['pn']}'] !=
                                            0
                                        ? '${e['q']} x ${Storage.products[e['id']]['q${e['pn']}']} ${Storage.products[e['id']]['u${e['pn']}']}'
                                        : '${e['q']}'))),
                                DataCell(Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        'Rs.${Storage.products[e['id']]['dp${e['pn']}'] * e['q']}'))),
                              ]);
                            }).toList() +
                            [
                              DataRow(cells: <DataCell>[
                                DataCell(
                                  Container(
                                      width: 96,
                                      child: Text(
                                        'Delivery',
                                        maxLines: 2,
                                      )),
                                ),
                                DataCell(Center(child: Text(' '))),
                                DataCell(Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        'Rs.${widget.snap['price']['del']}'))),
                              ])
                            ]),
                  ],
                ),
              ),
            ),
          )),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (widget.snap['det']['stage'] == 'Order Placed')
              Row(
                children: <Widget>[
                  RaisedButton.icon(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      color: Colors.redAccent,
                      onPressed: () async {
                        showLoadingDialog(context, 'Rejecting');
                        await NotificationHandler.instance.sendStage(
                            'Order Rejected',
                            'Sorry! Your Order has been Rejected.',
                            widget.snap['nt'],
                            'Rejected',
                            widget.snap['id']);
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(widget.snap['id'])
                            .update({
                          'det.stage': 'Rejected',
                          'time.rej': FieldValue.serverTimestamp()
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Reject ',
                        style: TextStyle(color: Colors.white),
                      )),
                  SizedBox(
                    width: 16,
                  ),
                  RaisedButton.icon(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      color: Colors.lightGreen,
                      onPressed: () async {
                        showLoadingDialog(context, 'Accepting');
                        await NotificationHandler.instance.sendStage(
                            'Order Accepted',
                            'Your Order has been Accepted. Your Order will soon be packed and delivered.',
                            widget.snap['nt'],
                            'Accepted',
                            widget.snap['id']);
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(widget.snap['id'])
                            .update({
                          'det.stage': 'Accepted',
                          'time.acc': FieldValue.serverTimestamp()
                        });
                        var mnth = DateTime.now();
                        DocumentReference documentReference =
                            FirebaseFirestore.instance.collection('shop').doc(
                                Storage.APP_NAME_ + '_' + Storage.APP_LOCATION);
                        await FirebaseFirestore.instance.runTransaction((t) {
                          return t.get(documentReference).then((doc) {
                            String mnt = '${mnth.year}_';
                            if (mnth.month <= 9) {
                              mnt += '0${mnth.month}';
                            } else {
                              mnt += '${mnth.month}';
                            }
                            var month = doc.data()['monthly'][mnt];
                            if (month == null) {
                              t.update(documentReference, {
                                'monthly.${mnt}': {
                                  '${widget.snap['id']}': widget.snap['price']
                                      ['tot'],
                                  'total': widget.snap['price']['tot']
                                }
                              });
                            } else {
                              t.update(documentReference, {
                                'monthly.${mnt}.${widget.snap['id']}':
                                    widget.snap['price']['tot'],
                                'monthly.${mnt}.total':
                                    month['total'] + widget.snap['price']['tot']
                              });
                            }
                          });
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Accept',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
            if (widget.snap['det']['stage'] == 'Accepted')
              RaisedButton.icon(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: Colors.blueAccent,
                  onPressed: () async {
                    showLoadingDialog(context, 'Packing');
                    await NotificationHandler.instance.sendStage(
                        'Order Packed',
                        'Your Order has been Packed. It will be delivered soon.',
                        widget.snap['nt'],
                        'Packed',
                        widget.snap['id']);
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(widget.snap['id'])
                        .update({
                      'det.stage': 'Packed',
                      'time.pac': FieldValue.serverTimestamp()
                    });
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Packed',
                    style: TextStyle(color: Colors.white),
                  )),
            if (widget.snap['det']['stage'] == 'Packed')
              RaisedButton.icon(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: Colors.cyan,
                  onPressed: () async {
                    showLoadingDialog(context, 'Delivering');
                    await NotificationHandler.instance.sendStage(
                        'Order Delivered',
                        'Your Order has been Delivered. Thank you for shopping with us.',
                        widget.snap['nt'],
                        'Delivered',
                        widget.snap['id']);
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(widget.snap['id'])
                        .update({
                      'det.stage': 'Delivered',
                      'time.del': FieldValue.serverTimestamp()
                    });
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Delivered',
                    style: TextStyle(color: Colors.white),
                  )),
          ],
        ),
      ),
    );
  }

  showLoadingDialog(BuildContext context, String title) {
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(8),
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 8,
                  ),
                  Text(title)
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
