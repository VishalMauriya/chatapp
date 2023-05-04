import 'package:chatapp/phone_otp_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Auth extends StatefulWidget {
  const Auth();

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _formKey = GlobalKey<FormState>();
  var phController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                ),
                Image(
                    image: AssetImage('assets/images/logo.png'),
                    color: Colors.black,
                    height: 200),
                Text(
                  'Welcome Back,',
                  style: Theme.of(context).textTheme.headline3,
                ),
                Text(
                  'Go ahead, your friends are waiting!',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(
                  height: 70,
                ),
                TextField(
                  controller: phController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.black,
                      ),
                      prefixText: '+91 ',
                      label: Text('Phone Number'),
                      hintText: 'Phone Number',
                      hintStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black))),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        fixedSize: Size.fromWidth(500),
                        shadowColor: Colors.grey),
                    onPressed: () {
                      Get.put(PhoneOtpController().phoneAuthentication(
                          '+91' + phController.text.trim()));
                    },
                    child: Text('Get OTP')),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Text('ChatApp', textAlign: TextAlign.center));
  }
}
