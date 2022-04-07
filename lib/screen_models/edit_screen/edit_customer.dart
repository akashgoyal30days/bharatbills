import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../main.dart';
import '../../toast_messeger.dart';
import '../all_customer.dart';
import '../all_suppliers.dart';

class EditCustomer extends StatefulWidget {
  EditCustomer({required this.fromscreen, required this.cid, required this.name, required this.contact,
  required this.email, required this.address, required this.city, required this.state,
  required this.pincode, required this.gstatus, required this.gstno, required this.btype,
  required this.openbalance, required this.panno, required this.tan, required this.dist});
  final String fromscreen;
  final String cid;
  final String name;
  final String contact;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String gstatus;
  final String gstno;
  final String btype;
  final String openbalance;
  final String panno;
  final String tan;
  final String dist;

  @override
  _EditCustomerState createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
  bool showfillwithgst = false;

  //required controllers
  dynamic nameController = TextEditingController();
  dynamic contactController = TextEditingController();
  dynamic emailController = TextEditingController();


  //fill with gst controllers
  dynamic fwgstnoController = TextEditingController();


  //address controllers
  dynamic addressController = TextEditingController();
  dynamic cityController = TextEditingController();
  dynamic pinController = TextEditingController();
  String? state;

  //gst controllers
  dynamic gstnoController = TextEditingController();
  String? gststatus;

  //other details controllers
  dynamic openbalController = TextEditingController();
  dynamic panController = TextEditingController();
  dynamic tanController = TextEditingController();
  dynamic cinController = TextEditingController();
  dynamic distanceController = TextEditingController();
  String balancetype = "start";
  List? stateslist;
  List? gststtlist;

  int selectedindex = 0;
  bool showloader = false;

  @override
  void initState(){
    getStates();
    super.initState();
  }

  //set values
  void setvals(){
    setState(() {
      nameController.text=widget.name;
      contactController.text=widget.contact;
      emailController.text=widget.email;
      addressController.text=widget.address;
      cityController.text=widget.city;
      if(widget.state!=''&&widget.state!='null') {
        state = widget.state;
      }
      pinController.text=widget.pincode;
      if(widget.gstatus!=''&&widget.gstatus!='null') {
        gststatus = widget.gstatus;
      }
      gstnoController.text=widget.gstno;
      if(widget.btype!=''&&widget.btype!='null') {
        balancetype = widget.btype;
      }
      openbalController.text=widget.openbalance;
      panController.text=widget.panno;
      tanController.text=widget.tan;
      distanceController.text=widget.dist;
    });
  }


  //get data with gst api
  void fillwithgstapi () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "common.php", {
        "type": "gst_dataa",
        "gst_num": fwgstnoController.text
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            showfillwithgst = false;
            fwgstnoController.clear();
            nameController.text = rsp['data']['tradeNam'].toString();
            addressController.text = rsp['data']['pradr']['addr']['bno'].toString()+' '+rsp['data']['pradr']['addr']['flno'].toString()+' '+rsp['data']['pradr']['addr']['st'].toString()+' '+rsp['data']['pradr']['addr']['city'].toString()+' '+rsp['data']['pradr']['addr']['loc'].toString()+' '+rsp['data']['pradr']['addr']['dst'].toString();
            pinController.text = rsp['data']['pradr']['addr']['pncd'].toString();
            cityController.text = rsp['data']['pradr']['addr']['city'].toString();
            state= rsp['data']['pradr']['addr']['stcd'].toString();
            gstnoController.text = rsp['data']['gstin'].toString();
            gststatus = rsp['data']['dty'].toString();
            //debugPrint(rsp['data']['tradeNam']);
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
      }
    }catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }
  String labelpan = "Pan";
  String labeltan = "Tan";
  String labelcin = "Cin";
  //get states
  void getStates () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "customer.php", {
        "type": "find_state",
        "state": "all"
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            //debugPrint(rsp['state'].length.toString());
            stateslist = rsp['state'];
            gststtlist = rsp['gststatus'];
            labelpan = rsp['labels']['pan'].toString();
            labeltan = rsp['labels']['tan'].toString();
            labelcin = rsp['labels']['cin'].toString();
            //debugPrint(rsp['labels'].toString());
            setvals();
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
      }
    }catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }


  //get states
  void update () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", widget.fromscreen=="Customer"?"customer.php":"supplier.php", {
        "type":"updateApp",
        "cid":widget.cid.toString(),
        "state": state!=null?state.toString():"",
        "name": nameController.text.toString(),
        "address":addressController.text.toString(),
        "phone":contactController.text.toString(),
        "email":emailController.text.toString(),
        "city":cityController.text.toString(),
        "pin":pinController.text.toString(),
        "pan":panController.text.toString(),
        "tan":tanController.text.toString(),
        "cin":cinController.text.toString(),
        if(widget.fromscreen=="Customer")
          "distance":distanceController.text.toString(),
        "gst_status":gststatus!=null?gststatus.toString():"",
        "gst":gstnoController.text.toString(),
        "bal_type": balancetype!=null?balancetype.toString():"",
        "open_bal": openbalController.text.toString()
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Updated Successfully", Colors.white,Colors.green, Icons.info, true, "top");
          setState(() {
            if(widget.fromscreen=="Customer"){
              Navigator.of(context)
                  .popUntil((route) =>
              route.isFirst);
              Navigator
                  .pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType
                          .fade,
                      child: AllCustomerScreen()));
            }else{
              Navigator.of(context)
                  .popUntil((route) =>
              route.isFirst);
              Navigator
                  .pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType
                          .fade,
                      child: AllSupplierScreen()));
            }
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
        else if(rsp['status'].toString()=="already_exist"){
          showPrintedMessage(context, "Failed", "Already Exist", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
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
          if(widget.fromscreen=="Customer"){
            Navigator.of(context)
                .popUntil((route) =>
            route.isFirst);
            Navigator
                .pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType
                        .fade,
                    child: AllCustomerScreen()));
          }else{
            Navigator.of(context)
                .popUntil((route) =>
            route.isFirst);
            Navigator
                .pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType
                        .fade,
                    child: AllSupplierScreen()));
          }
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 40,
              elevation: 0,
              title: Text('Edit ${widget.fromscreen}', style: GoogleFonts.poppins(fontSize: 16),),
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
                        if(showfillwithgst==false)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              child: RaisedButton(
                                color: Color(0xff667C3E).withOpacity(0.6),
                                splashColor: Colors.green.withOpacity(0.2),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                onPressed: (){
                                  setState(() {
                                    showfillwithgst=true;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.add, color: Colors.white,size: 30,),
                                    SizedBox(width: 10,),
                                    Text('Fill With Gst', style: GoogleFonts.poppins(
                                        fontSize: 18, fontWeight: FontWeight.w500,
                                        color: Colors.white
                                    ),)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if(showfillwithgst==true)
                          Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('GST Number', style: GoogleFonts.poppins(
                                          fontSize: 18, fontWeight: FontWeight.w500,
                                          color: Colors.black
                                      ),),

                                      GestureDetector(
                                          onTap: (){
                                            setState((){
                                              showfillwithgst=false;
                                            });
                                          },
                                          child: Icon(Icons.cancel, size: 30,color:Colors.red)),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
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
                                          isDense: true,labelText: "GST Number",
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
                                          controller: fwgstnoController,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(15, 20, 20, 8),
                                    child:  Container(
                                      child:  Text('Providing Party GST number will automatically update'
                                          ' party details like Name, Address, State, Pin code etc.', style: GoogleFonts.poppins(
                                          fontSize: 15, fontWeight: FontWeight.w500,
                                          color: Colors.black
                                      ),textAlign: TextAlign.center,),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(15, 20, 20, 8),
                                    child:  Container(
                                      child:  Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.security, color: Colors.blueAccent.withOpacity(0.3),),
                                          SizedBox(width: 10,),
                                          Text('Only you can see this information', style: GoogleFonts.poppins(
                                              fontSize: 15, fontWeight: FontWeight.w500,
                                              color: Colors.grey
                                          ),textAlign: TextAlign.center,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      child: RaisedButton(
                                        color: fwgstnoController.text.isEmpty?Colors.grey.withOpacity(0.3):AppBarColor.withOpacity(0.9),
                                        splashColor: AppBarColor.withOpacity(0.9),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)),
                                        onPressed: fwgstnoController.text.isEmpty?null:(){
                                          fillwithgstapi();
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Proceed', style: GoogleFonts.poppins(
                                                fontSize: 18, fontWeight: FontWeight.w500,
                                                color: Colors.white
                                            ),)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if(showfillwithgst==false)
                          Padding(
                              padding: const EdgeInsets.only(left: 9, bottom: 8),
                              child: Text('Required Fields', style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w400,
                                  color: Colors.black
                              ),)
                          ),
                        //required fields
                        if(showfillwithgst==false)
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
                        if(showfillwithgst==false)
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
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),],
                                  decoration: new InputDecoration(
                                          isDense: true,labelText: "Contact",
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
                                  controller: contactController,
                                ),
                              ),
                            ),
                          ),
                        if(showfillwithgst==false)
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
                                          isDense: true,labelText: "Email",
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
                                  controller: emailController,
                                ),
                              ),
                            ),
                          ),
                        //list menu
                        if(showfillwithgst==false)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
                            child:  Container(
                              height: 55,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      topLeft: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(30.0),
                                      bottomRight: Radius.circular(30.0))),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
                                child: ListView.builder(
                                    itemCount: 3,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (BuildContext context, index){
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 30,
                                          child: RaisedButton(
                                            color: selectedindex!=index?Colors.white:Color(0xff667C3E).withOpacity(0.6),
                                            splashColor: selectedindex!=index?Colors.white:Color(0xff667C3E).withOpacity(0.6),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                                side: BorderSide(color: selectedindex==index?Colors.white:AppBarColor.withOpacity(0.9), width: 1)),
                                            onPressed: (){
                                              setState(() {
                                                selectedindex=index;
                                              });
                                            },
                                            child: index==0?Text('Address', style: GoogleFonts.poppins(
                                                fontSize: 14, color: selectedindex==index?Colors.white:Colors.black
                                            ),):index==1?Text('GST Details', style: GoogleFonts.poppins(
                                                fontSize: 14, color: selectedindex==index?Colors.white:Colors.black
                                            ),):Text('Other Details', style: GoogleFonts.poppins(
                                                fontSize: 14, color: selectedindex==index?Colors.white:Colors.black
                                            ),),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ),
                        //other fields

                        //address fields
                        if(selectedindex==0&&showfillwithgst==false)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            child:  Container(
                              height: 60,
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
                        if(selectedindex==0&&showfillwithgst==false)
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
                                          isDense: true,labelText: "City",
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
                                  controller: cityController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==0&&showfillwithgst==false)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            child:  Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    child: DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      elevation: 0,
                                      focusColor:Colors.transparent,
                                      value: state,
                                      //elevation: 5,
                                      style: TextStyle(color: AppBarColor),
                                      iconEnabledColor:AppBarColor,
                                      items: stateslist?.map((item) {
                                        return new DropdownMenuItem(
                                          child: new Text(item['state_name'],style: TextStyle(fontSize: 18, color: AppBarColor),),
                                          value: item['state_name'].toString(),
                                        );
                                      })?.toList() ??
                                          [],
                                      hint:Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "State",
                                          style: GoogleFonts.poppins(
                                              color: AppBarColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      onChanged: (String? value) {
                                        FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                        FocusScopeNode currentFocus = FocusScope.of(context);

                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        setState(() {
                                          state = value.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==0&&showfillwithgst==false)
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
                                          isDense: true,labelText: "Pin Code",
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

                        //gst fields
                        if(selectedindex==1&&showfillwithgst==false)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            child:  Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    child: DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      elevation: 0,
                                      focusColor:Colors.transparent,
                                      value: gststatus,
                                      //elevation: 5,
                                      style: TextStyle(color: AppBarColor),
                                      iconEnabledColor:AppBarColor,
                                      items: gststtlist?.map((item) {
                                        return new DropdownMenuItem(
                                          child: new Text(item['value'],style: TextStyle(fontSize: 18, color: AppBarColor),),
                                          value: item['value'].toString(),
                                        );
                                      })?.toList() ??
                                          [],
                                      hint:Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "GST Status",
                                          style: GoogleFonts.poppins(
                                              color: AppBarColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      onChanged: (String? value) {
                                        FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                        FocusScopeNode currentFocus = FocusScope.of(context);

                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        setState(() {
                                          gststatus = value.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==1&&showfillwithgst==false)
                          Padding(
                            padding: EdgeInsets.fromLTRB(gststatus!='Unregistered'?10:20, 8, gststatus!='Unregistered'?10:20, 8),
                            child:  Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: gststatus!='Unregistered'?Colors.white:Colors.grey.withOpacity(0.3),
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
                                  readOnly: gststatus!='Unregistered'?false:true,
                                  decoration: new InputDecoration(
                                          isDense: true,labelText: gststatus!='Unregistered'?"GST No":"GST No",
                                    hintText: gststatus!='Unregistered'?"GST No":"GST No",
                                    labelStyle: GoogleFonts.poppins(
                                        fontSize: 14, color: AppBarColor
                                    ),
                                    floatingLabelBehavior: gststatus!='Unregistered'?FloatingLabelBehavior.always:FloatingLabelBehavior.never,
                                    fillColor: Colors.white.withOpacity(0.5),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        color: gststatus!='Unregistered'?Colors.blueAccent:Colors.transparent,
                                        width: 1.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        color: gststatus!='Unregistered'?Colors.grey:Colors.transparent,
                                        width: 1.0,
                                      ),
                                    ),
                                    //fillColor: Colors.green
                                  ),
                                  controller: gstnoController,
                                ),
                              ),
                            ),
                          ),

                        //other details fields
                        if(selectedindex==2&&showfillwithgst==false)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            child:  Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    child: DropdownButton(
                                        icon: Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Icon(Icons.arrow_drop_down,color: Colors.white,),
                                        ),
                                        dropdownColor: Colors.white,
                                        hint: Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: Text('Balance Type',style: GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                        ),
                                        value: balancetype,
                                        items: [
                                          DropdownMenuItem(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              child: Text('Balance Type',style:  GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                            ),
                                            value: 'start',
                                          ),
                                          DropdownMenuItem(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              child: Text("Debit (Receivable)",style:  GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                            ),
                                            value:"Debit (Receivable)",
                                          ),
                                          DropdownMenuItem(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              child: Text("Credit (Payable)",style:  GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                            ),
                                            value: "Credit (Payable)",
                                          ),
                                        ],
                                        onChanged: (value) {
                                          FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                          FocusScopeNode currentFocus = FocusScope.of(context);

                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                          setState(() {
                                            balancetype = value.toString();
                                          });
                                        }),
                                  ),
                                ),

                              ),
                            ),
                          ),
                        if(selectedindex==2&&showfillwithgst==false)
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
                                          isDense: true,labelText: "Opening Balannce",
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
                                  controller: openbalController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==2&&showfillwithgst==false)
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
                                          isDense: true,labelText: labelpan.toString(),
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
                                  controller: panController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==2&&showfillwithgst==false)
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
                                          isDense: true,labelText: labeltan.toString(),
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
                                  controller: tanController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==2&&showfillwithgst==false)
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
                                          isDense: true,labelText: labelcin.toString(),
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
                                  controller: cinController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==2&&showfillwithgst==false&&widget.fromscreen=="Customer")
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
                                          isDense: true,labelText: "Distance (In Km)",
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
                                  controller: distanceController,
                                ),
                              ),
                            ),
                          ),

                        Container(height: 200,
                          width: MediaQuery.of(context).size.width,)

                      ],
                    ),
                    if(showfillwithgst==false)
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
                                if(nameController.text.isEmpty){
                                  showPrintedMessage(context, "Alert", "Please fill all required fields to submit", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                }else{
                                  update();
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
