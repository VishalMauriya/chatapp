import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class NewGroupScreen extends StatefulWidget {
  List selectedMembers;

  NewGroupScreen({required this.selectedMembers});

  @override
  _NewGroupScreenState createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  List admins = [];
  String _groupName = '';
  String _groupDescription = '';
  final _descriptionController = TextEditingController();
  final _groupNameController = TextEditingController();
  int _descriptionMaxLength = 100;
  int _groupNameMaxLength = 30;
  var isLoading = false;
  File? _photo = null;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  void _createGroup() {
    admins.add(widget.selectedMembers[0]);
    setState(() {
      isLoading = true;
    });
    if (_photo != null) {
      uploadFile();
    } else {
      FirebaseFirestore.instance
          .collection('group')
          .doc(FirebaseAuth.instance.currentUser!.phoneNumber.toString() +
              '_' +
              _groupName)
          .set({
        'title': _groupName,
        'subtitle': _groupDescription,
        'url':
            'https://firebasestorage.googleapis.com/v0/b/chatapp-a9ffd.appspot.com/o/files%2Fgroup.jpeg?alt=media&token=20877149-011a-4d2b-8c52-d1b5411e6643',
        'created_on': DateTime.now().millisecondsSinceEpoch,
        'members': widget.selectedMembers,
        'admins': admins
      });
      setState(() {
        isLoading = false;
        Navigator.pop(this.context);
        Navigator.pop(this.context);
      });
    }
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        // uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        // uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = basename(_photo!.path);
    final destination = 'files/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file/');
      await ref.putFile(_photo!);
      _getImage('files/$fileName/file');
    } catch (e) {
      print('error occured');
    }
  }

  Future<void> _getImage(var str) async {
    final ref = FirebaseStorage.instance.ref().child(str);
    var imageURL = await ref.getDownloadURL();
    print("url => $imageURL");
    FirebaseFirestore.instance
        .collection('group')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber.toString() +
            '_' +
            _groupName)
        .set({
      'title': _groupName,
      'subtitle': _groupDescription,
      'url': imageURL,
      'created_on': DateTime.now().millisecondsSinceEpoch,
      'members': widget.selectedMembers,
      'admins': admins
    });
    setState(() {
      isLoading = false;
      Navigator.pop(this.context);
      Navigator.pop(this.context);
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        backgroundColor: isLoading ? Colors.grey.shade400 : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
              child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
              ),
              Text('Create New Group'),
              Spacer(),
              IconButton(
                onPressed: _createGroup,
                icon: Icon(Icons.done),
              ),
            ],
          )),
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () => _showPicker(context),
                        child: CircleAvatar(
                          radius: 60.0,
                          backgroundImage:
                              _photo != null ? FileImage(_photo!) : null,
                          child: _photo == null
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 60.0,
                                )
                              : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Group Name',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: _groupNameMaxLength,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a group name';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _groupName = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Group Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: _descriptionMaxLength,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a group description';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _groupDescription = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Members (${widget.selectedMembers.length})'),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        children: widget.selectedMembers
                            .map((member) => Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(member['img']),
                                        radius: 30,
                                        child: null,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        member['name'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      )
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isLoading
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Creating Group...')
                    ],
                  ))
                : Container()
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<File>('_image', _photo));
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(
                        Icons.photo_library,
                        color: Colors.teal,
                      ),
                      title: new Text('Gallery'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(
                      Icons.photo_camera,
                      color: Colors.teal,
                    ),
                    title: new Text('Camera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
