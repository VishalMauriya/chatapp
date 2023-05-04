import 'package:chatapp/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Register_User extends StatefulWidget {
  @override
  State<Register_User> createState() => _Register_UserState();
}

class _Register_UserState extends State<Register_User> {
  var name_controller = TextEditingController();

  var status_controller =
      TextEditingController(text: "Hey there, I'm on Chatapp");

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Center(
              child: Text('Create New Account',
                  style: TextStyle(color: Colors.grey.shade700))),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Stack(children: [
              Container(
                color: _isLoading ? Colors.grey : Colors.transparent,
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(children: [
                      CircleAvatar(
                        radius: 82,
                        backgroundColor: Colors.teal,
                        child: CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/avatar.png'),
                          radius: 78,
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 5,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.camera,
                              color: Colors.white,
                            ),
                          )),
                    ]),
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      children: [
                        TextField(
                          controller: name_controller,
                          autofocus: true,
                          onTap: () => name_controller.selection =
                              TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      name_controller.value.text.length),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.account_circle_rounded),
                            suffixIcon: Icon(Icons.edit),
                            label: Text('Enter Name'),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: status_controller,
                          onTap: () => status_controller.selection =
                              TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      status_controller.value.text.length),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.history_edu_rounded),
                            suffixIcon: Icon(Icons.edit),
                            label: Text('Enter Status'),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          _isLoading = true;
                          var id = FirebaseAuth.instance.currentUser!.uid;
                          var phno = FirebaseAuth
                              .instance.currentUser!.phoneNumber
                              .toString()
                              .replaceRange(0, 3, "+91 ");
                          var date = DateFormat.yMMMd().format(DateTime.now());

                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(id)
                              .set({
                                'name': name_controller.text.trim().toString(),
                                'status':
                                    status_controller.text.trim().toString(),
                                'phno': phno,
                                'state': 'Online',
                                'joined': date.toString(),
                                'img':
                                    'https://firebasestorage.googleapis.com/v0/b/chatapp-a9ffd.appspot.com/o/files%2Fdownload.png?alt=media&token=70377c5b-aa5e-4bb7-93ed-e4515bd199fb'
                              })
                              .whenComplete(
                                () => {
                                  Get.snackbar(
                                      "Hey ${name_controller.text.trim().toString()}, ",
                                      "your new account is created",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor:
                                          Colors.green.withOpacity(0.1),
                                      colorText: Colors.green),
                                  setState(() {
                                    _isLoading = false;
                                  }),
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MyHomePage(title: "ChatApp")))
                                },
                              )
                              .catchError((error, stackTrance) {
                                Get.snackbar(
                                    "Retry plz, ", "Something went wrong!",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor:
                                        Colors.green.withOpacity(0.1),
                                    colorText: Colors.red);
                                print(error.toString());
                              });
                        },
                        tooltip: 'Next',
                        child: const Icon(
                          Icons.navigate_next,
                          size: 45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Creating Account......",
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                    )
                  : Container()
            ]),
          ),
        ),
      ),
    );
  }
}
