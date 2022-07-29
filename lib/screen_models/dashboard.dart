import 'dart:io';

import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/main.dart';
import 'package:bbills/screen_models/account_details.dart';
import 'package:bbills/screen_models/login.dart';
import 'package:bbills/screen_models/payment.dart';
import 'package:bbills/screen_models/reciept.dart';
import 'package:bbills/screen_models/sales.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../toast_messeger.dart';
import 'add_screens/add_s_bill.dart';
import 'all_payables.dart';
import 'all_recieveables.dart';
import 'package:new_version/new_version.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

const List<String> _assetNames = <String>['assets/icons/sales.svg'];

class _DashboardState extends State<Dashboard> {
//scroll controller
  ScrollController _scrollcontroller = new ScrollController();

  late var newVersion = NewVersion();

  late List<_ChartData> data;
  bool ispub = false;
  bool showloader = true;
  String recieve = "";
  String pay = "";
  String reciept = "";
  String payment = "";
  bool shownotif = false;
  bool showsales = false;
  List notifs = [];
  List sales = [];
  int currindexnotif = 0;
  late TrackballBehavior _trackballBehavior;
  @override
  void initState() {
    setscreenposition();
    data = [_ChartData("a", 0, 0)];
    firmdata();
    _trackballBehavior = TrackballBehavior(
        // Enables the trackball
        enable: true,
        tooltipAlignment: ChartAlignment.near,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
        tooltipSettings: InteractiveTooltip(
          enable: true,
          color: Colors.red,
        ));
    newVersion = NewVersion(
        iOSId: 'in30days.bharatbills',
        androidId: 'in30days.bharatbills',
        context: context,
        updateText: "Update Now");
    basicStatusCheck(newVersion);
    super.initState();
  }

  void setpopupcalled() async {
    var oncecalled = await SharedPreferences.getInstance();
    oncecalled.setString("called", "yes");
  }

  basicStatusCheck(NewVersion newVersion) async {
    var oncecalled = await SharedPreferences.getInstance();
    if (oncecalled.getString("called") == null) {
      setpopupcalled();
      newVersion.showAlertIfNecessary();
    }
  }

  void firmdata() async {
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
          setState(() {
            getdata();
          });
        } else if (rsp['status'].toString() == "false") {
          if (rsp['error'].toString() == 'firm_not_found') {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: Accnt_Details(
                      from: "dashboard",
                    )));
          }
          setState(() {});
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            //showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
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

  void setscreenposition() async {
    var userdetails = await SharedPreferences.getInstance();
    var token = userdetails.getString("utoken");
    if (token == null) {
      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.fade, child: Login()));
    }
    var screen = await SharedPreferences.getInstance();
    setState(() {
      screen.setString("currentscreen", "dashboard");
    });
  }

  void getdata() async {
    try {
      var rsp = await apiurl("/member/process", "dashboard.php", {
        "type": "dashboard",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            recieve = rsp['data']['receivables'].toString();
            pay = rsp['data']['payables'].toString();
            reciept = rsp['data']['receipts'].toString();
            payment = rsp['data']['payments'].toString();
            if (rsp['data']['reminders'].length != 0) {
              shownotif = true;
              notifs = rsp['data']['reminders'];
            }
            if (rsp['data']['sales'].length != 0) {
              showsales = true;
              sales = rsp['data']['sales'];
            }
          });
          data.clear();
          for (var i = 0; i < rsp['data']['date'].length; i++) {
            setState(() {
              data.add(_ChartData(
                  rsp['data']['date'][i].toString(),
                  double.parse(rsp['data']['sale'][i].toString()),
                  double.parse(rsp['data']['purchase'][i].toString())));
            });
          }
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
          });
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            //showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
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

  @override
  void dispose() {
    super.dispose();
  }

  void AddNoteApi() async {
    try {
      var rsp = await apiurl("/member/process", "dashboard.php", {
        "type": "addReminder",
        "texts": notesController.text.toString(),
        if (ispub == false) "visib": 'a' else "visib": 'p'
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            notesController.clear();
            ispub = false;
          });
          showPrintedMessage(context, "Success", "Notes Added Successfully",
              Colors.white, Colors.green, Icons.info, true, "bottom");
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: Dashboard()));
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
          });
          showPrintedMessage(context, "Failed", "Failed to add notes",
              Colors.white, Colors.redAccent, Icons.info, true, "bottom");
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            //showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
            Navigator.pushReplacement(context,
                PageTransition(type: PageTransitionType.fade, child: Login()));
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

  //Ddelete button alert
  showAlertDialog(BuildContext context, String id, int index) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        Navigator.pop(context);
        setState(() {
          showloader = true;
        });
        deleteNotes(id, index);
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
      content: Text("Do you want to delete this Note?"),
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

  //add notes
  TextEditingController notesController = TextEditingController();

  ispubCallback(bool value) => ispub = value;

  void AddNotes(BuildContext context) {
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddNotesWidget(ispub,
                callBack: ispubCallback,
                notesController: notesController, submit: () {
              if (notesController.text.isNotEmpty) {
                Navigator.pop(context);
                AddNoteApi();
              } else {
                showPrintedMessage(context, "Error", "Please enter note",
                    Colors.white, Colors.red, Icons.info, true, "top");
              }
            }));
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     String contentText = "Content of Dialog";
    //     return StatefulBuilder(
    //       builder: (context, setState) {
    //         return AlertDialog(
    //           title: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Text("Add Notes"),
    //               Container(
    //                 height: 30,
    //                 child: Row(
    //                   children: [
    //                     Text(
    //                       "Public",
    //                       style: TextStyle(fontSize: 10),
    //                     ),
    //                     CupertinoSwitch(
    //                       value: ispub,
    //                       onChanged: (v) {
    //                         setState(() {
    //                           ispub = v;
    //                         });
    //                       },
    //                     ),
    //                     Text(
    //                       "Private",
    //                       style: TextStyle(fontSize: 10),
    //                     ),
    //                   ],
    //                 ),
    //               )
    //             ],
    //           ),
    //           content: Container(
    //             color: Colors.transparent,
    //             height: 60,
    //             child: Center(
    //               child: TextField(
    //                 minLines: 1,
    //                 maxLines: 5,
    //                 controller: notesController,
    //                 decoration: InputDecoration(
    //                     contentPadding: EdgeInsets.symmetric(horizontal: 10),
    //                     isDense: true,
    //                     hintText: "Enter your notes here",
    //                     hintStyle: TextStyle(color: Colors.grey),
    //                     fillColor: Colors.white,
    //                     floatingLabelBehavior: FloatingLabelBehavior.never,
    //                     border: OutlineInputBorder(
    //                         borderRadius:
    //                             BorderRadius.all(Radius.circular(10.0)))),
    //                 style: TextStyle(color: Colors.black),
    //               ),
    //             ),
    //           ),
    //           actions: <Widget>[
    //             TextButton(
    //               onPressed: () {
    //                 Navigator.pop(context);
    //                 setState(() {
    //                   notesController.clear();
    //                   ispub = false;
    //                 });
    //               },
    //               child: Text("Cancel"),
    //             ),
    //             TextButton(
    //               onPressed: () {
    //                 if (notesController.text.isNotEmpty) {
    //                   Navigator.pop(context);
    //                   AddNoteApi();
    //                 } else {
    //                   showPrintedMessage(context, "Error", "Please enter note",
    //                       Colors.white, Colors.red, Icons.info, true, "top");
    //                 }
    //               },
    //               child: Text("Done"),
    //             ),
    //           ],
    //         );
    //       },
    //     );
    //   },
    // );
  }

  void ExitApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Exit from Bharat Bills"),
              content: Text("Are you sure you want to exit from application ?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    exit(0);
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

  void deleteNotes(String remid, int index) async {
    try {
      var rsp = await apiurl("/member/process", "dashboard.php", {
        "type": "deleteReminder",
        "ids": remid,
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            notifs.removeAt(index);
          });
          showPrintedMessage(context, "Success", "Deleted Successfully",
              Colors.white, Colors.green, Icons.info, true, "top");
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
            showPrintedMessage(context, "Error", "Failed to delete this note",
                Colors.white, Colors.redAccent, Icons.info, true, "top");
          });
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            //showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
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

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () async {
        ExitApp(context);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: scaffoldbackground,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: AppBarColor,
            child: Stack(
              children: [
                Column(
                  children: [
                    ConstAppBar("intro_help"),
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
                                  'Dashboard',
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
                    if (showloader == false)
                      Container(
                        color: Colors.white,
                        child: Container(
                            height: 140,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              stops: [
                                0.9,
                                0.1,
                              ],
                              colors: [
                                AppBarColor,
                                Colors.grey.withOpacity(0.0),
                              ],
                            )),
                            child: Center(
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 2,
                                  itemBuilder: (BuildContext context, index) {
                                    return Container(
                                      height: 120,
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                          child: index == 0
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: IntrinsicHeight(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        '₹',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.green),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        recieve,
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.green),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    'Receiveables',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            VerticalDivider(),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          '₹',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 18,
                                                                              color: Colors.red),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          pay,
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 18,
                                                                              color: Colors.red),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            30),
                                                                    child: Text(
                                                                      'Payables',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 30,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: IntrinsicHeight(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .popUntil((route) =>
                                                                              route.isFirst);
                                                                      Navigator.pushReplacement(
                                                                          context,
                                                                          PageTransition(
                                                                              type: PageTransitionType.fade,
                                                                              child: AllRecvScreen()));
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          'Report',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 15,
                                                                              color: AppBarColor,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        Icon(
                                                                          Icons
                                                                              .arrow_right,
                                                                          size:
                                                                              20,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            VerticalDivider(),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .popUntil((route) =>
                                                                              route.isFirst);
                                                                      Navigator.pushReplacement(
                                                                          context,
                                                                          PageTransition(
                                                                              type: PageTransitionType.fade,
                                                                              child: AllPayScreen()));
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          'Report',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 15,
                                                                              color: AppBarColor,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        Icon(
                                                                          Icons
                                                                              .arrow_right,
                                                                          size:
                                                                              20,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: IntrinsicHeight(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        '₹',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.green),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        reciept,
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.green),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    'Receipts     ',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            VerticalDivider(),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          '₹',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 18,
                                                                              color: Colors.red),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          payment,
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 18,
                                                                              color: Colors.red),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            30),
                                                                    child: Text(
                                                                      'Payments',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 30,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: IntrinsicHeight(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .popUntil((route) =>
                                                                              route.isFirst);
                                                                      Navigator.pushReplacement(
                                                                          context,
                                                                          PageTransition(
                                                                              type: PageTransitionType.fade,
                                                                              child: RecieptScreen()));
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          '  Details',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 15,
                                                                              color: AppBarColor,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        Icon(
                                                                          Icons
                                                                              .arrow_right,
                                                                          size:
                                                                              20,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            VerticalDivider(),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .popUntil((route) =>
                                                                              route.isFirst);
                                                                      Navigator.pushReplacement(
                                                                          context,
                                                                          PageTransition(
                                                                              type: PageTransitionType.fade,
                                                                              child: PaymentScreen()));
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          'Details',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 15,
                                                                              color: AppBarColor,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        Icon(
                                                                          Icons
                                                                              .arrow_right,
                                                                          size:
                                                                              20,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    );
                                  }),
                            )),
                      ),
                    if (showloader == false)
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 280,
                        color: Colors.white,
                        child: ListView(
                          children: [
                            Container(
                              height: 330,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SfCartesianChart(
                                    trackballBehavior: _trackballBehavior,
                                    title: ChartTitle(
                                      text: 'Sale & Purchase Chart',
                                      textStyle: TextStyle(fontSize: 10),
                                    ),
                                    legend: Legend(
                                        isVisible: true,
                                        // Legend will be placed at the left
                                        position: LegendPosition.bottom),
                                    primaryXAxis: CategoryAxis(
                                      majorGridLines: MajorGridLines(width: 0),
                                      //Hide the axis line of x-axis
                                      axisLine: AxisLine(width: 0),
                                    ),
                                    primaryYAxis: CategoryAxis(
                                      majorGridLines: MajorGridLines(width: 0),
                                      //Hide the axis line of x-axis
                                      axisLine: AxisLine(width: 0),
                                    ),
                                    series: <CartesianSeries>[
                                      ColumnSeries<_ChartData, String>(
                                          name: 'Sales',
                                          dataSource: data,
                                          xValueMapper: (_ChartData data, _) =>
                                              data.x,
                                          yValueMapper: (_ChartData data, _) =>
                                              data.y),
                                      ColumnSeries<_ChartData, String>(
                                          name: 'Purchase',
                                          dataSource: data,
                                          xValueMapper: (_ChartData data, _) =>
                                              data.x,
                                          yValueMapper: (_ChartData data, _) =>
                                              data.y1),
                                    ]),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Notes',
                                      style: GoogleFonts.poppins(
                                          fontSize: 15, color: Colors.black),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        AddNotes(context);
                                      },
                                      child: Icon(
                                        Icons.add,
                                        size: 20,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ]),
                            ),
                            if (shownotif == true)
                              Container(
                                //height: 180,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                  child: Card(
                                      elevation: 0,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 155,
                                            child: PageView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: notifs.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              20,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(00),
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 1),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                showAlertDialog(
                                                                    context,
                                                                    notifs[index]
                                                                            [
                                                                            'id']
                                                                        .toString(),
                                                                    index);
                                                              },
                                                              child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child: Icon(
                                                                    Icons
                                                                        .cancel,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .red,
                                                                  )),
                                                            ),
                                                            Container(
                                                              height: 100,
                                                              child: ListView
                                                                  .builder(
                                                                itemCount: 1,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        indx) {
                                                                  return Text(
                                                                    notifs[index]
                                                                            [
                                                                            'reminder']
                                                                        .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Sales',
                                      style: GoogleFonts.poppins(
                                          fontSize: 15, color: Colors.black),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                        Navigator.pushReplacement(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType.fade,
                                            child: AddSBill(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.add,
                                        size: 20,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ]),
                            ),
                            if (showsales == true)
                              Container(
                                height: 300,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListView.builder(
                                      itemCount: sales.length,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).popUntil(
                                                (route) => route.isFirst);
                                            Navigator.pushReplacement(
                                                context,
                                                PageTransition(
                                                    type:
                                                        PageTransitionType.fade,
                                                    child: SalesScreen()));
                                          },
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
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          sales[index][
                                                                  'bill_to_name']
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
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
                                                                  'Bill no :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.7),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                Text(
                                                                  " " +
                                                                      sales[index]
                                                                              [
                                                                              'bill_no']
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.7),
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
                                                                      sales[index]
                                                                              [
                                                                              'bill_value']
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
                                                                      sales[index]
                                                                              [
                                                                              'bill_to_contact']
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
                                                                Text(
                                                                  'Bill Date :',
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
                                                                      sales[index]
                                                                              [
                                                                              'bill_date']
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
                                                  ],
                                                ),
                                              ),
                                              if (index != sales.length - 1)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 50, right: 50),
                                                  child: Divider(
                                                    color: Colors.blueAccent,
                                                    thickness: 0.2,
                                                  ),
                                                ),
                                              if (index == sales.length - 1)
                                                Container(
                                                  height: 80,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.white,
                                                ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            SizedBox(
                              height: 60,
                            )
                          ],
                        ),
                      ),
                  ],
                ),
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: BottomBar(lastscreen: "dashboard"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.y1);

  final String x;
  final double? y;
  final double? y1;
}

class AddNotesWidget extends StatefulWidget {
  const AddNotesWidget(this.ispub,
      {required this.notesController,
      required this.submit,
      required this.callBack,
      Key? key})
      : super(key: key);
  final TextEditingController notesController;
  final Function(bool) callBack;
  final VoidCallback submit;
  final bool ispub;
  @override
  State<AddNotesWidget> createState() => _AddNotesWidgetState();
}

class _AddNotesWidgetState extends State<AddNotesWidget> {
  late bool ispub;
  initState() {
    ispub = widget.ispub;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Add Notes",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                "Public",
              ),
              Switch(
                value: ispub,
                onChanged: (v) {
                  setState(() {
                    widget.callBack(v);
                    ispub = v;
                  });
                },
              ),
              Text(
                "Private",
              ),
            ],
          ),
          SizedBox(height: 10),
          TextField(
            minLines: 10,
            maxLines: 10,
            autofocus: true,
            controller: widget.notesController,
            decoration: InputDecoration(
                isDense: true,
                hintText: "Enter your notes here",
                hintStyle: TextStyle(color: Colors.grey),
                fillColor: Colors.white,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)))),
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                    onPressed: widget.submit,
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
