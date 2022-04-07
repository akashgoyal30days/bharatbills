import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../main.dart';
import '../../toast_messeger.dart';
import '../all_product.dart';
import '../cash_bank_book.dart';
import '../warehouse.dart';

class EditWareHouse extends StatefulWidget {
  EditWareHouse({required this.id});

  final String id;
  @override
  _EditWareHouseState createState() => _EditWareHouseState();
}


class _EditWareHouseState extends State<EditWareHouse> {

  dynamic nameController = TextEditingController();
  dynamic addressController = TextEditingController();
  dynamic locationController = TextEditingController();
  dynamic tradeController = TextEditingController();
  dynamic pinController = TextEditingController();

  bool showloader = false;

  void initState(){
    super.initState();
    getproddet();
  }




  //update warehouse api
  void Update () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "warehouse.php", {
        'type':'update',
        'wid': widget.id.toString(),
        'name':nameController.text.toString(),
        'address':addressController.text.toString(),
        'location':locationController.text.toString(),
        'tradename':tradeController.text.toString(),
        'loc_pin':pinController.text.toString(),
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Warehouse Details Updated Successfully", Colors.white,Colors.green, Icons.info, true, "top");
          setState(() {

            Navigator.of(context)
                .popUntil((route) =>
            route.isFirst);
            Navigator
                .pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType
                        .fade,
                    child: WareHouseScreen()));
          }
          );

        }else if(rsp['status'].toString()=="false"){
          setState(() {
            showloader=false;
          });
          if(rsp['error'].toString()=="invalid_auth"){
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
          }

        }
        else if(rsp['status'].toString()=="already_exist"){
          showPrintedMessage(context, "Failed", "Already Exist", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
        }
      }
    }
    catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  //getwaredet
  void getproddet() async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "warehouse.php", {
        "type": "view",
        "wid": widget.id
      });
      //debugPrint("prod det "+rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            //required controllers
            nameController.text = rsp['data']['name'].toString();
            tradeController.text = rsp['data']['tradename'].toString();
            addressController.text = rsp['data']['address'].toString();
            pinController.text = rsp['data']['loc_pin'].toString();
            locationController.text = rsp['data']['location'].toString();
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
                  child: WareHouseScreen()));
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 40,
              elevation: 0,
              title: Text('Add Warehouse', style: GoogleFonts.poppins(fontSize: 16),),
              backgroundColor: AppBarColor,
            ),
            backgroundColor: Colors.white,
            body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: showloader==false?Stack(
                  children: [
                    ListView(
                      children: [
                        //required
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child:  Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0)),),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextFormField(
                                decoration: new InputDecoration(
                                  isDense: true,labelText: "Name *",
                                  labelStyle: GoogleFonts.poppins(
                                      fontSize: 14, color: AppBarColor
                                  ),
                                  fillColor: Colors.white.withOpacity(0.5),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  //fillColor: Colors.green
                                ),
                                controller: nameController,
                              ),
                            ),
                          ),
                        ),


                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child:  Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0)),),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextFormField(
                                decoration: new InputDecoration(
                                  isDense: true,labelText: "Address",
                                  labelStyle: GoogleFonts.poppins(
                                      fontSize: 14, color: AppBarColor
                                  ),
                                  fillColor: Colors.white.withOpacity(0.5),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  //fillColor: Colors.green
                                ),
                                controller: addressController,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child:  Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0)),),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextFormField(
                                decoration: new InputDecoration(
                                  isDense: true,labelText: "Location *",
                                  labelStyle: GoogleFonts.poppins(
                                      fontSize: 14, color: AppBarColor
                                  ),
                                  fillColor: Colors.white.withOpacity(0.5),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  //fillColor: Colors.green
                                ),
                                controller: locationController,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child:  Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0)),),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextFormField(
                                decoration: new InputDecoration(
                                  isDense: true,labelText: "Trade Name",
                                  labelStyle: GoogleFonts.poppins(
                                      fontSize: 14, color: AppBarColor
                                  ),
                                  fillColor: Colors.white.withOpacity(0.5),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  //fillColor: Colors.green
                                ),
                                controller: tradeController,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child:  Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0)),),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                                decoration: new InputDecoration(
                                  isDense: true,labelText: "Pin",
                                  labelStyle: GoogleFonts.poppins(
                                      fontSize: 14, color: AppBarColor
                                  ),
                                  fillColor: Colors.white.withOpacity(0.5),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  //fillColor: Colors.green
                                ),
                                controller: pinController,
                              ),
                            ),
                          ),
                        ),

                        Container(height: 200,
                          width: MediaQuery.of(context).size.width,)

                      ],
                    ),
                    Positioned(
                      bottom: 2,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            color: AppBarColor.withOpacity(0.9),
                            splashColor: AppBarColor.withOpacity(0.9),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            onPressed: (){
                              if(nameController.text.isEmpty||locationController.text.isEmpty){
                                showPrintedMessage(context, "Alert", "Please fill required fields", Colors.white,Colors.redAccent, Icons.info, true, "top");
                              }else{
                                Update();
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Update', style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.w500,
                                    color: Colors.white
                                ),)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ):Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 0.7,
                  ),
                ))
        )
    );
  }
}
