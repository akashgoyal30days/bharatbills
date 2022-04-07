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

class Add_Cash_Bank_Book extends StatefulWidget {
  @override
  _Add_Cash_Bank_BookState createState() => _Add_Cash_Bank_BookState();
}

enum UomRate { uom1rate, uom2rate,}
class _Add_Cash_Bank_BookState extends State<Add_Cash_Bank_Book> {
  bool showfillwithgst = false;

  //required controllers
  dynamic bankNameController = TextEditingController();
  dynamic accnoController = TextEditingController();
  dynamic accHolderController = TextEditingController();

  dynamic openamountController = TextEditingController();
  String type = "Current Account";

  int selectedindex = 0;
  bool showloader = false;

  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  DateTime selectedDate = DateTime.now();
  String finalselected = '';

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

  //add product api
  void add () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "bank.php", {
        'type':'add',
        'acc_name':bankNameController.text.toString(),
        'acc_num':accnoController.text.toString(),
        'balance':openamountController.text.toString(),
        'sdate':finalselected.toString(),
        'acc_type':type.toString(),
        'bank_name':accHolderController.text.toString(),

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
                    child: CashBankBookScreen()));
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
                  child: CashBankBookScreen()));
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 40,
              elevation: 0,
              title: Text('Add Cash / Bank Book', style: GoogleFonts.poppins(fontSize: 16),),
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
                                  isDense: true,labelText: "Bank Name *",
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
                                controller: bankNameController,
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
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
                                decoration: new InputDecoration(
                                  isDense: true,labelText: "Acc No *",
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
                                controller: accnoController,
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
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.transparent), //Background Color
                                  elevation: MaterialStateProperty.all(0), //Defines Elevation
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10.0),
                                        topLeft: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0)),
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
                                    finalselected==''?Text('Start Date *',style: GoogleFonts.poppins(fontSize: 14, color: AppBarColor),):
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
                                  topRight: Radius.circular(10.0),
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0)),),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true,),
                                decoration: new InputDecoration(
                                  isDense: true,labelText: "Opening Balance *",
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
                                controller: openamountController,
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
                                  isDense: true,labelText: "Account Holder",
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
                                controller: accHolderController,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child:  Container(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 50,
                                  width:  MediaQuery.of(context).size.width-40,
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
                                    padding: const EdgeInsets.fromLTRB(10, 0, 2, 0),
                                    child: DropdownButtonHideUnderline(
                                      child: ButtonTheme(
                                        child: DropdownButton(
                                            icon: Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                              child: Icon(Icons.arrow_drop_down,color: Colors.black,),
                                            ),
                                            dropdownColor: Colors.white,
                                            hint: Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              child: Text('Select Account Type',style: GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                            ),
                                            value: type,
                                            items: [
                                              DropdownMenuItem(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  child: Text("Current Account",style:  GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                                ),
                                                value:"Current Account",
                                              ),
                                              DropdownMenuItem(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  child: Text("Saving Account",style:  GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                                ),
                                                value: "Saving Account",
                                              ),
                                              DropdownMenuItem(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  child: Text("CC Account",style:  GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                                ),
                                                value: "CC Account",
                                              ),
                                              DropdownMenuItem(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  child: Text("Other Account",style:  GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                                ),
                                                value: "Other Account",
                                              ),
                                            ],
                                            onChanged: (value) {
                                              FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                              FocusScopeNode currentFocus = FocusScope.of(context);

                                              if (!currentFocus.hasPrimaryFocus) {
                                                currentFocus.unfocus();
                                              }
                                              setState(() {
                                                type = value.toString();
                                              });
                                            }),
                                      ),
                                    ),

                                  ),
                                )
                              ],
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
                                if(bankNameController.text.isEmpty||accnoController.text.isEmpty||finalselected==''||type==null||openamountController.text.isEmpty){
                                  showPrintedMessage(context, "Alert", "Please fill all required fields to update", Colors.white,Colors.redAccent, Icons.info, true, "top");
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
                ))
        )
    );
  }
}
