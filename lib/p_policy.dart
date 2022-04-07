import 'dart:async';
import 'dart:io';

import 'package:bbills/screen_models/login.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'app_constants/ui_constants.dart';

class Ppolicy extends StatefulWidget {
  Ppolicy({required this.url});
  final String url;
  @override
  _PpolicyState createState() => _PpolicyState();
}

class _PpolicyState extends State<Ppolicy> {
  @override
  void initState() {
    super.initState();
    _controller = Completer<WebViewController>();
  }

  Completer<WebViewController>? _controller;

  @override
  void dispose() {
    super.dispose();
  }

  int progress = 100;
  WebViewController? _webViewController;

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(context,
            PageTransition(type: PageTransitionType.fade, child: Login()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: secondarycolor,
          title: Text("Privacy Policy"),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade, child: Login()));
              },
              icon: Icon(Icons.arrow_back)),
        ),
        body: Builder(builder: (context) {
          return Column(
            children: [
              if (progress != 100)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      color: Colors.orange,
                      height: 4,
                      width:
                          MediaQuery.of(context).size.width * (progress / 100),
                    ),
                  ],
                ),
              Expanded(
                child: WebView(
                  initialUrl: widget.url,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _webViewController = webViewController;
                    _controller!.complete(webViewController);
                  },
                  onProgress: (int value) {                   
                      setState(() {
                        progress = value;
                      });
                    print("WebView is loading (progress : $progress%)");
                  },
                  javascriptChannels: <JavascriptChannel>{
                    _toasterJavascriptChannel(context),
                  },
                  navigationDelegate: (NavigationRequest request) {
                    if (request.url.startsWith('https://www.youtube.com/')) {
                      print('blocking navigation to $request}');
                      return NavigationDecision.prevent;
                    }
                    print('allowing navigation to $request');
                    return NavigationDecision.navigate;
                  },
                  onPageStarted: (String url) {
                    print('Page started loading: $url');
                  },
                  onPageFinished: (String url) {
                    print('Page finished loading: $url');

                    _webViewController!
                        .evaluateJavascript("javascript:(function() { " +
                            "var head = document.getElementsByTagName('header')[0];" +
                            "head.parentNode.removeChild(head);" +
                            "var footer = document.getElementsByTagName('footer')[0];" +
                            "footer.parentNode.removeChild(footer);" +
                            "})()")
                        .then((value) =>
                            debugPrint('Page finished loading Javascript'))
                        .catchError((onError) => debugPrint('$onError'));
                  },
                  gestureNavigationEnabled: false,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
