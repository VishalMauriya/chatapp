import 'package:chatapp/media_view_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  final title;
  final icon;
  final type;

  SettingsPage({this.title, this.icon, required this.type});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late var page;

  @override
  void initState() {
    if (widget.type == 0) {
      page = PrivacyPolicyPage();
    } else if (widget.type == 1) {
      page = TermsAndConditionsPage();
    } else {
      page = AboutPage();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: SafeArea(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back),
                ),
                Row(
                  children: [widget.icon, widget.title],
                ),
                SizedBox()
              ],
            ),
          ),
        ),
      ),
      body: Container(
        child: page,
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thank you for using the Chat Application developed by Vishal Maurya. Your privacy is important to us, and we are committed to protecting your personal information. This Privacy Policy explains what information we collect, how we use it, and your options with respect to the collection and use of your personal information.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Information We Collect',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'We may collect the following types of information:',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Personal Information: We may collect personal information such as your name, email address, and phone number when you create an account on the Chat Application.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Usage Information: We may collect information about how you use the Chat Application, such as the pages you visit, the features you use, and the actions you take.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Device Information: We may collect information about the device you are using to access the Chat Application, such as the device type, operating system, and browser type.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Location Information: We may collect information about your location when you use the Chat Application.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'How We Use Your Information',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'We may use your information for the following purposes:',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- To provide and improve the Chat Application.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- To communicate with you about the Chat Application and to respond to your inquiries.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- To personalize your experience on the Chat Application.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- To send you promotional and marketing messages about the Chat Application and other products and services we think may interest you.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- To comply with legal obligations and to protect our rights and interests.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Your Options',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'You have the following options with respect to the collection and use of your personal information:',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- You can update or delete your personal information by logging into your account on the Chat Application.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- You can opt out of receiving promotional and marketing messages from us by following the instructions in the messages or by contacting us directly.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- You can disable location services on your device or deny the Chat Application access to your location.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Contact Us',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'If you have any questions or concerns about this Privacy Policy or our privacy practices, please contact us at vishal.maurya@email.com.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please read these Terms and Conditions carefully before using our Chat Application.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '1. Acceptance of Terms',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'By using our Chat Application, you agree to be bound by these Terms and Conditions and our Privacy Policy. If you do not agree to these Terms and Conditions, you may not use our Chat Application.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '2. Use of Chat Application',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Our Chat Application is for personal use only. You may not use our Chat Application for any commercial purpose without our prior written consent.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'You agree not to use our Chat Application to:',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Upload, post, or transmit any content that is illegal, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, libelous, invasive of another\'s privacy, hateful, or racially, ethnically, or otherwise objectionable.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Impersonate any person or entity, or falsely state or otherwise misrepresent your affiliation with a person or entity.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Upload, post, or transmit any content that you do not have a right to make available under any law or under contractual or fiduciary relationships.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Upload, post, or transmit any content that infringes any patent, trademark, trade secret, copyright, or other proprietary rights of any party.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '- Upload, post, or transmit any unsolicited or unauthorized advertising, promotional materials, "junk mail," "spam," "chain letters," "pyramid schemes," or any other form of solicitation.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '3. Intellectual Property',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'The Chat Application and its entire contents, features, and functionality (including but not limited to all information, software, text, displays, images, video, and audio, and the design, selection, and arrangement thereof), are owned by the Developer or its licensors, and are protected by United States and international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '4. Disclaimer of Warranties',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'THE CHAT APPLICATION AND ITS CONTENTS ARE PROVIDED "AS IS" AND WITHOUT WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED. TO THE FULLEST EXTENT PERMISSIBLE UNDER APPLICABLE LAW, THE DEVELOPER DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '5. Limitation of Liability',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'THE DEVELOPER SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, CONSEQUENTIAL, SPECIAL, EXEMPLARY, OR PUNITIVE DAMAGES, INCLUDING, BUT NOT LIMITED TO, DAMAGES FOR LOSS OF PROFITS, GOODWILL, USE, DATA, OR OTHER INTANGIBLE LOSSES (EVEN IF THE DEVELOPER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES), ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF THE CHAT APPLICATION.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '6. Indemnification',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'You agree to indemnify, defend, and hold harmless the Developer, its affiliates, officers, directors, employees, consultants, agents, and representatives from any and all claims, liabilities, damages, and/or costs (including reasonable attorneys fees) arising from your use of the Chat Application or your breach of these Terms and Conditions.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '7. Governing Law and Jurisdiction',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'These Terms and Conditions shall be governed by and construed in accordance with the laws of the State of California, without giving effect to any principles of conflicts of law. You agree that any action at law or in equity arising out of or relating to these Terms and Conditions or the Chat Application shall be filed only in the state or federal courts located in Los Angeles County, California, and you hereby consent and submit to the personal jurisdiction of such courts for the purposes of litigating any such action.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '8. Changes to These Terms and Conditions',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'The Developer reserves the right, at its sole discretion, to modify or replace these Terms and Conditions at any time. If a revision is material, we will provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion. By continuing to access or use the Chat Application after any revisions become effective, you agree to be bound by the updated Terms and Conditions. If you do not agree to the new Terms and Conditions, you are no longer authorized to use the Chat Application.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '9. Contact Us',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'If you have any questions about these Terms and Conditions or the Chat Application, please contact us at developeremail@example.com.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 32.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  var ss = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/5.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png',
                height: 120.0,
                width: 120.0,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16.0),
              Text(
                'ChatApp',
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Text(
                'ChatApp is a free messaging app that allows you to chat with your friends and family while keeping your privacy intact. With ChatApp, you can send text messages, photos, videos, and audio messages securely and easily. You can also create group chats and stay connected with your groups in real-time.',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(height: 26.0),
              Text(
                'Features:',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.message,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Private messaging',
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.group,
                        color: Colors.pink,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Group chats',
                        style: TextStyle(color: Colors.pink),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.lock,
                        color: Colors.teal,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'End-to-end encryption',
                        style: TextStyle(color: Colors.teal),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 26.0),
              Text(
                'Screenshots:',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 8.0),
              Container(
                height: 300,
                child: Expanded(
                  child: PageView(
                    children: [
                      GestureDetector(
                        onTap: () => _showScreenshot(
                            context, 'assets/images/0.jpg', 'screenshot_0'),
                        child: Hero(
                            tag: 'screenshot_0',
                            child: Image.asset('assets/images/0.jpg')),
                      ),
                      GestureDetector(
                        onTap: () => _showScreenshot(
                            context, 'assets/images/1.jpg', 'screenshot_1'),
                        child: Hero(
                            tag: 'screenshot_1',
                            child: Image.asset('assets/images/1.jpg')),
                      ),
                      GestureDetector(
                        onTap: () => _showScreenshot(
                            context, 'assets/images/2.jpg', 'screenshot_2'),
                        child: Hero(
                            tag: 'screenshot_2',
                            child: Image.asset('assets/images/2.jpg')),
                      ),
                      GestureDetector(
                        onTap: () => _showScreenshot(
                            context, 'assets/images/3.jpg', 'screenshot_3'),
                        child: Hero(
                            tag: 'screenshot_3',
                            child: Image.asset('assets/images/3.jpg')),
                      ),
                      GestureDetector(
                        onTap: () => _showScreenshot(
                            context, 'assets/images/4.jpg', 'screenshot_4'),
                        child: Hero(
                            tag: 'screenshot_4',
                            child: Image.asset('assets/images/4.jpg')),
                      ),
                      GestureDetector(
                        onTap: () => _showScreenshot(
                            context, 'assets/images/5.jpg', 'screenshot_5'),
                        child: Hero(
                            tag: 'screenshot_5',
                            child: Image.asset('assets/images/5.jpg')),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.0),
              Text(
                'Developer:',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundImage: AssetImage('assets/images/developer.png'),
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vishal Maurya',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          IconButton(
                            icon: FaIcon(FontAwesomeIcons.instagram),
                            onPressed: () =>
                                launch('https://www.instagram.com/_vishal79_/'),
                          ),
                          IconButton(
                            icon: FaIcon(FontAwesomeIcons.linkedin),
                            onPressed: () => launch(
                                'https://www.linkedin.com/in/vishal-mauriya/'),
                          ),
                          IconButton(
                            icon: FaIcon(FontAwesomeIcons.twitter),
                            onPressed: () =>
                                launch('https://twitter.com/_vishal79_'),
                          ),
                          IconButton(
                            icon: FaIcon(FontAwesomeIcons.github),
                            onPressed: () =>
                                launch('https://github.com/VishalMauriya'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScreenshot(BuildContext context, String imageAsset, String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Center(
                child: Hero(
                  tag: tag,
                  child: Image.asset(imageAsset),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
