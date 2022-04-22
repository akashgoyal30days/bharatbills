import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/screen_models/all_payables.dart';
import 'package:bbills/screen_models/category.dart';
import 'package:bbills/screen_models/dashboard.dart';
import 'package:bbills/screen_models/reports_screen/gst_reports_type_view.dart';
import 'package:bbills/screen_models/reports_screen/miscellaneous_reports.dart';
import 'package:bbills/screen_models/reports_screen/sales_purchase_ledger_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../screen_models/all_recieveables.dart';
import '../ui_constants.dart';

class Report_Screen extends StatefulWidget {
  @override
  _Report_ScreenState createState() => _Report_ScreenState();
}

class _Report_ScreenState extends State<Report_Screen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(context,
            PageTransition(type: PageTransitionType.fade, child: Dashboard()));
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppBarColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade, child: Dashboard()));
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title: Text(
              'Reports',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: HelpButton(helpURL: "reports_help"),
              )
            ],
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 0),
                  child: ExpansionTile(
                    leading: Image.asset(
                      'assets/icons/sreturn.png',
                      color: AppBarColor,
                      height: report_icon_size,
                    ),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    title: Text(
                      "Sales Report",
                      style: GoogleFonts.poppins(
                          fontSize: title_font,
                          color: AppBarColor,
                          fontWeight: FontWeight.w400),
                    ),
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Basic Sales",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/sales.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Basic Sales',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Sales Return",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/sreturn.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Sales Return',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Credit Note",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/cnote.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Credit Note',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Debit Note",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/dnote.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Debit Note',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey.shade500,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 0),
                  child: ExpansionTile(
                    leading: Image.asset(
                      'assets/icons/preturn.png',
                      color: AppBarColor,
                      height: report_icon_size,
                    ),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    title: Text(
                      "Purchase Report",
                      style: GoogleFonts.poppins(
                          fontSize: title_font,
                          color: AppBarColor,
                          fontWeight: FontWeight.w400),
                    ),
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Basic Purchase",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/prchse.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Basic Purchase',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Purchase Return",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/preturn.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Purchase Return',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Purchase Credit Note",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/cnote.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Credit Note',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Purchase Debit Note",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/dnote.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Debit Note',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey.shade500,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 0),
                  child: ExpansionTile(
                    leading: Image.asset(
                      'assets/icons/ldeger.png',
                      color: AppBarColor,
                      height: report_icon_size,
                    ),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    title: Text(
                      "Ledger",
                      style: GoogleFonts.poppins(
                          fontSize: title_font,
                          color: AppBarColor,
                          fontWeight: FontWeight.w400),
                    ),
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Customer Ledger",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/customer.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Customer Ledger',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Supplier Ledger",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/supplier.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Supplier Ledger',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey.shade500,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 0),
                  child: ExpansionTile(
                    leading: Image.asset(
                      'assets/icons/gstrep.png',
                      color: AppBarColor,
                      height: report_icon_size,
                    ),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    title: Text(
                      "GST Reports",
                      style: GoogleFonts.poppins(
                          fontSize: title_font,
                          color: AppBarColor,
                          fontWeight: FontWeight.w400),
                    ),
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: GstRepos(
                                    lastscreen: "GSTR - 1",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/gstrep.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'GSTR - 1',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      /* ListTile(
                          onTap: () { Navigator.of(context)
                              .popUntil((route) =>
                          route.isFirst);
                          Navigator
                              .pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType
                                      .fade,
                                  child: GstRepos(lastscreen: "GSTR - 2",)));},
                          contentPadding:const EdgeInsets.only(left: 70,),
                          leading: Icon(Icons.contacts, size: report_icon_size,),
                          title: Text('GSTR - 2',style: GoogleFonts.poppins(
                              fontSize: title_font, color: AppBarColor,
                              fontWeight: FontWeight.w400
                          ),),
                        ),*/
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: GstRepos(
                                    lastscreen: "GST 3B Summary",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/gstrep.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'GST 3B Summary',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      /* ListTile(
                          onTap: () { Navigator.of(context)
                              .popUntil((route) =>
                          route.isFirst);
                          Navigator
                              .pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType
                                      .fade,
                                  child: GstRepos(lastscreen: "TAX Rates",)));},
                          contentPadding:const EdgeInsets.only(left: 70,),
                          leading: Icon(Icons.contacts, size: report_icon_size,),
                          title: Text('TAX Rates',style: GoogleFonts.poppins(
                              fontSize: title_font, color: AppBarColor,
                              fontWeight: FontWeight.w400
                          ),),
                        ),*/
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey.shade500,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 0),
                  child: ExpansionTile(
                    leading: Image.asset(
                      'assets/icons/stransfer.png',
                      color: AppBarColor,
                      height: report_icon_size,
                    ),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    title: Text(
                      "Stock Report",
                      style: GoogleFonts.poppins(
                          fontSize: title_font,
                          color: AppBarColor,
                          fontWeight: FontWeight.w400),
                    ),
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Opening Stock",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/stransfer.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Opening Stock',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: BasicSales(
                                    lastscreen: "Closing Stock",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/stransfer.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Closing Stock',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      /*ListTile(
                          contentPadding:const EdgeInsets.only(left: 70,),
                          leading: Icon(Icons.contacts, size: report_icon_size,),
                          title: Text('Stock Summary',style: GoogleFonts.poppins(
                              fontSize: title_font, color: AppBarColor,
                              fontWeight: FontWeight.w400
                          ),),
                        ),*/
                      /*  ListTile(
                          contentPadding:const EdgeInsets.only(left: 70,),
                          leading: Icon(Icons.contacts, size: report_icon_size,),
                          title: Text('Negative Stock',style: GoogleFonts.poppins(
                              fontSize: title_font, color: AppBarColor,
                              fontWeight: FontWeight.w400
                          ),),
                        ),*/
                      /* ListTile(
                          contentPadding:const EdgeInsets.only(left: 70,),
                          leading: Icon(Icons.contacts, size: report_icon_size,),
                          title: Text('Current Stock (Location Wise)',style: GoogleFonts.poppins(
                              fontSize: title_font, color: AppBarColor,
                              fontWeight: FontWeight.w400
                          ),),
                        ),*/
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey.shade500,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 0),
                  child: ExpansionTile(
                    leading: Image.asset(
                      'assets/icons/misc.png',
                      color: AppBarColor,
                      height: report_icon_size,
                    ),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    title: Text(
                      "Miscellaneous Reports",
                      style: GoogleFonts.poppins(
                          fontSize: title_font,
                          color: AppBarColor,
                          fontWeight: FontWeight.w400),
                    ),
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: MiscRepos(
                                    lastscreen: "Profit & Loss",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/misc.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Profit & Loss',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: MiscRepos(
                                    lastscreen: "Day Book",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/misc.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Day Book',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: MiscRepos(
                                    lastscreen: "Funds Flow",
                                  )));
                        },
                        contentPadding: const EdgeInsets.only(
                          left: 70,
                        ),
                        leading: Image.asset(
                          'assets/icons/misc.png',
                          color: AppBarColor,
                          height: report_icon_size,
                        ),
                        title: Text(
                          'Funds Flow',
                          style: GoogleFonts.poppins(
                              fontSize: title_font,
                              color: AppBarColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey.shade500,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 0),
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      tileColor: Colors.white,
                      onTap: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: AllRecvScreen()));
                      },
                      leading: Image.asset(
                        'assets/icons/ldeger.png',
                        color: AppBarColor,
                        height: report_icon_size,
                      ),
                      title: Text(
                        'Receiveables',
                        style: GoogleFonts.poppins(
                            fontSize: title_font,
                            color: AppBarColor,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey.shade500,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 0),
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      tileColor: Colors.white,
                      onTap: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: AllPayScreen()));
                      },
                      leading: Image.asset(
                        'assets/icons/ldeger.png',
                        color: AppBarColor,
                        height: report_icon_size,
                      ),
                      title: Text(
                        'Payables',
                        style: GoogleFonts.poppins(
                            fontSize: title_font,
                            color: AppBarColor,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
