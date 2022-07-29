import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bbills/screen_models/purchase_return.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:dio/dio.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../shared preference singleton.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../main.dart';
import '../toast_messeger.dart';
import 'dashboard.dart';

class ViewPReturn extends StatefulWidget {
  @override
  _ViewPReturnState createState() => _ViewPReturnState();
}

class _ViewPReturnState extends State<ViewPReturn> {
  bool showloader = true;
  List warelist = [];
  bool showalertdetail = false;

  TextEditingController editingController = TextEditingController();
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  @override
  void initState() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    final initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin!
        .initialize(initSettings, onSelectNotification: _onSelectNotification);
    super.initState();
    setscreenposition();
  }

  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "preturn");
    //debugPrint(screen.getString("currentscreen").toString());
    setdates();
  }

  void setdates() {
    var date = new DateTime.now();
    var newDate = new DateTime(date.year, date.month - 1, date.day);
    setState(() {
      selectedtodate = formatter.format(DateTime.now());
      selectedfromdate = formatter.format(newDate);
    });
    getdatawithdate();
  }

  String selectedchallanid = "";
  String selectedchallanno = "";
  bool allwise = true;
  bool isclicked = false;
  final Dio _dio = Dio();
  Directory? appDocDir;
  bool filedownloading = false;
  String? filePath;
  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<bool> _requestPermissions() async {
    var permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
    }

    return permission == PermissionStatus.granted;
  }

  String _progress = "-";
  var oldfname = "";
  String myselcetedfilename = "";
  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Future<void> _onSelectNotification(String json) async {
    final obj = jsonDecode(json);

    if (obj['isSuccess']) {
      if (isclicked == true) {
        OpenFile.open(obj['filePath']);
      }
    } else {
      if (isclicked == true) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('${obj['error']}'),
          ),
        );
      }
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    setState(() {
      filedownloading = false;
    });
    final android = AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description',
        priority: Priority.High, importance: Importance.Max);
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android, iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];
    //debugPrint(json);

    await flutterLocalNotificationsPlugin!.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess
            ? 'File has been downloaded successfully!'
            : 'There was an error while downloading the file.',
        platform,
        payload: json);
  }

  String filepaths = '';

  Future getdirectory(String from) async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/Purchase Return');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('in function 1');
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/Purchase Return';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        var tstamp;
        var newfname;
        var myspath;
        var newext;
        setState(() {
          newext = myselcetedfilename.split(".");
          tstamp = DateTime.now().toString().replaceAll(" ", "");
          tstamp = tstamp.replaceAll("-", "");
          tstamp = tstamp.replaceAll(":", "");
          tstamp = tstamp.replaceAll(".", "");
          newfname = tstamp;
          //debugPrint(myspath.toString());
          filepaths = dirPath + '/' + tstamp + ".pdf";
        });
        await FlutterHtmlToPdf.convertFromHtmlContent(htmldata, dirPath, tstamp)
            .then(
                (v) => [
                      if (from != 'Share')
                        {
                          //      showPrintedMessage(context, "Success", "File Downloading completed, can be found at Downloads/Bharat Bills/Sale Return", Colors.white,Colors.green, Icons.info, false, "top"),
                        },
                      OpenFile.open(filepaths)
                    ],
                onError: (e) => [
                      //debugPrint(e.toString()),
                      if (from != 'Share')
                        {
                          showPrintedMessage(
                              context,
                              "Error",
                              "Failed to download file",
                              Colors.white,
                              Colors.red,
                              Icons.info,
                              true,
                              "top"),
                        }
                    ]);
      } else {
        //debugPrint('in function 2');
        final Directory _appDocNewFolder =
            await _appDocDirFolder.create(recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/Purchase Return';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        var tstamp;
        var newfname;
        var myspath;
        var newext;
        setState(() {
          newext = myselcetedfilename.split(".");
          tstamp = DateTime.now().toString().replaceAll(" ", "");
          tstamp = tstamp.replaceAll("-", "");
          tstamp = tstamp.replaceAll(":", "");
          tstamp = tstamp.replaceAll(".", "");
          newfname = tstamp;
          //debugPrint(myspath.toString());
          filepaths = dirPath + '/' + tstamp + ".pdf";
        });
        await FlutterHtmlToPdf.convertFromHtmlContent(htmldata, dirPath, tstamp)
            .then(
                (v) => [
                      if (from != 'Share')
                        {
                          //      showPrintedMessage(context, "Success", "File Downloading completed, can be found at Downloads/Bharat Bills/Sale Return", Colors.white,Colors.green, Icons.info, false, "top"),
                        },
                      OpenFile.open(filepaths)
                    ],
                onError: (e) => [
                      //debugPrint(e.toString()),
                      if (from != 'Share')
                        {
                          showPrintedMessage(
                              context,
                              "Error",
                              "Failed to download file",
                              Colors.white,
                              Colors.red,
                              Icons.info,
                              true,
                              "top"),
                        }
                    ]);
      }
    }
  }

  Future<void> shareFile(String number) async {
    //debugPrint(filepaths.toString());
    if (filepaths != '') {
      await WhatsappShare.shareFile(
        text: 'Please find the Purchase Return Note here',
        phone: "2345678900",
        filePath: [filepaths],
      );
    } else {
      showPrintedMessage(
          context,
          "Error",
          "Please Save the document before sharing",
          Colors.white,
          Colors.red,
          Icons.info,
          true,
          "top");
    }
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(htmldata));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
  }

  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  void getdata() async {
    setState(() {
      allwise = true;
    });
    try {
      var rsp = await apiurl("/member/process", "preturn.php", {
        "type": "view_alls",
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

  void getdatawithdate() async {
    setState(() {
      allwise = false;
    });
    try {
      var rsp = await apiurl("/member/process", "preturn.php", {
        "type": "view_alls_date",
        "date_from": selectedfromdate.toString(),
        "date_to": selectedtodate.toString()
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          warelist.clear();
          items.clear();
          indexpostion.clear();
          isbillfound = true;
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

  String? selectedfromdate;
  String? selectedtodate;

  //datepicker
  _selectDate(BuildContext context, String from) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (from == "From") {
      if (selected != null)
        setState(() {
          selectedfromdate = formatter.format(selected);
        });
    } else {
      if (selected != null)
        setState(() {
          selectedtodate = formatter.format(selected);
        });
    }
  }

  //delete challan api
  void delete() async {
    try {
      var rsp = await apiurl("/member/process", "preturn.php", {
        "type": "deleteNote",
        "bill_no": selectedchallanid,
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            indexpostion.clear();
            items.clear();
            isbillfound = true;
            editingController.clear();
            if (allwise == true) {
              getdata();
            } else {
              getdatawithdate();
            }
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
            showPrintedMessage(context, "Error", "This challan has data",
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

  bool ishtml = false;
  bool ishtmlloaded = false;

  //view challan
  void viewchallan() async {
    try {
      setState(() {
        showloader = true;
      });
      var rsp = await apiurl("/member/process", "preturn.php", {
        "type": "view_note",
        "bill_no": selectedchallanno,
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            htmldata = rsp['data']['body'].toString();
            ishtml = true;
            // //debugPrint(htmldata.toString());
          });
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
            ishtml = false;
            ishtmlloaded = false;
            showPrintedMessage(context, "Error", "Failed to load challan data",
                Colors.white, Colors.redAccent, Icons.info, true, "bottom");
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
            showPrintedMessage(context, "Error", "This challan has data",
                Colors.white, Colors.redAccent, Icons.info, true, "bottom");
          }
        }
      }
    } catch (error) {
      setState(() {
        showloader = false;
        ishtml = false;
        ishtmlloaded = false;
      });
      setState(() {
        showloader = false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  //Ddelete button alert
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
      content: Text("Do you want to delete this Purchase Return Note?"),
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
      showalertdetail = false;
    });
    indexpostion.clear();
    List dummySearchList = [];
    dummySearchList.addAll(warelist);
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if (item['bill_from_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['pr_no']
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
          final index = dummySearchList.indexWhere((element) =>
              element['bill_from_name'] == items[i]['bill_from_name']);
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

  //challan htmlview controller
  late String pdfPath = "";
  String htmldata = "";

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
        onWillPop: () async {
          setState(() {
            if (ishtml == true) {
              ishtml = false;
              filepaths = "";
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade, child: Dashboard()));
            }
          });
          return false;
        },
        child: ishtml == false
            ? Scaffold(
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
                          ConstAppBar(),
                          Container(
                            height: 35,
                            width: MediaQuery.of(context).size.width,
                            color: AppBarColor,
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 8, 8, 8),
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
                                        'Purchase Return',
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
                                      labelText:
                                          "Search using Purchase Return No, name",
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: "Search using bill no, name",
                                      hintStyle: TextStyle(color: Colors.white),
                                      fillColor: Colors.white,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue, width: 1.0),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25.0)))),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          if (showloader == false)
                            Container(
                              color: AppBarColor,
                              height: 60,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  color: Colors.white,
                                  child: Container(
                                    height: 55,
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.grey.withOpacity(0.2),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.3,
                                            child: TextButton(
                                                onPressed: () {
                                                  _selectDate(context, "From");
                                                },
                                                child: selectedfromdate == null
                                                    ? Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .calendar_today_sharp,
                                                              size: 20,
                                                              color:
                                                                  AppBarColor),
                                                          SizedBox(width: 5),
                                                          Text("From Date *",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .black)),
                                                        ],
                                                      )
                                                    : Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .calendar_today_sharp,
                                                              size: 20,
                                                              color:
                                                                  AppBarColor),
                                                          SizedBox(width: 5),
                                                          Text(
                                                              selectedfromdate
                                                                  .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .black)),
                                                        ],
                                                      ))),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.3,
                                          child: TextButton(
                                              onPressed: () {
                                                _selectDate(context, "To");
                                              },
                                              child: selectedtodate == null
                                                  ? Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_today_sharp,
                                                            size: 20,
                                                            color: AppBarColor),
                                                        SizedBox(width: 5),
                                                        Text("To Date *",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black)),
                                                      ],
                                                    )
                                                  : Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_today_sharp,
                                                            size: 20,
                                                            color: AppBarColor),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            selectedtodate
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black)),
                                                      ],
                                                    )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (showloader == false)
                            Container(
                              color: Colors.white,
                              child: Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 35,
                                      child: RaisedButton(
                                          elevation: 0,
                                          color: Colors.green,
                                          onPressed: () {
                                            setState(() {
                                              showloader = true;
                                            });
                                            getdata();
                                          },
                                          child: Text('View All',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  color: Colors.white))),
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      width: 60,
                                      height: 35,
                                      child: RaisedButton(
                                          elevation: 0,
                                          color: Colors.green,
                                          onPressed: () {
                                            if (selectedfromdate == null ||
                                                selectedtodate == null) {
                                              showPrintedMessage(
                                                  context,
                                                  "Error",
                                                  "Please select from date and to date",
                                                  Colors.white,
                                                  Colors.redAccent,
                                                  Icons.info,
                                                  true,
                                                  "top");
                                            } else {
                                              setState(() {
                                                showloader = true;
                                              });
                                              getdatawithdate();
                                            }
                                          },
                                          child: Text('Go',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  color: Colors.white))),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          if (showloader == false &&
                              items.isEmpty &&
                              isbillfound == true)
                            Container(
                              height: showalertdetail == false &&
                                      warelist.isNotEmpty
                                  ? MediaQuery.of(context).size.height - 295
                                  : showalertdetail == false && warelist.isEmpty
                                      ? MediaQuery.of(context).size.height - 295
                                      : 310,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: warelist.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: warelist.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                FocusScopeNode currentFocus =
                                                    FocusScope.of(context);
                                                if (!currentFocus
                                                    .hasPrimaryFocus) {
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
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8,
                                                                    top: 8,
                                                                    bottom: 2),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width -
                                                                        185,
                                                                    child: Text(
                                                                      warelist[index]
                                                                              [
                                                                              'bill_from_name']
                                                                          .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              16,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 150,
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          setState(
                                                                              () {
                                                                            selectedchallanno =
                                                                                warelist[index]['pr_no'].toString();
                                                                            ishtmlloaded =
                                                                                false;
                                                                          });

                                                                          viewchallan();
                                                                        },
                                                                        child: Text('View Note', style: TextStyle(color: Colors.blue))),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                        'Purchase Return No. :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            warelist[index]['pr_no'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                        'Purchase Return Date :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            warelist[index]['sr_date'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                      Container(
                                                                        width:
                                                                            80,
                                                                        child:
                                                                            Text(
                                                                          'Address:',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 13,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        width: MediaQuery.of(context).size.width -
                                                                            120,
                                                                        child:
                                                                            Text(
                                                                          " " +
                                                                              warelist[index]['bill_from_address'].toString(),
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 13,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                  Container(
                                                                    width: 170,
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              70,
                                                                          child:
                                                                              Text(
                                                                            'Contact :',
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 13,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              Text(
                                                                            " " +
                                                                                warelist[index]['bill_from_contact'].toString(),
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 13,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 80,
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          setState(
                                                                              () {
                                                                            selectedchallanid =
                                                                                warelist[index]['pr_id'].toString();
                                                                          });
                                                                          showAlertDialog(
                                                                              context);
                                                                        },
                                                                        child: Text('Delete', style: TextStyle(color: Colors.red))),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (index ==
                                                        warelist.length - 1)
                                                      Container(
                                                        height: 80,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color: Colors.white,
                                                      ),
                                                    if (index !=
                                                        warelist.length - 1)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 50,
                                                                right: 50),
                                                        child: Divider(
                                                          color:
                                                              Colors.blueAccent,
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
                              height: showalertdetail == false &&
                                      warelist.isNotEmpty
                                  ? MediaQuery.of(context).size.height - 295
                                  : showalertdetail == false && warelist.isEmpty
                                      ? MediaQuery.of(context).size.height - 295
                                      : 310,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: items.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: warelist.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                FocusScopeNode currentFocus =
                                                    FocusScope.of(context);
                                                if (!currentFocus
                                                    .hasPrimaryFocus) {
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
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8,
                                                                    top: 8,
                                                                    bottom: 2),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width -
                                                                        185,
                                                                    child: Text(
                                                                      items[index]
                                                                              [
                                                                              'bill_from_name']
                                                                          .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              16,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 150,
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          setState(
                                                                              () {
                                                                            selectedchallanno =
                                                                                items[index]['pr_no'].toString();
                                                                            ishtmlloaded =
                                                                                false;
                                                                          });

                                                                          viewchallan();
                                                                        },
                                                                        child: Text('View Note', style: TextStyle(color: Colors.blue))),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                        'Purchase Return No. :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['pr_no'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                        'Purchase Return Date :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['sr_date'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                      Container(
                                                                        width:
                                                                            80,
                                                                        child:
                                                                            Text(
                                                                          'Address:',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 13,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        width: MediaQuery.of(context).size.width -
                                                                            120,
                                                                        child:
                                                                            Text(
                                                                          " " +
                                                                              items[index]['bill_from_address'].toString(),
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 13,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                  Container(
                                                                    width: 170,
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              70,
                                                                          child:
                                                                              Text(
                                                                            'Contact :',
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 13,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              Text(
                                                                            " " +
                                                                                items[index]['bill_from_contact'].toString(),
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 13,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 80,
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          setState(
                                                                              () {
                                                                            selectedchallanid =
                                                                                items[index]['pr_id'].toString();
                                                                          });
                                                                          showAlertDialog(
                                                                              context);
                                                                        },
                                                                        child: Text('Delete', style: TextStyle(color: Colors.red))),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (index ==
                                                        items.length - 1)
                                                      Container(
                                                        height: 80,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color: Colors.white,
                                                      ),
                                                    if (index !=
                                                        items.length - 1)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 50,
                                                                right: 50),
                                                        child: Divider(
                                                          color:
                                                              Colors.blueAccent,
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
                              height: showalertdetail == false &&
                                      warelist.isNotEmpty
                                  ? MediaQuery.of(context).size.height - 295
                                  : showalertdetail == false && warelist.isEmpty
                                      ? MediaQuery.of(context).size.height - 295
                                      : 310,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  'No challan found',
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, color: Colors.black),
                                ),
                              ),
                            ),
                          if (showloader == false &&
                              items.isNotEmpty &&
                              isbillfound == false)
                            Container(
                              height: showalertdetail == false &&
                                      warelist.isNotEmpty
                                  ? MediaQuery.of(context).size.height - 295
                                  : showalertdetail == false && warelist.isEmpty
                                      ? MediaQuery.of(context).size.height - 295
                                      : 310,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: items.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: warelist.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                FocusScopeNode currentFocus =
                                                    FocusScope.of(context);
                                                if (!currentFocus
                                                    .hasPrimaryFocus) {
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
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8,
                                                                    top: 8,
                                                                    bottom: 2),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width -
                                                                        185,
                                                                    child: Text(
                                                                      items[index]
                                                                              [
                                                                              'bill_from_name']
                                                                          .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              16,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 150,
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          setState(
                                                                              () {
                                                                            selectedchallanno =
                                                                                items[index]['pr_no'].toString();
                                                                            ishtmlloaded =
                                                                                false;
                                                                          });

                                                                          viewchallan();
                                                                        },
                                                                        child: Text('View Note', style: TextStyle(color: Colors.blue))),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                        'Purchase Return No. :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['pr_no'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                        'Purchase Return Date :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['sr_date'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                      Container(
                                                                        width:
                                                                            80,
                                                                        child:
                                                                            Text(
                                                                          'Address:',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 13,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        width: MediaQuery.of(context).size.width -
                                                                            120,
                                                                        child:
                                                                            Text(
                                                                          " " +
                                                                              items[index]['bill_from_address'].toString(),
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 13,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                                                                  Container(
                                                                    width: 170,
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              70,
                                                                          child:
                                                                              Text(
                                                                            'Contact :',
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 13,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              Text(
                                                                            " " +
                                                                                items[index]['bill_from_contact'].toString(),
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 13,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 80,
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          setState(
                                                                              () {
                                                                            selectedchallanid =
                                                                                items[index]['pr_id'].toString();
                                                                          });
                                                                          showAlertDialog(
                                                                              context);
                                                                        },
                                                                        child: Text('Delete', style: TextStyle(color: Colors.red))),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (index ==
                                                        items.length - 1)
                                                      Container(
                                                        height: 80,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color: Colors.white,
                                                      ),
                                                    if (index !=
                                                        items.length - 1)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 50,
                                                                right: 50),
                                                        child: Divider(
                                                          color:
                                                              Colors.blueAccent,
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
                            lastscreen: "preturn",
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
                                          child: PurchaseReturn()));
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
              )
            : Scaffold(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 8, 8, 8),
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
                                          'PR No. :' + selectedchallanno,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            if (filepaths != '' ||
                                                filepaths != null) {
                                              shareFile('1234567890');
                                            } else {
                                              showPrintedMessage(
                                                  context,
                                                  "Error",
                                                  "Please Download the document before sharing",
                                                  Colors.white,
                                                  Colors.red,
                                                  Icons.info,
                                                  true,
                                                  "top");
                                            }
                                          },
                                          child: Image.asset(
                                            'assets/icons/whatsapp.png',
                                            color: Colors.white,
                                          )),
                                      GestureDetector(
                                          onTap: () {
                                            getdirectory('download');
                                          },
                                          child: Icon(Icons.save,
                                              size: 25, color: Colors.white))
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
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height - 140,
                                width: MediaQuery.of(context).size.width,
                                child: Zoom(
                                  maxZoomWidth: 1800,
                                  maxZoomHeight: 1800,
                                  child: Builder(builder: (context) {
                                    return WebView(
                                        initialUrl: Uri.dataFromString(
                                                '$htmldata',
                                                mimeType: 'text/html')
                                            .toString());
                                  }),
                                ),
                              ))
                        ],
                      )
                    ],
                  ),
                )));
  }
}
