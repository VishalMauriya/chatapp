import 'package:chatapp/group_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'group_info_page.dart';

class GroupChatPage extends StatelessWidget {
  const GroupChatPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('group').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Container();
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              String id = document.id;
              String title = data['title'];
              String subtitle = data['subtitle'];
              var members = data['members'];
              bool isMember = false;
              members.forEach((member) {
                if (FirebaseAuth.instance.currentUser!.uid == member['uid']) {
                  isMember = true;
                }
              });

              return Opacity(
                opacity: isMember ? 1.0 : 0.6,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['url']),
                    maxRadius: 25,
                  ),
                  title: Text(title),
                  subtitle: Text(isMember
                      ? subtitle
                      : "You'r no longer this group member"),
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            alignment: Alignment.bottomCenter,
                            curve: Curves.easeInOut,
                            duration: Duration(milliseconds: 600),
                            reverseDuration: Duration(milliseconds: 600),
                            type: PageTransitionType.rightToLeftJoined,
                            child: GroupDetailPage(doc: id),
                            // child: UserGroupDetails(title: id),
                            childCurrent: this));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
