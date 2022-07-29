import '../shared preference singleton.dart';
import 'package:intl/intl.dart';
import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../toast_messeger.dart';
import 'add_screens/add_product.dart';
import 'dashboard.dart';
import 'edit_screen/edit_product.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "products");
    //debugPrint(screen.getString("currentscreen").toString());
    getdata();
  }

  bool showloader = true;
  List products = [];
  bool showalert = false;
  String selecte_cat_did = "";
  String uom1 = "";
  String uom2 = "";
  String selectedname = "";
  String selectedstatus = "";
  String selectedparid = "";
  String srate = "";
  String prate = "";
  String hsn = "";
  String pdct = "";

  String selecteddescription = "";
  String selectedgstper = "";
  String selectedconversionval = "";
  String slectedbullet = "";
  String selectedminlevel = "";
  String selectedmaxlevel = "";
  String selectedreorderlevel = "";
  String selectedopenquant = "";
  String selectedopenamnt = "";

  TextEditingController editingController = TextEditingController();
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');

  void changestatus() async {
    try {
      var rsp = await apiurl("/member/process", "product.php", {
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
            showalert = false;
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

  //delete function
  void delete() async {
    try {
      var rsp = await apiurl("/member/process", "product.php", {
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
            showalert = false;
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
            showPrintedMessage(context, "Error", "This product has data",
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

  String selectedcustid = '';

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
      content: Text("Do you want to delete this product?"),
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

  //search function
  var items = [];
  var indexpostion = [];
  bool isbillfound = true;
  void filterSearchResults(String query) {
    setState(() {
      showalert = false;
    });
    indexpostion.clear();
    List dummySearchList = [];
    dummySearchList.addAll(products);
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if (item['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['cat_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['hsn_code']
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
        items.add(products[int.parse(indexpostion[i].toString())]);
        ////debugPrint(items.toString());
      }
      return;
    } else {
      setState(() {
        isbillfound = true;
        items.clear();
        items.addAll(products);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setscreenposition();
  }

  void getdata() async {
    try {
      var rsp = await apiurl("/member/process", "product.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            products = rsp['data'];
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
            products.isNotEmpty ? scaffoldbackground : Colors.white,
        //   bottomNavigationBar: BottomBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: products.isNotEmpty ? AppBarColor : Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  ConstAppBar("products_help"),
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
                                'Products',
                                style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (products.isNotEmpty && showloader == false)
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
                              labelText: "Search using name, hsn no, category",
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: "Search using name, hsn no, category",
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
                        height: MediaQuery.of(context).size.height - 140,
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
                        height: showalert == false && products.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalert == false && products.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 380,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: products.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: products.length,
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
                                            selecte_cat_did = "";
                                            selectedparid = "";
                                            selectedname = "";
                                            uom1 = "";
                                            uom2 = "";
                                            srate = "";
                                            prate = "";
                                            hsn = "";
                                            pdct = "";
                                            selectedcustid = "";

                                            selecteddescription = "";
                                            selectedgstper = "";
                                            selectedconversionval = "";
                                            slectedbullet = "";
                                            selectedminlevel = "";
                                            selectedmaxlevel = "";
                                            selectedreorderlevel = "";
                                            selectedopenquant = "";
                                            selectedopenamnt = "";

                                            selecteddescription =
                                                products[index]['item_desc']
                                                    .toString();
                                            selectedgstper = products[index]
                                                    ['gst']
                                                .toString();
                                            selectedconversionval =
                                                products[index]['conversion']
                                                    .toString();
                                            slectedbullet = products[index]
                                                    ['rate_on']
                                                .toString();
                                            selectedminlevel = "";
                                            selectedmaxlevel = "";
                                            selectedreorderlevel = "";
                                            selectedopenquant = products[index]
                                                    ['open_quant']
                                                .toString();
                                            selectedopenamnt = products[index]
                                                    ['open_amt']
                                                .toString();

                                            selectedcustid = products[index]
                                                    ['iid']
                                                .toString();
                                            srate = products[index]['rate']
                                                .toString();
                                            prate = products[index]['pur_rate']
                                                .toString();
                                            hsn = products[index]['hsn_code']
                                                .toString();
                                            pdct = products[index]['pr_type']
                                                .toString();
                                            uom1 = products[index]['uom1']
                                                .toString();
                                            uom2 = products[index]['uom2']
                                                .toString();
                                            selecte_cat_did = products[index]
                                                    ['cat_id']
                                                .toString();
                                            selectedparid = products[index]
                                                    ['par_id']
                                                .toString();
                                            selectedname = products[index]
                                                    ['name']
                                                .toString();
                                            if (products[index]['is_active']
                                                    .toString() ==
                                                "1") {
                                              selectedstatus = "Active";
                                            } else {
                                              selectedstatus = "Inctive";
                                            }
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
                                                                products[index]
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
                                                            color: products[index]
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
                                                                  'Category :',
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
                                                                      products[index]
                                                                              [
                                                                              'cat_name']
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
                                                              right: 20),
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
                                                                  'UOM :',
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
                                                                      products[index]
                                                                              [
                                                                              'uom1']
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
                                                                  'GST :',
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
                                                                      products[index]
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
                                                              right: 20),
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
                                                                  'Stock :',
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
                                                                      products[index]
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
                                                                              .w400),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Rate :',
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
                                                                      products[index]
                                                                              [
                                                                              'rate']
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
                                              if (index == products.length - 1)
                                                Container(
                                                  height: 80,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.white,
                                                ),
                                              if (index != products.length - 1)
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
                        height: showalert == false && items.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalert == false && items.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 380,
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
                                            selecte_cat_did = "";
                                            selectedparid = "";
                                            selectedname = "";
                                            uom1 = "";
                                            uom2 = "";
                                            srate = "";
                                            prate = "";
                                            hsn = "";
                                            pdct = "";
                                            selectedcustid = "";

                                            selecteddescription = "";
                                            selectedgstper = "";
                                            selectedconversionval = "";
                                            slectedbullet = "";
                                            selectedminlevel = "";
                                            selectedmaxlevel = "";
                                            selectedreorderlevel = "";
                                            selectedopenquant = "";
                                            selectedopenamnt = "";

                                            selectedcustid =
                                                items[index]['iid'].toString();
                                            srate =
                                                items[index]['rate'].toString();
                                            prate = items[index]['pur_rate']
                                                .toString();
                                            hsn = items[index]['hsn_code']
                                                .toString();
                                            pdct = items[index]['pr_type']
                                                .toString();
                                            uom1 =
                                                items[index]['uom1'].toString();
                                            uom2 =
                                                items[index]['uom2'].toString();
                                            selecte_cat_did = items[index]
                                                    ['cat_id']
                                                .toString();
                                            selectedparid = items[index]
                                                    ['par_id']
                                                .toString();
                                            selectedname =
                                                items[index]['name'].toString();
                                            if (items[index]['is_active']
                                                    .toString() ==
                                                "1") {
                                              selectedstatus = "Active";
                                            } else {
                                              selectedstatus = "Inctive";
                                            }
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
                                                                  'Category :',
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
                                                                              'cat_name']
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
                                                              right: 20),
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
                                                                  'UOM :',
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
                                                                              'uom1']
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
                                                                  'GST :',
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
                                                                              'gst']
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
                                                              right: 20),
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
                                                                  'Stock :',
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
                                                                              'cur_bal']
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
                                                                  'Rate :',
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
                                                                              'rate']
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
                        height: showalert == false && products.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalert == false && products.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 310,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            'No Supplier found',
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
                        height: showalert == false && items.isNotEmpty
                            ? MediaQuery.of(context).size.height - 200
                            : showalert == false && items.isEmpty
                                ? MediaQuery.of(context).size.height - 200
                                : 380,
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
                                            selecte_cat_did = "";
                                            selectedparid = "";
                                            selectedname = "";
                                            uom1 = "";
                                            uom2 = "";
                                            srate = "";
                                            prate = "";
                                            hsn = "";
                                            pdct = "";
                                            selectedcustid = "";

                                            selecteddescription = "";
                                            selectedgstper = "";
                                            selectedconversionval = "";
                                            slectedbullet = "";
                                            selectedminlevel = "";
                                            selectedmaxlevel = "";
                                            selectedreorderlevel = "";
                                            selectedopenquant = "";
                                            selectedopenamnt = "";

                                            selectedcustid =
                                                items[index]['iid'].toString();
                                            srate =
                                                items[index]['rate'].toString();
                                            prate = items[index]['pur_rate']
                                                .toString();
                                            hsn = items[index]['hsn_code']
                                                .toString();
                                            pdct = items[index]['pr_type']
                                                .toString();
                                            uom1 =
                                                items[index]['uom1'].toString();
                                            uom2 =
                                                items[index]['uom2'].toString();
                                            selecte_cat_did = items[index]
                                                    ['cat_id']
                                                .toString();
                                            selectedparid = items[index]
                                                    ['par_id']
                                                .toString();
                                            selectedname =
                                                items[index]['name'].toString();
                                            if (items[index]['is_active']
                                                    .toString() ==
                                                "1") {
                                              selectedstatus = "Active";
                                            } else {
                                              selectedstatus = "Inctive";
                                            }
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
                                                                  'Category :',
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
                                                                              'cat_name']
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
                                                              right: 20),
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
                                                                  'UOM :',
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
                                                                              'uom1']
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
                                                                  'GST :',
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
                                                                              'gst']
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
                                                              right: 20),
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
                                                                  'Stock :',
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
                                                                              'cur_bal']
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
                                                                  'Rate :',
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
                                                                              'rate']
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
                      height: 300,
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
                                    'Product Details',
                                    style: GoogleFonts.poppins(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showalert = false;
                                          selecte_cat_did = "";
                                          selectedcustid = "";
                                          uom1 = "";
                                          uom2 = "";
                                          srate = "";
                                          prate = "";
                                          hsn = "";
                                          pdct = "";
                                          selectedparid = "";
                                          selectedname = "";

                                          selecteddescription = "";
                                          selectedgstper = "";
                                          selectedconversionval = "";
                                          slectedbullet = "";
                                          selectedminlevel = "";
                                          selectedmaxlevel = "";
                                          selectedreorderlevel = "";
                                          selectedopenquant = "";
                                          selectedopenamnt = "";
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'UOM 1 :',
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5.5,
                                        child: Text(
                                          " " + uom1,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'UOM 2 :',
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5.5,
                                        child: Text(
                                          " " + uom2,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, top: 5, bottom: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Sales Rate :',
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5.5,
                                        child: Text(
                                          " " + srate,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Purchase Rate :',
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5.5,
                                        child: Text(
                                          " " + prate,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.black),
                                        )),
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
                                      'Hsn code :',
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
                                          " " + hsn,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.black),
                                        )),
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
                                      'Product :',
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
                                          " " + pdct,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RaisedButton(
                                elevation: 10,
                                color: AppBarColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  'Edit Products',
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
                                          child: EditProduct(
                                            id: selectedcustid.toString(),
                                          )));
                                },
                              ),
                              RaisedButton(
                                elevation: 10,
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  'Delete Product',
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
                    lastscreen: "products",
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
                                  child: AddProduct()));
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
