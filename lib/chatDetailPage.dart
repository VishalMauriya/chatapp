import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'chat_receiver_profile_page.dart';
import 'full_screen_img.dart';
import 'media_view_page.dart';

var _recid;
var senderRoom;
var receiverRoom;

class chatDetailPage extends StatefulWidget {
  var title;
  var recid;

  chatDetailPage(this.title, this.recid) {
    _recid = recid;
    senderRoom = FirebaseAuth.instance.currentUser!.uid.toString() + _recid;
    receiverRoom = _recid + FirebaseAuth.instance.currentUser!.uid.toString();
  }

  @override
  State<chatDetailPage> createState() => _Chat_DetailState();
}

class _Chat_DetailState extends State<chatDetailPage> {
  final _selectedItems = Set<String>();
  final _selectedColor = Colors.green.shade200;
  var enabled = false;
  var state = '';
  var img = '';
  var title = '';
  var total_msg = 0;
  var text_msg = 0;
  var media_msg = 0;

  final _db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection("chat")
      .doc(senderRoom)
      .collection("chat_details")
      .snapshots();
  var _scrollController = ScrollController();

  _animateToLast() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 200),
    );
  }

  var senderRad = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20));
  var receiverRad = BorderRadius.only(
      bottomRight: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final docRef = FirebaseFirestore.instance.collection("users").doc(_recid);
    docRef.snapshots().listen(
          (event) => {
            setState(() {
              state = event.get('state');
              title = event.get('name');
              img = event.get('img');
            }),
          },
          onError: (error) => print("Listen failed: $error"),
        );

    setState(() {
      Timer(Duration(milliseconds: 300), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        Navigator.push(
          this.context,
          MaterialPageRoute(
            builder: (context) => FullScreenImage(
              type: 0,
              image: FileImage(File(pickedFile.path)),
              sender_room: senderRoom,
              reciever_room: receiverRoom,
              photo: File(pickedFile.path),
            ),
          ),
        );
        _animateToLast();
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
        Navigator.push(
          this.context,
          MaterialPageRoute(
            builder: (context) => FullScreenImage(
              type: 0,
              image: FileImage(File(pickedFile.path)),
              sender_room: senderRoom,
              reciever_room: receiverRoom,
              photo: File(pickedFile.path),
            ),
          ),
        );
        _animateToLast();
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var msg_controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                enabled
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedItems.clear();
                            enabled = false;
                          });
                        },
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.white,
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                SizedBox(
                  width: 2,
                ),
                enabled
                    ? Container()
                    : CircleAvatar(
                        backgroundImage: NetworkImage(img),
                        maxRadius: 20,
                      ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: !enabled
                      ? InkWell(
                          onTap: () => Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.scale,
                              alignment: Alignment.topCenter,
                              duration: Duration(milliseconds: 400),
                              isIos: true,
                              child: ReceiverProfilePage(
                                  recid: _recid,
                                  name: title,
                                  text_msg: text_msg,
                                  media_msg: media_msg,
                                  total_msg: total_msg),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                title,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                state,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          _selectedItems.length.toString() + " Selected",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                ),
                InkWell(
                    onTap: () async {
                      if (_selectedItems.length > 0) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm delete'),
                              content: Text(
                                  'Are you sure you want to delete the selected items?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Delete For All'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    for (var item in _selectedItems) {
                                      print("Item => $item");
                                      var docRef = FirebaseFirestore.instance
                                          .collection('chat')
                                          .doc(senderRoom)
                                          .collection("chat_details")
                                          .doc(item);
                                      await docRef.delete();

                                      var docRef1 = FirebaseFirestore.instance
                                          .collection('chat')
                                          .doc(receiverRoom)
                                          .collection("chat_details")
                                          .doc(item);
                                      await docRef1.delete();
                                    }
                                    //update the data
                                    setState(() {
                                      _selectedItems.clear();
                                      enabled = false;
                                    });
                                  },
                                ),
                                TextButton(
                                  child: Text('Delete For Me'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    for (var item in _selectedItems) {
                                      print("Item => $item");
                                      var docRef = FirebaseFirestore.instance
                                          .collection('chat')
                                          .doc(senderRoom)
                                          .collection("chat_details")
                                          .doc(item);
                                      await docRef.delete();
                                    }
                                    //update the data
                                    setState(() {
                                      _selectedItems.clear();
                                      enabled = false;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Icon(
                      enabled ? Icons.delete_forever : Icons.settings,
                      color: enabled ? Colors.red : Colors.black54,
                    )),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 60),
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: const CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  print("Document does not exist testing");
                  return Text("No Data!");
                }
                if (snapshot.data!.size == 0)
                  return Center(
                    child: Container(
                      height: 100,
                      child: Column(
                        children: [
                          Text(
                            '😄',
                            style: TextStyle(fontSize: 40),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Start New Conversation'),
                        ],
                      ),
                    ),
                  );
                List<DocumentSnapshot> docs = snapshot.data!.docs;
                total_msg = docs.length;
                media_msg = 0;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (docs[index]['url'] != '') media_msg += 1;
                    text_msg = total_msg - media_msg;
                    final isSelected = _selectedItems.contains(docs[index].id);
                    final sender = docs[index]['senderid'] ==
                            FirebaseAuth.instance.currentUser!.uid
                        ? true
                        : false;
                    final date_time = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(docs[index]['timestamp']));
                    final time = DateFormat("hh:mm a").format(date_time);
                    if (docs[index]['senderid'] == _recid &&
                        docs[index]['seen'] == false) {
                      FirebaseFirestore.instance
                          .collection("chat")
                          .doc(senderRoom)
                          .collection("chat_details")
                          .doc(docs[index].id.toString())
                          .update({'seen': true});

                      FirebaseFirestore.instance
                          .collection("chat")
                          .doc(receiverRoom)
                          .collection("chat_details")
                          .doc(docs[index].id.toString())
                          .update({'seen': true});
                    }
                    return Container(
                      color: isSelected ? _selectedColor : null,
                      child: ListTile(
                        title: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: sender
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: <Widget>[
                              !sender
                                  ? Container(
                                      width: 3,
                                      height: double.infinity,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                    )
                                  : Container(),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment: sender
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: <Widget>[
                                  docs[index]['url'] != ""
                                      ? InkWell(
                                          onTap: () {
                                            int ts = int.parse(
                                                docs[index]['timestamp']);
                                            DateTime tsdate = DateTime
                                                .fromMillisecondsSinceEpoch(ts);
                                            var date =
                                                DateFormat('y, MMM d  hh:mm a')
                                                    .format(tsdate);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MediaViewPage(
                                                  image: docs[index]['url'],
                                                  name: widget.title,
                                                  time: date,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 200.0,
                                            height: 250.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              border: Border.all(
                                                  color: Colors.grey, width: 4),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    docs[index]['url']),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  docs[index]['url'] != ""
                                      ? SizedBox(
                                          height: 10,
                                        )
                                      : Container(),
                                  docs[index]['msg'] != ""
                                      ? ConstrainedBox(
                                          constraints:
                                              BoxConstraints(maxWidth: 300),
                                          child: Text(
                                            docs[index]['msg'],
                                          ),
                                        )
                                      : Container(),
                                  Text(
                                    time,
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              sender
                                  ? Container(
                                      width: 3,
                                      height: double.infinity,
                                      margin: const EdgeInsets.only(left: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        subtitle: docs.length - 1 == index &&
                                docs[index]['senderid'] ==
                                    FirebaseAuth.instance.currentUser!.uid &&
                                docs[index]['seen'] == true
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("Seen"),
                                  Icon(Icons.face),
                                ],
                              )
                            : null,
                        selectedColor: Colors.white,
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            if (enabled) {
                              if (isSelected) {
                                _selectedItems.remove(docs[index].id);
                              } else {
                                _selectedItems.add(docs[index].id);
                              }
                            }

                            if (_selectedItems.length == 0) enabled = false;
                          });

                          print(_selectedItems.toString());
                        },
                        onLongPress: () {
                          enabled = true;
                          setState(() {
                            if (!isSelected) {
                              _selectedItems.add(docs[index].id);
                            }
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      onTap: () {
                        Timer(Duration(milliseconds: 600), () {
                          _animateToLast();
                        });
                      },
                      controller: msg_controller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(2),
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      var msg = msg_controller.text.trim().toString();
                      if (msg == '') return;
                      String timestamp =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      msg_controller.clear();

                      DocumentReference<Map<String, dynamic>> ref =
                          _db.collection('chat').doc(senderRoom);

                      await ref.collection('chat_details').doc(timestamp).set({
                        'senderid': auth.currentUser!.uid,
                        'msg': msg,
                        'url': '',
                        'seen': false,
                        'timestamp': timestamp
                      });

                      DocumentReference<Map<String, dynamic>> ref2 =
                          _db.collection('chat').doc(receiverRoom);

                      await ref2.collection('chat_details').doc(timestamp).set({
                        'senderid': auth.currentUser!.uid,
                        'msg': msg,
                        'url': '',
                        'seen': false,
                        'timestamp': timestamp // 42
                      });

                      _animateToLast();
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
                      leading:
                          CircleAvatar(child: new Icon(Icons.photo_library)),
                      title: new Text('Gallery'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: CircleAvatar(child: new Icon(Icons.photo_camera)),
                    title: new Text('Camera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
