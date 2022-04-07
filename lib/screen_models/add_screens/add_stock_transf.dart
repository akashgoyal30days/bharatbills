import 'dart:async';
import 'dart:convert';

import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/api_models/webview_api.dart';
import 'package:bbills/app_constants/api_constants.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import '../../shared preference singleton.dart';
import 'package:bbills/app_constants/reports/reports_screen.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../../main.dart';
import '../../toast_messeger.dart';
import '../dashboard.dart';
import '../list_purchase_return.dart';
import '../list_sale_return.dart';
import '../stock_transfer.dart';

class AddStockTransf extends StatefulWidget {

  @override
  _AddStockTransfState createState() => _AddStockTransfState();
}

class _AddStockTransfState extends State<AddStockTransf> {
  String? selectedfromdate;
  String? selectedtodate;


  Color currstock = Colors.grey.withOpacity(0.3);
  Color curstocktextcolor = Colors.black;
  String currstockval = '';





  List<String> custlist = [];
  List<String> custlistid = [];
  String selectedbillid = "";

  String billnumber = '';
  String billdate = '';
  String selecteddate = '';


  dynamic remarks_Controller = TextEditingController();
  dynamic popup_remarks_Controller = TextEditingController();

  dynamic quant1Controller = TextEditingController();
  dynamic quant2Controller = TextEditingController();

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null )
      setState(() {
        selecteddate = formatter.format(selected);
      });
  }





  bool showloader = true;

  //get bill num
  void getBillnum () async{
    setState((){
      showloader=true;
    });

    try{
      var rsp = await apiurl("/member/process", "bill_nums.php", {
        "type": "stransfer",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            billnumber = rsp['no'].toString();
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
  List<String> warelist1 = [];
  List<String> warelist2 = [];
  List<String> warelistid1 = [];
  List<String> warelistid2 = [];
  List<String> uom1 = [];
  List<String> uom2 = [];
  String? selected_ware1;
  String? selected_ware2;
  String selected_ware1id = '';
  String selected_ware2id = '';
  void getWarehouse () async{
    setState(() {
      warelist1.clear();
      warelist2.clear();
      warelistid1.clear();
      warelistid2.clear();
      selected_ware1 = null;
      selected_ware2 = null;
    });
    try{
      var rsp = await apiurl("/member/process", "warehouse.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            for(var i = 0; i<rsp['data'].length; i++){
              warelist1.add(rsp['data'][i]['name'].toString());
              warelist2.add(rsp['data'][i]['name'].toString());
              warelistid1.add(rsp['data'][i]['wid'].toString());
              warelistid2.add(rsp['data'][i]['wid'].toString());
            }
            if(warelist1.isNotEmpty){
              selected_ware1 = warelist1[0].toString();
              selected_ware1id = warelistid1[0].toString();
            }
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




  AddRemrks(String remarks) {
    setState(() {
      popup_remarks_Controller.clear();
      popup_remarks_Controller.text = remarks.toString();
    });

    // set up the button
    Widget okButton = TextButton(
      child: Text("Done"),
      onPressed: () {
        setState((){
          remarks_Controller.text = popup_remarks_Controller.text.toString();
        });

        Navigator.pop(context);


      },
    );
    Widget CancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {

        Navigator.pop(context);


      },
    );
    Widget ClearButton = TextButton(
      child: Text("Clear Remark"),
      onPressed: () {
        setState((){
          popup_remarks_Controller.clear();
          remarks_Controller.clear();
        });

        Navigator.pop(context);


      },
    );


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Any Remarks ?'),
      content: Container(
          height: 120,
          child: Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 2, top: 10, right:20),
                child: Container(
                  height: 50,
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
                      readOnly:false,

                      onChanged: (v){

                      },
                      decoration: new InputDecoration(
                        isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: "Enter remarks here",
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
        ClearButton
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


  void save_Bill() async{
    setState((){
      showloader = true;
    });
    String token = "";
    var userdetails = SharedPreferenceSingleton.sharedPreferences;
    if(userdetails.getString("utoken")!=null){
      token = userdetails.getString("utoken").toString();
    }
    try{
      FormData formData = new FormData();
      formData = FormData.fromMap({
        "_req_from": reqfrom,
        "api_key": apikey,
        "_req_token": token,
        "type":"add_transfer",
        "form_no":billnumber.toString(),
        "stores_in":selected_ware2id.toString(),
        "stores_out":selected_ware1id.toString(),
        "date":selecteddate.toString(),
        "product1": selected_prod_id,
        "new_uom1": selected_prod_quant1,
        "new_uom2": selected_prod_quant2,
        "description": remarks_Controller.text.toString(),
      });
      //debugPrint(formData.fields.toString());
      var rsp = await gbill("/member/process", "sjournal.php", formData);
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Added Successfully", Colors.white,Colors.green, Icons.info, true, "top");
          Navigator.of(context)
              .popUntil((route) =>
          route.isFirst);
          Navigator
              .pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType
                      .fade,
                  child: StockTransferScreen()));
        }else if(rsp['status'].toString()=="false"){  setState(() {
          showloader=false;
          showPrintedMessage(context, "Error", rsp['error'].toString(), Colors.white,Colors.red, Icons.info, true, "top");
        });
        if(rsp['error'].toString()=="invalid_auth"){
          Navigator.of(context).popUntil((route) => route.isFirst);
          showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
        }

        }
        else if(rsp['status'].toString()=="already_exist"){
          showPrintedMessage(context, "Failed", "Failed to add", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
        }
      }
    }catch(error, stacktrace){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.red, Icons.info, true, "bottom");
      //debugPrint('Stacktrace: ' + stacktrace.toString());
      //debugPrint(error.toString());
    }
  }

  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  List config_name = [];
  List config_val = [];

  @override
  void initState(){
    super.initState();
    setscreenposition();
  }


  void setscreenposition() async{
    setState(() {
      selecteddate = formatter.format(DateTime.now());
    });
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "stocktransf");
    //debugPrint(screen.getString("currentscreen").toString());
    getWarehouse();
    get_status();
  }
  bool isnegative_stock_allowed = true;


  void get_status() async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "dashboard.php", {
        "type": "billsettings",
      });
      //debugPrint('status of user - '+rsp.toString());

      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });

        if(rsp['status'].toString()=="true"){
          setState(() {
            config_name.clear();
            config_val.clear();



            for(var i=0; i<rsp['config'].length; i++){
              config_name.add(rsp['config'][i]['fieldoption'].toString());
              config_val.add(rsp['config'][i]['value'].toString());
            }

            //debugPrint(config_name.toString());
            if(config_name.isNotEmpty){
              var a = config_name.indexOf('NSTOCK');
              //debugPrint(a.toString());
              if(config_val[a].toString()=='1'){
                isnegative_stock_allowed = true;
              }else{
                isnegative_stock_allowed = false;
              }
            }else{
              isnegative_stock_allowed = true;
            }
          });
          getBillnum();
          get_product();
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
      }
    }catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  List<String> pro_name1 = [];
  List<String> prod_id1 = [];
  List<String> prod_stock = [];
  List<String> pro_name2 = [];
  List<String> prod_id2 = [];

  String selectedprodidd = '';
  String selecteduom1 = '';
  String selecteduom2 = '';
  String? selectedprodname;
  String inddex = '';
  List<String> selected_pro_name = [];
  List<String> selected_index = [];
  List<String> selected_prod_id = [];
  List<String> selected_uom_1 = [];
  List<String> selected_uom_2 = [];
  List<String> selected_prod_stock = [];
  List<String> selected_prod_quant1 = [];
  List<String> selected_prod_quant2 = [];


  void get_product() async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "product.php", {
        "type": "view_all",
      });
      //debugPrint('product list - '+rsp.toString());

      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });

        if(rsp['status'].toString()=="true"){
          setState(() {
            pro_name1.clear();
            prod_id1.clear();
            pro_name2.clear();
            prod_id2.clear();
            for(var i=0; i<rsp['data'].length; i++){
              if(rsp['data'][i]['pr_type'].toString()=='Stockable') {
                if (isnegative_stock_allowed == true) {
                  pro_name1.add(rsp['data'][i]['name'].toString());
                  prod_stock.add(rsp['data'][i]['cur_bal'].toString());
                  prod_id1.add(rsp['data'][i]['iid'].toString());
                  pro_name2.add(rsp['data'][i]['name'].toString());
                  prod_id2.add(rsp['data'][i]['iid'].toString());
                  uom1.add(rsp['data'][i]['uom1'].toString());
                  uom2.add(rsp['data'][i]['uom2'].toString());
                }else {
                  if (rsp['data'][i]['cur_bal'].toString() != 'N/A') {
                    if (double.parse(rsp['data'][i]['cur_bal'].toString()) <= 0) {

                    } else {
                      pro_name1.add(rsp['data'][i]['name'].toString());
                      prod_stock.add(rsp['data'][i]['cur_bal'].toString());
                      prod_id1.add(rsp['data'][i]['iid'].toString());
                      pro_name2.add(rsp['data'][i]['name'].toString());
                      prod_id2.add(rsp['data'][i]['iid'].toString());
                      uom1.add(rsp['data'][i]['uom1'].toString());
                      uom2.add(rsp['data'][i]['uom2'].toString());
                    }
                  }
                }
              }
           }
          });

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
                  child: StockTransferScreen()));

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
                  ConstAppBar(),
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
                              Text('Stock Transfer', style: GoogleFonts.poppins(
                                  fontSize: 15, color: Colors.white
                              ),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      height: selected_prod_id.isEmpty?MediaQuery.of(context).size.height-140:MediaQuery.of(context).size.height-240,
                      width:MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: showloader==true?Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.7,

                        ),
                      ):Container(
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0, right: 0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width-MediaQuery.of(context).size.width/2,
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.transparent,),
                                              color: Colors.grey.withOpacity(0.3)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(billnumber.toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap:(){
                                            _selectDate(context);
                                          },
                                          child: Container(
                                            width:MediaQuery.of(context).size.width/2,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(color: Colors.grey.withOpacity(0.3),)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: selecteddate==''||selecteddate==null?Text('Date *', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),):Text(selecteddate.toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 40,
                                          width:MediaQuery.of(context).size.width-MediaQuery.of(context).size.width/2,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(color: Colors.grey.withOpacity(0.3),)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                hint : Text('From Location *'),
                                                value: selected_ware1,
                                                isDense: true,
                                                items:warelist1.map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: null
                                              ),
                                            ),
                                             ),
                                        ),
                                        Container(
                                          height: 40,
                                          width:MediaQuery.of(context).size.width-MediaQuery.of(context).size.width/2,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(color: Colors.grey.withOpacity(0.3),)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                hint : Text('To Location *'),
                                                value: selected_ware2,
                                                isDense: true,
                                                items:warelist2.map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (s){
                                                  FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                                  FocusScopeNode currentFocus = FocusScope.of(context);

                                                  if (!currentFocus.hasPrimaryFocus) {
                                                    currentFocus.unfocus();
                                                  }
                                                  int index = warelist2.indexOf(s.toString());
                                                  setState(() {
                                                    selected_ware2 = s.toString();
                                                    selected_ware2id = warelistid2[index].toString();
                                                    //debugPrint(selected_ware2id.toString());
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 135,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0, right: 0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height:45,
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.transparent,),
                                              color: Colors.white
                                          ),
                                          child: DropdownSearch<String>(
                                            dropdownSearchDecoration: InputDecoration(
                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                              isDense: true,labelText: "Select Product *",
                                              labelStyle: GoogleFonts.poppins(
                                                  fontSize: 14, color: AppBarColor
                                              ),
                                              fillColor: Colors.white.withOpacity(0.5),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(0.0),
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 0.0,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(0.0),
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 0.0,
                                                ),
                                              ),
                                              //fillColor: Colors.green
                                            ),
                                            mode: Mode.MENU,
                                            showSearchBox: true,
                                            showSelectedItems: true,
                                            showClearButton: false,
                                            items: pro_name2,
                                            hint: "Select Product *",
                                            selectedItem:selectedprodname,

                                            onChanged: (s){
                                              int index = pro_name2.indexOf(s.toString());
                                              setState(() {
                                                inddex = index.toString();
                                                selectedprodname = s.toString();
                                                currstockval = prod_stock[index].toString();
                                                selectedprodidd = prod_id2[index].toString();
                                                selecteduom1 = uom1[index].toString();
                                                selecteduom2 = uom2[index].toString();
                                                currstock = Colors.grey.withOpacity(0.3);
                                                curstocktextcolor = Colors.black;
                                                quant1Controller.clear();
                                                quant2Controller.clear();
                                              //debugPrint(selectedprodidd.toString());
                                              });
                                            },),
                                        ),

                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height:45,
                                          width:MediaQuery.of(context).size.width/2,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(color: Colors.grey.withOpacity(0.3))
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.all(0.0),
                                              child:Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                  child: TextFormField(
                                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                      MyNumberTextInputFormatter(digit: 2),
                                                    ],

                                                    onChanged: (v){
                                                      if(currstockval!=''){
                                                      setState((){
                                                        if (isnegative_stock_allowed != true) {
                                                          if(double.parse(v.toString())>double.parse(currstockval.toString())){
                                                            showPrintedMessage(context, "Error", "Negative stock is not allowed", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                                            quant1Controller.clear();
                                                            currstock = Colors.red;
                                                            curstocktextcolor = Colors.white;
                                                            Future.delayed(const Duration(milliseconds: 100), () {
                                                              setState(() {
                                                                currstock = Colors.grey.withOpacity(0.3);
                                                                curstocktextcolor = Colors.black;
                                                              });
                                                              Future.delayed(const Duration(milliseconds: 100), () {
                                                                setState(() {
                                                                  currstock = Colors.red;
                                                                  curstocktextcolor = Colors.white;
                                                                });
                                                                Future.delayed(const Duration(milliseconds: 100), () {
                                                                  setState(() {
                                                                    currstock = Colors.grey.withOpacity(0.3);
                                                                    curstocktextcolor = Colors.black;
                                                                  });
                                                                  Future.delayed(const Duration(milliseconds: 100), () {
                                                                    setState(() {
                                                                      currstock = Colors.red;
                                                                      curstocktextcolor = Colors.white;
                                                                    });

                                                                  });
                                                                });
                                                              });
                                                            });



                                                          }else{
                                                            currstock = Colors.grey.withOpacity(0.3);
                                                            curstocktextcolor = Colors.black;
                                                          }
                                                        }
                                                      });
                                                     }else{
                                                        showPrintedMessage(context, "Error", "Please select a product first", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                                        quant1Controller.clear();
                                                      }
                                                      },
                                                    decoration: new InputDecoration(
                                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                                      isDense: true,labelText: selecteduom1!=''?"Quant (UOM) *"+" "+'['+selecteduom1.toString()+']':"Quant (UOM) *",
                                                      labelStyle: GoogleFonts.poppins(
                                                          fontSize: 14, color: AppBarColor
                                                      ),
                                                      fillColor: Colors.white.withOpacity(0.5),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                        borderSide: BorderSide(
                                                          color: Colors.transparent,
                                                          width: 0.0,
                                                        ),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                        borderSide: BorderSide(
                                                          color: Colors.transparent,
                                                          width: 0.0,
                                                        ),
                                                      ),
                                                      //fillColor: Colors.green
                                                    ),
                                                    controller: quant1Controller,
                                                  ),
                                                ),
                                              )
                                          ),
                                        ),
                                        Container(
                                          height:45,
                                          width:MediaQuery.of(context).size.width/2,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(color: Colors.grey.withOpacity(0.3))
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.all(0.0),
                                              child:Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                  child: TextFormField(
                                                    onChanged: (v){
                                                      if(currstockval!=''){
                                                        setState((){
                                                          if (isnegative_stock_allowed != true) {
                                                            if(double.parse(v.toString())>double.parse(currstockval.toString())){
                                                              showPrintedMessage(context, "Error", "Negative stock is not allowed", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                                              quant2Controller.clear();
                                                              currstock = Colors.red;
                                                              curstocktextcolor = Colors.white;
                                                              Future.delayed(const Duration(milliseconds: 100), () {
                                                                setState(() {
                                                                  currstock = Colors.grey.withOpacity(0.3);
                                                                  curstocktextcolor = Colors.black;
                                                                });
                                                                Future.delayed(const Duration(milliseconds: 100), () {
                                                                  setState(() {
                                                                    currstock = Colors.red;
                                                                    curstocktextcolor = Colors.white;
                                                                  });
                                                                  Future.delayed(const Duration(milliseconds: 100), () {
                                                                    setState(() {
                                                                      currstock = Colors.grey.withOpacity(0.3);
                                                                      curstocktextcolor = Colors.black;
                                                                    });
                                                                    Future.delayed(const Duration(milliseconds: 100), () {
                                                                      setState(() {
                                                                        currstock = Colors.red;
                                                                        curstocktextcolor = Colors.white;
                                                                      });

                                                                    });
                                                                  });
                                                                });
                                                              });



                                                            }else{
                                                              currstock = Colors.grey.withOpacity(0.3);
                                                              curstocktextcolor = Colors.black;
                                                            }
                                                          }
                                                        });
                                                      }else{
                                                        showPrintedMessage(context, "Error", "Please select a product first", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                                        quant2Controller.clear();
                                                      }
                                                    },
                                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                      MyNumberTextInputFormatter(digit: 2),
                                                    ],
                                                    decoration: new InputDecoration(
                                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                                      isDense: true,labelText: selecteduom2!=''?"Quant (AUOM)"+" "+'['+selecteduom2.toString()+']':"Quant (AUOM)",
                                                      labelStyle: GoogleFonts.poppins(
                                                          fontSize: 14, color: AppBarColor
                                                      ),
                                                      fillColor: Colors.white.withOpacity(0.5),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                        borderSide: BorderSide(
                                                          color: Colors.transparent,
                                                          width: 0.0,
                                                        ),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                        borderSide: BorderSide(
                                                          color: Colors.transparent,
                                                          width: 0.0,
                                                        ),
                                                      ),
                                                      //fillColor: Colors.green
                                                    ),
                                                    controller: quant2Controller,
                                                  ),
                                                ),
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        AnimatedContainer(
                                          height: 45,
                                          duration: Duration(milliseconds: 500),
                                          width:MediaQuery.of(context).size.width/2,
                                          decoration: BoxDecoration(
                                              color: currstock,
                                              border: Border.all(color: currstock,)
                                          ),
                                          child: Center(child: currstockval==''?Text('Current Stock', style: TextStyle(color:curstocktextcolor, fontSize:17, fontWeight:FontWeight.w400),):Text(currstockval.toString(), style: TextStyle(color:curstocktextcolor, fontSize:17, fontWeight:FontWeight.w400),)),
                                        ),
                                        Container(
                                          height: 45,
                                          width:(MediaQuery.of(context).size.width-MediaQuery.of(context).size.width/2),
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              border: Border.all(color: Colors.green,)
                                          ),
                                          child: RaisedButton(
                                            onPressed: (){
                                              FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                              FocusScopeNode currentFocus = FocusScope.of(context);

                                              if (!currentFocus.hasPrimaryFocus) {
                                                currentFocus.unfocus();
                                              }
                                              setState(() {
                                                if(selectedprodidd!=''&&selectedprodidd!=null&&quant1Controller.text.isNotEmpty&&selected_ware1!=null&&selected_ware2!=null){
                                                  selected_pro_name.add(selectedprodname.toString());
                                                  selected_index.add(inddex.toString());
                                                  selected_prod_id.add(selectedprodidd.toString());
                                                  selected_prod_quant1.add(quant1Controller.text.toString());
                                                  if(quant2Controller.text.isNotEmpty){
                                                    selected_prod_quant2.add(quant2Controller.text.toString());
                                                  }else{
                                                    selected_prod_quant2.add(quant1Controller.text.toString());
                                                  }
                                                  selected_index.add(inddex.toString());
                                                  selected_uom_1.add(selecteduom1.toString());
                                                  selected_uom_2.add(selecteduom2.toString());
                                                  selected_prod_stock.add(currstockval.toString());
                                                  pro_name2.removeAt(int.parse(inddex));
                                                  prod_id2.removeAt(int.parse(inddex));
                                                  prod_stock.removeAt(int.parse(inddex));
                                                  uom1.removeAt(int.parse(inddex));
                                                  uom2.removeAt(int.parse(inddex));
                                                  selectedprodidd = '';
                                                  selecteduom1 = '';
                                                  selecteduom2 = '';
                                                  currstockval = '';
                                                  inddex = '';
                                                  selectedprodname = null;
                                                  quant2Controller.clear();
                                                  quant1Controller.clear();
                                                }else{
                                                  showPrintedMessage(context, "Error", "Please fill the required fields to add product", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                                }

                                              });
                                            },
                                            elevation: 0,
                                            color: Colors.green,
                                            child: Text('ADD', style: TextStyle(fontSize:18, color:Colors.white),),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: selected_prod_id.isNotEmpty?ListView.builder(
                                  itemCount: selected_prod_id.length,
                                  itemBuilder: (BuildContext context, indexz){
                                return Padding(
                                  padding: const EdgeInsets.only(left:10, right:10, bottom:2),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Container(
                                            width:MediaQuery.of(context).size.width,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width:MediaQuery.of(context).size.width-70,
                                                  child: Align(
                                                      alignment:Alignment.centerLeft,
                                                      child: Text(selected_pro_name[indexz].toString(), style:TextStyle(
                                                        fontSize:16, color:Colors.blue, fontWeight: FontWeight.w500
                                                      ))),
                                                ),
                                                Container(
                                                  width: 50,
                                                  child: RaisedButton(
                                                    elevation :0 ,
                                                    color: Colors.redAccent,
                                                    onPressed: (){
                                                      setState(() {
                                                        pro_name2.insert(int.parse(selected_index[indexz].toString()), selected_pro_name[indexz].toString());
                                                        prod_id2.insert(int.parse(selected_index[indexz].toString()), selected_prod_id[indexz].toString());
                                                        uom1.insert(int.parse(selected_index[indexz].toString()), selected_pro_name[indexz].toString());
                                                        uom2.insert(int.parse(selected_index[indexz].toString()), selected_prod_id[indexz].toString());
                                                      });


                                                      selected_pro_name.removeAt(indexz);
                                                      selected_prod_id.removeAt(indexz);
                                                      selected_index.removeAt(indexz);
                                                      selected_uom_1.removeAt(indexz);
                                                      selected_uom_2.removeAt(indexz);
                                                      selected_prod_stock.removeAt(indexz);
                                                      selected_prod_quant1.removeAt(indexz);
                                                      selected_prod_quant2.removeAt(indexz);
                                                    },
                                                    child:Center(child: Text('X', style:TextStyle(color:Colors.white)))
                                                  ),
                                                )
                                              ],
                                            )),
                                        Row(
                                          children: [
                                            Container(
                                              width:(MediaQuery.of(context).size.width-10)-MediaQuery.of(context).size.width/2,
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent,),
                                                  color: Colors.grey.withOpacity(0.3)
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 70,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(selected_uom_1[indexz].toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: ((MediaQuery.of(context).size.width-10)-MediaQuery.of(context).size.width/2)-74,
                                                    color:Colors.white,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(selected_prod_quant1[indexz].toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: (MediaQuery.of(context).size.width/2)-10,
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent,),
                                                  color: Colors.grey.withOpacity(0.3)
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 90,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(selected_uom_2[indexz].toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: ((MediaQuery.of(context).size.width-10)-MediaQuery.of(context).size.width/2)-92,
                                                    color:Colors.white,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(selected_prod_quant2[indexz].toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        if(indexz==selected_prod_id.length-1)
                                          Container(
                                            height: 200,
                                            width: MediaQuery.of(context).size.width,
                                            color: Colors.white,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }):Center(
                                child: Text('Please fill above fields to transfer stock', style: TextStyle(fontSize: 16, color:Colors.blue, fontWeight:FontWeight.w500),
                                textAlign: TextAlign.center,)
                              ),
                            ),
                          ],
                        ),
                      )
                  )
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: selected_prod_id.isEmpty?Container(
            height:0
        ):Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50,
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
                      readOnly:true,

                      onTap: (){
                        AddRemrks(remarks_Controller.text.toString());
                      },
                      decoration: new InputDecoration(
                        isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: "Any Remarks ?",
                        hintText: "Any Remarks ?",
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
                      controller: remarks_Controller,
                    ),
                  ),
                ),
                Container(
                  height:50,
                  width: 120,
                  child: RaisedButton(
                      color: AppBarColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onPressed:(){
                        if(selecteddate!=''&&selecteddate!=null){
                          FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          save_Bill();
                        }else{
                          showPrintedMessage(context, "Error", "Please fill the required fields", Colors.white,Colors.redAccent, Icons.info, true, "top");
                        }

                      },
                      child:Text('Done', style: TextStyle(fontSize:15, color:Colors.white),)
                  ),
                )

              ],
            ),
          ),

        ),

      ),
    );
  }
}
class MyNumberTextInputFormatter extends TextInputFormatter {
  static const defaultDouble = 0.001;

  /// Allowed decimal digits, -1 represents no limit
  int digit;
  MyNumberTextInputFormatter({this.digit = -1});
  static double strToFloat(String str, [double defaultValue = defaultDouble]) {
    try {
      return double.parse(str);
    } catch (e) {
      return defaultValue;
    }
  }

  /// Get the current count number
  static int getValueDigit(String value) {
    if (value.contains(".")) {
      return value.split(".")[1].length;
    } else {
      return -1;
    }
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    int selectionIndex = newValue.selection.end;
    if (value == ".") {
      value = "0.";
      selectionIndex++;
    } else if (value == "-") {
      value = "-";
      selectionIndex++;
    } else if (value != "" && value != defaultDouble.toString() && strToFloat(value, defaultDouble) == defaultDouble || getValueDigit(value) > digit) {
      value = oldValue.text;
      selectionIndex = oldValue.selection.end;
    }
    return new TextEditingValue(
      text: value,
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
