import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared preference singleton.dart';

import '../main.dart';
import '../toast_messeger.dart';
import 'dashboard.dart';

class BillFormat extends StatefulWidget {
  @override
  _BillFormatState createState() => _BillFormatState();
}

class _BillFormatState extends State<BillFormat> {
  bool showloader = true;
  List allformat = [];
  @override
  void initState(){
    super.initState();
    setscreenposition();
  }
  void setscreenposition() async{
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "allformat");
    //debugPrint(screen.getString("currentscreen").toString());
    getdata();
  }
  void getdata () async{
    setState(() {
      showloader = true;
    });
    try{
      var rsp = await apiurl("/member/process", "settings.php", {
        "type": "fetch_formats",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
           allformat = rsp['data'];
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

  void activateBillFormat (String id) async{
    setState(() {
      showloader = true;
    });
    try{
      var rsp = await apiurl("/member/process", "settings.php", {
        "type": "act_format",
        "format":id
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            showPrintedMessage(context, "Success", "Activated", Colors.white,Colors.green, Icons.info, true, "top");
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
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Stack(
              children : [
                Column(
                  children: [
                    ConstAppBar("bill_format_help"),
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
                                Text('Bill Format', style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.white
                                ),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: showloader==false?GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1/ 2,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 10),
                          itemCount: allformat.length,
                          itemBuilder: (BuildContext ctx, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    height: 300,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.orange,
                                        image: DecorationImage(
                                          image: NetworkImage(allformat[index]['file'].toString()),
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [],
                                        ),
                                      ],
                                    ),
                                  ),
                                  RaisedButton(
                                    elevation: 0,
                                    color: Colors.green,
                                    onPressed: (){
                                      activateBillFormat(allformat[index]['format'].toString());
                                    },
                                    child: Text('Activate',style: TextStyle(color:Colors.white, fontSize: 15),),
                                  )
                                ],
                              ),
                            );
                          }):Container(
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 0.7,

                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 80,
                    )
                  ],
                ),
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: BottomBar(lastscreen: "allformat",),
                ),
              ]
            ),
          )),
    );
  }
}
