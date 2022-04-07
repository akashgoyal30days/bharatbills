import 'package:bbills/app_constants/reports/reports_screen.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/screen_models/account_details.dart';
import 'package:bbills/screen_models/add_screens/add_stock_transf.dart';
import 'package:bbills/screen_models/all_customer.dart';
import 'package:bbills/screen_models/all_payables.dart';
import 'package:bbills/screen_models/all_product.dart';
import 'package:bbills/screen_models/all_recieveables.dart';
import 'package:bbills/screen_models/all_suppliers.dart';
import 'package:bbills/screen_models/cash_bank_book.dart';
import 'package:bbills/screen_models/category.dart';
import 'package:bbills/screen_models/company_logo.dart';
import 'package:bbills/screen_models/dashboard.dart';
import 'package:bbills/screen_models/delivery_challan.dart';
import 'package:bbills/screen_models/income_expense.dart';
import 'package:bbills/screen_models/list_purchase_return.dart';
import 'package:bbills/screen_models/list_sale_return.dart';
import 'package:bbills/screen_models/payment.dart';
import 'package:bbills/screen_models/purchase.dart';
import 'package:bbills/screen_models/reciept.dart';
import 'package:bbills/screen_models/sale_return.dart';
import 'package:bbills/screen_models/sales.dart';
import 'package:bbills/screen_models/settings.dart';
import 'package:bbills/screen_models/stock_transfer.dart';
import 'package:bbills/screen_models/warehouse.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:popover/popover.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomBar extends StatefulWidget {
  BottomBar({required this.lastscreen});
  final String lastscreen;
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  String? _chosenValue;
  bool issettingclicked = false;

  @override
  void initState() {
    //debugPrint(widget.lastscreen.toString());
    super.initState();
  }

  LogOut_Modal(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        Navigator.pop(context);
        setState(() {});
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
      title: Text("Log Out"),
      content: Text("Are you sure you want to log out ?"),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        decoration: BoxDecoration(
            color: AppBarColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0), topRight: Radius.circular(0))),
        height: 80,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        child: FloatingActionButton(
                          heroTag: null,
                          elevation: 0,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            if (widget.lastscreen != "dashboard") {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: Dashboard()));
                            }
                          },
                          child: Icon(
                            Icons.home,
                            color: AppBarColor,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        'Home',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        child: FloatingActionButton(
                          heroTag: null,
                          elevation: 0,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            showPopover(
                              context: context,
                              transitionDuration:
                                  const Duration(milliseconds: 150),
                              bodyBuilder: (context) => Column(
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      height: 50,
                                      color: MASTER_TITLE_COLOR,
                                      child: Center(
                                          child: Text(
                                        'Masters',
                                        style: GoogleFonts.poppins(
                                            fontSize: 15, color: Colors.white),
                                      )),
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height /
                                        3.2,
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                          itemCount: 1,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return Column(children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 15,
                                                  left: 8,
                                                  right: 8,
                                                  bottom: 2,
                                                ),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3.5,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Builder(builder:
                                                          (BuildContext
                                                              context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            if (widget
                                                                    .lastscreen !=
                                                                "allcustomerscreen") {
                                                              Navigator.of(
                                                                      context)
                                                                  .popUntil(
                                                                      (route) =>
                                                                          route
                                                                              .isFirst);
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .fade,
                                                                      child:
                                                                          AllCustomerScreen()));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6.5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Card(
                                                                  elevation: 5,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            MASTER_BACK,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0),
                                                                            topLeft: Radius.circular(10.0),
                                                                            topRight: Radius.circular(10.0))),
                                                                    child:
                                                                        Center(
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/icons/customer.png',
                                                                        color:
                                                                            MASTER_ICON_COLOR,
                                                                        height:
                                                                            MediaQuery.of(context).size.width /
                                                                                10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  'Customers',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          MENU_TEXT_COLOR),
                                                                ),
                                                                Text(
                                                                  ' ',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              MENU_TEXT_COLOR),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder:
                                                          (BuildContext
                                                              context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            if (widget
                                                                    .lastscreen !=
                                                                "allsupplierscreen") {
                                                              Navigator.of(
                                                                      context)
                                                                  .popUntil(
                                                                      (route) =>
                                                                          route
                                                                              .isFirst);
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .fade,
                                                                      child:
                                                                          AllSupplierScreen()));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6.5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Card(
                                                                  elevation: 5,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            MASTER_BACK,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0),
                                                                            topLeft: Radius.circular(10.0),
                                                                            topRight: Radius.circular(10.0))),
                                                                    child:
                                                                        Center(
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/icons/supplier.png',
                                                                        color:
                                                                            MASTER_ICON_COLOR,
                                                                        height:
                                                                            MediaQuery.of(context).size.width /
                                                                                10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  'Suppliers',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          MENU_TEXT_COLOR),
                                                                ),
                                                                Text(
                                                                  ' ',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              MENU_TEXT_COLOR),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder:
                                                          (BuildContext
                                                              context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            if (widget
                                                                    .lastscreen !=
                                                                "category") {
                                                              Navigator.of(
                                                                      context)
                                                                  .popUntil(
                                                                      (route) =>
                                                                          route
                                                                              .isFirst);
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .fade,
                                                                      child:
                                                                          CategoryScreen()));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6.5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Card(
                                                                  elevation: 5,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            MASTER_BACK,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0),
                                                                            topLeft: Radius.circular(10.0),
                                                                            topRight: Radius.circular(10.0))),
                                                                    child:
                                                                        Center(
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/icons/cat.png',
                                                                        color:
                                                                            TRANS_ICON_COLOR,
                                                                        height:
                                                                            MediaQuery.of(context).size.width /
                                                                                10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  'Product',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          MENU_TEXT_COLOR),
                                                                ),
                                                                Text(
                                                                  'Category',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          MENU_TEXT_COLOR),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder:
                                                          (BuildContext
                                                              context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            if (widget
                                                                    .lastscreen !=
                                                                "products") {
                                                              Navigator.of(
                                                                      context)
                                                                  .popUntil(
                                                                      (route) =>
                                                                          route
                                                                              .isFirst);
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .fade,
                                                                      child:
                                                                          ProductScreen()));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6.5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Card(
                                                                  elevation: 5,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            MASTER_BACK,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0),
                                                                            topLeft: Radius.circular(10.0),
                                                                            topRight: Radius.circular(10.0))),
                                                                    child:
                                                                        Center(
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/icons/products.png',
                                                                        color:
                                                                            MASTER_ICON_COLOR,
                                                                        height:
                                                                            MediaQuery.of(context).size.width /
                                                                                10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  'Products',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          MENU_TEXT_COLOR),
                                                                ),
                                                                Text(
                                                                  ' ',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              MENU_TEXT_COLOR),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder:
                                                          (BuildContext
                                                              context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            if (widget
                                                                    .lastscreen !=
                                                                "cashbankbook") {
                                                              Navigator.of(
                                                                      context)
                                                                  .popUntil(
                                                                      (route) =>
                                                                          route
                                                                              .isFirst);
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .fade,
                                                                      child:
                                                                          CashBankBookScreen()));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6.5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Card(
                                                                  elevation: 5,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            MASTER_BACK,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0),
                                                                            topLeft: Radius.circular(10.0),
                                                                            topRight: Radius.circular(10.0))),
                                                                    child:
                                                                        Center(
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/icons/cash_bank_books.png',
                                                                        color:
                                                                            MASTER_ICON_COLOR,
                                                                        height:
                                                                            MediaQuery.of(context).size.width /
                                                                                10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  'Bank Book',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          MENU_TEXT_COLOR),
                                                                ),
                                                                Text(
                                                                  ' ',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          MENU_TEXT_COLOR),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 2,
                                                  left: 8,
                                                  right: 8,
                                                  bottom: 2,
                                                ),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3.5,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Builder(builder:
                                                          (BuildContext
                                                              context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            if (widget
                                                                    .lastscreen !=
                                                                "warehouse") {
                                                              Navigator.of(
                                                                      context)
                                                                  .popUntil(
                                                                      (route) =>
                                                                          route
                                                                              .isFirst);
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .fade,
                                                                      child:
                                                                          WareHouseScreen()));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6.5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Card(
                                                                  elevation: 5,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            TRANSBACK,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0),
                                                                            topLeft: Radius.circular(10.0),
                                                                            topRight: Radius.circular(10.0))),
                                                                    child:
                                                                        Center(
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/icons/warehouse.png',
                                                                        color:
                                                                            TRANS_ICON_COLOR,
                                                                        height:
                                                                            MediaQuery.of(context).size.width /
                                                                                10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  'Warehouse',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              38,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          MENU_TEXT_COLOR),
                                                                ),
                                                                Text(
                                                                  '',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          MENU_TEXT_COLOR),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder:
                                                          (BuildContext
                                                              context) {
                                                        return GestureDetector(
                                                          onTap: () {},
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6.5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Card(
                                                                  elevation: 0,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0),
                                                                            topLeft: Radius.circular(10.0),
                                                                            topRight: Radius.circular(10.0))),
                                                                    child:
                                                                        Center(
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/icons/purchase.png',
                                                                        color: Colors
                                                                            .white,
                                                                        height:
                                                                            MediaQuery.of(context).size.width /
                                                                                10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  'Debit',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                Text(
                                                                  'Note',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder:
                                                          (BuildContext
                                                              context) {
                                                        return GestureDetector(
                                                          onTap: () {},
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6.5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Card(
                                                                  elevation: 0,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0),
                                                                            topLeft: Radius.circular(10.0),
                                                                            topRight: Radius.circular(10.0))),
                                                                    child:
                                                                        Center(
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/icons/purchase.png',
                                                                        color: Colors
                                                                            .white,
                                                                        height:
                                                                            MediaQuery.of(context).size.width /
                                                                                10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  'Debit',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                Text(
                                                                  'Note',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder:
                                                          (BuildContext
                                                              context) {
                                                        return GestureDetector(
                                                          onTap: () {},
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6.5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Card(
                                                                  elevation: 0,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0),
                                                                            topLeft: Radius.circular(10.0),
                                                                            topRight: Radius.circular(10.0))),
                                                                    child:
                                                                        Center(
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/icons/purchase.png',
                                                                        color: Colors
                                                                            .white,
                                                                        height:
                                                                            MediaQuery.of(context).size.width /
                                                                                10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  'Debit',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                Text(
                                                                  'Note',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder:
                                                          (BuildContext
                                                              context) {
                                                        return GestureDetector(
                                                          onTap: () {},
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6.5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Card(
                                                                  elevation: 0,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        7,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0),
                                                                            topLeft: Radius.circular(10.0),
                                                                            topRight: Radius.circular(10.0))),
                                                                    child:
                                                                        Center(
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/icons/purchase.png',
                                                                        color: Colors
                                                                            .white,
                                                                        height:
                                                                            MediaQuery.of(context).size.width /
                                                                                10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  'Debit',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                Text(
                                                                  'Note',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ]);
                                          }),
                                    ),
                                  )
                                ],
                              ),
                              onPop: () => print('Popover was popped!'),
                              direction: PopoverDirection.bottom,
                              barrierLabel: "Masters",
                              radius: 10,
                              width: MediaQuery.of(context).size.width - 10,
                              height: MediaQuery.of(context).size.height / 2.5,
                              arrowHeight: 5,
                              arrowWidth: 0,
                            );
                          },
                          child: Icon(
                            Icons.person,
                            color: AppBarColor,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        'Masters',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        child: FloatingActionButton(
                          heroTag: null,
                          elevation: 0,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              showPopover(
                                context: context,
                                transitionDuration:
                                    const Duration(milliseconds: 150),
                                bodyBuilder: (context) => Column(
                                  children: [
                                    InkWell(
                                      onTap: () {},
                                      child: Container(
                                        height: 50,
                                        color: TRANS_TITLE_COLOR,
                                        child: Center(
                                            child: Text(
                                          'Transactions',
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.white),
                                        )),
                                      ),
                                    ),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3.2,
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      child: MediaQuery.removePadding(
                                        context: context,
                                        removeTop: true,
                                        child: ListView.builder(
                                            itemCount: 1,
                                            itemBuilder:
                                                (BuildContext context, index) {
                                              return Column(children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 15,
                                                    left: 8,
                                                    right: 8,
                                                    bottom: 2,
                                                  ),
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.9,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Builder(builder:
                                                            (BuildContext
                                                                context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              if (widget
                                                                      .lastscreen !=
                                                                  "salesscreen") {
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
                                                                            SalesScreen()));
                                                              }
                                                            },
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6.5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Card(
                                                                    elevation:
                                                                        5,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              7,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          7,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              TRANSBACK,
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10.0),
                                                                              bottomRight: Radius.circular(10.0),
                                                                              topLeft: Radius.circular(10.0),
                                                                              topRight: Radius.circular(10.0))),
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/sales.png',
                                                                          color:
                                                                              TRANS_ICON_COLOR,
                                                                          height:
                                                                              MediaQuery.of(context).size.width / 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Sale',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                  Text(
                                                                    '',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                        Builder(builder:
                                                            (BuildContext
                                                                context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              if (widget
                                                                      .lastscreen !=
                                                                  "purchasescreen") {
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
                                                                            PurchaseScreen()));
                                                              }
                                                            },
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6.5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Card(
                                                                    elevation:
                                                                        5,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              7,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          7,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              TRANSBACK,
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10.0),
                                                                              bottomRight: Radius.circular(10.0),
                                                                              topLeft: Radius.circular(10.0),
                                                                              topRight: Radius.circular(10.0))),
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/prchse.png',
                                                                          color:
                                                                              TRANS_ICON_COLOR,
                                                                          height:
                                                                              MediaQuery.of(context).size.width / 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Purchase',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                  Text(
                                                                    '',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                        Builder(builder:
                                                            (BuildContext
                                                                context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              if (widget
                                                                      .lastscreen !=
                                                                  "recieptscreen") {
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
                                                                            RecieptScreen()));
                                                              }
                                                            },
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6.5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Card(
                                                                    elevation:
                                                                        5,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              7,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          7,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              TRANSBACK,
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10.0),
                                                                              bottomRight: Radius.circular(10.0),
                                                                              topLeft: Radius.circular(10.0),
                                                                              topRight: Radius.circular(10.0))),
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/reciept.png',
                                                                          color:
                                                                              TRANS_ICON_COLOR,
                                                                          height:
                                                                              MediaQuery.of(context).size.width / 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Receipt',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                  Text(
                                                                    ' ',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                        Builder(builder:
                                                            (BuildContext
                                                                context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              if (widget
                                                                      .lastscreen !=
                                                                  "supplierrecieptscreen") {
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
                                                                            PaymentScreen()));
                                                              }
                                                            },
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6.5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Card(
                                                                    elevation:
                                                                        5,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              7,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          7,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              TRANSBACK,
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10.0),
                                                                              bottomRight: Radius.circular(10.0),
                                                                              topLeft: Radius.circular(10.0),
                                                                              topRight: Radius.circular(10.0))),
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/payment.png',
                                                                          color:
                                                                              TRANS_ICON_COLOR,
                                                                          height:
                                                                              MediaQuery.of(context).size.width / 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Payment',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                  Text(
                                                                    ' ',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                        Builder(builder:
                                                            (BuildContext
                                                                context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              if (widget
                                                                      .lastscreen !=
                                                                  "sreturn") {
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
                                                                            ViewSReturn()));
                                                              }
                                                            },
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6.5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Card(
                                                                    elevation:
                                                                        5,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              7,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          7,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              TRANSBACK,
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10.0),
                                                                              bottomRight: Radius.circular(10.0),
                                                                              topLeft: Radius.circular(10.0),
                                                                              topRight: Radius.circular(10.0))),
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/sreturn.png',
                                                                          color:
                                                                              TRANS_ICON_COLOR,
                                                                          height:
                                                                              MediaQuery.of(context).size.width / 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Sale',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                  Text(
                                                                    'Return',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 2,
                                                    left: 8,
                                                    right: 8,
                                                    bottom: 2,
                                                  ),
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.9,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            40,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Builder(builder:
                                                            (BuildContext
                                                                context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              if (widget
                                                                      .lastscreen !=
                                                                  "preturn") {
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
                                                                            ViewPReturn()));
                                                              }
                                                            },
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6.5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Card(
                                                                    elevation:
                                                                        5,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              7,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          7,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              TRANSBACK,
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10.0),
                                                                              bottomRight: Radius.circular(10.0),
                                                                              topLeft: Radius.circular(10.0),
                                                                              topRight: Radius.circular(10.0))),
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/preturn.png',
                                                                          color:
                                                                              TRANS_ICON_COLOR,
                                                                          height:
                                                                              MediaQuery.of(context).size.width / 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Purchase',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                  Text(
                                                                    'Return',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                        Builder(builder:
                                                            (BuildContext
                                                                context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              if (widget
                                                                      .lastscreen !=
                                                                  "dchalan") {
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
                                                                            DeliveryChalanScreen()));
                                                              }
                                                            },
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6.5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Card(
                                                                    elevation:
                                                                        5,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              7,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          7,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              TRANSBACK,
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10.0),
                                                                              bottomRight: Radius.circular(10.0),
                                                                              topLeft: Radius.circular(10.0),
                                                                              topRight: Radius.circular(10.0))),
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/delivery_challan.png',
                                                                          color:
                                                                              TRANS_ICON_COLOR,
                                                                          height:
                                                                              MediaQuery.of(context).size.width / 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Delivery',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                  Text(
                                                                    'Challan',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                        Builder(builder:
                                                            (BuildContext
                                                                context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              if (widget
                                                                      .lastscreen !=
                                                                  "stocktransf") {
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
                                                                            StockTransferScreen()));
                                                              }
                                                            },
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6.5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Card(
                                                                    elevation:
                                                                        5,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              7,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          7,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              TRANSBACK,
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10.0),
                                                                              bottomRight: Radius.circular(10.0),
                                                                              topLeft: Radius.circular(10.0),
                                                                              topRight: Radius.circular(10.0))),
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/stransfer.png',
                                                                          color:
                                                                              TRANS_ICON_COLOR,
                                                                          height:
                                                                              MediaQuery.of(context).size.width / 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Stock',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                  Text(
                                                                    'Transfer',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color:
                                                                            MENU_TEXT_COLOR),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                        Builder(builder:
                                                            (BuildContext
                                                                context) {
                                                          return GestureDetector(
                                                            onTap: () {},
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6.5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Card(
                                                                    elevation:
                                                                        0,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              7,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          7,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10.0),
                                                                              bottomRight: Radius.circular(10.0),
                                                                              topLeft: Radius.circular(10.0),
                                                                              topRight: Radius.circular(10.0))),
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/purchase.png',
                                                                          color:
                                                                              Colors.white,
                                                                          height:
                                                                              MediaQuery.of(context).size.width / 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Debit',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  Text(
                                                                    'Note',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                        Builder(builder:
                                                            (BuildContext
                                                                context) {
                                                          return GestureDetector(
                                                            onTap: () {},
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6.5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Card(
                                                                    elevation:
                                                                        0,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              7,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          7,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          shape: BoxShape
                                                                              .rectangle,
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10.0),
                                                                              bottomRight: Radius.circular(10.0),
                                                                              topLeft: Radius.circular(10.0),
                                                                              topRight: Radius.circular(10.0))),
                                                                      child:
                                                                          Center(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/purchase.png',
                                                                          color:
                                                                              Colors.white,
                                                                          height:
                                                                              MediaQuery.of(context).size.width / 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Debit',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  Text(
                                                                    'Note',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                37,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ]);
                                            }),
                                      ),
                                    )
                                  ],
                                ),
                                onPop: () => print('Popover was popped!'),
                                direction: PopoverDirection.bottom,
                                barrierLabel: "Transactions",
                                radius: 10,
                                width: MediaQuery.of(context).size.width - 10,
                                height:
                                    MediaQuery.of(context).size.height / 2.5,
                                arrowHeight: 5,
                                arrowWidth: 0,
                              );
                              //isbuttonclicked = true;
                              /*   showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  context: context,
                                  builder: (context) {
                                    return  Container(
                                      height: 600,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          boxShadow: [BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 10.0,
                                          ),],
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(30.0),
                                              topLeft: Radius.circular(30.0),
                                              bottomLeft: Radius.circular(00.0),
                                              bottomRight: Radius.circular(00.0))),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                                color: Colors.white,

                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(30.0),
                                                    topLeft: Radius.circular(30.0),
                                                    bottomLeft: Radius.circular(00.0),
                                                    bottomRight: Radius.circular(00.0))),
                                            child: Center(
                                              child: Container(
                                                width: 100,
                                                child: Divider(
                                                  thickness:3.0,
                                                  color: AppBarColor,

                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: GridView.count(
                                                crossAxisCount: 4,
                                                childAspectRatio: 1.0,
                                                crossAxisSpacing: 5.0,
                                                mainAxisSpacing: 0.2,
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="salesscreen") {
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                        route.isFirst);
                                                        Navigator
                                                            .pushReplacement(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType
                                                                    .fade,
                                                                child: SalesScreen()));
                                                      }
                                                    },
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset('assets/icons/sales.png', height: 45,),
                                                              Text('Sales', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="allcustomerscreen") {
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                        route.isFirst);
                                                        Navigator
                                                            .pushReplacement(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType
                                                                    .fade,
                                                                child: AllCustomerScreen()));
                                                      }
                                                    },
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset('assets/icons/customer.png', height: 45,),
                                                              Text('Customers', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="allsupplierscreen") {
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                        route.isFirst);
                                                        Navigator
                                                            .pushReplacement(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType
                                                                    .fade,
                                                                child: AllSupplierScreen()));
                                                      }
                                                    },
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset('assets/icons/supplier.png', height: 45,),
                                                              Text('Suppliers', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="purchasescreen") {
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                        route.isFirst);
                                                        Navigator
                                                            .pushReplacement(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType
                                                                    .fade,
                                                                child: PurchaseScreen()));
                                                      }
                                                    },
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset('assets/icons/purchase.png', height: 45,),
                                                              Text('Purchase', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="allrecievalbes") {
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                        route.isFirst);
                                                        Navigator
                                                            .pushReplacement(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType
                                                                    .fade,
                                                                child: AllRecvScreen()));
                                                      }
                                                    },
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset('assets/icons/recieveables.png', height: 45,),
                                                              Text('Recieveables', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="allpayscreen") {
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                        route.isFirst);
                                                        Navigator
                                                            .pushReplacement(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType
                                                                    .fade,
                                                                child: AllPayScreen()));
                                                      }
                                                    },
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset('assets/icons/payables.png', height: 45,),
                                                              Text('Payables', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="category") {
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                        route.isFirst);
                                                        Navigator
                                                            .pushReplacement(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType
                                                                    .fade,
                                                                child: CategoryScreen()));
                                                      }
                                                    },
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(Icons.ac_unit_sharp, size: 40,),
                                                              Text('Category', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="reports") {
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                        route.isFirst);
                                                        Navigator
                                                            .pushReplacement(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType
                                                                    .fade,
                                                                child: ReportsScreen()));
                                                      }},
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset('assets/icons/reports.png', height: 45,),
                                                              Text('Reports', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="products") {
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
                                                    },
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset('assets/icons/products.png', height: 45,),
                                                              Text('Products', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                    if(widget.lastscreen!="recieptscreen") {
                                                      Navigator.of(context)
                                                          .popUntil((route) =>
                                                      route.isFirst);
                                                      Navigator
                                                          .pushReplacement(
                                                          context,
                                                          PageTransition(
                                                              type: PageTransitionType
                                                                  .fade,
                                                              child: RecieptScreen()));
                                                    }},
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset('assets/icons/reciept.png', height: 45,),
                                                              Text('Reciept', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  Container(
                                                      height: 80,
                                                      width: 80,
                                                      child: Card(
                                                        elevation: 0,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Image.asset('assets/icons/invoice.png', height: 45,),
                                                            Text('Invoice', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),),
                                                            SizedBox(height: 10,),
                                                          ],
                                                        ),
                                                      )),
                                                  Container(
                                                      height: 80,
                                                      width: 80,
                                                      child: Card(
                                                        elevation: 0,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.ac_unit_sharp, size: 40,),
                                                            Text('Signature', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),),
                                                            SizedBox(height: 10,),
                                                          ],
                                                        ),
                                                      )),
                                                  Container(
                                                      height: 80,
                                                      width: 80,
                                                      child: Card(
                                                        elevation: 0,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.ac_unit_sharp, size: 40,),
                                                            Text('Web Version', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),),
                                                            SizedBox(height: 10,),
                                                          ],
                                                        ),
                                                      )),
                                                  Container(
                                                      height: 80,
                                                      width: 80,
                                                      child: Card(
                                                        elevation: 0,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Image.asset('assets/icons/delivery_challan.png', height: 45,),
                                                            Text('Delivery', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),),
                                                            Text('Challan', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),),
                                                          ],
                                                        ),
                                                      )),

                                                  Container(
                                                      height: 80,
                                                      width: 80,
                                                      child: Card(
                                                        elevation: 0,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.ac_unit_sharp, size: 40,),
                                                            Text('Add Bank', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),),
                                                            SizedBox(height: 10,),
                                                          ],
                                                        ),
                                                      )),
                                                  Container(
                                                      height: 80,
                                                      width: 80,
                                                      child: Card(
                                                        elevation: 0,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.ac_unit_sharp, size: 40,),
                                                            Text('About', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),),
                                                            SizedBox(height: 10,),
                                                          ],
                                                        ),
                                                      )),
                                                  Container(
                                                      height: 80,
                                                      width: 80,
                                                      child: Card(
                                                        elevation: 0,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.ac_unit_sharp, size: 40,),
                                                            Text('Bluetooth', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),),
                                                            Text('Devices', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),)
                                                          ],
                                                        ),
                                                      )),
                                                  GestureDetector(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="cashbankbook") {
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
                                                    },
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset('assets/icons/cash_bank_books.png', height: 45,),
                                                              Text('Cash/', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              Text('Bank Book', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),)
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                      if(widget.lastscreen!="incomeexp") {
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                        route.isFirst);
                                                        Navigator
                                                            .pushReplacement(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType
                                                                    .fade,
                                                                child: InExpScreen()));
                                                      }
                                                    },
                                                    child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: Card(
                                                          elevation: 0,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(Icons.ac_unit_sharp, size: 40,),
                                                              Text('Income/', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),),
                                                              Text('Expense', style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black
                                                              ),)
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                  Container(
                                                      height: 80,
                                                      width: 80,
                                                      child: Card(
                                                        elevation: 0,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.ac_unit_sharp, size: 40,),
                                                            Text('Support/', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),),
                                                            Text('Feedback', style: GoogleFonts.poppins(
                                                                fontSize: 15, color: Colors.black
                                                            ),)
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );*/
                            });
                          },
                          child: Icon(
                            Icons.keyboard_arrow_up_sharp,
                            size: 30,
                            color: AppBarColor,
                          ),
                        ),
                      ),
                      Text(
                        'Transaction',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        child: FloatingActionButton(
                          heroTag: null,
                          elevation: 0,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: Report_Screen()));
                          },
                          child: Icon(
                            Icons.wysiwyg,
                            size: 20,
                            color: AppBarColor,
                          ),
                        ),
                      ),
                      Text(
                        'Reports',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        child: FloatingActionButton(
                          heroTag: null,
                          elevation: 0,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: Settings_Screen()));
                            /*  showSimpleNotification(
                                Container(
                                  height: 50,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(0.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Settings',
                                          style: GoogleFonts.roboto(
                                              fontSize: 18, color: Colors.black
                                          ),),
                                        Builder(builder: (BuildContext context) {
                                          return FlatButton(
                                            onPressed: () {
                                              OverlaySupportEntry.of(context)!
                                                  .dismiss();
                                              setState(() {
                                                issettingclicked = false;
                                              });
                                            },
                                            child: Text(
                                              'Dismiss', style: GoogleFonts.roboto(
                                                fontSize: 15, color: Colors.black
                                            ),),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                autoDismiss: false,
                                slideDismiss: true,
                                slideDismissDirection: DismissDirection.up,
                                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                elevation: 0,
                                subtitle: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                          height: 150,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(0.0),
                                                  bottomRight: Radius.circular(0.0))),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    20, 8, 0, 0),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.circle, size: 15, color: Colors.black,),
                                                    SizedBox(width: 10,),
                                                    Text('Account Settings', style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 120,
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(
                                                      8, 8, 8, 8),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                            if(widget.lastscreen!="accountdetails"){
                                                              Navigator.of(context)
                                                                  .popUntil((route) =>
                                                              route.isFirst);
                                                              Navigator
                                                                  .pushReplacement(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .fade,
                                                                      child: Accnt_Details()));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: AppBarColor.withOpacity(0.9),
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(Icons.settings, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('Account', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                SizedBox(height: 0,),
                                                                Text('Details', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),)
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                            if(widget.lastscreen!="complogo"){
                                                              Navigator.of(context)
                                                                  .popUntil((route) =>
                                                              route.isFirst);
                                                              Navigator
                                                                  .pushReplacement(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType
                                                                          .fade,
                                                                      child: CompLogo()));
                                                            }
                                                          },
                                                          child:  Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: AppBarColor.withOpacity(0.9),
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(Icons.animation, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('Logo', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                Text(' ', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),

                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                          },
                                                          child:  Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: AppBarColor.withOpacity(0.9),
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(Icons.edit, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('Signature', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                Text(' ', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),

                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                          },
                                                          child:  Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: AppBarColor.withOpacity(0.9),
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(Icons.wysiwyg, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('Terms &', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                Text('Conditions', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),

                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                      Container(
                                          height: 270,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(0.0),
                                                  bottomRight: Radius.circular(0.0))),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    20, 4, 0, 0),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.circle, size: 15, color: Colors.black,),
                                                    SizedBox(width: 10,),
                                                    Text('Other Settings', style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 120,
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(
                                                      8, 8, 8, 8),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                          },
                                                          child:  Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: AppBarColor.withOpacity(0.9),
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(CupertinoIcons.doc_append, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('Invoice', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                SizedBox(height: 0,),
                                                                Text('Settings', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),)
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                          },
                                                          child:  Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: AppBarColor.withOpacity(0.9),
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(CupertinoIcons.qrcode, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('QR', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                Text('Code', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),

                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                          },
                                                          child:  Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: AppBarColor.withOpacity(0.9),
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(CupertinoIcons.chat_bubble, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('SMS', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                Text('Template', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),

                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                          },
                                                          child:  Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: AppBarColor.withOpacity(0.9),
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Text('GST', style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('GST API', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                Text('Settings', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),

                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),

                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 120,
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(
                                                      8, 8, 8, 8),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                          },
                                                          child:  Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: AppBarColor.withOpacity(0.9),
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(CupertinoIcons.person_alt, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('User', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                SizedBox(height: 0,),
                                                                Text('Roles', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),)
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                            LogOut_Modal(context);
                                                          },
                                                          child:  Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: AppBarColor.withOpacity(0.9),
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(CupertinoIcons.square_arrow_right, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('Log Out', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                Text(' ', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),

                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                          },
                                                          child:  Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(CupertinoIcons.chat_bubble, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                Text('', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),

                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      Builder(builder: (BuildContext context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            OverlaySupportEntry.of(context)!
                                                                .dismiss();
                                                            setState(() {
                                                              issettingclicked = false;
                                                            });
                                                          },
                                                          child: Container(
                                                            width: 80,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(10.0),
                                                                          bottomRight: Radius.circular(10.0),
                                                                          topLeft: Radius.circular(10.0),
                                                                          topRight: Radius.circular(10.0))),
                                                                  child: Center(child: Icon(CupertinoIcons.chat_bubble, color: Colors.white,)),
                                                                ),
                                                                SizedBox(height: 1,),
                                                                Text('', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),
                                                                Text('', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),),

                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),

                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                      Builder(builder: (BuildContext context) {
                                        return GestureDetector(
                                          onTap:(){
                                            OverlaySupportEntry.of(context)!
                                                .dismiss();
                                            setState(() {
                                              issettingclicked = false;
                                            });
                                          },
                                          child: Container(
                                              height:MediaQuery.of(context).size.height-512.9097,
                                              width:  MediaQuery.of(context).size.width,
                                              color: AppBarColor.withOpacity(0.3)
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                ),
                                background: AppBarColor.withOpacity(0.0),
                                position: NotificationPosition.top,
                              );*/
                          },
                          child: Icon(
                            Icons.settings,
                            size: 20,
                            color: AppBarColor,
                          ),
                        ),
                      ),
                      Text(
                        'Settings',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
