import 'package:intl/intl.dart';
import '../shared preference singleton.dart';
import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../toast_messeger.dart';
import 'add_screens/add_category.dart';
import 'dashboard.dart';
import 'edit_screen/edit_category.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "category");
    //debugPrint(screen.getString("currentscreen").toString());
    getdata();
  }

  bool showloader = true;
  List purchase = [];
  bool showalert = false;
  String selectedid = "";
  String selecteddescription = "";
  String selectedname = "";
  String selectedparid = "";
  TextEditingController editingController = TextEditingController();
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');

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
      content: Text("Do you want to delete this category?"),
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

  //delete function
  void delete() async {
    try {
      var rsp = await apiurl("/member/process", "category.php", {
        "type": "delete",
        "id": selectedid,
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            showalert = false;
            //purchase.clear();
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

  @override
  void initState() {
    super.initState();
    setscreenposition();
  }

  void getdata() async {
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
            purchase = rsp['data'];
          });
        } else if (rsp['status'].toString() == "false") {
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
    indexpostion.clear();
    List dummySearchList = [];
    dummySearchList.addAll(purchase);
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if (item['name']
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
        for (var i = 0; i < items.length; i++) {
          final index = dummySearchList
              .indexWhere((element) => element['name'] == items[i]['name']);
          indexpostion.add(index);
        }
        ////debugPrint(indexpostion.toString());
      });
      items.clear();
      for (var i = 0; i < indexpostion.length; i++) {
        items.add(purchase[int.parse(indexpostion[i].toString())]);
        ////debugPrint(items.toString());
      }
      return;
    } else {
      setState(() {
        isbillfound = true;
        items.clear();
        items.addAll(purchase);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: Dashboard()));
        });
        return false;
      },
      child: Scaffold(
        backgroundColor:
            purchase.isNotEmpty ? scaffoldbackground : Colors.white,
        //   bottomNavigationBar: BottomBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: purchase.isNotEmpty ? AppBarColor : Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  ConstAppBar("product_category_help"),
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
                                'Category',
                                style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (purchase.isNotEmpty && showloader == false)
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
                              labelText: "Search using name",
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: "Search using name",
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
                  if (showloader == true)
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height - 175,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 0.7,
                          ),
                        ),
                      ),
                    ),
                  if (showloader == false &&
                      items.isEmpty &&
                      isbillfound == true)
                    Expanded(
                      child: Container(
                        height: showalert == false && purchase.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalert == false && purchase.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 451,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: purchase.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: purchase.length,
                                    itemBuilder: (BuildContext context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScopeNode currentFocus =
                                              FocusScope.of(context);
                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                          setState(() {
                                            showalert = true;
                                            selectedid = "";
                                            selectedparid = "";
                                            selectedname = "";
                                            selecteddescription =
                                                purchase[index]['cat_desc']
                                                    .toString();
                                            selectedid = purchase[index]
                                                    ['cat_id']
                                                .toString();
                                            selectedparid = purchase[index]
                                                    ['par_id']
                                                .toString();
                                            selectedname = purchase[index]
                                                    ['name']
                                                .toString();
                                          });
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
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Name : ",
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Text(
                                                              purchase[index]
                                                                      ['name']
                                                                  .toString(),
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
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
                                                                  'Parent Category :',
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
                                                                      purchase[index]
                                                                              [
                                                                              'par_name']
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
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (index == purchase.length - 1)
                                                Container(
                                                  height: 80,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.white,
                                                ),
                                              if (index != purchase.length - 1)
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
                        height: showalert == false && purchase.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalert == false && purchase.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 451,
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
                                            showalert = true;
                                            selectedid = "";
                                            selectedparid = "";
                                            selectedname = "";
                                            selecteddescription = items[index]
                                                    ['cat_desc']
                                                .toString();
                                            selectedid = items[index]['cat_id']
                                                .toString();
                                            selectedparid = items[index]
                                                    ['par_id']
                                                .toString();
                                            selectedname =
                                                items[index]['name'].toString();
                                          });
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
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Name : ",
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Text(
                                                              items[index]
                                                                      ['name']
                                                                  .toString(),
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
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
                                                                  'Parent Category :',
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
                                                                              'par_name']
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
                                                          ],
                                                        ),
                                                      ),
                                                    ),
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
                        height: showalert == false && purchase.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalert == false && purchase.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 451,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            'No category found',
                            style: GoogleFonts.poppins(
                                fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  if (showloader == false &&
                      items.isNotEmpty &&
                      isbillfound == false)
                    Expanded(
                      child: Container(
                        height: showalert == false && purchase.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalert == false && purchase.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 451,
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
                                            showalert = true;
                                            selectedid = "";
                                            selectedparid = "";
                                            selectedname = "";
                                            selecteddescription = items[index]
                                                    ['cat_desc']
                                                .toString();
                                            selectedid = items[index]['cat_id']
                                                .toString();
                                            selectedparid = items[index]
                                                    ['par_id']
                                                .toString();
                                            selectedname =
                                                items[index]['name'].toString();
                                          });
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
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Name : ",
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Text(
                                                              items[index]
                                                                      ['name']
                                                                  .toString(),
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
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
                                                                  'Parent Category :',
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
                                                                              'par_name']
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
                                                          ],
                                                        ),
                                                      ),
                                                    ),
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
                  if (showloader == false && showalert == true)
                    Container(
                      height: 200,
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
                                    'Category Details',
                                    style: GoogleFonts.poppins(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showalert = false;
                                          selectedid = "";
                                          selecteddescription = "";
                                          selectedparid = "";
                                          selectedname = "";
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
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, top: 5, bottom: 2),
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Description :',
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                150,
                                        child: Text(
                                          " " + selecteddescription,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              ],
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
                                color: AppBarColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  'Edit Category',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.fade,
                                          child: EditCategory(
                                            catname: selectedname,
                                            catdisc: selecteddescription,
                                            allparent: purchase,
                                            catid: selectedparid,
                                          )));
                                },
                              ),
                              RaisedButton(
                                elevation: 10,
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  'Delete Category',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, color: Colors.white),
                                ),
                                onPressed: () {
                                  showAlertDialog(context);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                ],
              ),
              if (showalert == false)
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: BottomBar(
                    lastscreen: "category",
                  ),
                ),
              if (showalert == false)
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
                                  child: AddCategory(
                                    allparent: purchase,
                                  )));
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
