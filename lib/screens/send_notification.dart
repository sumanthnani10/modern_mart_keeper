import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../service/notification_handler.dart';
import '../storage.dart';

class SendNotification extends StatefulWidget {
  @override
  _SendNotificationState createState() => _SendNotificationState();
}

class _SendNotificationState extends State<SendNotification> {
  TextEditingController msg_controller = new TextEditingController();
  TextEditingController title_controller = new TextEditingController();
  String title = '', msg = '';
  final formkey = GlobalKey<FormState>();

  bool loading = false;

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
          'Send Notification',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                if (formkey.currentState.validate()) {
                  setState(() {
                    loading = true;
                  });
                  Storage.customers.keys.forEach((c) async {
                    await NotificationHandler.instance.init(context);
                    await NotificationHandler.instance
                        .sendMessage(title, msg, Storage.customers[c]['nt']);
                  });
                  FirebaseFirestore.instance
                      .collection('shop')
                      .doc(Storage.APP_NAME_ + '_' + Storage.APP_LOCATION)
                      .update({
                    'ns': FieldValue.arrayUnion([
                      {'tle': title, 'msg': msg}
                    ])
                  });
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.send),
              label: Text(
                'Send',
                style: TextStyle(color: Colors.blue),
              ))
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formkey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
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
                        if (pname == '') return 'Required';
                        title = pname;
                        return null;
                      },
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          labelStyle: TextStyle(color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          labelText: 'Title',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.white),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: msg_controller,
                      maxLines: 15,
                      onFieldSubmitted: (term) {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(context).nextFocus();
                      },
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      validator: (pname) {
                        if (pname == '') return 'Required';
                        msg = pname;
                        return null;
                      },
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          labelStyle: TextStyle(color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          labelText: 'Message',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (loading)
            Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
