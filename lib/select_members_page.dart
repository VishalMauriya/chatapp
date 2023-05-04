import 'package:chatapp/new_group_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SelectedMembers extends StatefulWidget {
  @override
  _SelectedMembersState createState() => _SelectedMembersState();
}

class _SelectedMembersState extends State<SelectedMembers> {
  List selectedMembers = [];
  bool search = false;
  final searchController = TextEditingController();
  var len = 0;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: ListTile(
          title: Text('New Group',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(
              selectedMembers.length == 0
                  ? 'select participants'
                  : '${selectedMembers.length} of $len Members Selected',
              style: TextStyle(color: Colors.white, fontSize: 12)),
          trailing: IconButton(
            onPressed: () => setState(() {
              search = search ? false : true;
            }),
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Container(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final chatUsers = snapshot.data!.docs;
                  len = chatUsers.length - 1;
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
                        user['uid'] = userID;
                        if (userID == FirebaseAuth.instance.currentUser!.uid) {
                          if ((selectedMembers.singleWhere(
                                  (it) => it['phno'] == user['phno'],
                                  orElse: () => null)) !=
                              null) {
                            print('Already exists!');
                          } else {
                            selectedMembers.add(user);
                          }
                          return Container();
                        }

                        return Container(
                            color: searchController.text.isNotEmpty
                                ? Colors.blue.shade50
                                : Colors.transparent,
                            child: ListTile(
                              onTap: () => setState(() {
                                if ((selectedMembers.singleWhere(
                                        (it) => it['phno'] == user['phno'],
                                        orElse: () => null)) !=
                                    null) {
                                  print('Already exists!');
                                } else {
                                  selectedMembers.add(user);
                                }
                              }),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(user['img']),
                                maxRadius: 25,
                              ),
                              title: Text(user['name']),
                              subtitle: Text(user['phno']),
                            ));
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: NewGroupScreen(selectedMembers: selectedMembers),
              isIos: true,
              duration: Duration(milliseconds: 400),
            ),
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
