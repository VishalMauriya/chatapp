import 'package:chatapp/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class On_Borading_Screen extends StatefulWidget {
  @override
  State<On_Borading_Screen> createState() => _On_Borading_ScreenState();
}

class _On_Borading_ScreenState extends State<On_Borading_Screen> {
  final liquid_controller = LiquidController();

  int currentPage = 0;
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          LiquidSwipe(
            liquidController: liquid_controller,
            onPageChangeCallback: onPageChange,
            slideIconWidget: const Icon(Icons.arrow_back_ios),
            enableSideReveal: true,
            pages: [
              Container(
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.enhanced_encryption,
                      size: 100,
                    ),
                    Column(
                      children: [
                        Text('End to End Encryption',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30)),
                        Text(
                          'Securely chat with your dear ones',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                    Text('1/3'),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.orange.shade100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.offline_share_rounded,
                      size: 100,
                    ),
                    Column(
                      children: [
                        Text('Connect & Share',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30)),
                        Text(
                          'Send Text messages, Photos, Videos etc...',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                    Text('2/3'),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.deepOrange.shade100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image(
                      image: AssetImage('assets/images/chatlogo.png'),
                      color: Colors.black,
                      height: 100,
                    ),
                    // Icon(Icons.enhanced_encryption, size: 100,),
                    Column(
                      children: [
                        Text('Welcome To ChatApp',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30)),
                        Text(
                          'Go ahead, your friends are waiting there',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                    Text('3/3'),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            ],
          ),
          Positioned(
              bottom: 60,
              child: OutlinedButton(
                style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.black),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    onPrimary: Colors.white),
                onPressed: () {
                  setState(() {
                    int nextPage = liquid_controller.currentPage + 1;
                    liquid_controller.jumpToPage(page: nextPage);
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_forward_ios),
                ),
              )),
          Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    liquid_controller.jumpToPage(page: 2);
                  });
                },
                child: Text(
                  'Skip',
                  style: TextStyle(color: Colors.black54),
                ),
              )),
          Positioned(
              bottom: 10,
              child: AnimatedSmoothIndicator(
                activeIndex: liquid_controller.currentPage,
                count: 3,
                effect: const WormEffect(
                    activeDotColor: Colors.black, dotHeight: 5.0),
              ))
        ],
      ),
    );
  }

  void onPageChange(int activePageIndex) {
    setState(() {
      currentPage = activePageIndex;
      counter = liquid_controller.currentPage + 1;
      print("Current page $currentPage");
      if (counter == 3) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(title: 'ChatApp'),
            ));
      }
    });
  }
}
