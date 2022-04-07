import 'dart:developer';

import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/screen_models/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../shared preference singleton.dart';
import '../toast_messeger.dart';
import 'dashboard.dart';

class Accnt_Details extends StatefulWidget {
  Accnt_Details({required this.from});
  final String from;
  @override
  _Accnt_DetailsState createState() => _Accnt_DetailsState();
}

class _Accnt_DetailsState extends State<Accnt_Details> {
  bool showloader = true;
  bool iseditclicked = false;

  //details variables
  String person = "";
  String firmname = "";
  String address = "";
  String phone = "";
  String email = "";
  String pid = "";

  //controllers
  TextEditingController companyController = TextEditingController();
  dynamic emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  dynamic addressController = TextEditingController();
  dynamic cityController = TextEditingController();
  dynamic pinController = TextEditingController();
  String? state;
  dynamic stateController = TextEditingController();
  dynamic landlineController = TextEditingController();
  dynamic panController = TextEditingController();
  dynamic TdsController = TextEditingController();
  dynamic pinCodeController = TextEditingController();
  String? gststatus;
  dynamic gstportalunameController = TextEditingController();
  dynamic gstdateController = TextEditingController();
  dynamic gstnoController = TextEditingController();
  dynamic authsignatoryController = TextEditingController();
  dynamic authsignatorydesigController = TextEditingController();
  dynamic contactpersonController = TextEditingController();
  dynamic additionalinfoController = TextEditingController();
  dynamic upiidController = TextEditingController();
  dynamic telegramController = TextEditingController();
  List? stateslist;
  List? gststtlist;

  void getStates() async {
    setState(() {
      showloader = true;
    });
    try {
      var rsp = await apiurl("/member/process", "customer.php",
          {"type": "find_state", "state": "all"});
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            //debugPrint(rsp['state'].length.toString());
            stateslist = rsp['state'];
            gststtlist = rsp['gststatus'];
            //debugPrint(rsp['labels'].toString());
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

  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  //datepicker
  _selectDate(
    BuildContext context,
  ) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );

    if (selected != null) {
      setState(() {
        gstdateController.text = formatter.format(selected);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setscreenposition();
    if (widget.from == 'settings') {
    } else {
      setState(() {
        iseditclicked = true;
      });
    }
  }

  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "accountdetails");
    //debugPrint(screen.getString("currentscreen").toString());
    //getdata();
    getStates();
    getdata();
  }

  void getdata() async {
    try {
      var rsp = await apiurl("/member/process", "firm.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          if (widget.from == 'settings') {
            setState(() {
              person = "";
              firmname = "";
              address = "";
              phone = "";
              email = "";
              pid = "";
              gststatus = null;
              person = rsp['data'][0]['firm_person'].toString();
              pid = rsp['data'][0]['pid'].toString();
              firmname = rsp['data'][0]['name'].toString();
              address = rsp['data'][0]['address'].toString();
              phone = rsp['data'][0]['phone'].toString();
              email = rsp['data'][0]['email'].toString();
              companyController.text = rsp['data'][0]['name'].toString();
              upiidController.text = rsp['data'][0]['upi_id'].toString();
              phoneController.text = rsp['data'][0]['phone'].toString();
              if (rsp['data'][0]['state'].toString() == "") {
                state = null;
              } else {
                state = rsp['data'][0]['state'].toString();
              }
              gststatus = rsp['data'][0]['gst_status'].toString();
              emailController.text = rsp['data'][0]['email'].toString();
              cityController.text = rsp['data'][0]['city'].toString();
              pinCodeController.text = rsp['data'][0]['pin'].toString();
              landlineController.text = rsp['data'][0]['landline'].toString();
              addressController.text = rsp['data'][0]['address'].toString();
              panController.text = rsp['data'][0]['firm_pan'].toString();
              TdsController.text = rsp['data'][0]['firm_tan'].toString();
              if (rsp['data'][0]['gst_date'].toString() != '1970-01-01') {
                gstdateController.text = rsp['data'][0]['gst_date'].toString();
              }
              gstnoController.text = rsp['data'][0]['gst'].toString();
              authsignatoryController.text =
                  rsp['data'][0]['auth_sig'].toString();
              authsignatorydesigController.text =
                  rsp['data'][0]['desig'].toString();
              contactpersonController.text =
                  rsp['data'][0]['firm_person'].toString();
              additionalinfoController.text = rsp['data'][0]['comm'].toString();
            });
          } else {
            var userdetails = SharedPreferenceSingleton.sharedPreferences;
            setState(() {
              userdetails.setString(
                  "companies", rsp['data'][0]['name'].toString());
            });
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: Dashboard()));
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
      setState(() {
        showloader = false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  void addfirm() async {
    setState(() {
      showloader = true;
      iseditclicked = false;
    });
    try {
      var rsp = await apiurl("/member/process", "firm.php", {
        if (widget.from == 'settings') "type": "update" else "type": "add",
        if (widget.from == 'settings') "pid": pid,
        "firm_state": state.toString(),
        "firm_name": companyController.text.toString(),
        "firm_email": emailController.text.toString(),
        "firm_contact": phoneController.text.toString(),
        "firm_address": addressController.text.toString(),
        "firm_city": cityController.text.toString(),
        "firm_pin": pinCodeController.text.toString(),
        "gst_status": gststatus.toString(),
        "gst": gstnoController.text.toString(),
        "upi_id": upiidController.text.toString(),
        "firm_pan": panController.text.toString(),
        "firm_tan": TdsController.text.toString(),
        "firm_cin": "",
        "auth_sig": authsignatoryController.text.toString(),
        "desig": authsignatorydesigController.text.toString(),
        "firm_person": contactpersonController.text.toString(),
        "certify": additionalinfoController.text.toString(),
        if (widget.from != 'settings')
          "gst_date": gstdateController.text.toString(),
      });
      debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          showPrintedMessage(context, "Success", "Updated Successfully",
              Colors.white, Colors.green, Icons.info, true, "top");
          if (widget.from == 'settings') {
            setState(() {
              person = "";
              firmname = "";
              address = "";
              phone = "";
              email = "";
              getdata();
              companyController.clear();
              upiidController.clear();
              phoneController.clear();
              state = null;
              gststatus = null;
              emailController.clear();
              cityController.clear();
              pinCodeController.clear();
              landlineController.clear();
              addressController.clear();
              panController.clear();
              TdsController.clear();
              gstdateController.clear();
              gstnoController.clear();
              authsignatoryController.clear();
              authsignatorydesigController.clear();
              contactpersonController.clear();
              additionalinfoController.clear();
            });
          } else {
            getdata();
          }
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
          });
          showPrintedMessage(context, "Error", rsp['error'].toString(),
              Colors.white, Colors.redAccent, Icons.info, true, "bottom");
          setState(() {
            iseditclicked = true;
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

  Future<void> logoutapi() async {
    String token = '';
    var userdetails = SharedPreferenceSingleton.sharedPreferences;
    setState(() {
      token = userdetails.getString("utoken").toString();
    });
    try {
      var rsp = await apiurl("/process", "logout.php", {"_req_token": token});
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        var userdetails = SharedPreferenceSingleton.sharedPreferences;
        setState(() {
          userdetails.clear();
          Navigator.popUntil(context, (_) => !Navigator.canPop(context));
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) => Login()));
        });
        if (rsp['status'].toString() == "true") {
          setState(() {});
        } else {
          //  showPrintedMessage(context, "Error", 'Failed to logout', Colors.white,Colors.red, Icons.info, true, "bottom");

        }
      }
    } catch (error) {
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      var userdetails = SharedPreferenceSingleton.sharedPreferences;
      setState(() {
        userdetails.clear();
        Navigator.popUntil(context, (_) => !Navigator.canPop(context));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => Login()));
      });
    }
  }

  void LogOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Log Out ?"),
              content: Text("Are you sure you want to logout ?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No"),
                ),
                TextButton(
                  onPressed: () async {
                    logoutapi();
                  },
                  child: Text("Yes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.from == 'settings') {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: Dashboard()));
        }
        return false;
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
            bottomNavigationBar: iseditclicked == true
                ? Container(
                    margin: EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width,
                    child: RaisedButton(
                      color: AppBarColor.withOpacity(0.9),
                      splashColor: AppBarColor.withOpacity(0.9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () async {
                        bool response = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: Text(
                                        "Update",
                                        style: TextStyle(
                                            color: secondarycolor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      content: Text(
                                        "Do you want to update the details?",
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: Text(
                                            "Cancel",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      secondarycolor)),
                                          child: Text(
                                            "Yes, Update",
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ) ??
                            false;
                        if (!response) return;
                        if (companyController.text.isNotEmpty &&
                            phoneController.text.isNotEmpty &&
                            state != null &&
                            gststatus != null) {
                          addfirm();
                        } else {
                          showPrintedMessage(
                              context,
                              "Alert",
                              "Please fill all required fields to submit",
                              Colors.white,
                              Colors.redAccent,
                              Icons.info,
                              true,
                              "top");
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.from == 'settings')
                              Text(
                                'Update',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              )
                            else
                              Text(
                                'Save',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              )
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            appBar: iseditclicked == true
                ? AppBar(
                    bottom: TabBar(
                        indicatorColor: Colors.blue[200],
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                        unselectedLabelStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.white.withOpacity(0.5)),
                        tabs: const [
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Business",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Address",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "GST",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Other",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ]),
                    leading: widget.from == 'settings'
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                iseditclicked = false;
                              });
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : const SizedBox(),
                    backgroundColor: AppBarColor,
                    title: widget.from == 'settings'
                        ? Text(
                            'Edit Details',
                            style: GoogleFonts.poppins(fontSize: 15),
                          )
                        : Text('Add Details',
                            style: GoogleFonts.poppins(fontSize: 15)),
                    actions: [
                      if (widget.from != 'settings')
                        IconButton(
                          onPressed: () {
                            LogOut(context);
                          },
                          icon: const Icon(Icons.logout),
                        ),
                    ],
                  )
                : AppBar(
                    toolbarHeight: 0,
                    elevation: 0,
                  ),
            backgroundColor: Colors.white,
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  if (iseditclicked == false)
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
                                    const Icon(
                                      Icons.circle,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Account Details',
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
                          height: MediaQuery.of(context).size.height - 140,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: showloader == true
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 0.7,
                                  ),
                                )
                              : SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  child: Column(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: AppBarColor.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8, bottom: 8),
                                          child: Column(
                                            children: [
                                              /* Row(
                                        children: [
                                          Container(
                                            width: 130,
                                            alignment: Alignment.centerRight,
      
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 2),
                                              child: Text("Person Name", style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1
                                              ),),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width-140,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 0, top: 5, right: 8, bottom: 2),
                                              child: Text(person, style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1
                                              ),),
                                            ),
                                          )
                                        ],
                                      ),*/

                                              ShowDetailsWidget(
                                                label: "Firm Name",
                                                address: firmname,
                                              ),
                                              const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Divider(height: 0)),
                                              ShowDetailsWidget(
                                                label: "Address",
                                                address: address,
                                              ),
                                              const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Divider(height: 0)),
                                              ShowDetailsWidget(
                                                label: "Phone",
                                                address: phone,
                                              ),
                                              const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Divider(height: 0)),
                                              ShowDetailsWidget(
                                                label: "Email",
                                                address: email,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: RaisedButton(
                                                elevation: 0,
                                                color: Colors.green,
                                                onPressed: () {
                                                  setState(() {
                                                    iseditclicked = true;
                                                  });
                                                },
                                                child: Text(
                                                  'Edit',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                        )
                      ],
                    ),
                  if (iseditclicked == true)
                    TabBarView(children: [
                      ListView(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: new InputDecoration(
                                    isDense: true, labelText: "Firm Name *",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: companyController,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  decoration: new InputDecoration(
                                    isDense: true,
                                    labelText: "Contact number *",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: phoneController,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border:
                                    Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    child: DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      elevation: 0,
                                      focusColor: Colors.transparent,
                                      value: state,
                                      //elevation: 5,
                                      style: TextStyle(color: AppBarColor),
                                      iconEnabledColor: AppBarColor,
                                      items: stateslist?.map((item) {
                                            return new DropdownMenuItem(
                                              child: new Text(
                                                item['state_name'],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: AppBarColor),
                                              ),
                                              value:
                                                  item['state_name'].toString(),
                                            );
                                          })?.toList() ??
                                          [],
                                      hint: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "State *",
                                          style: GoogleFonts.poppins(
                                              color: AppBarColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      onChanged: (String? value) {
                                        FocusScope.of(context).requestFocus(
                                            new FocusNode()); //remove focus

                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);

                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        setState(() {
                                          state = value.toString();
                                          //debugPrint(state.toString());
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border:
                                    Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    child: DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      elevation: 0,
                                      focusColor: Colors.transparent,
                                      value: gststatus,
                                      //elevation: 5,
                                      style: TextStyle(color: AppBarColor),
                                      iconEnabledColor: AppBarColor,
                                      items: gststtlist?.map((item) {
                                            return new DropdownMenuItem(
                                              child: new Text(
                                                item['value'],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: AppBarColor),
                                              ),
                                              value: item['value'].toString(),
                                            );
                                          })?.toList() ??
                                          [],
                                      hint: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "GST Registration Status *",
                                          style: GoogleFonts.poppins(
                                              color: AppBarColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      onChanged: (String? value) {
                                        FocusScope.of(context).requestFocus(
                                            new FocusNode()); //remove focus

                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);

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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: new InputDecoration(
                                    isDense: true, labelText: "UPI ID",

                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: upiidController,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //-----------------
                      ListView(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: new InputDecoration(
                                    isDense: true, labelText: "Email ",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: new InputDecoration(
                                    isDense: true, labelText: "City",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: new InputDecoration(
                                    isDense: true, labelText: "Pin Code",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: pinCodeController,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: new InputDecoration(
                                    isDense: true, labelText: "Land Line",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: landlineController,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: new InputDecoration(
                                    isDense: true, labelText: "Address",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                        ],
                      ),
                      ListView(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: new InputDecoration(
                                    isDense: true,
                                    labelText: "Permanent Account Number",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: new InputDecoration(
                                    isDense: true,
                                    labelText: "TDS Account Number",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: TdsController,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                widget.from != 'settings' ? 10 : 20,
                                10,
                                widget.from != 'settings' ? 10 : 20,
                                8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                onTap: () {
                                  _selectDate(context);
                                },
                                readOnly: true,
                                style: GoogleFonts.poppins(
                                  color: AppBarColor,
                                ),
                                decoration: new InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.calendar_month,
                                    color: secondarycolor,
                                    size: 26,
                                  ),
                                  isDense: true,
                                  labelText: "GST Registration Date",
                                  labelStyle:
                                      GoogleFonts.poppins(color: AppBarColor),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: widget.from != 'settings'
                                          ? Colors.blueAccent
                                          : Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: widget.from != 'settings'
                                      ? Colors.white
                                      : Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: widget.from != 'settings'
                                          ? Colors.blueAccent
                                          : Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  //fillColor: Colors.green
                                ),
                                controller: gstdateController,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: new InputDecoration(
                                    isDense: true, labelText: "GST No.",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: gstnoController,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListView(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: new InputDecoration(
                                    isDense: true,
                                    labelText: "Authorised Signatory",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: authsignatoryController,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: new InputDecoration(
                                    isDense: true,
                                    labelText:
                                        "Authorised Signatory Designation",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: authsignatorydesigController,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: new InputDecoration(
                                    isDense: true,
                                    labelText: "Name of contact person",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: contactpersonController,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: new InputDecoration(
                                    isDense: true,
                                    labelText: "Additional Information",
                                    labelStyle:
                                        GoogleFonts.poppins(color: AppBarColor),
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
                                  controller: additionalinfoController,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ]),
                  if (iseditclicked == false)
                    Positioned(
                      bottom: 2,
                      left: 0,
                      right: 0,
                      child: BottomBar(
                        lastscreen: "accountdetails",
                      ),
                    ),
                ],
              ),
            )),
      ),
    );
  }
}

class ShowDetailsWidget extends StatelessWidget {
  const ShowDetailsWidget({
    Key? key,
    required this.address,
    required this.label,
  }) : super(key: key);

  final String address, label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 2),
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 15, letterSpacing: 1),
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 0, top: 0, right: 8, bottom: 2),
            child: Text(
              address,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        )
      ],
    );
  }
}
