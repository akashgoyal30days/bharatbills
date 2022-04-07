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
import '../all_product.dart';
import '../all_suppliers.dart';


enum UomRate { uom1rate, uom2rate,}


class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  bool showfillwithgst = false;

  //required controllers
  dynamic itemController = TextEditingController();
  String? catname;
  List Catlist = [];
  List gstperlist = [];
  dynamic descriptionController = TextEditingController();
  dynamic itemCodeController = TextEditingController();
  String? gstpercent;
  dynamic hsnController = TextEditingController();

  //unit Controllers
  String? uom1;
  String? uom2;
  List uoms = [];
  dynamic unitConversionController = TextEditingController();
  UomRate _urate = UomRate.uom1rate;

  //rates controllers
  dynamic salerateController = TextEditingController();
  dynamic purchaserateController = TextEditingController();


  //level controllers
  dynamic minlevelController = TextEditingController();
  dynamic maxlevelController = TextEditingController();
  dynamic reorderlevelController = TextEditingController();

  //other controllers
  dynamic openquantityController = TextEditingController();
  dynamic openamountController = TextEditingController();
  String type = "Stockable";

  int selectedindex = 0;
  bool showloader = false;

  @override
  void initState(){
    getCat();
    getgstper();
    uomdrop();
    super.initState();
  }

  //get gst percentage
  void getgstper () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "common.php", {
        "type": "get_gst_per",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
           gstperlist = rsp['data'];
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

  //get type
  void getCat() async{
    setState(() {
      showloader=true;
    });
    try {
      var rsp = await apiurl("/member/process", "category.php", {
        "type": "view",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            Catlist = rsp['data'];
          });
        } else if (rsp['status'].toString() == "false") {
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(
                context,
                "Error",
                "Session expired",
                Colors.white,
                Colors.redAccent,
                Icons.info,
                true,
                "bottom");
            Navigator.pushReplacement(context, PageTransition(
                type: PageTransitionType.fade, child: MyHomePage()));
          }
        }
      }
    } catch (error) {
      showPrintedMessage(
          context,
          "Error",
          error.toString(),
          Colors.white,
          Colors.blueAccent,
          Icons.info,
          true,
          "bottom");
      //debugPrint(error.toString());
    }
  }

  //get uom
  void uomdrop () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "product.php", {
        "type": "units",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            uoms=rsp['data'];
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


  //add product api
  void add () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "product.php", {
        "type":"add",
        "cat_id": catname.toString(),
        "item_code": itemCodeController.text.toString(),
        'name': itemController.text.toString(),
        "item_desc": descriptionController.text.toString(),
        "uom1": uom1.toString(),
        "uom2": uom2.toString(),
        "conversion": unitConversionController.text.toString(),
        "rate": salerateController.text.toString(),
        "pur_rate": purchaserateController.text.toString(),
        "gst": gstpercent.toString(),
        "hsn_code": hsnController.text.toString(),
        "pr_type": type.toString(),
        "min_level":minlevelController.text.toString(),
        "max_level":maxlevelController.text.toString(),
        "re_level":reorderlevelController.text.toString(),
        if(_urate==UomRate.uom1rate)
        "rate_on": "uom1"
        else
          "rate_on": "uom2",
        "open_quant": openquantityController.text.toString(),
        "open_amt": openamountController.text.toString(),

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
                      child: ProductScreen()));
          }
          );

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showPrintedMessage(context, "Failed", rsp['error'].toString(), Colors.white,Colors.redAccent, Icons.info, true, "top");
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
            Navigator.of(context)
                .popUntil((route) =>
            route.isFirst);
            Navigator
                .pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType
                        .fade,
                    child: ProductScreen()));
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 40,
              elevation: 0,
              title: Text('Add Product', style: GoogleFonts.poppins(fontSize: 16),),
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
                                    value: catname,
                                    //elevation: 5,
                                    style: TextStyle(color: AppBarColor),
                                    iconEnabledColor:AppBarColor,
                                    items: Catlist?.map((item) {
                                      return new DropdownMenuItem(
                                        child: new Text(item['name'],style: TextStyle(fontSize: 18, color: AppBarColor),),
                                        value: item['cat_id'].toString(),
                                      );
                                    })?.toList() ??
                                        [],
                                    hint:Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        "Select Category Name *",
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
                                        catname = value.toString();
                                      });
                                    },
                                  ),
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
                                  decoration: new InputDecoration(
                                          isDense: true,labelText: "Item Name *",
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
                                  controller: itemController,
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
                                          isDense: true,labelText: "Description",
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
                                  controller: descriptionController,
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
                                    value: gstpercent,
                                    //elevation: 5,
                                    style: TextStyle(color: AppBarColor),
                                    iconEnabledColor:AppBarColor,
                                    items: gstperlist?.map((item) {
                                      return new DropdownMenuItem(
                                        child: new Text(item['gst']+" "+ "%",style: TextStyle(fontSize: 18, color: AppBarColor),),
                                        value: item['gst'].toString(),
                                      );
                                    })?.toList() ??
                                        [],
                                    hint:Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        "GST %",
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
                                        gstpercent = value.toString();
                                      });
                                    },
                                  ),
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
                                  decoration: new InputDecoration(
                                          isDense: true,labelText: "HSN Code",
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
                                  controller: hsnController,
                                ),
                              ),
                            ),
                          ),

                        //list menu
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
                                    itemCount: 4,
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
                                            child: index==0?Text('Unit', style: GoogleFonts.poppins(
                                                fontSize: 14, color: selectedindex==index?Colors.white:Colors.black
                                            ),):index==1?Text('Rates ', style: GoogleFonts.poppins(
                                                fontSize: 14, color: selectedindex==index?Colors.white:Colors.black
                                            ),):index==3?Text('Other Details', style: GoogleFonts.poppins(
                                                fontSize: 14, color: selectedindex==index?Colors.white:Colors.black
                                            ),):Text('Levels', style: GoogleFonts.poppins(
                                                fontSize: 14, color: selectedindex==index?Colors.white:Colors.black
                                            ),)
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ),

                        //unit fields
                        if(selectedindex==0)
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
                                      value: uom1,
                                      //elevation: 5,
                                      style: TextStyle(color: AppBarColor),
                                      iconEnabledColor:AppBarColor,
                                      items: uoms?.map((item) {
                                        return new DropdownMenuItem(
                                          child: new Text(item['name'],style: TextStyle(fontSize: 18, color: AppBarColor),),
                                          value: item['code'].toString(),
                                        );
                                      })?.toList() ??
                                          [],
                                      hint:Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "Unit Of Measurement",
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
                                          uom1 = value.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==0)
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
                                      value: uom2,
                                      //elevation: 5,
                                      style: TextStyle(color: AppBarColor),
                                      iconEnabledColor:AppBarColor,
                                      items: uoms?.map((item) {
                                        return new DropdownMenuItem(
                                          child: new Text(item['name'],style: TextStyle(fontSize: 18, color: AppBarColor),),
                                          value: item['code'].toString(),
                                        );
                                      })?.toList() ??
                                          [],
                                      hint:Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "Alternate Unit Of Measurement",
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
                                          uom2 = value.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==0)
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
                                          isDense: true,labelText: "Unit Conversion",
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
                                  controller: unitConversionController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==0)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 20, 8),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width/3,
                                    child: Row(
                                      children: [
                                        Radio(
                                          value: UomRate.uom1rate,
                                          groupValue: _urate,
                                          onChanged: (UomRate? value) {
                                            setState(() {
                                              _urate = value!;
                                            });
                                          },
                                        ),
                                        Text('Rate on UOM 1'),

                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width/3,
                                    child: Row(
                                      children: [
                                        Radio(
                                          value: UomRate.uom2rate,
                                          groupValue: _urate,
                                          onChanged: (UomRate? value) {
                                            setState(() {
                                              _urate = value!;
                                            });
                                          },
                                        ),
                                        Text('Rate on UOM 2'),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        //rates fields
                        if(selectedindex==1)
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
                                          isDense: true,labelText: "Sales Rate",
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
                                  controller: salerateController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==1)
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
                                          isDense: true,labelText: "Purchase Rate",
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
                                  controller: purchaserateController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==1)
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
                                          isDense: true,labelText: "Item Code",
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
                                  controller: itemCodeController,
                                ),
                              ),
                            ),
                          ),

                        //level fields
                        if(selectedindex==2)
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
                                          isDense: true,labelText: "Minimum Level",
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
                                  controller: minlevelController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==2)
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
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: new InputDecoration(
                                          isDense: true,labelText: "Maximum Level",
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
                                  controller: maxlevelController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==2)
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
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: new InputDecoration(
                                          isDense: true,labelText: "Reorder Level",
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
                                  controller: reorderlevelController,
                                ),
                              ),
                            ),
                          ),

                        //other fields
                        if(selectedindex==3)
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
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: new InputDecoration(
                                          isDense: true,labelText: "Opening Quantity",
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
                                  controller: openquantityController,
                                ),
                              ),
                            ),
                          ),
                        if(selectedindex==3)
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
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: new InputDecoration(
                                          isDense: true,labelText: "Opening Amount",
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
                        if(selectedindex==3)
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
                                              child: Text('Type',style: GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                            ),
                                            value: type,
                                            items: [
                                              DropdownMenuItem(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  child: Text("Stockable",style:  GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                                ),
                                                value:"Stockable",
                                              ),
                                              DropdownMenuItem(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  child: Text("Service",style:  GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                                ),
                                                value: "Service",
                                              ),
                                              DropdownMenuItem(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  child: Text("Non stockable",style:  GoogleFonts.poppins(fontSize: 14, color: AppBarColor),),
                                                ),
                                                value: "Non stockable",
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
                                if(itemController.text.isEmpty||catname==null||gstpercent==null){
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
