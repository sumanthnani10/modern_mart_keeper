import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../storage.dart';

class Sliders extends StatefulWidget {
  @override
  _SlidersState createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  Map<String, dynamic> sliders;

  bool uploading = false;

  Future deleteFile() async {
    setState(() {
      uploading = true;
    });
    await FirebaseStorage.instance
        .ref()
        .child('Sliders')
        .child('image1')
        .delete();
    await FirebaseFirestore.instance
        .collection('shop')
        .doc(Storage.APP_NAME_ + '_' + Storage.APP_LOCATION)
        .update({'sliders': []});
    setState(() {
      uploading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sliders = null;
    if (Storage.sliders.length != 0) {
      sliders = Storage.sliders[0];
    }
    print(sliders);
    return AbsorbPointer(
      absorbing: uploading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            'Banners',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Builder(
              builder: (context) {
                if (sliders !=
                    null /*sliders['title'] != null && sliders['url'] != null*/) {
                  return ExpansionTile(
                    title: Text(
                      sliders['title'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    leading: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/modern-mart.appspot.com/o/Sliders%2Fimage1?alt=media&token=' +
                          sliders['url'],
                      width: 50,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      AspectRatio(
                          aspectRatio: 4 / 2,
                          child: Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/modern-mart.appspot.com/o/Sliders%2Fimage1?alt=media&token=' +
                                sliders['url'],
                            fit: BoxFit.cover,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        sliders['title'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddImage()));
                              setState(() {});
                            },
                            child: Text(
                              'Change',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightGreen),
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              deleteFile();
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      )
                    ],
                  );
                } else {
                  return ExpansionTile(
                    title: Text(
                      "Modern Mart",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    leading: Image.asset(
                      'assets/logo/logo.jpg',
                      width: 50,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                    children: <Widget>[
                      AspectRatio(
                          aspectRatio: 4 / 2,
                          child: Image.asset(
                            'assets/logo/logo.jpg',
                            fit: BoxFit.cover,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Modern Mart",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddImage()));
                              setState(() {});
                            },
                            child: Text(
                              'Change',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightGreen),
                            ),
                          ),
                          FlatButton(
                            onPressed: () {},
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      )
                    ],
                  );
                }
              },
            ),
            if (uploading) Center(child: CircularProgressIndicator())
          ],
        ),
        /*floatingActionButton: new FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddImage()));
          },
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ),*/
      ),
    );
  }
}

class AddImage extends StatefulWidget {
  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  final formkey = GlobalKey<FormState>();
  File _image;
  String title = "";
  String uploadedurl = "";

  bool uploading = false;

  TextEditingController title_controller = new TextEditingController();

  void getImage() async {
    PickedFile image =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image.path);
    });
  }

  Future uploadfile() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('Sliders').child('image1');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;

    await storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        uploadedurl = fileURL.substring(fileURL.indexOf('token=') + 6);
      });
    });
    await FirebaseFirestore.instance
        .collection('shop')
        .doc(Storage.APP_NAME_ + '_' + Storage.APP_LOCATION)
        .update({
      'sliders': [
        {
          'url': uploadedurl,
          'title': title,
        }
      ]
    });
    Navigator.pop(context);
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
                  if (_image != null) {
                    uploadfile();
                  } else {
                    setState(() {
                      uploading = false;
                    });
                    _showDialog('Please Select an Image');
                  }
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
        iconTheme: IconThemeData(
          color: Colors.black,
          size: 32,
        ),
        title: Text(
          'Add Image',
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
                                  image: _image == null
                                      ? AssetImage(
                                          'assets/choose_an_image_ph.png')
                                      : FileImage(_image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
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
                          child: TextFormField(
                            controller: title_controller,
                            maxLines: 1,
                            onFieldSubmitted: (term) {
                              FocusScope.of(context).unfocus();
                              FocusScope.of(context).nextFocus();
                            },
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            validator: (pname) {
                              title = pname;
                              return null;
                            },
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                labelStyle: TextStyle(color: Colors.black),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                labelText: 'Title Name',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                fillColor: Colors.white),
                          ),
                        ),
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
