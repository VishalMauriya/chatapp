import 'package:chatapp/authenticationModel.dart';
import 'package:chatapp/chatPage.dart';
import 'package:chatapp/contacts.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/select_members_page.dart';
import 'package:chatapp/search_screen.dart';
import 'package:chatapp/account_screen.dart';
import 'package:chatapp/splash_screen.dart';
import 'package:chatapp/group_page_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) => Get.put(AuthenticationModel()));
  runApp(const MyApp());
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    var ref = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    if (state == AppLifecycleState.paused) {
      // update the user status to offline
      print("user id OFFLINE");
      ref.update({
        'state': 'Last seen at ${DateFormat("hh:mm a").format(DateTime.now())}'
      });
    } else if (state == AppLifecycleState.resumed) {
      print("user id ONLINE");
      ref.update({'state': 'Online'});
    } else if (state == AppLifecycleState.detached) {
      print("user id DETACHED");
      ref.update({'state': 'Offline'});
    } else if (state == AppLifecycleState.inactive) {
      print("user id INACTIVE");
      ref.update({'state': 'Offline'});
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splash_Screen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isDark = false;
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30);
  static const List<Widget> _widgetOptions = <Widget>[
    const ChatPage(),
    const GroupChatPage(),
    Text(
      'Account Page',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var ref = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    ref.update({'state': 'Online'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          InkWell(
            child: _isDark ? Icon(Icons.dark_mode) : Icon((Icons.light_mode)),
            onTap: () => setState(() {
              _isDark = !_isDark;
            }),
          ),
          SizedBox(
            width: 25,
          ),
          InkWell(
            child: Icon(Icons.search_outlined),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                )),
          ),
          SizedBox(
            width: 15,
          ),
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              // PopupMenuItem 1
              PopupMenuItem(
                value: 1,
                // row with 2 children
                child: Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.grey),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Account")
                  ],
                ),
              ),
              // PopupMenuItem 2
              PopupMenuItem(
                value: 2,
                // row with two children
                child: Row(
                  children: [
                    Icon(
                      Icons.group_add,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("New Group")
                  ],
                ),
              ),
            ],
            offset: Offset(0, 100),
            color: Colors.white,
            elevation: 2,
            // on selected we show the dialog box
            onSelected: (value) {
              // if value 1 show dialog
              if (value == 1) {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.scale,
                    alignment: Alignment.topCenter,
                    duration: Duration(milliseconds: 400),
                    isIos: true,
                    child: AccountPage(),
                  ),
                );
                // if value 2 show dialog
              } else if (value == 2) {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.scale,
                    alignment: Alignment.topCenter,
                    duration: Duration(milliseconds: 400),
                    isIos: true,
                    child: SelectedMembers(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  alignment: Alignment.bottomCenter,
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 600),
                  reverseDuration: Duration(milliseconds: 600),
                  type: PageTransitionType.rightToLeftJoined,
                  child: Contacts(),
                  childCurrent: this.widget));
        },
        tooltip: 'Contacts',
        child: const Icon(Icons.group),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chats',
            // title: Text("Chats"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
            // title: Text("Channels"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Account',
            // title: Text("Profile"),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
