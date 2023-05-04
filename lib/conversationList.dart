import 'package:chatapp/chatDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ConversationList extends StatefulWidget {
  String id;
  String name;
  String messageText;
  String imageUrl;
  String time;
  bool isMessageRead;
  bool messageType;

  ConversationList(
      {required this.id,
      required this.name,
      required this.messageText,
      required this.imageUrl,
      required this.time,
      required this.isMessageRead,
      required this.messageType});

  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: chatDetailPage(widget.name, widget.id),
              ),
            ),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.imageUrl),
                maxRadius: 25,
              ),
              title: Text(
                widget.name,
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Row(
                children: [
                  widget.messageType
                      ? Icon(
                          Icons.done_all,
                          size: 20,
                          color:
                              widget.isMessageRead ? Colors.green : Colors.grey,
                        )
                      : Container(),
                  widget.messageType
                      ? SizedBox(
                          width: 4,
                        )
                      : Container(),
                  widget.messageText == 'photo'
                      ? Icon(Icons.photo_library)
                      : Container(),
                  Container(
                    width: 180,
                    child: Text(
                      widget.messageText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 13,
                          color: !widget.isMessageRead && !widget.messageType
                              ? Colors.green.shade600
                              : Colors.grey.shade600,
                          fontWeight:
                              !widget.isMessageRead && !widget.messageType
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                    ),
                  ),
                ],
              ),
              trailing: Text(
                widget.time,
                style: TextStyle(
                    color: !widget.isMessageRead && !widget.messageType
                        ? Colors.black
                        : Colors.grey,
                    fontSize: 12,
                    fontWeight: !widget.isMessageRead && !widget.messageType
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
            ),
          ),
        ));
  }
}

// Route _createRoute() {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => const Page2(),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       return child;
//     },
//   );
// }
