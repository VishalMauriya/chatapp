import 'package:chatapp/auth.dart';
import 'package:chatapp/authenticationModel.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/on_boarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Splash_Screen extends StatefulWidget {
  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  bool animate = false;
  var opac = 0.0;
  var h = 0.0;
  var w = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startAnimation();
  }

  Future<void> startAnimation() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      animate = true;
      opac = 0.8;
    });
    await Future.delayed(Duration(milliseconds: 1000));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(title: "ChatApp"),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xfffdfbfb), Color(0xffebedee)])),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(seconds: 1),
                curve: Curves.bounceOut,
                top: animate ? 300 : 0,
                left: animate ? 140 : 0,
                child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    color: Colors.black.withOpacity(animate ? 0.8 : 0),
                    colorBlendMode: BlendMode.modulate),
                height: 115,
              ),
              Center(
                child: Text(
                  'C h a t A p p',
                  style: TextStyle(
                      fontSize: 20, color: Colors.black.withOpacity(opac)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
