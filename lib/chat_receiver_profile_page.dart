import 'package:chatapp/chatDetailPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'image_grid.dart';
import 'media_view_page.dart';

class ReceiverProfilePage extends StatefulWidget {
  final recid;
  final name;
  final total_msg;
  final text_msg;
  final media_msg;

  ReceiverProfilePage(
      {required this.recid,
      this.name,
      this.total_msg,
      this.text_msg,
      this.media_msg});

  @override
  State<ReceiverProfilePage> createState() => _ReceiverProfilePageState();
}

class _ReceiverProfilePageState extends State<ReceiverProfilePage> {
  final _db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> imageUrls = [];

  @override
  void initState() {
    super.initState();
    // Get the image URL fields from Firebase
    FirebaseFirestore.instance
        .collection("chat")
        .doc(auth.currentUser!.uid + widget.recid)
        .collection("chat_details")
        .where("url", isNotEqualTo: "")
        .snapshots()
        .listen((event) {
      for (var doc in event.docs) {
        int ts = int.parse(doc.data()['timestamp']);
        DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(ts);
        var date = DateFormat('y, MMM d  hh:mm a').format(tsdate);

        FirebaseFirestore.instance
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
      print("url in CA: ${imageUrls.join(", ")}");
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.recid);
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
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back),
                ),
                Text(widget.name, style: Theme.of(context).textTheme.headline6)
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _db.collection("users").doc(widget.recid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
                                      time: "",
                                    )),
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.teal,
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data!.get('img')),
                              radius: 78,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 18,
                          right: 8,
                          child: snapshot.data!.get('state') == 'Online'
                              ? Icon(
                                  Icons.circle,
                                  color: Colors.teal,
                                )
                              : Container()),
                    ]),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Since ' + snapshot.data!.get('joined'),
                        style: TextStyle(color: Colors.grey)),
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
                                    child: Text(snapshot.data!.get('status')),
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
                                child: Text(snapshot.data!.get('phno'))))
                      ]),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    InkWell(
                      onTap: () => imageUrls.length != 0
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageGrid(
                                    name: widget.name,
                                    room: auth.currentUser!.uid.toString() +
                                        widget.recid.toString(),
                                    type: 0),
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
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MediaViewPage(
                                              image: url['url'],
                                              name: url['senderName'],
                                              time: url['timestamp']),
                                        ),
                                      ),
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
      bottomNavigationBar: ElevatedButton(
          onPressed: () {
            picker(context);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
              elevation: 0,
              side: const BorderSide(
                width: 1.0,
                color: Colors.green,
              )),
          child: const Text('Clear All Chats',
              style: TextStyle(color: Colors.green))),
    );
  }

  void picker(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Clear'),
          content: Text('Are you sure you want to clear all messages?'),
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
              child: Text('Clear'),
            ),
          ],
        );
      },
    ).then((value) async {
      if (value == true) {
        final collectionRef = FirebaseFirestore.instance
            .collection('chat')
            .doc(senderRoom)
            .collection('chat_details');
        final docsSnapshot = await collectionRef.get();

        for (final docSnapshot in docsSnapshot.docs) {
          await docSnapshot.reference.delete();
        }
      } else {
        // User cancelled delete action, handle accordingly
      }
    });
  }
}
