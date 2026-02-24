import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../storage.dart';

class ModifyProduct extends StatefulWidget {
  var snap;

  ModifyProduct({@required this.snap});

  @override
  _ModifyProductState createState() => _ModifyProductState();
}

class _ModifyProductState extends State<ModifyProduct> {
  final formkey = GlobalKey<FormState>();
  TextEditingController name_controller = new TextEditingController();
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  Map<String, dynamic> product = new Map<String, dynamic>();
  bool uploading = false;
  bool stock = true;
  var time = FieldValue.serverTimestamp();

  List<TextInputFormatter> numwl = [WhitelistingTextInputFormatter.digitsOnly];

  File image;
  final picker = ImagePicker();
  List<TextEditingController> price_controller =
      new List<TextEditingController>();
  List<TextEditingController> oprice_controller =
      new List<TextEditingController>();
  List<TextEditingController> quan_controller =
      new List<TextEditingController>();
  List<int> prices = new List<int>(),
      oprices = new List<int>(),
      quans = new List<int>();
  List<String> units = new List<String>();
  int count;

  String name, cat, desc;
  bool imageChanged = false;

  TextEditingController desc_controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    image = null;
    cat = widget.snap['c'].toString();
    count = widget.snap['p'];
    name = widget.snap['n'];
    desc = widget.snap['d'];
    name_controller.text = widget.snap['n'];
    desc_controller.text = widget.snap['d'];
    for (int i = 0; i < widget.snap['p']; i++) {
      price_controller.add(new TextEditingController());
      oprice_controller.add(new TextEditingController());
      quan_controller.add(new TextEditingController());
      units.add(widget.snap['u${i + 1}']);
//      print(widget.snap['u${i + 1}']);
      prices.add(widget.snap['p${i + 1}']);
      oprices.add(widget.snap['m${i + 1}']);
      quans.add(widget.snap['q${i + 1}']);
      buildItem(context, i, null, widget.snap);
      price_controller[i].text = '${widget.snap['p${i + 1}']}';
      if (widget.snap['m${i + 1}'] != widget.snap['p${i + 1}'])
        oprice_controller[i].text = '${widget.snap['m${i + 1}']}';
      if (widget.snap['q${i + 1}'] != 0)
        quan_controller[i].text = '${widget.snap['q${i + 1}']}';
    }
  }

  Future getImage() async {
    PickedFile pickedFile = await picker
        .getImage(source: ImageSource.gallery)
        .whenComplete(() => imageChanged = true);
    setState(() {
      image = File(pickedFile.path);
    });
  }

  Widget getWidget(int index) {
//    print(widget.snap.data);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: TextFormField(
              onFieldSubmitted: (term) {
                FocusScope.of(context).unfocus();
                FocusScope.of(context).nextFocus();
              },
              controller: price_controller[index],
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: numwl,
              textInputAction: TextInputAction.next,
              validator: (pprice) {
                if (pprice.isEmpty) {
                  return "*Required";
                } else {
                  prices[index] = int.parse(pprice);
                  return null;
                }
              },
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  labelText: 'Price',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  fillColor: Colors.white),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Flexible(
            child: TextFormField(
              onFieldSubmitted: (term) {
                FocusScope.of(context).unfocus();
                FocusScope.of(context).nextFocus();
              },
              textInputAction: TextInputAction.next,
              controller: oprice_controller[index],
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: numwl,
              validator: (pprice) {
                if (pprice.isEmpty) {
                  oprices[index] = prices[index];
                  return null;
                } else {
                  oprices[index] = int.parse(pprice);
                  return null;
                }
              },
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  labelText: 'MRP',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  fillColor: Colors.white),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Flexible(
            child: TextFormField(
              onFieldSubmitted: (term) {
                FocusScope.of(context).unfocus();
                FocusScope.of(context).nextFocus();
              },
              textInputAction: TextInputAction.next,
              controller: quan_controller[index],
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: numwl,
              validator: (pprice) {
                if (pprice.isEmpty) {
                  quans[index] = 0;
                } else {
                  quans[index] = int.parse(pprice);
                }
                return null;
              },
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  fillColor: Colors.white),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black)),
              child: DropdownButton<String>(
                elevation: 0,
                autofocus: true,
                dropdownColor: Colors.greenAccent,
                iconSize: 16,
                isExpanded: true,
                value: units[index],
                items: <String>['', 'kg', 'gm', 'l', 'ml', 'units']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == '' ? '-' : value),
                  );
                }).toList(),
                onChanged: (String value) {
                  setState(() {
                    units[index] = value;
                    FocusScope.of(context).unfocus();
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getOldWidget(int index, price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: TextFormField(
              onFieldSubmitted: (term) {
                FocusScope.of(context).unfocus();
                FocusScope.of(context).nextFocus();
              },
              controller: price_controller[index],
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: numwl,
              textInputAction: TextInputAction.next,
              validator: (pprice) {
                if (pprice.isEmpty) {
                  return "*Required";
                } else {
                  prices[index] = int.parse(pprice);
                  return null;
                }
              },
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  labelText: 'Price',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  fillColor: Colors.white),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Flexible(
            child: TextFormField(
              onFieldSubmitted: (term) {
                FocusScope.of(context).unfocus();
                FocusScope.of(context).nextFocus();
              },
              textInputAction: TextInputAction.next,
              controller: oprice_controller[index],
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: numwl,
              validator: (pprice) {
                if (pprice.isEmpty) {
                  oprices[index] = prices[index];
                  return null;
                } else {
                  oprices[index] = int.parse(pprice);
                  return null;
                }
              },
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  labelText: 'MRP',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  fillColor: Colors.white),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Flexible(
            child: TextFormField(
              onFieldSubmitted: (term) {
                FocusScope.of(context).unfocus();
                FocusScope.of(context).nextFocus();
              },
              textInputAction: TextInputAction.next,
              controller: quan_controller[index],
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: numwl,
              validator: (pprice) {
                if (pprice.isEmpty) {
                  quans[index] = 0;
                } else {
                  quans[index] = int.parse(pprice);
                }
                return null;
              },
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  fillColor: Colors.white),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black)),
              child: DropdownButton<String>(
                elevation: 0,
                autofocus: true,
                dropdownColor: Colors.greenAccent,
                iconSize: 16,
                isExpanded: true,
                value: units[index],
                items: <String>['', 'kg', 'gm', 'l', 'ml', 'units']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == '' ? '-' : value),
                  );
                }).toList(),
                onChanged: (String value) {
                  setState(() {
                    units[index] = value;
                    FocusScope.of(context).unfocus();
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, animation) {
    //Widget item = _items[index];
    return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: getWidget(index));
  }

  Widget buildItem(BuildContext context, int index, animation, price) {
    return getOldWidget(index, price);
  }

  uploadProduct() async {
    FocusScope.of(context).unfocus();

    product = {
      'n': name,
      'c': int.parse(cat),
      'p': count,
      'd': desc,
      'id': widget.snap['id'],
      's': widget.snap['s'],
      'o': widget.snap['o'],
      'a': true
    };

    for (int i = 1; i <= count; i++) {
      product['p${i}'] = prices[i - 1];
      product['dp${i}'] = prices[i - 1];
      product['m${i}'] = oprices[i - 1];
      product['q${i}'] = quans[i - 1];
      product['u${i}'] = units[i - 1];
    }
    product['i'] = widget.snap['i'];

    if (imageChanged) {
      final StorageUploadTask uploadTask = FirebaseStorage()
          .ref()
          .child(
              'Images/${Storage.APP_NAME_ + '_' + Storage.APP_LOCATION}/products')
          .child(widget.snap['id'])
          .putFile(image);
      final StorageTaskSnapshot snapshot = await uploadTask.onComplete;
      String img = await snapshot.ref.getDownloadURL();
      product['i'] = img.substring(img.indexOf('ken=') + 4);
    }
    await FirebaseFirestore.instance
        .collection('shop')
        .doc(Storage.APP_NAME_ + '_' + Storage.APP_LOCATION)
        .collection('prods')
        .doc(widget.snap['id'])
        .set(product);
    setState(() {
      uploading = false;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              if (!uploading) {
                setState(() {
                  uploading = true;
                });
                if (formkey.currentState.validate()) {
                  uploadProduct();
                } else {
                  setState(() {
                    uploading = false;
                  });
                }
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.indigo),
            ),
          ),
        ],
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
        title: Text(
          'Modify',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: <Widget>[
          AbsorbPointer(
            absorbing: uploading,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              getImage();
                            },
                            child: Container(
                              color: Colors.white,
                              height: 100,
                              width: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image(
                                  image: image == null
                                      ? NetworkImage(Storage.getImageURL(
                                              widget.snap['id']) +
                                          widget.snap['i'])
                                      : FileImage(image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              RaisedButton(
                                color: Color(0xff0011FF),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                onPressed: () {
                                  getImage();
                                },
                                child: Text(
                                  'Add Image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              if (image != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          image = null;
                                          imageChanged = false;
                                        });
                                      },
                                      child: Text(
                                        'Remove Image',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 16),
                                      )),
                                )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Theme(
                        data: ThemeData(primaryColor: Colors.black),
                        child: Form(
                            key: formkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextFormField(
                                  controller: name_controller,
                                  maxLines: 1,
                                  onFieldSubmitted: (term) {
                                    FocusScope.of(context).unfocus();
                                    FocusScope.of(context).nextFocus();
                                  },
                                  validator: (pname) {
                                    if (pname.isEmpty) {
                                      return "Please enter Product Name.";
                                    } else {
                                      name = pname;
                                      return null;
                                    }
                                  },
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                      labelText: 'Product Name',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      fillColor: Colors.white),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(' Category'),
                                SizedBox(
                                  height: 1,
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.black)),
                                  child: DropdownButton<String>(
                                    elevation: 0,
                                    autofocus: true,
                                    dropdownColor: Colors.greenAccent,
                                    iconSize: 32,
                                    isExpanded: true,
                                    value: cat,
                                    items: List.generate(
                                        Storage.categories.length,
                                        (i) => DropdownMenuItem<String>(
                                              value: i.toString(),
                                              child:
                                                  Text(Storage.categories[i]),
                                            )),
                                    onChanged: (value) {
                                      setState(() {
                                        cat = value;
                                        FocusScope.of(context).unfocus();
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                TextFormField(
                                  controller: desc_controller,
                                  maxLines: 3,
                                  onFieldSubmitted: (term) {
                                    FocusScope.of(context).unfocus();
                                    FocusScope.of(context).nextFocus();
                                  },
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (pname) {
                                    desc = pname;
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 8),
                                      labelText: 'Description',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      fillColor: Colors.white),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Container(
                                    height: 210,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            child: AnimatedList(
                                              key: listKey,
                                              initialItemCount:
                                                  widget.snap['p'],
                                              itemBuilder:
                                                  (context, index, animation) {
                                                return _buildItem(
                                                    context, index, animation);
                                              },
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                if (count <= 1) return;
                                                price_controller.removeLast();
                                                oprice_controller.removeLast();
                                                quan_controller.removeLast();
                                                units.removeLast();
                                                prices.removeLast();
                                                oprices.removeLast();
                                                quans.removeLast();
                                                count--;
                                                listKey.currentState.removeItem(
                                                    /*_items.length - 1*/
                                                    count,
                                                    (_, animation) =>
                                                        _buildItem(
                                                            context,
                                                            /*_items.length - 1*/
                                                            count - 1,
                                                            animation),
                                                    duration: const Duration(
                                                        milliseconds: 500));
                                                setState(() {});
                                                /*setState(() {
                                                  _items.removeLast();
                                                });*/
                                              },
                                              child: Text(
                                                "Remove",
                                              ),
                                            ),
                                            FlatButton(
                                              onPressed: () {
                                                setState(() {
                                                  price_controller.add(
                                                      new TextEditingController());
                                                  oprice_controller.add(
                                                      new TextEditingController());
                                                  quan_controller.add(
                                                      new TextEditingController());
                                                  units.add('');
                                                  prices.add(0);
                                                  oprices.add(0);
                                                  quans.add(0);
                                                  count++;
                                                  listKey.currentState
                                                      .insertItem(
                                                          /*_items.length*/
                                                          count - 1,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500));
                                                  setState(() {});
                                                  /*_items = []
                                                    ..addAll(_items)
                                                    ..add(getWidget(
                                                        _items.length));*/
                                                });
                                              },
                                              child: Text(
                                                "Add",
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ))
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (uploading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[CircularProgressIndicator()],
              ),
            )
        ],
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
}
