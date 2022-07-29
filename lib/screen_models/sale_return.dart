import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/api_constants.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import '../shared preference singleton.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../main.dart';
import '../../toast_messeger.dart';
import 'list_sale_return.dart';

class SaleReturn extends StatefulWidget {
  @override
  _SaleReturnState createState() => _SaleReturnState();
}

class _SaleReturnState extends State<SaleReturn> {
  String? selectedfromdate;
  String? selectedtodate;
  bool gotresp = false;

  List allproid = [];
  List allnewquant = [];
  List uom2 = [];
  List uom1 = [];
  List discount = [];
  List p_rate = [];
  List description = [];
  List gst_val = [];
  List orig_quant = [];
  List rate_on = [];

  List<String> custlist = ['ALL'];
  List<String> custlistid = [];
  String selectedbillid = "";

  String billnumber = '';
  String billdate = '';
  String customername = '';
  String selecteddate = '';
  String billto = '';

  dynamic remarks_Controller = TextEditingController();
  dynamic popup_remarks_Controller = TextEditingController();

  dynamic cnotenumberController = TextEditingController();
  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null)
      setState(() {
        selecteddate = formatter.format(selected);
      });
  }

  List bodydata = [];
  int headerlength = 0;
  List title = [];

  bool showloader = true;
  var htmldata;
  //get customer/supplier/warehouse
  void getBillList() async {
    setState(() {
      selectedbillid = "";
      custlist.clear();
      custlistid.clear();
    });

    try {
      var rsp = await apiurl("/member/process", "sale.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            //debugPrint(rsp['data'].length.toString());
          });
          for (var i = 0; i < rsp['data'].length; i++) {
            setState(() {
              custlist.add(rsp['data'][i]['bill_no'].toString());
              custlistid.add(rsp['data'][i]['bill_id'].toString());
            });
          }
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
          });
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(context, "Error", "Session expired",
                Colors.white, Colors.redAccent, Icons.info, true, "bottom");
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: MyHomePage()));
          }
        }
      }
    } catch (error) {
      setState(() {
        showloader = false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  List allproducts = [];

  AddRemrks(String remarks) {
    setState(() {
      popup_remarks_Controller.clear();
      popup_remarks_Controller.text = remarks.toString();
    });

    // set up the button
    Widget okButton = TextButton(
      child: Text("Done"),
      onPressed: () {
        setState(() {
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
        setState(() {
          popup_remarks_Controller.clear();
          remarks_Controller.clear();
        });

        Navigator.pop(context);
      },
    );

    List series = [];
    String? seriesid;
    void getseries() async {
      setState(() {
        series.clear();
        seriesid = "auto";
        series.add({
          "id": "auto",
          "sname": "Auto Series",
          "name": "aseries",
          "last_count": "0",
          "status": "0"
        });
        series.add({
          "id": "manual",
          "sname": "Manual",
          "name": "manual",
          "last_count": "0",
          "status": "0"
        });
      });
    }

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Any Remarks ?'),
      content: Container(
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 0, bottom: 2, top: 10, right: 20),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 150,
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
                      readOnly: false,
                      onChanged: (v) {},
                      decoration: new InputDecoration(
                        isDense: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
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
      actions: [okButton, CancelButton, ClearButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  List convers = [];

  void save_Bill() async {
    setState(() {
      showloader = true;
    });
    String token = "";
    var userdetails = SharedPreferenceSingleton.sharedPreferences;
    if (userdetails.getString("utoken") != null) {
      token = userdetails.getString("utoken").toString();
    }
    try {
      FormData formData = new FormData();
      formData = FormData.fromMap({
        "_req_from": reqfrom,
        "api_key": apikey,
        "_req_token": token,
        "type": "addSnote",
        "sr_date": selecteddate.toString(),
        "bill_date": billdate.toString(),
        "bill_to": billto.toString(),
        "ship_to": billto.toString(),
        "series": seriesid,
        "conversion": convers,
        "cr_no": cnotenumberController.text.toString(),
        "bill_no": billnumber.toString(),
        "inc_st": "",
        "stores": "1",
        "product": allproid,
        "uom2": uom2,
        "rate": p_rate,
        "disc": discount,
        "description": description,
        "gst_value": gst_val,
        "quant": orig_quant,
        "uom1": uom1,
        "prod_quant": allnewquant,
        "rateo": rate_on,
        "remarks": remarks_Controller.text.toString(),
      });
      //debugPrint(allproid.toString());
      //debugPrint(uom2.toString());
      //debugPrint(p_rate.toString());
      //debugPrint(formData.fields.toString());
      var rsp = await gbill("/member/process", "sreturn.php", formData);
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          showPrintedMessage(context, "Success", "Added Successfully",
              Colors.white, Colors.green, Icons.info, true, "top");
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: ViewSReturn()));
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
            showPrintedMessage(context, "Error", rsp['error'].toString(),
                Colors.white, Colors.red, Icons.info, true, "top");
          });
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(context, "Error", "Session expired",
                Colors.white, Colors.redAccent, Icons.info, true, "bottom");
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: MyHomePage()));
          }
        } else if (rsp['status'].toString() == "already_exist") {
          showPrintedMessage(context, "Failed", "Failed to add", Colors.white,
              Colors.redAccent, Icons.info, true, "bottom");
        }
      }
    } catch (error) {
      setState(() {
        showloader = false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.red, Icons.info, true, "bottom");
      //debugPrint('Stacktrace: ' + stacktrace.toString());
      //debugPrint(error.toString());
    }
  }

  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    getseries();
    setscreenposition();
  }

  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "sreturn");
    //debugPrint(screen.getString("currentscreen").toString());
    getBillList();
    getbillnum();
  }

  void getbillnum() async {
    try {
      var rsp = await apiurl("/member/process", "bill_nums.php", {
        "type": "sreturn",
      });
      //debugPrint('myseries num- '+rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            cnotenumberController.text = rsp['no'].toString();
          });
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
          });
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(context, "Error", "Session expired",
                Colors.white, Colors.redAccent, Icons.info, true, "bottom");
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: MyHomePage()));
          }
        }
      }
    } catch (error) {
      setState(() {
        showloader = false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  List series = [];
  String? seriesid;
  void getseries() async {
    setState(() {
      series.clear();
      seriesid = "auto";
      series.add({
        "id": "auto",
        "sname": "Auto Series",
        "name": "aseries",
        "last_count": "0",
        "status": "0"
      });
      series.add({
        "id": "manual",
        "sname": "Manual",
        "name": "manual",
        "last_count": "0",
        "status": "0"
      });
    });
  }

  //get customer/supplier/warehouse
  void getBill() async {
    setState(() {
      showloader = true;
      allproducts.clear();
      gotresp = false;
      allproid.clear();
      allnewquant.clear();
      //debugPrint(selectedbillid.toString());
    });
    try {
      var rsp = await apiurl("/member/process", "sale.php",
          {"type": "getData", "bill_id": selectedbillid});
      //debugPrint(rsp.toString());
      //debugPrint(rsp['BILL'].toString());
      //debugPrint('inc - '+rsp['inc_st'].toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            convers.clear();
            uom1.clear();
            showloader = false;
            gotresp = true;
            billnumber = rsp['BILL']['bill_no'].toString();
            billdate =
                rsp['BILL']['bill_date'].toString().replaceAll(" 00:00:00", "");
            billto = rsp['BILL']['bill_to'].toString();
            customername = rsp['BILL']['bt_name'].toString();
            for (var i = 0; i < rsp['BILL']['prods'].length; i++) {
              rsp['BILL']['prods'][i]
                  .addAll({'new_quant': TextEditingController()});
            }
            allproducts = rsp['BILL']['prods'];
            for (var i = 0; i < allproducts.length; i++) {
              allproid.add(allproducts[i]['product_id'].toString());
              convers.add(allproducts[i]['conversion'].toString());
              allnewquant.add('0');
              discount.add(allproducts[i]['disc'].toString());
              p_rate.add(allproducts[i]['sp'].toString());
              description.add(allproducts[i]['prod_desc'].toString());
              uom1.add(allproducts[i]['uom1'].toString());
              if (allproducts[i]['rate_on'].toString() == 'uom1') {
                orig_quant.add(allproducts[i]['qsuom'].toString());
                uom2.add(allproducts[i]['qauom'].toString());
              } else {
                orig_quant.add(allproducts[i]['qauom'].toString());
                uom2.add(allproducts[i]['qauom'].toString());
              }
              gst_val.add(allproducts[i]['gst_value'].toString());
              rate_on.add(allproducts[i]['rate_on'].toString());
            }
            //debugPrint(allproducts.toString());
          });
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
            gotresp = false;
          });
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(context, "Error", "Session expired",
                Colors.white, Colors.redAccent, Icons.info, true, "bottom");
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: MyHomePage()));
          }
        }
      }
    } catch (error) {
      setState(() {
        showloader = false;
        gotresp = false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (gotresp == false) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: ViewSReturn()));
        } else {
          setState(() {
            seriesid = "auto";
            getbillnum();
            gotresp = false;
            selectedbillid = '';
            billnumber = '';
            billdate = '';
            customername = '';
            selecteddate = '';
            cnotenumberController.clear();
          });
        }
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
                              Icon(
                                Icons.circle,
                                color: Colors.white,
                                size: 15,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Add Sale Return',
                                style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      height: gotresp == false
                          ? MediaQuery.of(context).size.height - 140
                          : MediaQuery.of(context).size.height - 240,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: showloader == true
                          ? Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 0.7,
                              ),
                            )
                          : gotresp == false
                              ? Center(
                                  child: Container(
                                    color: Colors.white,
                                    child: Card(
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Please select your bill to generate sale return',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blue,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                              height: 45,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: Colors.white,
                                              child: Container(
                                                height: 45,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    100,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.rectangle,
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight: Radius
                                                              .circular(10.0),
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10.0)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 0),
                                                  child: DropdownSearch<String>(
                                                    mode: Mode.MENU,
                                                    showSearchBox: true,
                                                    showSelectedItems: true,
                                                    showClearButton: false,
                                                    items: custlist,
                                                    label: "Select Your Bill *",
                                                    hint: "",
                                                    selectedItem: null,
                                                    onChanged: (s) {
                                                      int index =
                                                          custlist.indexOf(
                                                              s.toString());
                                                      setState(() {
                                                        selectedbillid =
                                                            custlistid[index]
                                                                .toString();
                                                        //debugPrint(selectedbillid.toString());
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                              width: 150,
                                              height: 35,
                                              child: RaisedButton(
                                                  elevation: 0,
                                                  color: Colors.green,
                                                  onPressed: () {
                                                    if (selectedbillid == '') {
                                                      showPrintedMessage(
                                                          context,
                                                          "Error",
                                                          "Please select a bill ",
                                                          Colors.white,
                                                          Colors.redAccent,
                                                          Icons.info,
                                                          true,
                                                          "top");
                                                    } else {
                                                      gotresp = false;
                                                      getBill();
                                                    }
                                                  },
                                                  child: Text(
                                                      'Get Bill Details',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .white))),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 110,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0, right: 0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        color: Colors.grey
                                                            .withOpacity(0.3)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        billnumber.toString(),
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Container(
                                                    height: 30,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            160,
                                                    decoration: BoxDecoration(
                                                        color: seriesid ==
                                                                "auto"
                                                            ? Colors.grey
                                                                .withOpacity(
                                                                    0.3)
                                                            : Colors.white,
                                                        border: Border.all(
                                                          color: Colors.grey
                                                              .withOpacity(0.3),
                                                        )),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 0, 10, 0),
                                                        child: TextFormField(
                                                          readOnly:
                                                              seriesid == "auto"
                                                                  ? true
                                                                  : false,
                                                          decoration:
                                                              new InputDecoration(
                                                            floatingLabelBehavior:
                                                                FloatingLabelBehavior
                                                                    .never,
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10),
                                                            isDense: true,
                                                            hintText: seriesid ==
                                                                    "auto"
                                                                ? "Credit note number"
                                                                : "Credit note number *",
                                                            labelStyle: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        AppBarColor),
                                                            fillColor: Colors
                                                                .white
                                                                .withOpacity(
                                                                    0.5),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .transparent,
                                                                width: 0.0,
                                                              ),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .transparent,
                                                                width: 0.0,
                                                              ),
                                                            ),
                                                            //fillColor: Colors.green
                                                          ),
                                                          controller:
                                                              cnotenumberController,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        color: Colors.grey
                                                            .withOpacity(0.3)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        billdate.toString(),
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _selectDate(context);
                                                    },
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              160,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3),
                                                          )),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child:
                                                            selecteddate == ''
                                                                ? Text(
                                                                    'Credit note date *',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  )
                                                                : Text(
                                                                    selecteddate
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 34,
                                                    width: 160,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius: BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    0.0),
                                                            topLeft:
                                                                Radius.circular(
                                                                    0.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    0.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0.0)),
                                                        border: Border.all(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3))),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 0, 10, 0),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                00, 0, 00, 0),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: ButtonTheme(
                                                            child:
                                                                DropdownButton<
                                                                    String>(
                                                              dropdownColor:
                                                                  Colors.white,
                                                              elevation: 0,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              value: seriesid,
                                                              //elevation: 5,
                                                              style: TextStyle(
                                                                  color:
                                                                      AppBarColor),
                                                              iconEnabledColor:
                                                                  AppBarColor,
                                                              items: series.map(
                                                                      (item) {
                                                                    return new DropdownMenuItem(
                                                                      child:
                                                                          new Text(
                                                                        item['sname']
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                AppBarColor),
                                                                      ),
                                                                      value: item[
                                                                              'id']
                                                                          .toString(),
                                                                    );
                                                                  }).toList() ??
                                                                  [],

                                                              hint: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            5),
                                                                child: Text(
                                                                  "Auto Series",
                                                                  style: GoogleFonts.poppins(
                                                                      color:
                                                                          AppBarColor,
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ),
                                                              onChanged:
                                                                  (String?
                                                                      value) {
                                                                setState(() {
                                                                  seriesid = value
                                                                      .toString();
                                                                  if (seriesid !=
                                                                      'manual') {
                                                                    getbillnum();
                                                                  } else {
                                                                    cnotenumberController
                                                                        .clear();
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            160,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        color: Colors.grey
                                                            .withOpacity(0.3)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                          child: Text(
                                                        customername.toString(),
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: allproducts.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10,
                                                  bottom: 2,
                                                  right: 10),
                                              child: Container(
                                                color: Colors.white,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Container(
                                                        child: Text(
                                                          allproducts[index]
                                                                  ['prod_name']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 100,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      color: Colors
                                                                          .white),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0,
                                                                        8,
                                                                        8,
                                                                        8),
                                                                child: Text(
                                                                  'HSN',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Container(
                                                              width: 70,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      color: Colors
                                                                          .white),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0,
                                                                        8,
                                                                        8,
                                                                        8),
                                                                child: Text(
                                                                  'GST %',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  210,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      color: Colors
                                                                          .white),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0,
                                                                        8,
                                                                        8,
                                                                        8),
                                                                child: Text(
                                                                  'Rate',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 100,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.3)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                  allproducts[index]
                                                                          [
                                                                          'hsn']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Container(
                                                              width: 70,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.3)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                  allproducts[index]
                                                                          [
                                                                          'gst_value']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  210,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.3)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                  double.parse(allproducts[index]
                                                                              [
                                                                              'sp']
                                                                          .toString())
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2.5,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      color: Colors
                                                                          .white),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0,
                                                                        8,
                                                                        8,
                                                                        8),
                                                                child: Text(
                                                                  'Old Quantity',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2.5,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      color: Colors
                                                                          .white),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0,
                                                                        8,
                                                                        8,
                                                                        8),
                                                                child: Text(
                                                                  'Return Quantity',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            if (allproducts[index]
                                                                        [
                                                                        'rate_on']
                                                                    .toString() ==
                                                                'uom1')
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2.5,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        border: Border
                                                                            .all(
                                                                          color:
                                                                              Colors.transparent,
                                                                        ),
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.3)),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    allproducts[index]
                                                                            [
                                                                            'qsuom']
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                              )
                                                            else
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2.5,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        border: Border
                                                                            .all(
                                                                          color:
                                                                              Colors.transparent,
                                                                        ),
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.3)),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    allproducts[index]
                                                                            [
                                                                            'qauom']
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                              ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Container(
                                                                height: 32,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2.5,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        border: Border
                                                                            .all(
                                                                          color:
                                                                              AppBarColor,
                                                                        ),
                                                                        color: Colors
                                                                            .white),
                                                                child: Center(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            0,
                                                                            0,
                                                                            10,
                                                                            0),
                                                                    child:
                                                                        TextFormField(
                                                                      keyboardType:
                                                                          TextInputType.numberWithOptions(
                                                                              decimal: true),
                                                                      inputFormatters: <
                                                                          TextInputFormatter>[
                                                                        FilteringTextInputFormatter(
                                                                            RegExp(
                                                                                "[0-9.]"),
                                                                            allow:
                                                                                true),
                                                                        MyNumberTextInputFormatter(
                                                                            digit:
                                                                                4),
                                                                      ],
                                                                      onChanged:
                                                                          (v) {
                                                                        if (v
                                                                            .isNotEmpty) {
                                                                          if (allproducts[index]['rate_on'].toString() ==
                                                                              'uom1') {
                                                                            if (double.parse(v.toString()) >
                                                                                double.parse(allproducts[index]['qsuom'])) {
                                                                              showPrintedMessage(context, "Error", "Quantity should not exceed original quantity", Colors.white, Colors.redAccent, Icons.info, true, "top");
                                                                              setState(() {
                                                                                allproducts[index]['new_quant'].clear();
                                                                                allnewquant[index] = '0';
                                                                              });
                                                                            } else {
                                                                              setState(() {
                                                                                allnewquant[index] = v.toString();
                                                                              });
                                                                            }
                                                                          } else {
                                                                            if (double.parse(v.toString()) >
                                                                                double.parse(allproducts[index]['qauom'])) {
                                                                              showPrintedMessage(context, "Error", "Quantity should not exceed original quantity", Colors.white, Colors.redAccent, Icons.info, true, "top");
                                                                              setState(() {
                                                                                allproducts[index]['new_quant'].clear();
                                                                                allnewquant[index] = '0';
                                                                              });
                                                                            } else {
                                                                              setState(() {
                                                                                allnewquant[index] = v.toString();
                                                                              });
                                                                            }
                                                                          }
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            allproducts[index]['new_quant'].clear();
                                                                            allnewquant[index] =
                                                                                '0';
                                                                          });
                                                                        }
                                                                      },
                                                                      decoration:
                                                                          new InputDecoration(
                                                                        floatingLabelBehavior:
                                                                            FloatingLabelBehavior.never,
                                                                        contentPadding:
                                                                            EdgeInsets.symmetric(horizontal: 10),
                                                                        isDense:
                                                                            true,
                                                                        labelText:
                                                                            "New Quantity",
                                                                        labelStyle: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AppBarColor),
                                                                        fillColor: Colors
                                                                            .white
                                                                            .withOpacity(0.5),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Colors.transparent,
                                                                            width:
                                                                                0.0,
                                                                          ),
                                                                        ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Colors.transparent,
                                                                            width:
                                                                                0.0,
                                                                          ),
                                                                        ),
                                                                        //fillColor: Colors.green
                                                                      ),
                                                                      controller:
                                                                          allproducts[index]
                                                                              [
                                                                              'new_quant'],
                                                                    ),
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    if (index !=
                                                        allproducts.length - 1)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 0,
                                                                right: 0,
                                                                top: 10,
                                                                bottom: 10),
                                                        child: Divider(
                                                          color: Colors.black,
                                                          thickness: 1,
                                                        ),
                                                      ),
                                                    if (index ==
                                                        allproducts.length - 1)
                                                      Container(
                                                        height: 200,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color: Colors.white,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: gotresp == false
            ? Container(height: 0)
            : Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 150,
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
                            readOnly: true,
                            onTap: () {
                              AddRemrks(remarks_Controller.text.toString());
                            },
                            decoration: new InputDecoration(
                              isDense: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
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
                        height: 50,
                        width: 120,
                        child: RaisedButton(
                            color: AppBarColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            onPressed: () {
                              if (seriesid == "manual") {
                                if (cnotenumberController.text.isNotEmpty &&
                                    selecteddate != '') {
                                  save_Bill();
                                } else {
                                  showPrintedMessage(
                                      context,
                                      "Error",
                                      "Please fill the required fields",
                                      Colors.white,
                                      Colors.redAccent,
                                      Icons.info,
                                      true,
                                      "top");
                                }
                              } else {
                                if (selecteddate != '') {
                                  save_Bill();
                                } else {
                                  showPrintedMessage(
                                      context,
                                      "Error",
                                      "Please fill the required fields",
                                      Colors.white,
                                      Colors.redAccent,
                                      Icons.info,
                                      true,
                                      "top");
                                }
                              }
                            },
                            child: Text(
                              'Save',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            )),
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
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    int selectionIndex = newValue.selection.end;
    if (value == ".") {
      value = "0.";
      selectionIndex++;
    } else if (value == "-") {
      value = "-";
      selectionIndex++;
    } else if (value != "" &&
            value != defaultDouble.toString() &&
            strToFloat(value, defaultDouble) == defaultDouble ||
        getValueDigit(value) > digit) {
      value = oldValue.text;
      selectionIndex = oldValue.selection.end;
    }
    return new TextEditingValue(
      text: value,
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
