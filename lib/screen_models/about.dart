import 'dart:io';

import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';
import '../shared preference singleton.dart';
import '../toast_messeger.dart';
import 'dashboard.dart';
import 'package:get_version/get_version.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool showloader = true;
  List allformat = [];
  @override
  void initState(){
    super.initState();
    setscreenposition();
    getpackage();
  }

  String version = '';
  void getpackage()async{
    String projectCode;
// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      projectCode = await GetVersion.projectVersion;
    } on PlatformException {
      projectCode = 'Failed to get build number.';
    }
    //debugPrint(projectCode.toString());
    setState(() {
      version = projectCode;
    });
  }


  void setscreenposition() async{
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "about");
    //debugPrint(screen.getString("currentscreen").toString());
  }
  dynamic remarks_Controller = TextEditingController();
  dynamic popup_remarks_Controller = TextEditingController();
  AddRemrks() {
    setState(() {
      popup_remarks_Controller.clear();
    });

    // set up the button
    Widget okButton = TextButton(
      child: Text("Done"),
      onPressed: () {
        if(popup_remarks_Controller.text.isNotEmpty) {
          sendFeedback();

          Navigator.pop(context);
        }else{
          showPrintedMessage(context, "Error", "Please enter a message", Colors.white,Colors.red, Icons.info, true, "top");

        }

      },
    );
    Widget CancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {

        Navigator.pop(context);


      },
    );






    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Enter Message '),
      content: Container(
          height: 120,
          child: Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 2, top: 10, right:20),
                child: Container(
                  height: 100,
                  width:MediaQuery.of(context).size.width-150,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      border: Border.all(color: AppBarColor, width: 1.0),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5.0),
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0),
                          bottomRight: Radius.circular(5.0))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextFormField(
                      maxLines: 4,
                      readOnly:false,

                      onChanged: (v){

                      },
                      decoration: new InputDecoration(
                        isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: "Enter message here *",
                        fillColor: Colors.white.withOpacity(0.5),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        //fillColor: Colors.green
                      ),
                      controller: popup_remarks_Controller,
                    ),
                  ),
                ),
              ),
            ],
          )),
      actions: [
        okButton,
        CancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void sendFeedback () async{
    setState(() {
      showloader = true;
      showPrintedMessage(context, "Alert", "Please wait sending feedback", Colors.white,Colors.amber, Icons.info, true, "top");

    });
    try{
      var rsp = await apiurl("/member/process", "dashboard.php", {
        "type": "suggestion",
        "message": popup_remarks_Controller.text.toString()
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "FeedBack sent successfully", Colors.white,Colors.green, Icons.info, true, "top");
          setState(() {
            popup_remarks_Controller.clear();
          });
        }else if(rsp['status'].toString()=="false"){  setState(() {
          showloader=false;
        });
        if(rsp['error'].toString()=="invalid_auth"){
          Navigator.of(context).popUntil((route) => route.isFirst);
          showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
        }

        }
      }
    }catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  void getlink () async{
    setState(() {
      showloader = true;
    });
    try{
      var rsp = await apiurl("/member/process", "dashboard.php", {
        "type": "refLink",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
           referallink = rsp['url'];
          });

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showloader=false;
        });
        if(rsp['error'].toString()=="invalid_auth"){
          Navigator.of(context).popUntil((route) => route.isFirst);
          showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
        }

        }
      }
    }catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }
  _launchURL(String url) async {
    if (Platform.isIOS) {
      if (await canLaunch(url)) {
        await launch(url, forceSafariVC: false);
      } else {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }
    } else {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  String referallink = '';



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.of(context)
            .popUntil((route) =>
        route.isFirst);
        Navigator
            .pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType
                    .fade,
                child: Dashboard()));

        return false;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
                onPressed: (){
                  Navigator.of(context)
                      .popUntil((route) =>
                  route.isFirst);
                  Navigator
                      .pushReplacement(
                      context,
                      PageTransition(
                          type: PageTransitionType
                              .fade,
                          child: Dashboard()));
                },
                icon: Icon(Icons.arrow_back, color:Colors.white)),
            elevation: 0,
            backgroundColor: AppBarColor,
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: AppBarColor,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                Container(

                                  height: 60,
                                  child: Column(
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(left: 20),
                                          child: Text('BharatBills', style: TextStyle(
                                        fontSize: 35, color: Colors.white,
                                        fontWeight: FontWeight.w500
                                      ),)),
                                      Container(
                                          margin: EdgeInsets.only(left: 40),
                                          child: Text('More than a billing software', style: TextStyle(
                                              fontSize: 11, color: Colors.white,
                                              fontWeight: FontWeight.w500
                                          ),)),
                                    ],
                                  ),
                                ),

                                Container(
                                  height: 50,
                                  child: FittedBox(
                                    child: Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.language, size: 18, color: Colors.white,),
                                            SizedBox(width: 8,),
                                            Text('www.bharatbills.com', style: TextStyle(
                                                fontSize: 14, color: Colors.white,
                                                fontWeight: FontWeight.w500
                                            ),),
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: (){
                            },
                            child: Container(
                             decoration: BoxDecoration(
                                 image: new DecorationImage(
                                   image: new AssetImage("assets/muscat.png"),
                                   fit: BoxFit.cover,
                                 )
                             ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: RaisedButton(
                              color: Colors.green,
                              elevation: 0,
                              onPressed : (){
                                getlink();
                                },
                              child: Padding(
                                padding: const EdgeInsets.only(left:10, right: 10, top: 5, bottom: 5),
                                child: Text('Refer a friend',  style: TextStyle(
                                  height: 1.3,
                                  fontSize: 18,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500
                                ),
                                textAlign: TextAlign.justify,),
                              ),
                            ),
                          ),
                          if(referallink!='')
                          Padding(padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextButton(
                            onPressed: (){},
                            child: Text(referallink),
                          ),),
                          if(referallink!='')
                          Padding(padding: const EdgeInsets.only(left: 10, right: 10),
                          child: GestureDetector(
                            onTap: () async{
                              await launch(
                                  "https://wa.me/?text=$referallink");
                            },
                            child: Container(
                              child: Column(
                                children: [
                                  Container(
                                      child: Container(
                                        child: Center(
                                          child: FaIcon(FontAwesomeIcons.share, color: Colors.green,size: 35,),
                                        ),
                                      )),
                                  Text('Share Link', style: TextStyle(fontSize: 10),)
                                ],
                              ),
                            ),
                          ),),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 20,bottom: 5),
                            child: Text('You can find us on',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppBarColor),),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0, top: 20),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        _launchURL('https://www.youtube.com/c/BharatBillsGSTSoftware');
                                      },
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Container(
                                                child: Container(
                                                  child: Center(
                                                    child: FaIcon(FontAwesomeIcons.youtube, color: Colors.red,size: 35,),
                                                  ),
                                                )),
                                            Text('Youtube', style: TextStyle(fontSize: 10),)
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        _launchURL('https://www.instagram.com/bharatbills/?hl=en');
                                      },
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Container(
                                                child: Container(
                                                  child: Center(
                                                    child: FaIcon(FontAwesomeIcons.instagram, color: Colors.red,size: 35,),
                                                  ),
                                                )),
                                            Text('Instagram', style: TextStyle(fontSize: 10),)
                                          ],
                                        ),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: (){
                                        _launchURL('https://twitter.com/BharatBills');
                                      },
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Container(
                                                child: Container(
                                                  child: Center(
                                                    child: FaIcon(FontAwesomeIcons.twitter, color: Colors.blueAccent,size: 35,),
                                                  ),
                                                )),
                                            Text('Twitter', style: TextStyle(fontSize:10),)
                                          ],
                                        ),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: (){
                                        _launchURL('https://www.facebook.com/BharatBillsGSTSoftware');
                                      },
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Container(
                                                child: Container(
                                                  child: Center(
                                                    child: FaIcon(FontAwesomeIcons.facebookF, color: Colors.indigo,size: 35,),
                                                  ),
                                                )),
                                            Text('Facebook', style: TextStyle(fontSize: 10),)
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async{
                                        await launch(
                                            "https://wa.me/+919992321321?text=Hello BharatBills");
                                      },
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Container(
                                                child: Container(
                                                  child: Center(
                                                    child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green,size: 35,),
                                                  ),
                                                )),
                                            Text('WhatsApp', style: TextStyle(fontSize: 10),)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          if(version!='')
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text('v'+' '+version.toString(), style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.7)),)),
                            ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 50,

                                width:MediaQuery.of(context).size.width,
                                child: RaisedButton(
                                  color: AppBarColor,
                                  elevation:0,
                                  onPressed: (){
                                    AddRemrks();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Send FeedBack', style: TextStyle(fontSize: 18, color:Colors.white, fontWeight: FontWeight.w400),),
                                      SizedBox(width: 30,),
                                      FaIcon(FontAwesomeIcons.telegramPlane, color: Colors.white,size: 25,),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          )),
    );
  }
}
