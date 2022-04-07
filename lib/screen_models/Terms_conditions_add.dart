import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/api_constants.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/screen_models/settings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../shared preference singleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../toast_messeger.dart';

class Terms_Conds extends StatefulWidget {
  @override
  _Terms_CondsState createState() => _Terms_CondsState();
}

class _Terms_CondsState extends State<Terms_Conds> {
  bool islist = false;
  bool showloader = true;
  List allterms = [];
  List termsid = [];
  List alltermsController = [];
  List allreadonly = [];

  String type = 'sales';



  @override
  void initState(){
    super.initState();
    setscreenposition();
  }

  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "terms_and_cond");
    //debugPrint(screen.getString("currentscreen").toString());
    //getdata();
    getdata();
  }
  List totalterms = [];
  void getdata () async{
    setState(() {
      showloader = true;
      alltermsController.clear();
    });
    try{
      var rsp = await apiurl("/member/process", "firm.php", {
        "type": "view_terms",
        "format": type=="sales"?"invoice":type=='pinvoice'?"pinvoice":"quotation"
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            allterms.clear();
            termsid.clear();
            allreadonly.clear();
            totalterms = rsp['data'];
          for(var i = 0; i<rsp['data'].length; i++){
            allterms.add(rsp['data'][i]['term'].toString());
            termsid.add(rsp['data'][i]['id'].toString());
            if(rsp['data'][i]['term'].isNotEmpty) {
              allreadonly.add(true);
            }
                else{
              allreadonly.add(false);
            }

          }
          //debugPrint(allreadonly.toString());
            addfields();

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
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }
  void updateTerm (String term, String id) async{
    setState((){
      showloader = true;
    });
    try{
      var rsp = await apiurl("/member/process", "firm.php", {
        "type": "update_term",
        "format": type=="sales"?"invoice":type=='pinvoice'?"pinvoice":"quotation",
        "term": term.replaceAll("[","").toString().replaceAll("]",""),
        "id": id.replaceAll("[","").toString().replaceAll("]",""),
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        getdata();
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Updated Successfully", Colors.white,Colors.green, Icons.info, true, "top");

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showloader=false;
          showPrintedMessage(context, "Failed", "Failed to Update", Colors.white,Colors.redAccent, Icons.info, true, "top");
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
      getdata();
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }
  void delTerm ( String id) async{
    setState((){
      showloader = true;
    });
    try{
      var rsp = await apiurl("/member/process", "firm.php", {
        "type": "delete_term",
        "format": type=="sales"?"invoice":type=='pinvoice'?"pinvoice":"quotation",
        "id": id.replaceAll("[","").toString().replaceAll("]",""),
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        getdata();
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Updated Successfully", Colors.white,Colors.green, Icons.info, true, "top");

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showloader=false;
          showPrintedMessage(context, "Failed", "Failed to Update", Colors.white,Colors.redAccent, Icons.info, true, "top");
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
      getdata();
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }
  void AddTerm (List term) async{
    //debugPrint(term.toString());
    String token = "";
    var userdetails = SharedPreferenceSingleton.sharedPreferences;
    setState((){
      showloader = true;
      if(userdetails.getString("utoken")!=null){
        token = userdetails.getString("utoken").toString();
      }
    });
    try{
      FormData formData = new FormData();
      formData = FormData.fromMap({
        "_req_from": reqfrom,
        "api_key": apikey,
        "_req_token": token,
        "type": "add_terms",
        "format": type=="sales"?"invoice":type=='pinvoice'?"pinvoice":"quotation",
        "term": term,
      });
      var rsp = await gbill("/member/process", "firm.php", formData);
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        getdata();
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Added Successfully", Colors.white,Colors.green, Icons.info, true, "top");

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showloader=false;
          showPrintedMessage(context, "Failed", "Failed to Update", Colors.white,Colors.redAccent, Icons.info, true, "top");
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
      getdata();
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  void addfields (){
    alltermsController.clear();
    for(var i = 0; i < allterms.length; i++){
      setState(() {
        alltermsController.add(TextEditingController());
      });

    }
    for(var i = 0; i < alltermsController.length; i++){
      setState(() {
        alltermsController[i].text = allterms[i].toString();
      });

    }
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
                child: Settings_Screen()));
        return false;
      },
      child: Scaffold(

          backgroundColor: Colors.white,
          body: Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Stack(
              children: [
                  Column(
                    children: [
                      ConstAppBar(),
                      Container(
                        height: 35,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        color: AppBarColor,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle, color: Colors.white, size: 15,),
                                  SizedBox(width: 10,),
                                  Text(
                                    'Terms and Conditions', style: GoogleFonts.poppins(
                                      fontSize: 15, color: Colors.white
                                  ),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if(showloader==false&&alltermsController.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 170,
                            height: 35,
                            color: Colors.green,
                            child: RaisedButton(
                                elevation: 0,
                                color: Colors.green,
                                onPressed:(){
                                  if(alltermsController.length<6){
                                    setState(() {
                                      alltermsController.add(TextEditingController());
                                      allterms.add('-');
                                      termsid.add('');
                                      allreadonly.add(false);
                                      //debugPrint(allterms.toString());
                                    });
                                  }else{
                                    showPrintedMessage(context, "Error", "Maximum 6 fields allowed", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.add_box_sharp, color:Colors.white, size:17),
                                    Text('Add New Field', style: GoogleFonts.poppins(
                                        fontSize: 15, color: Colors.white
                                    )),
                                  ],
                                )
                            ),
                          ),
                        ],
                      ),
                      if(showloader==false)
                        Container(
                          width: MediaQuery.of(context).size.width-20,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 40,
                                width: 65,
                                child: RaisedButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(00)),
                                  elevation: 0,
                                  color: Colors.white,
                                  onPressed: (){
                                    setState(() {
                                      type='sales';
                                      allterms.clear();
                                    });
                                    getdata();
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 15,
                                        left: 0,
                                        right: 0,
                                        child: Text('Sales', style:TextStyle(fontSize:13, color:Colors.black)),
                                      ),

                                      if(type=='sales')
                                        Positioned(
                                          top: 00,
                                          left: 10,
                                          right: 0,
                                          child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(width:5),
                              Container(
                                height: 40,
                                width: 120,
                                child: RaisedButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(00)),
                                  elevation: 0,
                                  color: Colors.white,
                                  onPressed: (){
                                    setState(() {
                                      type='pinvoice';
                                      allterms.clear();
                                    });
                                    getdata();
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 15,
                                        left: 0,
                                        right: 0,
                                        child: Text('Proforma', style:TextStyle(fontSize:13, color:Colors.black)),
                                      ),

                                      if(type=='pinvoice')
                                        Positioned(
                                          top: 00,
                                          left: 45,
                                          right: 0,
                                          child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(width:5),

                              Container(
                                height: 40,
                                width: 100,
                                child: RaisedButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(00)),
                                  elevation: 0,
                                  color: Colors.white,
                                  onPressed: (){
                                    setState(() {
                                      type='quote';
                                      allterms.clear();
                                    });
                                    getdata();
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 15,
                                        left: 0,
                                        right: 0,
                                        child: Text('Quotation', style:TextStyle(fontSize:15, color:Colors.black)),
                                      ),

                                      if(type=='quote')
                                        Positioned(
                                          top: 00,
                                          left: 30,
                                          right: 0,
                                          child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height-140,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: showloader==true?Container(
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 0.7,

                              ),
                            ),
                          ):Container(
                              height: MediaQuery.of(context).size.height,
                              child: Container(
                                height: MediaQuery.of(context).size.height-180,
                                child: alltermsController.isNotEmpty?ListView.builder(
                                    itemCount:alltermsController.length,
                                    itemBuilder: (BuildContext context, index){
                                      return Container(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
                                              child:  Container(
                                                height: 45,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(5.0),
                                                        topLeft: Radius.circular(5.0),
                                                        bottomLeft: Radius.circular(5.0),
                                                        bottomRight: Radius.circular(5.0))),
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: allreadonly[index]==true?Colors.grey.withOpacity(0.3):Colors.white,
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.only(
                                                            topRight: Radius.circular(5.0),
                                                            topLeft: Radius.circular(5.0),
                                                            bottomLeft: Radius.circular(5.0),
                                                            bottomRight: Radius.circular(5.0))),
                                                    child: TextFormField(
                                                      readOnly: allreadonly[index],
                                                      onChanged: (v){


                                                      },
                                                      decoration: new InputDecoration(
                                                        prefixIcon: Container(
                                                          height: 30,
                                                          width: 20,
                                                          decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              shape: BoxShape.rectangle,
                                                              borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(0.0),
                                                                  topLeft: Radius.circular(5.0),
                                                                  bottomLeft: Radius.circular(5.0),
                                                                  bottomRight: Radius.circular(0.0))),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width:30,
                                                                decoration: BoxDecoration(
                                                                    color: AppBarColor,
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.only(
                                                                        topRight: Radius.circular(0.0),
                                                                        topLeft: Radius.circular(5.0),
                                                                        bottomLeft: Radius.circular(5.0),
                                                                        bottomRight: Radius.circular(0.0))),
                                                                child: TextButton(
                                                                  onPressed: null,
                                                                  child: Text((index+1).toString(), style: TextStyle(color:Colors.white),),
                                                                ),
                                                              ),
                                                              Container(
                                                                height: 5,
                                                                width: 5,
                                                                color:Colors.white,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        suffixIcon: Container(
                                                          height: 30,
                                                          width: 60,
                                                          decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              shape: BoxShape.rectangle,
                                                              borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(5.0),
                                                                  topLeft: Radius.circular(0.0),
                                                                  bottomLeft: Radius.circular(0.0),
                                                                  bottomRight: Radius.circular(5.0))),
                                                          child: Row(
                                                            children: [
                                                              if(allreadonly[index]==true)
                                                              Container(
                                                                width:30,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.green,
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.only(
                                                                        topRight: Radius.circular(0.0),
                                                                        topLeft: Radius.circular(0.0),
                                                                        bottomLeft: Radius.circular(0.0),
                                                                        bottomRight: Radius.circular(0.0))),
                                                                child: IconButton(
                                                                  onPressed: (){
                                                                    setState(() {
                                                                      allreadonly[index] = false;
                                                                    });
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.edit,
                                                                    color:Colors.white,
                                                                    size: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                              if(allreadonly[index]==false&&allterms[index].toString()=='-')
                                                              Container(
                                                                width:30,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.green,
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.only(
                                                                        topRight: Radius.circular(0.0),
                                                                        topLeft: Radius.circular(0.0),
                                                                        bottomLeft: Radius.circular(0.0),
                                                                        bottomRight: Radius.circular(0.0))),
                                                                child: IconButton(
                                                                  onPressed: (){
                                                                    setState(() {
                                                                      List a = [
                                                                      ];
                                                                      if(alltermsController[index].text.isNotEmpty){
                                                                        a.add(alltermsController[index].text.toString());
                                                                      }else{
                                                                        a.add('');
                                                                      }
                                                                      AddTerm(
                                                                          a,);
                                                                    });
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.check,
                                                                    color:Colors.white,
                                                                    size: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                              if(allreadonly[index]==false&&allterms[index].toString()!='-')
                                                              Container(
                                                                width:30,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.green,
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.only(
                                                                        topRight: Radius.circular(0.0),
                                                                        topLeft: Radius.circular(0.0),
                                                                        bottomLeft: Radius.circular(0.0),
                                                                        bottomRight: Radius.circular(0.0))),
                                                                child: IconButton(
                                                                  onPressed: (){
                                                                    setState(() {
                                                                      List a = [
                                                                      ];
                                                                      if(alltermsController[index].text.isNotEmpty){
                                                                        a.add(alltermsController[index].text.toString());
                                                                      }else{
                                                                        a.add('');
                                                                      }
                                                                      List b = [
                                                                      ];
                                                                      b.add(
                                                                          termsid[index]
                                                                              .toString());
                                                                      updateTerm(
                                                                          a.toString(),
                                                                          b.toString());
                                                                    });
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.upload_rounded,
                                                                    color:Colors.white,
                                                                    size: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width:30,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.red,
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.only(
                                                                        topRight: Radius.circular(5.0),
                                                                        topLeft: Radius.circular(0.0),
                                                                        bottomLeft: Radius.circular(0.0),
                                                                        bottomRight: Radius.circular(5.0))),
                                                                child: IconButton(
                                                                  onPressed: alltermsController[index].text.isEmpty?(){
                                                                    showPrintedMessage(context, "Error", "Already Blank", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                                                  }:(){
                                                                    setState(() {
                                                                      alltermsController[index].clear();
                                                                      if(allterms[index].isNotEmpty) {
                                                                        List a = [
                                                                          ''
                                                                        ];
                                                                        List b = [
                                                                        ];
                                                                        b.add(
                                                                            termsid[index]
                                                                                .toString());
                                                                        delTerm(
                                                                            b.toString());
                                                                      }
                                                                    });
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.delete,
                                                                    color:Colors.white,
                                                                    size: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                                        isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                        labelText: "Add Terms and Conditions",
                                                        fillColor: Colors.white.withOpacity(0.5),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey.withOpacity(0.3),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey.withOpacity(0.3),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        //fillColor: Colors.green
                                                      ),
                                                      controller: alltermsController[index],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if(index==alltermsController.length-1)
                                              Container(
                                                height: 70,
                                                width: MediaQuery.of(context).size.width,
                                                color: Colors.white,
                                              ),
                                          ],
                                        ),
                                      );
                                    })
                                    :Center(
                                  child:  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('No Terms & Conditions added', style: TextStyle(fontSize:16),),
                                      SizedBox(height: 10,),
                                      Container(
                                        width: 180,
                                        height: 35,
                                        color: Colors.green,
                                        child: RaisedButton(
                                            elevation: 0,
                                            color: Colors.green,
                                            onPressed:(){
                                              if(alltermsController.length<6){
                                                setState(() {
                                                  allterms.clear();
                                                  alltermsController.add(TextEditingController());
                                                  allterms.add('-');
                                                  termsid.add('');
                                                  allreadonly.add(false);
                                                });
                                              }else{
                                                showPrintedMessage(context, "Error", "Maximum 6 fields allowed", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                              children: [
                                                Icon(Icons.add_box_sharp, color:Colors.white, size:17),
                                                Text('Add New Field', style: GoogleFonts.poppins(
                                                    fontSize: 15, color: Colors.white
                                                )),
                                              ],
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ),
                        ),
                      ),
                      //this button is hidden! don't panic

                      SizedBox(height: 100,)
                    ],
                  ),
                  Positioned(
                    bottom: 2,
                    left: 0,
                    right: 0,
                    child: BottomBar(lastscreen: "accountdetails",),
                  ),
              ],
            ),
          )),
    );
  }
}
