import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../storage.dart';

class Offers extends StatefulWidget {
  @override
  _OffersState createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  TextEditingController addOfferFieldController = new TextEditingController();

  bool loading = false;

  TextStyle liveTextStyle = TextStyle(color: Colors.black, fontSize: 12);
  TextStyle notLiveTextStyle = TextStyle(color: Colors.black45, fontSize: 12);
  TextStyle livebTextStyle =
      TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w600);
  TextStyle endbTextStyle =
      TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600);
  TextStyle editbTextStyle = TextStyle(color: Colors.blue, fontSize: 16);
  TextStyle delbTextStyle = TextStyle(color: Colors.deepOrange, fontSize: 16);

  BoxDecoration buttonDec = BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(8));

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            'Offers',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        body: Stack(
          children: <Widget>[
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('offers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LinearProgressIndicator();
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length > 0) {
                      return SingleChildScrollView(
                        child: Column(
                          children:
                              List.generate(snapshot.data.docs.length, (index) {
                            var offer = snapshot.data.docs[index].data();
                            return ExpansionTile(
                              backgroundColor: offer['live']
                                  ? Colors.lightGreenAccent
                                  : Colors.white,
                              initiallyExpanded: offer['live'],
                              title: Text('${offer['n']}'),
                              subtitle: offer['live']
                                  ? Text('Live', style: liveTextStyle)
                                  : Text(
                                      'Not Live',
                                      style: notLiveTextStyle,
                                    ),
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () async {
                                        if (!offer['live']) {
                                          var ch = false;
                                          snapshot.data.docs.forEach((e) {
                                            if (e.data()['live']) {
                                              ch = true;
                                            }
                                          });
                                          if (ch) {
                                            _showDialog(
                                                'Already An Offer is Live');
                                          } else {
                                            setState(() {
                                              loading = true;
                                            });
                                            var batch = FirebaseFirestore
                                                .instance
                                                .batch();
                                            offer['prods']
                                                .forEach((pk, pv) async {
                                              var prod = Storage.products[pk];
                                              for (int pi = 1;
                                                  pi <= prod['p'];
                                                  pi++) {
                                                if (pv['pe$pi'] != null) {
                                                  prod['dp$pi'] =
                                                      (prod['m$pi'] -
                                                              (prod['m$pi'] *
                                                                  pv['pe$pi'] /
                                                                  100))
                                                          .ceil();
                                                }
                                              }
                                              batch.set(
                                                  FirebaseFirestore.instance
                                                      .collection('shop')
                                                      .doc(Storage.APP_NAME_ +
                                                          '_' +
                                                          Storage.APP_LOCATION)
                                                      .collection('prods')
                                                      .doc(pk),
                                                  prod);
                                            });
                                            var date = DateTime.now();
                                            batch.update(
                                                FirebaseFirestore.instance
                                                    .collection('offers')
                                                    .doc(offer['n']),
                                                {
                                                  'live': true,
                                                  'lvd': FieldValue.arrayUnion([
                                                    '${date.day}-${date.month}-${date.year}'
                                                  ])
                                                });
                                            await batch.commit();
                                            setState(() {
                                              loading = false;
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            loading = true;
                                          });
                                          var batch = FirebaseFirestore.instance
                                              .batch();
                                          offer['prods']
                                              .forEach((pk, pv) async {
                                            var prod = Storage.products[pk];
                                            for (int pi = 1;
                                                pi <= prod['p'];
                                                pi++) {
                                              prod['dp$pi'] = prod['p$pi'];
                                            }
                                            batch.set(
                                                FirebaseFirestore.instance
                                                    .collection('shop')
                                                    .doc(Storage.APP_NAME_ +
                                                        '_' +
                                                        Storage.APP_LOCATION)
                                                    .collection('prods')
                                                    .doc(pk),
                                                prod);
                                          });
                                          var date = DateTime.now();
                                          batch.update(
                                              FirebaseFirestore.instance
                                                  .collection('offers')
                                                  .doc(offer['n']),
                                              {
                                                'live': false,
                                                'end': FieldValue.arrayUnion([
                                                  '${date.day}-${date.month}-${date.year}'
                                                ])
                                              });
                                          await batch.commit();
                                          setState(() {
                                            loading = false;
                                          });
                                        }
                                      },
                                      child: Container(
                                        decoration: buttonDec,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2, horizontal: 8),
                                        child: Text(
                                          offer['live'] ? 'End' : 'Live',
                                          style: offer['live']
                                              ? endbTextStyle
                                              : livebTextStyle,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        if (!offer['live']) {
                                          setState(() {
                                            loading = true;
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('offers')
                                              .doc(offer['n'])
                                              .delete();
                                          setState(() {
                                            loading = false;
                                          });
                                        } else {
                                          _showDialog(
                                              'Offer is Live.Can\'t Delete');
                                        }
                                      },
                                      child: Container(
                                        decoration: buttonDec,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2, horizontal: 8),
                                        child: Text('Delete',
                                            style: delbTextStyle),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (!offer['live']) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Offer(
                                                  offer: offer,
                                                ),
                                              ));
                                        } else {
                                          _showDialog(
                                              'Offer is Live.Can\'t Edit');
                                        }
                                      },
                                      child: Container(
                                        decoration: buttonDec,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2, horizontal: 8),
                                        child:
                                            Text('Edit', style: editbTextStyle),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                )
                              ],
                            );
                          }),
                        ),
                      );
                    } else {
                      return Center(child: Text('No Offers Added'));
                    }
                  } else {
                    return Center(child: Text('No Offers Added'));
                  }
                }
              },
            ),
            if (loading) Center(child: CircularProgressIndicator())
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.black,
            size: 32,
          ),
          onPressed: () {
            _showDialogAdd('Offer Name');
          },
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  void _showDialog(text) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
//          title: new Text("Alert Dialog title"),
          content: new Text(text),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogAdd(
    String title,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: addOfferFieldController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.emailAddress,
              maxLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: "Category Name"),
              validator: (v) {
                if (v.isEmpty) {
                  return 'Enter Offer Name';
                } else {
                  if (/*Storage.categories.contains(v)*/ false) {
                    return 'Offer Already exists';
                  } else {
                    return null;
                  }
                }
              },
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Add"),
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  setState(() {
                    loading = true;
                  });
                  Navigator.of(context).pop();
                  await FirebaseFirestore.instance
                      .collection('offers')
                      .doc(addOfferFieldController.text)
                      .set({
                    'n': addOfferFieldController.text,
                    'prods': {},
                    'live': false,
                    'o': FieldValue.serverTimestamp(),
                    'lvd': [],
                    'end': [],
                    'dep': 0
                  });
                  setState(() {
                    loading = false;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class Offer extends StatefulWidget {
  final offer;

  const Offer({Key key, this.offer}) : super(key: key);

  @override
  _OfferState createState() => _OfferState();
}

class _OfferState extends State<Offer> {
  Map<String, dynamic> offer;

  TextEditingController defperccont = new TextEditingController();

  TextStyle mrpStyle = new TextStyle(
      color: Colors.black,
      decoration: TextDecoration.lineThrough,
      decorationColor: Colors.red,
      fontSize: 10);
  TextStyle priceStyle = new TextStyle(color: Colors.black, fontSize: 10);
  TextStyle newPriceStyle = new TextStyle(color: Colors.black, fontSize: 16);
  List<TextEditingController> percConts = new List<TextEditingController>();

  List<TextInputFormatter> numwl = [WhitelistingTextInputFormatter.digitsOnly];

  InputDecoration percDec = InputDecoration(
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black)),
      labelStyle: TextStyle(color: Colors.black),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      suffixText: '%',
      counterText: '',
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black)),
      fillColor: Colors.white);

  BoxDecoration boxdecPrice = BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.black38, width: 0.5)));

  bool loading = false;
  bool shouldUpdate = false;

  // Set<String> updateProducts = {};

  @override
  void initState() {
    offer = widget.offer;
    super.initState();
    defperccont.text = offer['dep'].toString();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (shouldUpdate) {
        await updateOffer();
        shouldUpdate = false;
      }
    });
    int ind = -1;
    var offkeys = offer['prods'].keys.toList();
    percConts.clear();
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              title: Text(
                'Offer',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () => updateOffer(),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                        Text(
                          '${offer['n']}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Lived Dates:')),
                        if (offer['lvd'].length == 0)
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Never Lived')),
                        if (offer['lvd'].length != 0)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  children: List<Widget>.generate(
                                      offer['lvd'].length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(offer['lvd'].length - 1 != index
                                      ? ' ${offer['lvd'][index]},'
                                      : ' ${offer['lvd'][index]}'),
                                );
                              })),
                            ),
                          ),
                        Container(
                          width: 300,
                          height: 0.5,
                          color: Colors.black,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('Offer Percentage :'),
                            Container(
                              width: 100,
                              child: TextField(
                                controller: defperccont,
                                maxLines: 1,
                                inputFormatters: numwl,
                                maxLength: 2,
                                onChanged: (v) {
                                  offer['dep'] = int.parse(v);
                                },
                                decoration: percDec,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: <Widget>[
                            Text('Products'),
                            Spacer(),
                            FlatButton(
                                onPressed: () async {
                                  var rep = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SelctProducts(
                                          p: offer['prods'],
                                          dep: offer['dep'],
                                        ),
                                      ));
                                  if (rep != null) {
                                    setState(() {
                                      offer['prods'] = rep;
                                    });
                                  }
                                },
                                child: Text(
                                  'Add Products',
                                  style: TextStyle(color: Colors.blue),
                                ))
                          ],
                        ),
                      ] +
                      List<Widget>.generate(offer['prods'].length, (pindex) {
                        Map<String, dynamic> product =
                            Storage.products[offkeys[pindex]];
                        var ofp = offer['prods'][offkeys[pindex]];
                        return ExpansionTile(
                          title: Text('${product['n']}',
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${Storage.categories[product['c']]}'),
                          children:
                              List<Widget>.generate(product['p'], (index) {
                            ind++;
                            if (ofp['pe${index + 1}'] == null) {
                              ofp['pe${index + 1}'] = 0;
                              offer['prods'][offkeys[pindex]]
                                  ['pe${index + 1}'] = 0;
                              shouldUpdate = true;
                            }
                            percConts.add(new TextEditingController(
                                text: '${ofp['pe${index + 1}']}'));
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              decoration: boxdecPrice,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '(${product['p${index + 1}']}|',
                                    style: priceStyle,
                                  ),
                                  Text(
                                    ' ${product['m${index + 1}']} ',
                                    style: mrpStyle,
                                  ),
                                  Text(
                                    '| ${(((product['m${index + 1}'] - product['p${index + 1}']) / product['m${index + 1}']) * 100).round()}%',
                                    style: priceStyle,
                                  ),
                                  Text(
                                    '| ${product['q${index + 1}'].toString() != '0' ? 'Rs.${product['dp${index + 1}']} - ${product['q${index + 1}']}${product['u${index + 1}']}' : 'Rs.${product['dp${index + 1}']}'})',
                                    style: priceStyle,
                                  ),
                                  Spacer(),
                                  Text(
                                    ' Rs.${product['m${index + 1}'] - (product['m${index + 1}'] * ofp['pe${index + 1}'] / 100).ceil()} ',
                                    style: newPriceStyle,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Container(
                                    width: 60,
                                    child: TextField(
                                      controller: percConts[ind],
                                      inputFormatters: numwl,
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      maxLength: 2,
                                      decoration: percDec,
                                      onSubmitted: (c) {
                                        ofp['pe${index + 1}'] = int.parse(c);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        );
                      }),
                ),
              ),
            ),
          ),
        ),
        if (loading) Center(child: CircularProgressIndicator())
      ],
    );
  }

  Future<bool> updateOffer() async {
    setState(() {
      loading = true;
    });
    var batch = FirebaseFirestore.instance.batch();
    batch.set(
        FirebaseFirestore.instance.collection('offers').doc(offer['n']), offer);
    /*if(offer['live']){
      updateProducts.forEach((e) async {
        print(e);
        var prod = Storage.products[e];
        for (int pi = 1; pi <=
            prod['p']; pi++) {
          if (offer['prods'][e]['pe$pi'] != null) {
            prod['dp$pi'] = (prod['m$pi'] -
                (prod['m$pi'] *
                    offer['prods'][e]['pe$pi'] / 100)).ceil();
          }
        }
        batch.set(FirebaseFirestore.instance.collection('shop')
            .doc(Storage.APP_NAME_+'_'+Storage.APP_LOCATION)
            .collection('prods')
            .doc(e), prod);
      });
    }*/
    await batch.commit();
    setState(() {
      loading = false;
    });
    return true;
  }
}

class SelctProducts extends StatefulWidget {
  final p, dep;

  const SelctProducts({Key key, this.p, this.dep}) : super(key: key);

  @override
  _SelctProductsState createState() => _SelctProductsState();
}

class _SelctProductsState extends State<SelctProducts> {
  TextStyle catstyle = TextStyle(
    color: Colors.black45,
    fontSize: 10,
  );
  TextStyle titlestyle = TextStyle(
    fontSize: 12,
  );

  Map<String, dynamic> oprods;

  ScrollController scrollController = new ScrollController();
  int viewItems = 20;

  TextEditingController search_controller = new TextEditingController();

  String search = '';

  @override
  void initState() {
    oprods = widget.p;
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        viewItems += 20;
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var prods = Storage.productsList.sublist(0);
    prods = prods
        .where(
            (e) => e.data()['n'].toLowerCase().contains(search.toLowerCase()))
        .toList();
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, oprods);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, oprods);
                },
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.blue),
                ))
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 10,
          ),
          title: Text(
            'Products',
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: search_controller,
                maxLines: 1,
                textInputAction: TextInputAction.search,
                onChanged: (s) {
                  search = s;
                },
                onSubmitted: (value) {
                  setState(() {
                    search = value;
                  });
                },
                decoration: InputDecoration(
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          search_controller.text = '';
                          search = '';
                        });
                      },
                      child: Icon(
                        Icons.clear,
                        color: search == '' ? Colors.white : Colors.black,
                        size: 16,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black)),
                    labelStyle: TextStyle(color: Colors.black),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black)),
                    fillColor: Colors.white),
              ),
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: GridView.count(
              controller: scrollController,
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              children: List<Widget>.generate(
                  prods.length >= viewItems ? viewItems : prods.length,
                  (index) {
                return InkWell(
                  onTap: () {
                    if (oprods[prods[index].id] == null) {
                      oprods[prods[index].id] = {};
                      for (int i = 1; i <= prods[index].data()['p']; i++) {
                        oprods[prods[index].id]['pe$i'] = widget.dep;
                      }
                    } else {
                      oprods.remove(prods[index].id);
                    }
                    setState(() {});
                  },
                  child: Card(
                    elevation: 4,
                    color: oprods[prods[index].id] == null
                        ? Colors.white
                        : Colors.blue[100],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              Storage.getImageURL(prods[index].id) +
                                  prods[index].data()['i'],
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                    child: Text(
                                  '${prods[index].data()['n']}',
                                  style: titlestyle,
                                  maxLines: 2,
                                )),
                                Flexible(
                                  child: Text(
                                    '${Storage.categories[prods[index].data()['c']]}',
                                    style: catstyle,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
            )),
      ),
    );
  }
}
