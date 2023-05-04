import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatUsers {
  String id;
  String name;
  String messageText;
  String imageURL;
  String time;

  ChatUsers(
      {required this.id,
      required this.name,
      required this.messageText,
      required this.imageURL,
      required this.time});

  factory ChatUsers.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    final data = documentSnapshot.data()!;

    return ChatUsers(
      id: documentSnapshot.id,
      name: data["name"],
      messageText: data["phno"],
      imageURL: data["name"],
      time: data["status"],
    );
  }
}
