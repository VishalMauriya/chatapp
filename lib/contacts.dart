import 'package:chatapp/chatDetailPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';

class Contacts extends StatefulWidget {
  const Contacts();

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Contact>? contacts = [];
  var list1 = [];
  var isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContact();
    FirebaseFirestore.instance.collection("users").snapshots().listen((event) {
      for (var doc in event.docs) {
        if (doc.id == FirebaseAuth.instance.currentUser!.uid) continue;
        String no = doc.get('phno').toString().substring(4);
        print(no);
        Map<String, dynamic> dataWithId = Map<String, dynamic>.from(doc.data());
        dataWithId['uid'] = doc.id;
        list1.add(dataWithId);
      }
      print("cities in CA: ${list1.join(", ")}");
    });
  }

  void getContact() async {
    if (await FlutterContacts.requestPermission()) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      print(contacts);
      setState(() {});
    }
    isLoading = false;
  }

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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.blue,
                    ),
                  ),
                  Text('Contacts')
                ],
              ),
            ),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: (list1.length + contacts!.length),
                itemBuilder: (context, index) {
                  if (index < list1.length) {
                    String no = list1[index]['phno'].toString().substring(4);
                    contacts!
                        .removeWhere((item) => item.phones.first.number == no);
                    return ListTile(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => chatDetailPage(
                                list1[index]['name'], list1[index]['uid']),
                          )),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(list1[index]['img']),
                        maxRadius: 25,
                      ),
                      title: Text(list1[index]['name']),
                      subtitle: Text(list1[index]['phno']),
                    );
                  } else {
                    Uint8List? image = contacts![index - list1.length].photo;
                    String num = (contacts![index - list1.length]
                            .phones
                            .isNotEmpty)
                        ? (contacts![index - list1.length].phones.first.number)
                        : "--";
                    return ListTile(
                        leading: (contacts![index - list1.length].photo == null)
                            ? const CircleAvatar(child: Icon(Icons.person))
                            : CircleAvatar(
                                backgroundImage: MemoryImage(image!)),
                        title: Text(
                            "${contacts![index - list1.length].name.first} ${contacts![index - list1.length].name.last}"),
                        subtitle: Text(num),
                        trailing: Container(
                          height: 20,
                          width: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.green)),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Center(
                                child: Text(
                              'Invite',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 10),
                            )),
                          ),
                        ),
                        onTap: () {
                          if (contacts![index].phones.isNotEmpty) {
                            Uri sms = Uri.parse(
                                'sms:${num}?body=Hello, I am on Chatapp, it has great experience..you should also downnload it :)');
                            launchUrl(sms);
                            // launch('tel: ${num}');
                          }
                        });
                  }
                },
              ));
  }
}
