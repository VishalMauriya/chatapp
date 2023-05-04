import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatMessage {
  String messageContent;
  String messageType;
  String messageTime;

  ChatMessage(
      {required this.messageContent,
      required this.messageTime,
      required this.messageType});

  factory ChatMessage.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    final data = documentSnapshot.data()!;

    return ChatMessage(
      messageContent: data["msg"],
      messageType: data["senderid"],
      messageTime: data["timestamp"],
    );
  }
}
