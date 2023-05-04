import 'package:chatapp/media_view_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImageGrid extends StatefulWidget {
  final name;
  final room;
  final type;

  ImageGrid({this.name, this.room, required this.type});

  @override
  _ImageGridState createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  List<Map<String, dynamic>> imageUrls = [];

  @override
  void initState() {
    super.initState();
    // Get the image URL fields from Firebase
    if (widget.type == 0) {
      FirebaseFirestore.instance
          .collection("chat")
          .doc(widget.room)
          .collection("chat_details")
          .where("url", isNotEqualTo: "")
          .snapshots()
          .listen((event) {
        for (var doc in event.docs) {
          setState(() {
            imageUrls.add(doc.data());
          });
        }
        print("url in CA: ${imageUrls.join(", ")}");
      });
    } else if (widget.type == 1) {
      FirebaseFirestore.instance
          .collection("group")
          .doc(widget.room)
          .collection("chat_details")
          .where("url", isNotEqualTo: "")
          .snapshots()
          .listen((event) {
        for (var doc in event.docs) {
          setState(() {
            imageUrls.add(doc.data());
          });
        }
        print("url in CA: ${imageUrls.join(", ")}");
      });
    } else {}
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: SafeArea(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back)),
                Text(widget.name),
                Text(
                  '( ' + imageUrls.length.toString() + ' )',
                  style: TextStyle(color: Colors.blue),
                )
              ],
            ),
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          crossAxisCount: 3,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(imageUrls[index]['senderid'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('Loading...');
                }
                final name = snapshot.data!['name'];
                int ts = int.parse(imageUrls[index]['timestamp']);
                DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(ts);
                var date = DateFormat('y, MMM d  hh:mm a').format(tsdate);

                return new GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MediaViewPage(
                            image: imageUrls[index]['url'],
                            name: name,
                            time: date),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.white),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(imageUrls[index]['url']),
                      ),
                    ),
                  ),
                );
              });
          //   new GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => MediaViewPage(
          //             image: imageUrls[index]['url'],
          //             name: imageUrls[index]['senderid'],
          //             time: imageUrls[index]['timestamp']
          //         ),
          //       ),
          //     );
          //   },
          //   child: Container(
          //     decoration: BoxDecoration(
          //       border: Border.all(width: 2, color: Colors.white),
          //       image: DecorationImage(
          //         fit: BoxFit.cover,
          //         image: NetworkImage(imageUrls[index]['url']),
          //       ),
          //     ),
          //   ),
          // );
        },
      ),
    );
  }
}
