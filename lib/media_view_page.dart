import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MediaViewPage extends StatefulWidget {
  final image;
  final name;
  final time;

  MediaViewPage({required this.image, this.name, this.time});

  @override
  State<MediaViewPage> createState() => _MediaViewPageState();
}

class _MediaViewPageState extends State<MediaViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
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
                SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name,
                        style: TextStyle(color: Colors.blue, fontSize: 20)),
                    Text(widget.time,
                        style: TextStyle(
                            color: Colors.blue.shade100, fontSize: 10))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.black,
          // alignment: Alignment.center,
          child: Image(
            image: NetworkImage(widget.image),
          ),
        ),
      ),
    );
  }
}
