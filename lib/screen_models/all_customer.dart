import 'package:bbills/screen_models/edit_screen/edit_customer.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../shared preference singleton.dart';

import '../main.dart';
import '../toast_messeger.dart';
import 'add_screens/add_customer.dart';
import 'dashboard.dart';

class AllCustomerScreen extends StatefulWidget {
  @override
  _AllCustomerScreenState createState() => _AllCustomerScreenState();
}

class _AllCustomerScreenState extends State<AllCustomerScreen> {
  _callNumber(String phn) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phn);
  }

  launchWhatsApp(String phn) async {
    if (phn.contains("+91") == false) {
      await FlutterOpenWhatsapp.sendSingleMessage("+91" + phn, "");
    } else {
      await FlutterOpenWhatsapp.sendSingleMessage(phn, "");
    }
  }

  late String pdfPath = "";
  bool inprintermode = false;
  bool showloader = true;
  List allcustomers = [];
  bool showalertdetail = false;
  String selectedbillno = "";
  String selectedcustid = "";
  String selectedemail = "";
  String selectedbaltype = "";
  String selectedpartyname = "";
  String selectedaddress = "";
  String selectedpincode = "";
  String? currentTime;
  String selectedstatus = "";
  DateTime? parseddate;
  TextEditingController editingController = TextEditingController();
  final DateFormat formatter1 = DateFormat('MM/dd/yyyy');
  //final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
  @override
  void initState() {
    super.initState();
    setscreenposition();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        Navigator.pop(context);
        setState(() {
          showloader = true;
        });
        delete();
      },
    );
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Do you want to remove this customer?"),
      actions: [okButton, cancelButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "allcustomerscreen");
    //debugPrint(screen.getString("currentscreen").toString());
    getdata();
  }

  void getdata() async {
    try {
      var rsp = await apiurl("/member/process", "customer.php", {
        "type": "view_alls",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            allcustomers = rsp['data'];
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
      setState(() {
        showloader = false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  void delete() async {
    try {
      var rsp = await apiurl("/member/process", "customer.php", {
        "type": "delete",
        "id": selectedcustid,
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            showalertdetail = false;
            indexpostion.clear();
            items.clear();
            isbillfound = true;
            editingController.clear();
            getdata();
            showPrintedMessage(context, "Success", "Deleted Successfully",
                Colors.white, Colors.green, Icons.info, true, "top");
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
          if (rsp['error'].toString() == "data exists") {
            showPrintedMessage(context, "Error", "This customer has data",
                Colors.white, Colors.redAccent, Icons.info, true, "bottom");
          }
        }
      }
    } catch (error) {
      setState(() {
        showloader = false;
      });
      setState(() {
        showloader = false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  void changestatus() async {
    try {
      var rsp = await apiurl("/member/process", "customer.php", {
        "type": "changeStatus",
        "id": selectedcustid,
        if (selectedstatus == "Active") "cstatus": "0" else "cstatus": "1"
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            showalertdetail = false;
            indexpostion.clear();
            items.clear();
            isbillfound = true;
            editingController.clear();
            getdata();
            showPrintedMessage(
                context,
                "Success",
                "Status Changed Successfully",
                Colors.white,
                Colors.green,
                Icons.info,
                true,
                "top");
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
      setState(() {
        showloader = false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  //search function
  var items = [];
  var indexpostion = [];
  bool isbillfound = true;
  void filterSearchResults(String query) {
    setState(() {
      showalertdetail = false;
    });
    indexpostion.clear();
    List dummySearchList = [];
    dummySearchList.addAll(allcustomers);
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if (item['gst']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['phone']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase())) {
          setState(() {
            dummyListData.add(item);
            isbillfound = true;
          });
        } else {
          setState(() {
            isbillfound = false;
          });
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
        indexpostion.clear();
        for (var i = 0; i != items.length; i++) {
          final index = dummySearchList
              .indexWhere((element) => element['name'] == items[i]['name']);
          indexpostion.add(index);
        }
        ////debugPrint(indexpostion.toString());
      });
      items.clear();
      for (var i = 0; i != indexpostion.length; i++) {
        items.add(allcustomers[int.parse(indexpostion[i].toString())]);
        ////debugPrint(items.toString());
      }
      return;
    } else {
      setState(() {
        isbillfound = true;
        items.clear();
        items.addAll(allcustomers);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(context,
            PageTransition(type: PageTransitionType.fade, child: Dashboard()));

        return false;
      },
      child: Scaffold(
        backgroundColor:
            allcustomers.isNotEmpty ? scaffoldbackground : Colors.white,
        //   bottomNavigationBar: BottomBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: allcustomers.isNotEmpty ? AppBarColor : Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  ConstAppBar("customers_help"),
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
                                'Customers',
                                style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showloader == true)
                    Container(
                      height: MediaQuery.of(context).size.height - 140,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.7,
                        ),
                      ),
                    ),
                  if (allcustomers.isNotEmpty && showloader == false)
                    Container(
                      color: AppBarColor,
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: editingController,
                          onChanged: (v) {
                            filterSearchResults(v.toString());
                          },
                          decoration: InputDecoration(
                              labelText: "Search using name, GST no, contact",
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: "Search using name, GST no, contact",
                              hintStyle: TextStyle(color: Colors.white),
                              fillColor: Colors.white,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 1.0),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)))),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (showloader == false &&
                      items.isEmpty &&
                      isbillfound == true)
                    Expanded(
                      child: Container(
                        height: showalertdetail == false &&
                                allcustomers.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalertdetail == false && allcustomers.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 310,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: allcustomers.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: allcustomers.length,
                                    itemBuilder: (BuildContext context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScopeNode currentFocus =
                                              FocusScope.of(context);
                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                          setState(() {
                                            showalertdetail = true;
                                            pdfPath = "";
                                            selectedbillno = "";
                                            selectedbaltype = "";
                                            selectedemail = "";
                                            selectedpartyname = "";
                                            selectedaddress = "";
                                            selectedpincode = "";
                                            selectedcustid = "";

                                            selectedcustid = allcustomers[index]
                                                    ['cid']
                                                .toString();
                                            selectedbillno = allcustomers[index]
                                                    ['gst']
                                                .toString();
                                            selectedbaltype =
                                                allcustomers[index]['bal_type']
                                                    .toString();
                                            selectedpartyname =
                                                allcustomers[index]['name']
                                                    .toString();
                                            selectedaddress =
                                                allcustomers[index]['address']
                                                    .toString();
                                            selectedpincode =
                                                allcustomers[index]['pin']
                                                    .toString();
                                            selectedemail = allcustomers[index]
                                                    ['email']
                                                .toString();
                                            selectedstatus = "";
                                            if (allcustomers[index]['is_active']
                                                    .toString() ==
                                                "1") {
                                              selectedstatus = "Active";
                                            } else {
                                              selectedstatus = "Inctive";
                                            }
                                          });
                                          //debugPrint(selectedbillno);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            children: [
                                              Card(
                                                elevation: 0,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              top: 8,
                                                              bottom: 2),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                45,
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                allcustomers[
                                                                            index]
                                                                        ['name']
                                                                    .toString(),
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.circle,
                                                            size: 10,
                                                            color: allcustomers[index]
                                                                            [
                                                                            'is_active']
                                                                        .toString() ==
                                                                    "1"
                                                                ? Colors.green
                                                                : Colors.red,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              top: 0,
                                                              bottom: 2,
                                                              right: 8),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'GST No :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                Text(
                                                                  " " +
                                                                      allcustomers[index]
                                                                              [
                                                                              'gst']
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  '₹',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                Text(
                                                                  " " +
                                                                      allcustomers[index]
                                                                              [
                                                                              'cur_bal']
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              top: 0,
                                                              bottom: 2,
                                                              right: 8),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Contact :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                Text(
                                                                  " " +
                                                                      allcustomers[index]
                                                                              [
                                                                              'phone']
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      if (allcustomers[index]['phone']
                                                                              .toString() !=
                                                                          "") {
                                                                        _callNumber(
                                                                            allcustomers[index]['phone'].toString());
                                                                      } else {
                                                                        showPrintedMessage(
                                                                            context,
                                                                            "Error",
                                                                            "Invalid phone number",
                                                                            Colors.white,
                                                                            Colors.redAccent,
                                                                            Icons.info,
                                                                            true,
                                                                            "bottom");
                                                                      }
                                                                    },
                                                                    child: Center(
                                                                        child: Icon(
                                                                      Icons
                                                                          .phone,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .blue,
                                                                    ))),
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      if (allcustomers[index]['phone']
                                                                              .toString() !=
                                                                          "") {
                                                                        launchWhatsApp(
                                                                            allcustomers[index]['phone'].toString());
                                                                      } else {
                                                                        showPrintedMessage(
                                                                            context,
                                                                            "Error",
                                                                            "Invalid phone number",
                                                                            Colors.white,
                                                                            Colors.redAccent,
                                                                            Icons.info,
                                                                            true,
                                                                            "bottom");
                                                                      }
                                                                    },
                                                                    child: Center(
                                                                        child: Image.asset(
                                                                      'assets/icons/whatsapp.png',
                                                                      width: 30,
                                                                    ))),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (allcustomers[index]
                                                                ['name']
                                                            .toString() !=
                                                        'Cash')
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8,
                                                                top: 0,
                                                                bottom: 2,
                                                                right: 8),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'GST Status :',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  Text(
                                                                    " " +
                                                                        allcustomers[index]['gst_status']
                                                                            .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ],
                                                              ),
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .popUntil((route) =>
                                                                            route.isFirst);
                                                                    Navigator.pushReplacement(
                                                                        context,
                                                                        PageTransition(
                                                                            type: PageTransitionType
                                                                                .fade,
                                                                            child: EditCustomer(
                                                                                fromscreen: 'Customer',
                                                                                cid: allcustomers[index]['cid'].toString(),
                                                                                name: allcustomers[index]['name'].toString(),
                                                                                contact: allcustomers[index]['phone'].toString(),
                                                                                email: allcustomers[index]['email'].toString(),
                                                                                address: allcustomers[index]['address'].toString(),
                                                                                city: allcustomers[index]['city'].toString(),
                                                                                state: allcustomers[index]['state'].toString(),
                                                                                pincode: allcustomers[index]['pin'].toString(),
                                                                                gstatus: allcustomers[index]['gst_status'].toString(),
                                                                                gstno: allcustomers[index]['gst'].toString(),
                                                                                btype: allcustomers[index]['bal_type'].toString(),
                                                                                openbalance: allcustomers[index]['open_bal'].toString(),
                                                                                panno: allcustomers[index]['pan'].toString(),
                                                                                tan: allcustomers[index]['tan'].toString(),
                                                                                dist: allcustomers[index]['distance'].toString())));
                                                                  },
                                                                  child: Text(
                                                                    "Edit",
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .blueAccent),
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8,
                                                                top: 0,
                                                                bottom: 2,
                                                                right: 8),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'GST Status :',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  Text(
                                                                    " " +
                                                                        allcustomers[index]['gst_status']
                                                                            .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              if (index ==
                                                  allcustomers.length - 1)
                                                Container(
                                                  height: 80,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.white,
                                                ),
                                              if (index !=
                                                  allcustomers.length - 1)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 50, right: 50),
                                                  child: Divider(
                                                    color: Colors.blueAccent,
                                                    thickness: 0.2,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : Center(
                                child: Text(
                                  'No data found',
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, color: Colors.black),
                                ),
                              ),
                      ),
                    ),
                  if (showloader == false &&
                      items.isNotEmpty &&
                      isbillfound == true)
                    Expanded(
                      child: Container(
                        height: showalertdetail == false &&
                                allcustomers.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalertdetail == false && allcustomers.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 310,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: items.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: items.length,
                                    itemBuilder: (BuildContext context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScopeNode currentFocus =
                                              FocusScope.of(context);
                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                          setState(() {
                                            showalertdetail = true;
                                            pdfPath = "";
                                            selectedbillno = "";
                                            selectedbaltype = "";
                                            selectedemail = "";
                                            selectedpartyname = "";
                                            selectedaddress = "";
                                            selectedpincode = "";
                                            selectedcustid = "";
                                            selectedstatus = "";
                                            selectedcustid =
                                                items[index]['cid'].toString();
                                            selectedbillno =
                                                items[index]['gst'].toString();
                                            selectedbaltype = items[index]
                                                    ['bal_type']
                                                .toString();
                                            selectedpartyname =
                                                items[index]['name'].toString();
                                            selectedaddress = items[index]
                                                    ['address']
                                                .toString();
                                            selectedpincode =
                                                items[index]['pin'].toString();
                                            selectedemail = items[index]
                                                    ['email']
                                                .toString();
                                            if (items[index]['is_active']
                                                    .toString() ==
                                                "1") {
                                              selectedstatus = "Active";
                                            } else {
                                              selectedstatus = "Inctive";
                                            }
                                          });
                                          //debugPrint(selectedbillno);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            children: [
                                              Card(
                                                elevation: 0,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              top: 8,
                                                              bottom: 2),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                45,
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                items[index]
                                                                        ['name']
                                                                    .toString(),
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.circle,
                                                            size: 10,
                                                            color: items[index][
                                                                            'is_active']
                                                                        .toString() ==
                                                                    "1"
                                                                ? Colors.green
                                                                : Colors.red,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              top: 0,
                                                              bottom: 2,
                                                              right: 8),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'GST No :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                Text(
                                                                  " " +
                                                                      items[index]
                                                                              [
                                                                              'gst']
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  '₹',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                Text(
                                                                  " " +
                                                                      items[index]
                                                                              [
                                                                              'cur_bal']
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              top: 0,
                                                              bottom: 2,
                                                              right: 8),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Contact :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                Text(
                                                                  " " +
                                                                      items[index]
                                                                              [
                                                                              'phone']
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      if (items[index]['phone']
                                                                              .toString() !=
                                                                          "") {
                                                                        _callNumber(
                                                                            items[index]['phone'].toString());
                                                                      } else {
                                                                        showPrintedMessage(
                                                                            context,
                                                                            "Error",
                                                                            "Invalid phone number",
                                                                            Colors.white,
                                                                            Colors.redAccent,
                                                                            Icons.info,
                                                                            true,
                                                                            "bottom");
                                                                      }
                                                                    },
                                                                    child: Center(
                                                                        child: Icon(
                                                                      Icons
                                                                          .phone,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .blue,
                                                                    ))),
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      if (items[index]['phone']
                                                                              .toString() !=
                                                                          "") {
                                                                        launchWhatsApp(
                                                                            items[index]['phone'].toString());
                                                                      } else {
                                                                        showPrintedMessage(
                                                                            context,
                                                                            "Error",
                                                                            "Invalid phone number",
                                                                            Colors.white,
                                                                            Colors.redAccent,
                                                                            Icons.info,
                                                                            true,
                                                                            "bottom");
                                                                      }
                                                                    },
                                                                    child: Center(
                                                                        child: Image.asset(
                                                                      'assets/icons/whatsapp.png',
                                                                      width: 30,
                                                                    ))),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (items[index]['name']
                                                            .toString() !=
                                                        'Cash')
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8,
                                                                top: 0,
                                                                bottom: 2,
                                                                right: 8),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'GST Status :',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  Text(
                                                                    " " +
                                                                        items[index]['gst_status']
                                                                            .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ],
                                                              ),
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .popUntil((route) =>
                                                                            route.isFirst);
                                                                    Navigator.pushReplacement(
                                                                        context,
                                                                        PageTransition(
                                                                            type: PageTransitionType
                                                                                .fade,
                                                                            child: EditCustomer(
                                                                                fromscreen: 'Customer',
                                                                                cid: items[index]['cid'].toString(),
                                                                                name: items[index]['name'].toString(),
                                                                                contact: items[index]['phone'].toString(),
                                                                                email: items[index]['email'].toString(),
                                                                                address: items[index]['address'].toString(),
                                                                                city: items[index]['city'].toString(),
                                                                                state: items[index]['state'].toString(),
                                                                                pincode: items[index]['pin'].toString(),
                                                                                gstatus: items[index]['gst_status'].toString(),
                                                                                gstno: items[index]['gst'].toString(),
                                                                                btype: items[index]['bal_type'].toString(),
                                                                                openbalance: items[index]['open_bal'].toString(),
                                                                                panno: items[index]['pan'].toString(),
                                                                                tan: items[index]['tan'].toString(),
                                                                                dist: items[index]['distance'].toString())));
                                                                  },
                                                                  child: Text(
                                                                    "Edit",
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .blueAccent),
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8,
                                                                top: 0,
                                                                bottom: 2,
                                                                right: 8),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'GST Status :',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  Text(
                                                                    " " +
                                                                        items[index]['gst_status']
                                                                            .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              if (index == items.length - 1)
                                                Container(
                                                  height: 80,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.white,
                                                ),
                                              if (index != items.length - 1)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 50, right: 50),
                                                  child: Divider(
                                                    color: Colors.blueAccent,
                                                    thickness: 0.2,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : Center(
                                child: Text(
                                  'No data found',
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, color: Colors.black),
                                ),
                              ),
                      ),
                    ),
                  if (showloader == false &&
                      items.isEmpty &&
                      isbillfound == false)
                    Expanded(
                        child: Container(
                      height:
                          showalertdetail == false && allcustomers.isNotEmpty
                              ? MediaQuery.of(context).size.height - 200
                              : showalertdetail == false && allcustomers.isEmpty
                                  ? MediaQuery.of(context).size.height - 200
                                  : 310,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'No Customer found',
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.black),
                        ),
                      ),
                    )),
                  if (showloader == false &&
                      items.isNotEmpty &&
                      isbillfound == false)
                    Expanded(
                      child: Container(
                        height: showalertdetail == false &&
                                allcustomers.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalertdetail == false && allcustomers.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 310,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: items.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: items.length,
                                    itemBuilder: (BuildContext context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScopeNode currentFocus =
                                              FocusScope.of(context);
                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                          setState(() {
                                            showalertdetail = true;
                                            pdfPath = "";
                                            selectedbillno = "";
                                            selectedbaltype = "";
                                            selectedemail = "";
                                            selectedpartyname = "";
                                            selectedaddress = "";
                                            selectedpincode = "";
                                            selectedcustid = "";
                                            selectedstatus = "";
                                            selectedcustid =
                                                items[index]['cid'].toString();
                                            selectedbillno =
                                                items[index]['gst'].toString();
                                            selectedbaltype = items[index]
                                                    ['bal_type']
                                                .toString();
                                            selectedpartyname =
                                                items[index]['name'].toString();
                                            selectedaddress = items[index]
                                                    ['address']
                                                .toString();
                                            selectedpincode =
                                                items[index]['pin'].toString();
                                            selectedemail = items[index]
                                                    ['email']
                                                .toString();
                                            if (items[index]['is_active']
                                                    .toString() ==
                                                "1") {
                                              selectedstatus = "Active";
                                            } else {
                                              selectedstatus = "Inctive";
                                            }
                                          });
                                          //debugPrint(selectedbillno);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            children: [
                                              Card(
                                                elevation: 0,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              top: 8,
                                                              bottom: 2),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                45,
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                items[index]
                                                                        ['name']
                                                                    .toString(),
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.circle,
                                                            size: 10,
                                                            color: items[index][
                                                                            'is_active']
                                                                        .toString() ==
                                                                    "1"
                                                                ? Colors.green
                                                                : Colors.red,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              top: 0,
                                                              bottom: 2,
                                                              right: 8),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'GST No :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                Text(
                                                                  " " +
                                                                      allcustomers[index]
                                                                              [
                                                                              'gst']
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  '₹',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                Text(
                                                                  " " +
                                                                      items[index]
                                                                              [
                                                                              'cur_bal']
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              top: 0,
                                                              bottom: 2,
                                                              right: 8),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Contact :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                Text(
                                                                  " " +
                                                                      items[index]
                                                                              [
                                                                              'phone']
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      if (items[index]['phone']
                                                                              .toString() !=
                                                                          "") {
                                                                        _callNumber(
                                                                            items[index]['phone'].toString());
                                                                      } else {
                                                                        showPrintedMessage(
                                                                            context,
                                                                            "Error",
                                                                            "Invalid phone number",
                                                                            Colors.white,
                                                                            Colors.redAccent,
                                                                            Icons.info,
                                                                            true,
                                                                            "bottom");
                                                                      }
                                                                    },
                                                                    child: Center(
                                                                        child: Icon(
                                                                      Icons
                                                                          .phone,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .blue,
                                                                    ))),
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      if (items[index]['phone']
                                                                              .toString() !=
                                                                          "") {
                                                                        launchWhatsApp(
                                                                            items[index]['phone'].toString());
                                                                      } else {
                                                                        showPrintedMessage(
                                                                            context,
                                                                            "Error",
                                                                            "Invalid phone number",
                                                                            Colors.white,
                                                                            Colors.redAccent,
                                                                            Icons.info,
                                                                            true,
                                                                            "bottom");
                                                                      }
                                                                    },
                                                                    child: Center(
                                                                        child: Image.asset(
                                                                      'assets/icons/whatsapp.png',
                                                                      width: 30,
                                                                    ))),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (items[index]['name']
                                                            .toString() !=
                                                        'Cash')
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8,
                                                                top: 0,
                                                                bottom: 2,
                                                                right: 8),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'GST Status :',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  Text(
                                                                    " " +
                                                                        items[index]['gst_status']
                                                                            .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ],
                                                              ),
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .popUntil((route) =>
                                                                            route.isFirst);
                                                                    Navigator.pushReplacement(
                                                                        context,
                                                                        PageTransition(
                                                                            type: PageTransitionType
                                                                                .fade,
                                                                            child: EditCustomer(
                                                                                fromscreen: 'Customer',
                                                                                cid: items[index]['cid'].toString(),
                                                                                name: items[index]['name'].toString(),
                                                                                contact: items[index]['phone'].toString(),
                                                                                email: items[index]['email'].toString(),
                                                                                address: items[index]['address'].toString(),
                                                                                city: items[index]['city'].toString(),
                                                                                state: items[index]['state'].toString(),
                                                                                pincode: items[index]['pin'].toString(),
                                                                                gstatus: items[index]['gst_status'].toString(),
                                                                                gstno: items[index]['gst'].toString(),
                                                                                btype: items[index]['bal_type'].toString(),
                                                                                openbalance: items[index]['open_bal'].toString(),
                                                                                panno: items[index]['pan'].toString(),
                                                                                tan: items[index]['tan'].toString(),
                                                                                dist: items[index]['distance'].toString())));
                                                                  },
                                                                  child: Text(
                                                                    "Edit",
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .blueAccent),
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8,
                                                                top: 0,
                                                                bottom: 2,
                                                                right: 8),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'GST Status :',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  Text(
                                                                    " " +
                                                                        items[index]['gst_status']
                                                                            .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              if (index == items.length - 1)
                                                Container(
                                                  height: 80,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.white,
                                                ),
                                              if (index != items.length - 1)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 50, right: 50),
                                                  child: Divider(
                                                    color: Colors.blueAccent,
                                                    thickness: 0.2,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : Center(
                                child: Text(
                                  'No data found',
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, color: Colors.black),
                                ),
                              ),
                      ),
                    ),
                  if (showloader == false && showalertdetail == true)
                    Container(
                      height: MediaQuery.of(context).size.height - 605,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            color: AppBarColor,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 10, left: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Customer Details',
                                    style: GoogleFonts.poppins(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showalertdetail = false;
                                          selectedbaltype = "";
                                          selectedbillno = "";
                                          selectedpartyname = "";
                                          selectedaddress = "";
                                          selectedcustid = "";
                                          pdfPath = "";
                                        });
                                      },
                                      child: Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height - 703,
                            child: ListView.builder(
                              itemCount: 1,
                              itemBuilder: (BuildContext context, index) {
                                return Container(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 3, bottom: 2),
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Name :',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  " " + selectedpartyname,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 3, bottom: 2),
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Email ID :',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  " " + " " + selectedemail,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 5, bottom: 2),
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'GST No :',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  " " + selectedbillno,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 3, bottom: 2),
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Pin Code :',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  " " + selectedpincode,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 3, bottom: 20),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Address :',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    75,
                                                child: Text(
                                                  " " + selectedaddress,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RaisedButton(
                                elevation: 10,
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  'Delete',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, color: Colors.white),
                                ),
                                onPressed: () {
                                  showAlertDialog(context);
                                },
                              ),
                              RaisedButton(
                                elevation: 10,
                                color: selectedstatus == "Active"
                                    ? Colors.red
                                    : Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: selectedstatus == "Active"
                                    ? Text(
                                        'Make Inactive ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 16, color: Colors.white),
                                      )
                                    : Text(
                                        'Make Active ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                onPressed: () {
                                  setState(() {
                                    showloader = true;
                                  });
                                  changestatus();
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                ],
              ),
              if (showalertdetail == false)
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: BottomBar(
                    lastscreen: "allcustomerscreen",
                  ),
                ),
              if (showalertdetail == false)
                Positioned(
                  top: 100,
                  left: 330,
                  right: 0,
                  child: Container(
                    width: 50,
                    height: 30,
                    child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: AddCustomer(fromscreen: "Customer")));
                        },
                        child: Icon(
                          Icons.add,
                          color: AppBarColor,
                        )),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
