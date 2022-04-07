import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/screen_models/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../shared preference singleton.dart';

import '../main.dart';
import '../toast_messeger.dart';

class Add_Bank extends StatefulWidget {
  @override
  _Add_BankState createState() => _Add_BankState();
}

class _Add_BankState extends State<Add_Bank> {
  bool islist = false;
  bool showloader = true;
  var allbank;

  //controllers
  dynamic banknameController = TextEditingController();
  dynamic payeenameController = TextEditingController();
  dynamic accnoController = TextEditingController();
  dynamic ifscController = TextEditingController();
  dynamic branchController = TextEditingController();





  @override
  void initState(){
    super.initState();
    setscreenposition();
  }

  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "add_bank");
    //debugPrint(screen.getString("currentscreen").toString());
    //getdata();
    getdata();
  }
  void getdata () async{
    setState(() {
      showloader = true;
    });
    try{
      var rsp = await apiurl("/member/process", "firm.php", {
        "type": "view_bank",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            allbank = rsp['data'];
            banknameController.text = rsp['data']['bank'].toString();
            payeenameController.text = rsp['data']['payee'].toString();
            accnoController.text = rsp['data']['acc_no'].toString();
            ifscController.text = rsp['data']['ifsc'].toString();
            branchController.text = rsp['data']['branch'].toString();

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
  void updateTerm (String id) async{
    setState((){
      showloader = true;
    });
    try{
      var rsp = await apiurl("/member/process", "firm.php", {
        "type": "update_bank",
        "payee": payeenameController.text.toString(),
        "bank": banknameController.text.toString(),
        "acc_no": accnoController.text.toString(),
        "ifsc": ifscController.text.toString(),
        "branch": branchController.text.toString(),
        "id": id,
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        getdata();
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Updated Successfully", Colors.white,Colors.green, Icons.info, true, "top");
          getdata();
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
                                  'Add Bank', style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.white
                                ),),
                              ],
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
                            child: ListView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                  child: Row(
                                    children: [
                                      Text('Bank Name', style: GoogleFonts.poppins(
                                          fontSize: 15, fontWeight: FontWeight.w500
                                      ),),
                                      Text('', style: GoogleFonts.poppins(
                                          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red
                                      ),),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                  child:  Container(
                                    height: 50,
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
                                      child: TextFormField(
                                        onChanged: (v){

                                        },
                                        decoration: new InputDecoration(
                                          prefixIcon: Icon(Icons.ballot_outlined, color: Colors.grey.withOpacity(0.9),size: 25,),
                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                          labelText: "Bank Name",
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
                                        controller: banknameController,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                  child: Row(
                                    children: [
                                      Text('Payee Name', style: GoogleFonts.poppins(
                                          fontSize: 15, fontWeight: FontWeight.w500
                                      ),),
                                      Text('', style: GoogleFonts.poppins(
                                          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red
                                      ),),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                  child:  Container(
                                    height: 50,
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
                                      child: TextFormField(
                                        onChanged: (v){

                                        },
                                        decoration: new InputDecoration(
                                          prefixIcon: Icon(Icons.ballot_outlined, color: Colors.grey.withOpacity(0.9),size: 25,),
                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                          labelText: "Payee Name",
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
                                        controller: payeenameController,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                  child: Row(
                                    children: [
                                      Text('Acc No.', style: GoogleFonts.poppins(
                                          fontSize: 15, fontWeight: FontWeight.w500
                                      ),),
                                      Text('', style: GoogleFonts.poppins(
                                          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red
                                      ),),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                  child:  Container(
                                    height: 50,
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
                                      child: TextFormField(
                                        onChanged: (v){

                                        },
                                        decoration: new InputDecoration(
                                          prefixIcon: Icon(Icons.ballot_outlined, color: Colors.grey.withOpacity(0.9),size: 25,),
                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                          labelText: "Acc No.",
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
                                        controller: accnoController,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                  child: Row(
                                    children: [
                                      Text('IFSC', style: GoogleFonts.poppins(
                                          fontSize: 15, fontWeight: FontWeight.w500
                                      ),),
                                      Text('', style: GoogleFonts.poppins(
                                          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red
                                      ),),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                  child:  Container(
                                    height: 50,
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
                                      child: TextFormField(
                                        onChanged: (v){

                                        },
                                        decoration: new InputDecoration(
                                          prefixIcon: Icon(Icons.ballot_outlined, color: Colors.grey.withOpacity(0.9),size: 25,),
                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                          labelText: "IFSC",
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
                                        controller: ifscController,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                  child: Row(
                                    children: [
                                      Text('Bank Branch', style: GoogleFonts.poppins(
                                          fontSize: 15, fontWeight: FontWeight.w500
                                      ),),
                                      Text('', style: GoogleFonts.poppins(
                                          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red
                                      ),),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                  child:  Container(
                                    height: 50,
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
                                      child: TextFormField(
                                        onChanged: (v){

                                        },
                                        decoration: new InputDecoration(
                                          prefixIcon: Icon(Icons.ballot_outlined, color: Colors.grey.withOpacity(0.9),size: 25,),
                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                          labelText: "Bank Branch",
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
                                        controller: branchController,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          ),
                        ),
                      ),
                    ),
                    //this button is hidden! don't panic
                    Container(
                      height: 50,
                      width:  200,
                      child: RaisedButton(
                        elevation: 0,
                        color: AppBarColor,
                        onPressed: (){
                          updateTerm(allbank['id'].toString());
                        },
                        child: Text('Save Details', style: TextStyle(fontSize:15, color:Colors.white),),
                      ),
                    ),
                    SizedBox(height: 100,)
                  ],
                ),
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: BottomBar(lastscreen: "addbank",),
                ),
              ],
            ),
          )
      ),
    );
  }
}
