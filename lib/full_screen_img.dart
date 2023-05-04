import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FullScreenImage extends StatelessWidget {
  final type;
  final doc;
  final image;
  final photo;
  final sender_room;
  final reciever_room;
  final _db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  var msg_controller = TextEditingController();

  FullScreenImage(
      {required this.type,
      required this.image,
      this.sender_room,
      this.reciever_room,
      this.photo,
      this.doc});

  Future uploadFile() async {
    if (photo == null) return;
    final fileName = basename(photo!.path);
    final destination = 'files/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file/');
      await ref.putFile(photo!);
      return fileName;
    } catch (e) {
      print('error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image(image: image),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                  height: 60,
                  width: double.infinity,
                  color: Colors.black,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: msg_controller,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(2),
                              hintText: "Write message...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      FloatingActionButton(
                        onPressed: () async {
                          var fileName = await uploadFile();
                          final storage = FirebaseStorage.instance
                              .ref()
                              .child('files/$fileName/file');
                          var imageURL = await storage.getDownloadURL();
                          var msg = msg_controller.text.trim().toString();
                          String timestamp =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          msg_controller.clear();
                          String time =
                              DateFormat("hh:mm a").format(DateTime.now());

                          if (type == 0) {
                            DocumentReference<Map<String, dynamic>> ref =
                                _db.collection('chat').doc(sender_room);

                            await ref
                                .collection('chat_details')
                                .doc(timestamp)
                                .set({
                              'senderid': auth.currentUser!.uid,
                              'msg': msg,
                              'seen': false,
                              'url': imageURL,
                              'timestamp': timestamp
                            });

                            DocumentReference<Map<String, dynamic>> ref2 =
                                _db.collection('chat').doc(reciever_room);

                            await ref2
                                .collection('chat_details')
                                .doc(timestamp)
                                .set({
                              'senderid': auth.currentUser!.uid,
                              'msg': msg,
                              'seen': false,
                              'url': imageURL,
                              'timestamp': timestamp // 42
                            });
                          } else if (type == 1) {
                            print("doc is : " + doc);
                            DocumentReference<Map<String, dynamic>> ref =
                                _db.collection('group').doc(doc);

                            await ref
                                .collection('chat_details')
                                .doc(timestamp)
                                .set({
                              'senderid': auth.currentUser!.uid,
                              'msg': msg,
                              'url': imageURL,
                              'seen': false,
                              'timestamp': timestamp
                            });
                          } else {}

                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                        backgroundColor: Colors.blue,
                        elevation: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
