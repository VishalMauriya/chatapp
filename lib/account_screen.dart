import 'package:chatapp/auth.dart';
import 'package:chatapp/profilePage.dart';
import 'package:chatapp/register_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'settings_screen.dart';

class AccountPage extends StatefulWidget {
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: ListTile(
                    onTap: () => Navigator.push(
                        context,
                        PageTransition(
                            alignment: Alignment.bottomCenter,
                            curve: Curves.easeInOut,
                            duration: Duration(milliseconds: 600),
                            reverseDuration: Duration(milliseconds: 600),
                            type: PageTransitionType.rightToLeftPop,
                            child: ProfilePage(),
                            childCurrent: this.widget)),
                    leading: Hero(
                      tag: 'bg',
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(snapshot.data!.get('img')),
                        maxRadius: 30,
                      ),
                    ),
                    title: Text(
                      snapshot.data!.get('name'),
                      style: TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      snapshot.data!.get('status'),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  color: Colors.blueAccent, //color of divider
                  height: 5, //height spacing of divider
                  indent: 25, //spacing at the start of divider
                  endIndent: 25, //spacing at the end of divider
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Settings',
                  style: TextStyle(color: Colors.blue),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      settingsView(Icon(Icons.privacy_tip_rounded),
                          Text('Privacy Policy'), 0),
                      settingsView(Icon(Icons.handshake_rounded),
                          Text('Terms and Conditions'), 1),
                      settingsView(Icon(Icons.info), Text('About'), 2),
                      ListTile(
                        onTap: () => picker(context, 0),
                        leading: Icon(Icons.logout_rounded, color: Colors.red),
                        title:
                            Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          onTap: () => picker(context, 1),
                          leading: Icon(Icons.no_accounts_rounded,
                              color: Colors.white),
                          title: Text('Delete my account',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }

  Widget settingsView(var icon, var text, var type) {
    return ListTile(
      onTap: () => Navigator.push(
          context,
          PageTransition(
              alignment: Alignment.bottomCenter,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 600),
              reverseDuration: Duration(milliseconds: 600),
              type: PageTransitionType.rightToLeftJoined,
              child: SettingsPage(title: text, icon: icon, type: type),
              childCurrent: this.widget)),
      // Navigator.push(context, MaterialPageRoute(builder: (context) => HorizontalImageList(title: text, icon: icon),)),
      leading: icon,
      title: text,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 15,
      ),
    );
  }

  void picker(context, type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(type == 0 ? 'Logout' : 'Delete Account'),
          content: Text(type == 0
              ? 'Are you sure you want to logout?'
              : 'Are you sure you want to delete your account permanently?'),
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
              child: Text(type == 0 ? 'Logout' : 'Delete'),
            ),
          ],
        );
      },
    ).then((value) async {
      if (value == true && type == 0) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Auth(),
            ));
      } else if (value == true && type == 1) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .delete();

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Register_User(),
            ));
      } else {}
    });
  }
}
