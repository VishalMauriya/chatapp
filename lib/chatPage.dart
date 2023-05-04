import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'conversationList.dart';

class ChatPage extends StatefulWidget {
  const ChatPage();

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var ind = 0;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var user =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            var userID = snapshot.data!.docs[index].id;
            var room = FirebaseAuth.instance.currentUser!.uid.toString() +
                userID.toString();
            if (userID == FirebaseAuth.instance.currentUser!.uid)
              return Container();
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chat")
                  .doc(room)
                  .collection("chat_details")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  print("Document does not exist = > $room");
                  return Container();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: const CircularProgressIndicator());
                }

                var lastMessage = snapshot.data!.docs.isNotEmpty
                    ? snapshot.data!.docs.last.get("msg")
                    : "No message";
                bool seen = snapshot.data!.docs.isNotEmpty
                    ? snapshot.data!.docs.last.get("seen")
                    : true;
                var url = snapshot.data!.docs.isNotEmpty
                    ? snapshot.data!.docs.last.get("url")
                    : "";
                if (url != '') lastMessage = 'photo';
                var senderid = snapshot.data!.docs.isNotEmpty
                    ? snapshot.data!.docs.last.get("senderid")
                    : "";
                var lastTime = snapshot.data!.docs.isNotEmpty
                    ? snapshot.data!.docs[0].get("timestamp")
                    : "No time";
                var time = "";
                if (lastTime != 'No time') {
                  var date_time =
                      DateTime.fromMillisecondsSinceEpoch(int.parse(lastTime));
                  time = DateFormat("hh:mm a").format(date_time);
                }

                return snapshot.data!.docs.isNotEmpty
                    ? ConversationList(
                        id: userID,
                        name: user["name"],
                        messageText: lastMessage,
                        imageUrl: user["img"],
                        time: time,
                        isMessageRead: seen,
                        messageType: senderid !=
                                FirebaseAuth.instance.currentUser!.uid
                                    .toString()
                            ? false
                            : true,
                      )
                    : Container();
              },
            );
          },
        );
      },
    );
  }
}
