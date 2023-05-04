import 'package:chatapp/phone_otp_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';

class OtpScreen extends StatelessWidget {
  final phno;

  OtpScreen({this.phno});

  @override
  Widget build(BuildContext context) {
    var OtpCotroller = TextEditingController();
    var otp = '';

    return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'CO\nDE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 80),
                  ),
                  Text('VERIFICATION', textAlign: TextAlign.center),
                  SizedBox(
                    height: 40,
                  ),
                  Text('Enter the code sent at $phno',
                      textAlign: TextAlign.center),
                  SizedBox(
                    height: 20,
                  ),
                  OtpTextField(
                    numberOfFields: 6,
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.1),
                    onSubmit: (code) async {
                      otp = code;
                      otp = code;
                      print('OTP is code => $code');
                      Get.put(PhoneOtpController().verifyOTP(code));
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: () async {
                          // PhoneOtpController phoneOtpController = Get.put(PhoneOtpController());
                          // phoneOtpController.verifyOTP(otp);
                          Get.put(PhoneOtpController()!.verifyOTP(otp));
                        },
                        child: Text('Verify')),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Text('ChatApp', textAlign: TextAlign.center));
  }
}
