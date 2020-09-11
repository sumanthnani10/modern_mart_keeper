import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../storage.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  TextEditingController addCatFieldController = new TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AbsorbPointer(
          absorbing: loading,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              title: Text(
                'Categories',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: List.generate(
                    Storage.categories.length,
                    (index) => Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.black))),
                        child: ListTile(
                          title: Text(Storage.categories[index]),
                        ))),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 32,
              ),
              onPressed: () {
                _showDialogAdd('Category Name');
              },
              backgroundColor: Colors.white,
            ),
          ),
        ),
        if (loading) Center(child: CircularProgressIndicator())
      ],
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
              controller: addCatFieldController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.emailAddress,
              maxLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: "Category Name"),
              validator: (v) {
                if (v.isEmpty) {
                  return 'Enter Category Name';
                } else {
                  if (Storage.categories.contains(v)) {
                    return 'Category Already exists';
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
                      .collection('shop')
                      .doc(Storage.APP_NAME_ + '_' + Storage.APP_LOCATION)
                      .update({
                    'categories':
                        FieldValue.arrayUnion([addCatFieldController.text])
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
