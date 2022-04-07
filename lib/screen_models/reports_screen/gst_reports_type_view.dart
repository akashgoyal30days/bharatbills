import 'dart:async';
import 'dart:convert';

import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/api_models/webview_api.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/reports/reports_screen.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../../main.dart';
import '../../toast_messeger.dart';

class GstRepos extends StatefulWidget {
  GstRepos({required this.lastscreen});
  final String lastscreen;
  @override
  _GstReposState createState() => _GstReposState();
}

class _GstReposState extends State<GstRepos> {
  String? selectedfromdate;
  String? selectedtodate;
  String? selectedtype;
  bool gotresp = false;

  List bodydata = [];
  int headerlength = 0;
  List title = [];

  bool showloader = false;
  var htmldata;
  //datepicker
  _selectDate(BuildContext context, String from) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),

    );
    if(from=="From"){
      if (selected != null )
        setState(() {
          selectedfromdate = formatter.format(selected);
        });
    }else{
      if (selected != null )
        setState(() {
          selectedtodate = formatter.format(selected);
        });
    }
  }




  final DateFormat formatter = DateFormat('dd-MM-yyyy');


  @override
  void initState(){
    super.initState();
    _controller= Completer<WebViewController>();
    setdates();
  }

  void setdates (){
    var date = new DateTime.now();
    var newDate = new DateTime(date.year, date.month - 1, date.day);
    setState(() {
      selectedtodate = formatter.format(DateTime.now());
      selectedfromdate = formatter.format(newDate);
    });

  }
  //get bill
  void getBill () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await webapiurl("/member/appview", widget.lastscreen=='GSTR - 1'?"return_view.php":widget.lastscreen=='GST 3B Summary'?"gstsummary.php":"saleview.php", {
        //"type": "basic_sale",
        'f_date': selectedfromdate.toString(),
        't_date': selectedtodate.toString(),
        if(widget.lastscreen=='GSTR - 1')
          'type': selectedtype.toString()


      });
      //debugPrint(rsp.toString());
      /* if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            //debugPrint(rsp['data'].length.toString());
*//*            title = rsp['data']['header'];
            headerlength = title.length;
            bodydata = rsp['data']['body'];
            //debugPrint(bodydata.toString());
            //debugPrint(rsp['request'].toString());*//*
          }
          );

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showloader=false;
        });
        if(rsp['error'].toString()=="invalid_auth"){
          Navigator.of(context).popUntil((route) => route.isFirst);
          showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
        }

        }
      }*/

      setState((){

        showloader=false;
        htmldata = rsp;
        gotresp = true;
      });
    }catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  Completer<WebViewController>? _controller;


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
  _loadHTML() async {
    _webViewController!.loadUrl(Uri.dataFromString(
        htmldata,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.of(context)
            .popUntil((route) =>
        route.isFirst);
        Navigator
            .pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType
                    .fade,
                child: Report_Screen()));
        return false;
      },
      child: Scaffold(
          backgroundColor: scaffoldbackground,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Column(
                  children: [
                    ConstAppBar("reports_help"),
                    Container(
                      height: 35,
                      width: MediaQuery.of(context).size.width,
                      color: AppBarColor,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                            child: Row(
                              children: [
                                Icon(Icons.circle, color: Colors.white,size: 15,),
                                SizedBox(width: 10,),
                                Text(widget.lastscreen.toString(), style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.white
                                ),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color:Colors.white,
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey.withOpacity(0.2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width/2.3,
                                child: TextButton(
                                    onPressed: (){
                                      _selectDate(context, "From");
                                    },
                                    child: selectedfromdate==null?Row(
                                      children: [
                                        Icon(Icons.calendar_today_sharp, size : 20, color: AppBarColor),
                                        SizedBox(width:5),
                                        Text("From Date *", style:GoogleFonts.poppins(fontSize: 15, color: Colors.black)),
                                      ],
                                    ):Row(
                                      children: [
                                        Icon(Icons.calendar_today_sharp, size : 20, color: AppBarColor),
                                        SizedBox(width:5),
                                        Text(selectedfromdate.toString(), style:GoogleFonts.poppins(fontSize: 15, color: Colors.black)),
                                      ],
                                    )
                                )),
                            Container(
                              width: MediaQuery.of(context).size.width/2.3,
                              child: TextButton(
                                  onPressed: (){
                                    _selectDate(context, "To");
                                  },
                                  child: selectedtodate==null?Row(
                                    children: [
                                      Icon(Icons.calendar_today_sharp, size : 20, color: AppBarColor),
                                      SizedBox(width:5),
                                      Text("To Date *", style:GoogleFonts.poppins(fontSize: 15, color: Colors.black)),
                                    ],
                                  ):Row(
                                    children: [
                                      Icon(Icons.calendar_today_sharp, size : 20, color: AppBarColor),
                                      SizedBox(width:5),
                                      Text(selectedtodate.toString(), style:GoogleFonts.poppins(fontSize: 15, color: Colors.black)),
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                    if(widget.lastscreen == 'GSTR - 1')
                      Container(
                      color:Colors.white,
                      child: Container(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            Container(
                              width: MediaQuery.of(context).size.width-60,
                              height: 35,
                                decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(0),  // radius of 10
                                 color: Colors.white,
                                    border: Border.all(color: Colors.grey)// green as background color
                               ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  hint: Text(' Select Type *'),
                                  value: selectedtype,
                                  items: <String>['b2b','b2cs','b2cl','cdnr','cdnur','exp','hsn'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value.toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      selectedtype = v.toString();
                                    });
                                  },
                                ),
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 35,
                              child: RaisedButton(
                                  elevation: 0,
                                  color: Colors.green,
                                  onPressed:(){
                                    if(selectedfromdate==null||selectedtodate==null || selectedtype==null){
                                      showPrintedMessage(context, "Error", "Please fill all fields", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                    }else{
                                      _controller= Completer<WebViewController>();
                                      gotresp = false;
                                      getBill();
                                    }

                                  },
                                  child: Text('Go', style: GoogleFonts.poppins(
                                      fontSize: 15, color: Colors.white
                                  ))
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                    else
                      Container(
                        color:Colors.white,
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 60,
                                height: 35,
                                child: RaisedButton(
                                    elevation: 0,
                                    color: Colors.green,
                                    onPressed:(){
                                      if(selectedfromdate==null||selectedtodate==null){
                                        showPrintedMessage(context, "Error", "Please fill all fields", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                      }else{
                                        _controller= Completer<WebViewController>();
                                        gotresp = false;
                                        getBill();
                                      }

                                    },
                                    child: Text('Go', style: GoogleFonts.poppins(
                                        fontSize: 15, color: Colors.white
                                    ))
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    Container(
                        height: MediaQuery.of(context).size.height-240,
                        width:MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: showloader==true?Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 0.7,

                          ),
                        ):gotresp==true?
                        Zoom(
                          maxZoomWidth: 1800,
                          maxZoomHeight: 1800,
                          child: Builder(
                              builder: (context) {
                                return WebView(
                                  initialUrl: '',
                                  javascriptMode: JavascriptMode.unrestricted,
                                  onWebViewCreated: (WebViewController webViewController) {
                                    _webViewController = webViewController;
                                    _loadHTML();
                                    _controller!.complete(webViewController);

                                  },
                                  onProgress: (int progress) {
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
                                        .then((value) => debugPrint('Page finished loading Javascript'))
                                        .catchError((onError) => debugPrint('$onError'));
                                  },
                                  gestureNavigationEnabled: true,
                                );
                              }
                          ),
                        ):Container()
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
