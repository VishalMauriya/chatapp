import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  final doc;

  UserListScreen({required this.doc});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User user = FirebaseAuth.instance.currentUser!;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  List selectedMembers = [];
  bool search = false;
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.keyboard_backspace,
                  color: Colors.black,
                ),
              ),
              Text('Add Members',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              Spacer(),
              IconButton(
                onPressed: () => setState(() {
                  search = search ? false : true;
                }),
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
              ),
            ],
          )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Selected members (${selectedMembers.length})',
              style: TextStyle(fontSize: 16.0, color: Colors.teal),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: selectedMembers
                  .map((member) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedMembers.remove(member);
                                });
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(member['img']),
                                radius: 30,
                                child: null,
                              ),
                            ),
                            Positioned(
                              right: -2,
                              top: 40,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 10,
                                child: Icon(
                                  Icons.close,
                                  size: 17,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          selectedMembers.length != 0
              ? SizedBox(
                  height: 20,
                )
              : SizedBox(),
          search
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
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
                  ),
                )
              : Container(),
          Expanded(
            child: StreamBuilder(
              stream: firestore.collection("group").doc(widget.doc).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }

                var members =
                    snapshot.data!.data()!['members'] as List<dynamic>;
                var admins = snapshot.data!.data()!['admins'] as List<dynamic>;
                members.removeWhere((item) =>
                    admins.any((other) => other['phno'] == item['phno']));
                members.addAll(admins);
                print(members);

                return StreamBuilder<QuerySnapshot>(
                  stream: firestore.collection('users').snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final List<QueryDocumentSnapshot> users =
                        snapshot.data!.docs;
                    List<DocumentSnapshot> filteredUsers = users;
                    if (searchController.text.isNotEmpty) {
                      filteredUsers = users
                          .where((user) => user
                              .get('name')
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase()))
                          .toList();
                    }

                    if (filteredUsers.isNotEmpty) {
                      return ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (BuildContext context, int index) {
                          // final QueryDocumentSnapshot user = users[index];
                          var user = filteredUsers[index].data()
                              as Map<String, dynamic>;
                          var userID = filteredUsers[index].id;
                          user['uid'] = userID;
                          bool found = false;

                          members.forEach((member) {
                            if (userID == member['uid']) {
                              found = true;
                            }
                          });

                          return userID != uid
                              ? (found
                                  ? AnimatedOpacity(
                                      opacity: 0.5,
                                      // set the starting opacity level here
                                      duration: Duration(seconds: 1),
                                      // set the duration of the animation
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(user['img']),
                                          maxRadius: 25,
                                        ),
                                        title: Text(user['name']),
                                        subtitle: Text(user['phno']),
                                        onTap: () {
                                          // Handle user tap
                                        },
                                      ),
                                    )
                                  : ListTile(
                                      onTap: () => setState(() {
                                        if ((selectedMembers.singleWhere(
                                                (it) =>
                                                    it['phno'] == user['phno'],
                                                orElse: () => null)) !=
                                            null) {
                                          print('Already exists!');
                                        } else {
                                          selectedMembers.add(user);
                                        }
                                      }),
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(user['img']),
                                        maxRadius: 25,
                                      ),
                                      title: Text(user['name']),
                                      subtitle: Text(user['phno']),
                                    ))
                              : Container();
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
                'members': FieldValue.arrayUnion([...selectedMembers])
              })
              .then((value) => print("Member added"))
              .catchError((error) => print("Failed to add member: $error"));

          Navigator.pop(context);
        },
      ),
    );
  }
}
