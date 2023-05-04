import 'package:chatapp/media_view_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var name_ctrl = TextEditingController();
  var status_ctrl = TextEditingController();
  var phone_ctrl = TextEditingController();
  bool isLoading = false;

  Future<void> _getImage(var str) async {
    final ref = FirebaseStorage.instance.ref().child(str);
    var imageURL = await ref.getDownloadURL();
    print("url => $imageURL");
    _db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .update({"img": imageURL});

    setState(() {
      isLoading = false;
    });
  }

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    setState(() {
      isLoading = true;
    });
    final fileName = basename(_photo!.path);
    final destination = 'files/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file/');
      await ref.putFile(_photo!);
      _getImage('files/$fileName/file');
    } catch (e) {
      print('error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: SafeArea(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _db.collection("users").doc(auth.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            name_ctrl.text = snapshot.data!.get('name');
            status_ctrl.text = snapshot.data!.get('status');
            phone_ctrl.text = snapshot.data!.get('phno');
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Stack(children: [
                      Hero(
                        tag: 'bg',
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MediaViewPage(
                                      image: snapshot.data!.get('img'),
                                      name: snapshot.data!.get('name'),
                                      time: snapshot.data!.get('joined'),
                                    )),
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.teal,
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data!.get('img')),
                              radius: 78,
                              child: isLoading
                                  ? CircularProgressIndicator()
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              _showPicker(context);
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.teal,
                              child: Icon(
                                Icons.camera,
                                color: Colors.white,
                              ),
                            ),
                          )),
                    ]),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Since ' + snapshot.data!.get('joined'),
                        style: TextStyle(color: Colors.grey)),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          TextField(
                            controller: name_ctrl,
                            onSubmitted: (value) {
                              _db
                                  .collection("users")
                                  .doc(auth.currentUser!.uid)
                                  .update({"name": value});
                            },
                            onTap: () => name_ctrl.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: name_ctrl.value.text.length),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.account_circle_rounded),
                              suffixIcon: Icon(Icons.edit),
                              label: Text('Name'),
                            ),
                          ),
                          TextField(
                            controller: status_ctrl,
                            onSubmitted: (value) {
                              _db
                                  .collection("users")
                                  .doc(auth.currentUser!.uid)
                                  .update({"status": value});
                            },
                            onTap: () => status_ctrl.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: status_ctrl.value.text.length),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.history_edu_rounded),
                              suffixIcon: Icon(Icons.edit),
                              label: Text('Status'),
                            ),
                          ),
                          TextField(
                            controller: phone_ctrl,
                            onSubmitted: (value) {
                              _db
                                  .collection("users")
                                  .doc(auth.currentUser!.uid)
                                  .update({"phno": value});
                            },
                            onTap: () => phone_ctrl.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: phone_ctrl.value.text.length),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.phone),
                              suffixIcon: Icon(Icons.edit),
                              label: Text('Phone'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(
                        Icons.photo_library,
                        color: Colors.teal,
                      ),
                      title: new Text('Gallery'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(
                      Icons.photo_camera,
                      color: Colors.teal,
                    ),
                    title: new Text('Camera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                      leading: new Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.red,
                      ),
                      title: new Text('Remove Photo'),
                      onTap: () {
                        _db
                            .collection("users")
                            .doc(auth.currentUser!.uid)
                            .update({
                          "img": 'https://firebasestorage.googleapis.com/v0/b/chatapp-a9ffd.appspot.com/o/files%2F'
                              'download.png?alt=media&token=70377c5b-aa5e-4bb7-93ed-e4515bd199fb'
                        });
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          );
        });
  }
}
