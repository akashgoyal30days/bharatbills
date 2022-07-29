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
import 'add_screens/add_warehouse.dart';
import 'dashboard.dart';
import 'edit_screen/edit_warehouse.dart';

class WareHouseScreen extends StatefulWidget {
  @override
  _WareHouseScreenState createState() => _WareHouseScreenState();
}

class _WareHouseScreenState extends State<WareHouseScreen> {
  bool showloader = true;
  List warelist = [];
  bool showalertdetail = false;

  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setscreenposition();
  }

  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "warehouse");
    //debugPrint(screen.getString("currentscreen").toString());
    getdata();
  }

  String selectedcustid = "";
  //delete function

  void getdata() async {
    try {
      var rsp = await apiurl("/member/process", "warehouse.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            warelist = rsp['data'];
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

  //Downloading section

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
    dummySearchList.addAll(warelist);
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if (item['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['location']
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
        items.add(warelist[int.parse(indexpostion[i].toString())]);
        ////debugPrint(items.toString());
      }
      return;
    } else {
      setState(() {
        isbillfound = true;
        items.clear();
        items.addAll(warelist);
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
            warelist.isNotEmpty ? scaffoldbackground : Colors.white,
        //   bottomNavigationBar: BottomBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: warelist.isNotEmpty ? AppBarColor : Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  ConstAppBar("warehouse_help"),
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
                                'Warehouse',
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
                  if (warelist.isNotEmpty && showloader == false)
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
                              labelText: "Search using location, name",
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: "Search using location, name",
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
                    Container(
                      height: showalertdetail == false && warelist.isNotEmpty
                          ? MediaQuery.of(context).size.height - 200
                          : showalertdetail == false && warelist.isEmpty
                              ? MediaQuery.of(context).size.height - 200
                              : 310,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: warelist.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: warelist.length,
                                  itemBuilder: (BuildContext context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        warelist[index]['name']
                                                            .toString(),
                                                        style:
                                                            GoogleFonts.poppins(
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Trade Name :',
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
                                                                    warelist[index]
                                                                            [
                                                                            'tradename']
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 0,
                                                            bottom: 2,
                                                            right: 8),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Address:',
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
                                                                    warelist[index]
                                                                            [
                                                                            'address']
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 0,
                                                            bottom: 2,
                                                            right: 8),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Pin :',
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
                                                                    warelist[index]
                                                                            [
                                                                            'loc_pin']
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 0,
                                                            bottom: 2,
                                                            right: 8),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                90,
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 70,
                                                                  child: Text(
                                                                    'Location :',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      170,
                                                                  child: Text(
                                                                    " " +
                                                                        warelist[index]['location']
                                                                            .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 50,
                                                            child: TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .popUntil(
                                                                          (route) =>
                                                                              route.isFirst);
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      PageTransition(
                                                                          type: PageTransitionType
                                                                              .fade,
                                                                          child:
                                                                              EditWareHouse(id: warelist[index]['wid'].toString())));
                                                                },
                                                                child: Text(
                                                                    'Edit')),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (index == warelist.length - 1)
                                              Container(
                                                height: 80,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: Colors.white,
                                              ),
                                            if (index != warelist.length - 1)
                                              Padding(
                                                padding: const EdgeInsets.only(
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
                  if (showloader == false &&
                      items.isNotEmpty &&
                      isbillfound == true)
                    Container(
                      height: showalertdetail == false && warelist.isNotEmpty
                          ? MediaQuery.of(context).size.height - 200
                          : showalertdetail == false && warelist.isEmpty
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        items[index]['name']
                                                            .toString(),
                                                        style:
                                                            GoogleFonts.poppins(
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Trade Name :',
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
                                                                            'tradename']
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 0,
                                                            bottom: 2,
                                                            right: 8),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Address:',
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
                                                                            'address']
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 0,
                                                            bottom: 2,
                                                            right: 8),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Pin :',
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
                                                                            'loc_pin']
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 0,
                                                            bottom: 2,
                                                            right: 8),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                90,
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 70,
                                                                  child: Text(
                                                                    'Location :',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      170,
                                                                  child: Text(
                                                                    " " +
                                                                        items[index]['location']
                                                                            .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 50,
                                                            child: TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .popUntil(
                                                                          (route) =>
                                                                              route.isFirst);
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      PageTransition(
                                                                          type: PageTransitionType
                                                                              .fade,
                                                                          child:
                                                                              EditWareHouse(id: items[index]['wid'].toString())));
                                                                },
                                                                child: Text(
                                                                    'Edit')),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (index == warelist.length - 1)
                                              Container(
                                                height: 80,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: Colors.white,
                                              ),
                                            if (index != warelist.length - 1)
                                              Padding(
                                                padding: const EdgeInsets.only(
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
                  if (showloader == false &&
                      items.isEmpty &&
                      isbillfound == false)
                    Container(
                      height: showalertdetail == false && warelist.isNotEmpty
                          ? MediaQuery.of(context).size.height - 200
                          : showalertdetail == false && warelist.isEmpty
                              ? MediaQuery.of(context).size.height - 200
                              : 310,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'No receipt found',
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  if (showloader == false &&
                      items.isNotEmpty &&
                      isbillfound == false)
                    Container(
                      height: showalertdetail == false && warelist.isNotEmpty
                          ? MediaQuery.of(context).size.height - 200
                          : showalertdetail == false && warelist.isEmpty
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        items[index]['name']
                                                            .toString(),
                                                        style:
                                                            GoogleFonts.poppins(
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Trade Name :',
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
                                                                            'tradename']
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 0,
                                                            bottom: 2,
                                                            right: 8),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Address:',
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
                                                                            'address']
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 0,
                                                            bottom: 2,
                                                            right: 8),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Pin :',
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
                                                                            'loc_pin']
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 0,
                                                            bottom: 2,
                                                            right: 8),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                90,
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 70,
                                                                  child: Text(
                                                                    'Location :',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      170,
                                                                  child: Text(
                                                                    " " +
                                                                        items[index]['location']
                                                                            .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 50,
                                                            child: TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .popUntil(
                                                                          (route) =>
                                                                              route.isFirst);
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      PageTransition(
                                                                          type: PageTransitionType
                                                                              .fade,
                                                                          child:
                                                                              EditWareHouse(id: items[index]['wid'].toString())));
                                                                },
                                                                child: Text(
                                                                    'Edit')),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (index == warelist.length - 1)
                                              Container(
                                                height: 80,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: Colors.white,
                                              ),
                                            if (index != warelist.length - 1)
                                              Padding(
                                                padding: const EdgeInsets.only(
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
                ],
              ),
              if (showalertdetail == false)
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: BottomBar(
                    lastscreen: "warehouse",
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
                                  child: AddWareHouse()));
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
