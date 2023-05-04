import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'conversationList.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final chatUsers = snapshot.data!.docs;
            // Filter the chat users based on the search query
            List<DocumentSnapshot> filteredUsers = chatUsers;
            if (searchController.text.isNotEmpty) {
              filteredUsers = chatUsers
                  .where((user) => user
                      .get('name')
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()))
                  .toList();
            }

            if (filteredUsers.isNotEmpty) {
              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  var user =
                      filteredUsers[index].data() as Map<String, dynamic>;
                  var userID = filteredUsers[index].id;
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
                      int length = snapshot.data!.docs.length;
                      print(length);
                      int idx = length - 1;
                      var seen = true;
                      for (int i = idx; i >= 0; i--) {
                        if (snapshot.data!.docs[i].get("senderid") == userID) {
                          print(
                              "res of length $length if => ${snapshot.data!.docs[i].get("msg")} , ${snapshot.data!.docs[i].get("seen")}");
                          seen = snapshot.data!.docs[i].get("seen");
                          break;
                        }
                      }
                      var lastMessage = snapshot.data!.docs.isNotEmpty
                          ? snapshot.data!.docs.last.get("msg")
                          : "No message";
                      var senderid = snapshot.data!.docs.isNotEmpty
                          ? snapshot.data!.docs.last.get("senderid")
                          : "";
                      var lastTime = snapshot.data!.docs.isNotEmpty
                          ? snapshot.data!.docs[0].get("timestamp")
                          : "No time";
                      var time = "";
                      if (lastTime != 'No time') {
                        var date_time = DateTime.fromMillisecondsSinceEpoch(
                            int.parse(lastTime));
                        time = DateFormat("hh:mm a").format(date_time);
                      }

                      return Container(
                        color: searchController.text.isNotEmpty
                            ? Colors.blue.shade50
                            : Colors.transparent,
                        child: new ConversationList(
                          id: userID,
                          name: user["name"],
                          messageText: lastMessage,
                          imageUrl: user["img"],
                          time: time,
                          isMessageRead: seen,
                          messageType:
                              senderid == FirebaseAuth.instance.currentUser!.uid
                                  ? true
                                  : false,
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return Center(
                child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(50)),
                    child: Text(" 😅 No results found ")),
              );
            }
          },
        ),
      ),
    );
  }
}
