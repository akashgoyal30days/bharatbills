import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/screen_models/category.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../main.dart';
import '../../toast_messeger.dart';
import '../payment.dart';
import '../reciept.dart';

class AddPayment extends StatefulWidget {
  @override
  _AddPaymentState createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  List<String> custlist = [];
  List<String> custlistid = [];
  String selectedcomp = "";

  List<String> banklist = [];
  List<String> banklistid = [];
  String selectedbank = "";


  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  DateTime selectedDate = DateTime.now();
  String finalselected = '';

  dynamic billNoController = TextEditingController();
  dynamic amountController = TextEditingController();
  dynamic narrationController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        finalselected = formatter.format(selectedDate);
      });
  }


  @override
  void initState(){
    super.initState;
    getSupplier();
    getBillNumber();
    getBank();
  }


  //required controllers
  dynamic categorynameController = TextEditingController();
  dynamic catdescriptionController = TextEditingController();
  String? parentcat;

  bool showloader = false;

  void getBillNumber() async{
    setState(() {
      finalselected = formatter.format(DateTime.now()).toString();
    });
    try{
      var rsp = await apiurl("/member/process", "bill_nums.php", {
        "type": "supreceipt",
        'date':formatter.format(DateTime.now()).toString(),
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            billNoController.text = rsp['no'].toString();
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

  void getBank() async{
    setState((){
      selectedbank = "";
      banklist.clear();
      banklistid.clear();
    });
    try{
      var rsp = await apiurl("/member/process", "bank.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            //debugPrint('bank - '+rsp['data'].toString());
            for(var i=0; i<rsp['data'].length; i++) {
              banklist.add(rsp['data'][i]['acc_name'].toString());
            banklistid.add(rsp['data'][i]['bid'].toString());
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
      }
    }catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  void getSupplier() async{
    setState((){
      selectedcomp = "";
      custlist.clear();
      custlistid.clear();
    });
    try{
      var rsp = await apiurl("/member/process", "supplier.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            //debugPrint(rsp['data'].length.toString());
            for(var i=0; i<rsp['data'].length; i++) {
              custlist.add(rsp['data'][i]['name'].toString());
              custlistid.add(rsp['data'][i]['cid'].toString());
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
      }
    }catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  void add () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "sreceipt.php", {
        'type': 'add',
        'sid': selectedcomp.toString(),
        'date':finalselected.toString(),
        'amount': amountController.text.toString(),
        'remarks':narrationController.text.toString(),
        'bank': selectedbank.toString()
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Added Successfully", Colors.white,Colors.green, Icons.info, true, "top");
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
                    child: PaymentScreen()));
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
          showPrintedMessage(context, "Failed", "Category already exist", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
        }
      }
      else{
        //debugPrint('error adding payment');
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
                child: PaymentScreen()));
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 40,
            elevation: 0,
            title: Text('Add Payment', style: GoogleFonts.poppins(fontSize: 16),),
            backgroundColor: AppBarColor,
          ),
          backgroundColor: Colors.white,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child:  showloader==false?Stack(
              children: [
                ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child:  Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          border: Border.all(color: Colors.transparent, width: 0.0),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0)),),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: DropdownSearch<String>(
                            mode: Mode.MENU,
                            showSearchBox: true,
                            showSelectedItems: true,
                            showClearButton: true,
                            items: custlist,
                            label: "Select Supplier *",
                            hint: "",
                            selectedItem: null,

                            onChanged: (s){
                              int index = custlist.indexOf(s.toString());
                              setState(() {
                                selectedcomp = custlistid[index].toString();
                                //debugPrint(selectedcomp.toString());
                              });
                            },),
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
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.transparent), //Background Color
                              elevation: MaterialStateProperty.all(0), //Defines Elevation
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5.0),
                                          topLeft: Radius.circular(5.0),
                                          bottomLeft: Radius.circular(5.0),
                                          bottomRight: Radius.circular(5.0)),
                                      side: BorderSide(color: Colors.grey)
                                  )
                              ),
                              shadowColor: MaterialStateProperty.all(Colors.transparent), //Defines shadowColor
                            ),
                            onPressed: (){
                              setState(() {
                              });
                              _selectDate(context);
                            },
                            child: Row(
                              children: [
                                finalselected==''?Text('Select Date *',style: GoogleFonts.poppins(fontSize: 14, color: AppBarColor),):
                                Text(finalselected.toString(),style: GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                              ],
                            ),
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
                              topRight: Radius.circular(5.0),
                              topLeft: Radius.circular(5.0),
                              bottomLeft: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0)),),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: TextFormField(
                            readOnly:true,
                            decoration: new InputDecoration(
                              isDense: true,labelText: "Bill No. *",
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 14, color: AppBarColor
                              ),
                              fillColor: Colors.white.withOpacity(0.5),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              //fillColor: Colors.green
                            ),
                            controller: billNoController,
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
                              topRight: Radius.circular(5.0),
                              topLeft: Radius.circular(5.0),
                              bottomLeft: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0)),),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: TextFormField(
                            keyboardType: TextInputType.numberWithOptions(decimal: true,),
                            decoration: new InputDecoration(
                              isDense: true,labelText: "Paid Amount *",
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 14, color: AppBarColor
                              ),
                              fillColor: Colors.white.withOpacity(0.5),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              //fillColor: Colors.green
                            ),
                            controller: amountController,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child:  Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          border: Border.all(color: Colors.transparent, width: 0.0),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0)),),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: DropdownSearch<String>(
                            mode: Mode.MENU,
                            showSearchBox: true,
                            showSelectedItems: true,
                            showClearButton: true,
                            items: banklist,
                            label: "Select Bank *",
                            hint: "",
                            selectedItem: null,

                            onChanged: (s){
                              int index = banklist.indexOf(s.toString());
                              setState(() {
                                selectedbank = banklistid[index].toString();
                                //debugPrint(selectedbank.toString());
                              });
                            },),
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
                              topRight: Radius.circular(5.0),
                              topLeft: Radius.circular(5.0),
                              bottomLeft: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0)),),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: TextFormField(
                            decoration: new InputDecoration(
                              isDense: true,labelText: "Narration",
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 14, color: AppBarColor
                              ),
                              fillColor: Colors.white.withOpacity(0.5),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              //fillColor: Colors.green
                            ),
                            controller: narrationController,
                          ),
                        ),
                      ),
                    ),
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
                          if(selectedcomp==''||finalselected==''||billNoController.text.isEmpty||amountController.text.isEmpty||selectedbank==''){
                            showPrintedMessage(context, "Alert", "Please fill category name fields to submit", Colors.white,Colors.redAccent, Icons.info, true, "top");
                          }else{
                            add();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Submit', style: GoogleFonts.poppins(
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
            ),
          )),
    );
  }
}
