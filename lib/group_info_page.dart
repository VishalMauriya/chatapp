import 'dart:async';
import 'dart:io';
import 'package:chatapp/chatDetailPage.dart';
import 'package:chatapp/user_list_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'image_grid.dart';
import 'media_view_page.dart';
import 'package:path/path.dart';

class GroupInfoPage extends StatefulWidget {
  final doc;
  final name;
  final total_msg;
  final text_msg;
  final media_msg;

  GroupInfoPage(
      {required this.doc,
      this.name,
      this.total_msg,
      this.text_msg,
      this.media_msg});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final _db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String _groupName = '';
  String _groupDescription = '';
  int _descriptionMaxLength = 100;
  int _groupNameMaxLength = 30;
  List<Map<String, dynamic>> imageUrls = [];
  bool isAdmin = false;
  bool isMember = false;
  late var currentMember;

  @override
  void initState() {
    super.initState();
    // Get the image URL fields from Firebase
    _db
        .collection("group")
        .doc(widget.doc)
        .collection("chat_details")
        .where("url", isNotEqualTo: "")
        .snapshots()
        .listen((event) {
      for (var doc in event.docs) {
        int ts = int.parse(doc.data()['timestamp']);
        DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(ts);
        var date = DateFormat('y, MMM d  hh:mm a').format(tsdate);

        _db
            .collection("users")
            .doc(doc.data()['senderid'])
            .get()
            .then((userData) {
          String userName = userData.data()!['name'];

          setState(() {
            // imageUrls.add(doc.data());
            imageUrls.add({
              'timestamp': date,
              'url': doc.data()['url'],
              'senderName': userName,
            });
          });
        });
      }
      print("url in groups: ${imageUrls.join(", ")}");
    });

    final docRef = _db.collection("group").doc(widget.doc);
    docRef.snapshots().listen(
      (event) {
        var members = event.data()!['members'];
        var admins = event.data()!['admins'];

        admins.forEach((admin) {
          if (auth.currentUser!.uid == admin['uid']) {
            setState(() {
              isAdmin = true;
              currentMember = admin;
            });
          }
        });

        members.forEach((member) {
          if (auth.currentUser!.uid == member['uid']) {
            setState(() {
              isMember = true;
              currentMember = member;
            });
          }
        });
      },
      onError: (error) {
        print("Listen failed: $error");
      },
    );
  }

  bool isLoading = false;

  Future<void> _getImage(var str) async {
    final ref = FirebaseStorage.instance.ref().child(str);
    var imageURL = await ref.getDownloadURL();
    print("url => $imageURL");
    _db.collection("group").doc(widget.doc).update({"url": imageURL});

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
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back),
                ),
                Text(widget.name, style: Theme.of(context).textTheme.headline6),
                Spacer(),
                isAdmin
                    ? IconButton(
                        onPressed: () => _editPicker(context),
                        icon: Icon(Icons.edit),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _db.collection("group").doc(widget.doc).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var members = snapshot.data!.data()!['members'] as List<dynamic>;
            var admins = snapshot.data!.data()!['admins'] as List<dynamic>;

            DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(
                snapshot.data!.get('created_on'));
            var date = DateFormat('MMM d, y').format(tsdate);
            members.removeWhere(
                (item) => admins.any((other) => other['phno'] == item['phno']));

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Stack(children: [
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MediaViewPage(
                                    image: snapshot.data!.get('url'),
                                    name: snapshot.data!.get('title'),
                                    time: "",
                                  )),
                        ),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.teal,
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(snapshot.data!.get('url')),
                            radius: 78,
                            child:
                                isLoading ? CircularProgressIndicator() : null,
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 5,
                          child: isAdmin
                              ? GestureDetector(
                                  onTap: () {
                                    _showPicker(context);
                                  },
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.teal,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Container()),
                    ]),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Since ' + date, style: TextStyle(color: Colors.grey)),
                    Container(
                      padding: EdgeInsets.only(
                          top: 30, bottom: 30, left: 10, right: 10),
                      child: Stack(children: [
                        Align(
                          alignment: Alignment.center,
                          child: Card(
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.lightBlue,
                              ),
                              borderRadius:
                                  BorderRadius.circular(10.0), //<-- SEE HERE
                            ),
                            child: Container(
                              width: 300,
                              child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 120,
                                        bottom: 10,
                                        left: 16,
                                        right: 16),
                                    child: Text(snapshot.data!.get('subtitle')),
                                  )),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 45,
                          left: 18,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Card(
                                  elevation: 2,
                                  shadowColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        10.0), //<-- SEE HERE
                                  ),
                                  child: Container(
                                    width: 110,
                                    padding: const EdgeInsets.only(
                                        right: 16, left: 16, top: 8, bottom: 8),
                                    child: Column(
                                      children: [
                                        Text(
                                          (widget.total_msg - imageUrls.length)
                                              .toString(),
                                          style: TextStyle(fontSize: 25),
                                        ),
                                        Text(
                                          'Text',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        )
                                      ],
                                    ),
                                  )),
                              Card(
                                  elevation: 2,
                                  shadowColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        10.0), //<-- SEE HERE
                                  ),
                                  child: Container(
                                    width: 110,
                                    padding: const EdgeInsets.only(
                                        right: 16, left: 16, top: 8, bottom: 8),
                                    child: Column(
                                      children: [
                                        Text(
                                          widget.total_msg.toString(),
                                          style: TextStyle(fontSize: 25),
                                        ),
                                        Text(
                                          'Total',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        )
                                      ],
                                    ),
                                  )),
                              Card(
                                  elevation: 2,
                                  shadowColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        10.0), //<-- SEE HERE
                                  ),
                                  child: Container(
                                    width: 110,
                                    padding: const EdgeInsets.only(
                                        right: 16, left: 16, top: 8, bottom: 8),
                                    child: Column(
                                      children: [
                                        Text(
                                          imageUrls.length.toString(),
                                          style: TextStyle(fontSize: 25),
                                        ),
                                        Text(
                                          'Media',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        )
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Center(
                            child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.blue.shade200,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(snapshot.data!.get('title'))))
                      ]),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    isMember
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () => picker(context, 0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.message,
                                      color: Colors.green,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Clear Chats',
                                      style: TextStyle(color: Colors.green),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserListScreen(doc: widget.doc),
                                    )),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.group,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Add Member',
                                      style: TextStyle(color: Colors.blue),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => picker(context, 1),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Leave Group',
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 40,
                    ),
                    InkWell(
                      onTap: () => isMember && imageUrls.length != 0
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageGrid(
                                  name: widget.name,
                                  room: widget.doc,
                                  type: 1,
                                ),
                              ),
                            )
                          : null,
                      child: ListTile(
                        title: Text('Media Chats (${imageUrls.length})',
                            style: Theme.of(context).textTheme.bodySmall),
                        trailing: Icon(Icons.navigate_next_rounded),
                      ),
                    ),
                    Divider(),
                    imageUrls.length != 0
                        ? Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (var url in imageUrls)
                                    InkWell(
                                      onTap: () => isMember
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MediaViewPage(
                                                        image: url['url'],
                                                        name: url['senderName'],
                                                        time: url['timestamp']),
                                              ),
                                            )
                                          : null,
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2, color: Colors.white),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(url['url']),
                                          ),
                                        ),
                                      ),
                                    ), //C
                                ],
                              ),
                            ),
                          )
                        : Text('No Media!',
                            style: TextStyle(color: Colors.grey)),
                    Divider(),
                    ListTile(
                      title: Text(
                          'Group Members (${members.length + admins.length})',
                          style: Theme.of(context).textTheme.bodySmall),
                      trailing: Icon(Icons.arrow_drop_down),
                    ),
                    Container(
                      height: 700,
                      width: double.infinity,
                      child: ListView.builder(
                        itemCount: (admins.length + members.length),
                        itemBuilder: (context, index) {
                          if (index < admins.length) {
                            return ListTile(
                              onTap: () => admins[index]['uid'] !=
                                          auth.currentUser!.uid &&
                                      isMember
                                  ? showPicker(context, 0, admins[index])
                                  : null,
                              // onTap: () => showPicker(context, 0, admins[index]),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(admins[index]['img']),
                                maxRadius: 25,
                              ),
                              title: Text(admins[index]['name']),
                              subtitle: Text(admins[index]['status']),
                              trailing: Container(
                                height: 20,
                                width: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green),
                                    borderRadius: BorderRadius.circular(5)),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Center(
                                      child: Text(
                                    'admin',
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 10),
                                  )),
                                ),
                              ),
                            );
                          } else {
                            return ListTile(
                              onTap: () => members[index - admins.length]
                                              ['uid'] !=
                                          auth.currentUser!.uid &&
                                      isMember
                                  ? showPicker(context, 1,
                                      members[index - admins.length])
                                  : null,
                              // onTap: () => showPicker(context, 1, members[index-admins.length]),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    members[index - admins.length]['img']),
                                maxRadius: 25,
                              ),
                              title: Text(
                                  "${members[index - admins.length]['name']}"),
                              subtitle: Text(
                                  members[index - admins.length]['status']),
                            );
                          }
                        },
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

  void showPicker(context, type, newAdmin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200],
          title: Text(newAdmin['name'],
              style: TextStyle(color: Colors.grey, fontSize: 15)),
          contentPadding: EdgeInsets.only(top: 5.0, bottom: 0.0),
          content: Container(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                isAdmin
                    ? ListTile(
                        leading: Icon(Icons.admin_panel_settings,
                            color: type == 0 ? Colors.red : Colors.blue),
                        title: Text(type == 0 ? 'Remove Admin' : 'Make Admin',
                            style: TextStyle(
                                color: type == 0 ? Colors.red : Colors.blue)),
                        onTap: () async {
                          if (type == 1) {
                            FirebaseFirestore.instance
                                .collection('group')
                                .doc(widget.doc)
                                .update({
                                  'admins': FieldValue.arrayUnion([newAdmin])
                                })
                                .then((value) => print("Admin value added"))
                                .catchError((error) =>
                                    print("Failed to add admin value: $error"));
                          } else {
                            FirebaseFirestore.instance
                                .collection('group')
                                .doc(widget.doc)
                                .update({
                                  'admins': FieldValue.arrayRemove([newAdmin])
                                })
                                .then((value) => print("Admin object deleted"))
                                .catchError((error) => print(
                                    "Failed to delete admin object: $error"));
                          }

                          Navigator.pop(context);
                        },
                      )
                    : Container(),
                isAdmin
                    ? ListTile(
                        leading: Icon(
                          Icons.person_remove,
                          color: Colors.teal,
                        ),
                        title: Text('Remove Member',
                            style: TextStyle(color: Colors.teal)),
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('group')
                              .doc(widget.doc)
                              .update({
                                'admins': FieldValue.arrayRemove([newAdmin])
                              })
                              .then((value) => print("Admin object deleted"))
                              .catchError((error) => print(
                                  "Failed to delete admin object: $error"));

                          FirebaseFirestore.instance
                              .collection('group')
                              .doc(widget.doc)
                              .update({
                                'members': FieldValue.arrayRemove([newAdmin])
                              })
                              .then((value) => print("Member object deleted"))
                              .catchError((error) => print(
                                  "Failed to delete member object: $error"));

                          Navigator.pop(context);
                        },
                      )
                    : Container(),
                ListTile(
                  leading: Icon(
                    Icons.message,
                    color: Colors.green,
                  ),
                  title: Text('Send Message',
                      style: TextStyle(color: Colors.green)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              chatDetailPage(newAdmin['name'], newAdmin['uid']),
                        ));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void picker(context, type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(type == 0 ? 'Confirm Clear' : 'Confirm Leave'),
          content: Text(type == 0
              ? 'Are you sure you want to clear all messages?'
              : 'Are you sure you want to leave group?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Dismiss dialog and return false
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Dismiss dialog and return true
              },
              child: Text(type == 0 ? 'Clear' : 'Leave'),
            ),
          ],
        );
      },
    ).then((value) async {
      if (value == true && type == 0) {
        final collectionRef = FirebaseFirestore.instance
            .collection('group')
            .doc(widget.doc)
            .collection('chat_details');
        final docsSnapshot = await collectionRef.get();

        for (final docSnapshot in docsSnapshot.docs) {
          await docSnapshot.reference.delete();
        }
      } else if (value == true && type == 1) {
        FirebaseFirestore.instance
            .collection('group')
            .doc(widget.doc)
            .update({
              'admins': FieldValue.arrayRemove([currentMember])
            })
            .then((value) => print("Admin object deleted"))
            .catchError(
                (error) => print("Failed to delete admin object: $error"));

        FirebaseFirestore.instance
            .collection('group')
            .doc(widget.doc)
            .update({
              'members': FieldValue.arrayRemove([currentMember])
            })
            .then((value) => print("Admin object deleted"))
            .catchError(
                (error) => print("Failed to delete admin object: $error"));
      } else {}
    });
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
                        _db.collection("group").doc(widget.doc).update({
                          "url": 'https://firebasestorage.googleapis.com/v0/b/chatapp-a9ffd.appspot.com/o/files%2F'
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

  void _editPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      initialValue: _groupName,
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: _groupNameMaxLength,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a group name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _groupName = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      initialValue: _groupDescription,
                      decoration: InputDecoration(
                        labelText: 'Group Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: _descriptionMaxLength,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a group description';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _groupDescription = value;
                        });
                      },
                    ),
                  ),
                  FloatingActionButton.extended(
                    label: Text('Save'),
                    backgroundColor: Colors.black,
                    icon: Icon(
                      Icons.done,
                      size: 24.0,
                    ),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('group')
                          .doc(widget.doc)
                          .update({
                            'title': _groupName,
                            'subtitle': _groupDescription
                          })
                          .then((value) => print("updated group"))
                          .catchError((error) =>
                              print("Failed to update value: $error"));

                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          );
        });
  }
}
