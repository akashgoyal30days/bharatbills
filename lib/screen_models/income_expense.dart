import 'dart:convert';
import 'dart:io';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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

import '../main.dart';
import '../toast_messeger.dart';

class InExpScreen extends StatefulWidget {
  @override
  _InExpScreenState createState() => _InExpScreenState();
}

class _InExpScreenState extends State<InExpScreen>
    with SingleTickerProviderStateMixin {
  //--------defining & initialising parameters------------//
  TabController? controller;
  double listViewOffset1 = 0.0;
  double listViewOffset2 = 0.0;
  double listViewOffset3 = 0.0;
  double listViewOffset4 = 0.0;
  late String pdfPath = "";
  String htmldata = "";
  bool inprintermode = false;
  bool showloader = true;
  List purchase = [];
  bool showalertdetail = false;
  String selectedbillno = "";
  String selectedemail = "";
  String selectedbilldate = "";
  String selectedpartyname = "";
  String selectedvalue = "";
  String selectednumber = "";
  String? currentTime;
  DateTime? parseddate;
  TextEditingController editingController = TextEditingController();
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  @override
  void initState() {
    setState(() {
      controller = new TabController(
        length: 3,
        vsync: this,
      );
    });
    super.initState();
    setscreenposition();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "incomeexp");
    //debugPrint(screen.getString("currentscreen").toString());
    getdata();
  }

  void getdata() async {
    try {
      var rsp = await apiurl("/member/process", "purchase.php", {
        "type": "view_all",
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

  void gethtmldata(String billid) async {
    try {
      var rsp = await apiurl("/member/process", "purchase.php",
          {"type": "view", "bill_id": billid});
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            htmldata = rsp['data']['body'].toString();
            inprintermode = true;
            getdirectory();
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
  bool isclicked = false;
  final Dio _dio = Dio();
  Directory? appDocDir;
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

  bool filedownloading = false;
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

  Future getdirectory() async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/purchase/bills');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('in function 1');
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/purchase/bills';
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
        });
        await FlutterHtmlToPdf.convertFromHtmlContent(
            htmldata, dirPath, tstamp + ".pdf");
      } else {
        //debugPrint('in function 2');
        final Directory _appDocNewFolder =
            await _appDocDirFolder.create(recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/purchase/bills';
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
        });
        await FlutterHtmlToPdf.convertFromHtmlContent(
            htmldata, dirPath, tstamp + ".pdf");
      }
    }
  }

  Future<void> shareFile(String number, String filepath) async {
    await WhatsappShare.shareFile(
      text: 'Please find the bill here',
      phone: number,
      filePath: [filepath],
    );
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(htmldata));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
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
    dummySearchList.addAll(purchase);
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if (item['bill_no']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['bill_from_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['bill_from_contact']
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
          final index = dummySearchList.indexWhere(
              (element) => element['bill_no'] == items[i]['bill_no']);
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
      onWillPop: () async => false,
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
                                'Income / Expenses',
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
                    height: 35,
                    width: MediaQuery.of(context).size.width,
                    color: AppBarColor,
                    child: Center(
                      child: TabBar(
                        controller: controller,
                        indicatorColor: CupertinoColors.white,
                        labelColor: CupertinoColors.white,
                        isScrollable: true,
                        unselectedLabelColor: CupertinoColors.white,
                        tabs: [
                          Tab(child: Text('Expense')),
                          Tab(child: Text('Income')),
                          Tab(child: Text('RCM Voucher')),
                        ],
                      ),
                    ),
                  ),
                  if (showloader == false)
                    Container(
                      height: MediaQuery.of(context).size.height - 175,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: TabBarView(
                        controller: controller,
                        children: <Widget>[
                          new Expense(
                              getOffsetMethod: () => listViewOffset1,
                              setOffsetMethod: (offset) =>
                                  this.listViewOffset1 = offset),
                          new Income(
                              getOffsetMethod: () => listViewOffset2,
                              setOffsetMethod: (offset) =>
                                  this.listViewOffset2 = offset),
                          new RcmVoucher(
                              getOffsetMethod: () => listViewOffset3,
                              setOffsetMethod: (offset) =>
                                  this.listViewOffset3 = offset),
                        ],
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
                    lastscreen: "incomeexp",
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef double GetOffsetMethod();
typedef void SetOffsetMethod(double offset);

////----Expense class------///
class Expense extends StatefulWidget {
  Expense({required this.getOffsetMethod, required this.setOffsetMethod});

  final GetOffsetMethod getOffsetMethod;
  final SetOffsetMethod setOffsetMethod;

  @override
  _ExpenseState createState() => new _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  ScrollController? scrollController;
  late String pdfPath = "";
  String htmldata = "";
  bool inprintermode = false;
  bool showloader = true;
  List purchase = [];
  bool showalertdetail = false;
  String selectedbillno = "";
  String selectedemail = "";
  String selectedbilldate = "";
  String selectedpartyname = "";
  String selectedvalue = "";
  String selectednumber = "";
  String? currentTime;
  DateTime? parseddate;
  TextEditingController editingController = TextEditingController();
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
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
    scrollController =
        new ScrollController(initialScrollOffset: widget.getOffsetMethod());
    getdata();
  }

  void getdata() async {
    try {
      var rsp = await apiurl(
          "/member/process", "expense.php", {"type": "view_all", "view": "e"});
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

  void gethtmldata(String billid) async {
    try {
      var rsp = await apiurl("/member/process", "purchase.php",
          {"type": "view", "bill_id": billid});
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            htmldata = rsp['data']['body'].toString();
            inprintermode = true;
            getdirectory();
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
  bool isclicked = false;
  final Dio _dio = Dio();
  Directory? appDocDir;
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

  bool filedownloading = false;
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

  Future getdirectory() async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/purchase/bills');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('in function 1');
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/purchase/bills';
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
        });
        await FlutterHtmlToPdf.convertFromHtmlContent(
            htmldata, dirPath, tstamp + ".pdf");
      } else {
        //debugPrint('in function 2');
        final Directory _appDocNewFolder =
            await _appDocDirFolder.create(recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/purchase/bills';
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
        });
        await FlutterHtmlToPdf.convertFromHtmlContent(
            htmldata, dirPath, tstamp + ".pdf");
      }
    }
  }

  Future<void> shareFile(String number, String filepath) async {
    await WhatsappShare.shareFile(
      text: 'Please find the bill here',
      phone: number,
      filePath: [filepath],
    );
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(htmldata));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
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
    dummySearchList.addAll(purchase);
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if (item['vch_no']
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
              .indexWhere((element) => element['vch_no'] == items[i]['vch_no']);
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
    return WillPopScope(
      onWillPop: () async => false,
      child: new NotificationListener(
        child: Container(
          height: MediaQuery.of(context).size.height - 35,
          width: MediaQuery.of(context).size.width,
          color: purchase.isNotEmpty ? AppBarColor : Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  if (showloader == true)
                    Container(
                      height: MediaQuery.of(context).size.height - 175,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.7,
                        ),
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
                              labelText: "Search using voucher no",
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: "Search using voucher no",
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
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
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
                                          showalertdetail = false;
                                          pdfPath = "";
                                          selectedbillno = "";
                                          selectedbillno = purchase[index]
                                                  ['vch_no']
                                              .toString();
                                          gethtmldata(
                                              purchase[index]['id'].toString());
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Vch No : ",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                          Text(
                                                            purchase[index]
                                                                    ['vch_no']
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
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
                                                                'Amount :',
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
                                                                " ₹" +
                                                                    " " +
                                                                    purchase[index]
                                                                            [
                                                                            'vch_amount']
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
                                                                'Vch Date :',
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
                                                                    purchase[index]
                                                                            [
                                                                            'vch_date']
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
                                                                'Narration :',
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
                                                                            'vch_narration']
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
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
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
                                          showalertdetail = false;
                                          pdfPath = "";
                                          selectedbillno = "";
                                          selectedbillno =
                                              items[index]['vch_no'].toString();
                                          gethtmldata(
                                              items[index]['id'].toString());
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Vch No : ",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                          Text(
                                                            items[index]
                                                                    ['vch_no']
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
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
                                                                'Amount :',
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
                                                                " ₹" +
                                                                    " " +
                                                                    items[index]
                                                                            [
                                                                            'vch_amount']
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
                                                                'Vch Date :',
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
                                                                            'vch_date']
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
                                                                'Narration :',
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
                                                                            'vch_narration']
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
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'No voucher found',
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  if (showloader == false &&
                      items.isNotEmpty &&
                      isbillfound == false)
                    Container(
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
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
                                          showalertdetail = false;
                                          pdfPath = "";
                                          selectedbillno = "";
                                          selectedbillno =
                                              items[index]['vch_no'].toString();
                                          gethtmldata(
                                              items[index]['id'].toString());
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Vch No : ",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                          Text(
                                                            items[index]
                                                                    ['vch_no']
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
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
                                                                'Amount :',
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
                                                                " ₹" +
                                                                    " " +
                                                                    items[index]
                                                                            [
                                                                            'vch_amount']
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
                                                                'Vch Date :',
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
                                                                            'vch_date']
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
                                                                'Narration :',
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
                                                                            'vch_narration']
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
            ],
          ),
        ),
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            widget.setOffsetMethod(notification.metrics.pixels);
          }
          return true;
        },
      ),
    );
  }
}

////----Income class------///
class Income extends StatefulWidget {
  Income({required this.getOffsetMethod, required this.setOffsetMethod});

  final GetOffsetMethod getOffsetMethod;
  final SetOffsetMethod setOffsetMethod;

  @override
  _IncomeState createState() => new _IncomeState();
}

class _IncomeState extends State<Income> {
  ScrollController? scrollController;
  late String pdfPath = "";
  String htmldata = "";
  bool inprintermode = false;
  bool showloader = true;
  List purchase = [];
  bool showalertdetail = false;
  String selectedbillno = "";
  String selectedemail = "";
  String selectedbilldate = "";
  String selectedpartyname = "";
  String selectedvalue = "";
  String selectednumber = "";
  String? currentTime;
  DateTime? parseddate;
  TextEditingController editingController = TextEditingController();
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
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
    scrollController =
        new ScrollController(initialScrollOffset: widget.getOffsetMethod());
    getdata();
  }

  void getdata() async {
    try {
      var rsp = await apiurl(
          "/member/process", "expense.php", {"type": "view_all", "view": "i"});
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

  void gethtmldata(String billid) async {
    try {
      var rsp = await apiurl("/member/process", "purchase.php",
          {"type": "view", "bill_id": billid});
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            htmldata = rsp['data']['body'].toString();
            inprintermode = true;
            getdirectory();
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
  bool isclicked = false;
  final Dio _dio = Dio();
  Directory? appDocDir;
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

  bool filedownloading = false;
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

  Future getdirectory() async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/purchase/bills');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('in function 1');
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/purchase/bills';
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
        });
        await FlutterHtmlToPdf.convertFromHtmlContent(
            htmldata, dirPath, tstamp + ".pdf");
      } else {
        //debugPrint('in function 2');
        final Directory _appDocNewFolder =
            await _appDocDirFolder.create(recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/purchase/bills';
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
        });
        await FlutterHtmlToPdf.convertFromHtmlContent(
            htmldata, dirPath, tstamp + ".pdf");
      }
    }
  }

  Future<void> shareFile(String number, String filepath) async {
    await WhatsappShare.shareFile(
      text: 'Please find the bill here',
      phone: number,
      filePath: [filepath],
    );
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(htmldata));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
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
    dummySearchList.addAll(purchase);
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if (item['vch_no']
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
              .indexWhere((element) => element['vch_no'] == items[i]['vch_no']);
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
    return WillPopScope(
      onWillPop: () async => false,
      child: new NotificationListener(
        child: Container(
          height: MediaQuery.of(context).size.height - 35,
          width: MediaQuery.of(context).size.width,
          color: purchase.isNotEmpty ? AppBarColor : Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  if (showloader == true)
                    Container(
                      height: MediaQuery.of(context).size.height - 175,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.7,
                        ),
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
                              labelText: "Search using voucher no",
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: "Search using voucher no",
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
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
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
                                          showalertdetail = false;
                                          pdfPath = "";
                                          selectedbillno = "";
                                          selectedbillno = purchase[index]
                                                  ['vch_no']
                                              .toString();
                                          gethtmldata(
                                              purchase[index]['id'].toString());
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Vch No : ",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                          Text(
                                                            purchase[index]
                                                                    ['vch_no']
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
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
                                                                'Amount :',
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
                                                                " ₹" +
                                                                    " " +
                                                                    purchase[index]
                                                                            [
                                                                            'vch_amount']
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
                                                                'Vch Date :',
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
                                                                    purchase[index]
                                                                            [
                                                                            'vch_date']
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
                                                                'Narration :',
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
                                                                            'vch_narration']
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
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
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
                                          showalertdetail = false;
                                          pdfPath = "";
                                          selectedbillno = "";
                                          selectedbillno =
                                              items[index]['vch_no'].toString();
                                          gethtmldata(
                                              items[index]['id'].toString());
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Vch No : ",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                          Text(
                                                            items[index]
                                                                    ['vch_no']
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
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
                                                                'Amount :',
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
                                                                " ₹" +
                                                                    " " +
                                                                    items[index]
                                                                            [
                                                                            'vch_amount']
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
                                                                'Vch Date :',
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
                                                                            'vch_date']
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
                                                                'Narration :',
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
                                                                            'vch_narration']
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
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'No voucher found',
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  if (showloader == false &&
                      items.isNotEmpty &&
                      isbillfound == false)
                    Container(
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
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
                                          showalertdetail = false;
                                          pdfPath = "";
                                          selectedbillno = "";
                                          selectedbillno =
                                              items[index]['vch_no'].toString();
                                          gethtmldata(
                                              items[index]['id'].toString());
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Vch No : ",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                          Text(
                                                            items[index]
                                                                    ['vch_no']
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
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
                                                                'Amount :',
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
                                                                " ₹" +
                                                                    " " +
                                                                    items[index]
                                                                            [
                                                                            'vch_amount']
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
                                                                'Vch Date :',
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
                                                                            'vch_date']
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
                                                                'Narration :',
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
                                                                            'vch_narration']
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
            ],
          ),
        ),
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            widget.setOffsetMethod(notification.metrics.pixels);
          }
          return true;
        },
      ),
    );
  }
}

////----RcmVoucher class------///
class RcmVoucher extends StatefulWidget {
  RcmVoucher({required this.getOffsetMethod, required this.setOffsetMethod});

  final GetOffsetMethod getOffsetMethod;
  final SetOffsetMethod setOffsetMethod;

  @override
  _RcmVoucherState createState() => new _RcmVoucherState();
}

class _RcmVoucherState extends State<RcmVoucher> {
  ScrollController? scrollController;
  late String pdfPath = "";
  String htmldata = "";
  bool inprintermode = false;
  bool showloader = true;
  List purchase = [];
  bool showalertdetail = false;
  String selectedbillno = "";
  String selectedemail = "";
  String selectedbilldate = "";
  String selectedpartyname = "";
  String selectedvalue = "";
  String selectednumber = "";
  String? currentTime;
  DateTime? parseddate;
  TextEditingController editingController = TextEditingController();
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
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
    scrollController =
        new ScrollController(initialScrollOffset: widget.getOffsetMethod());
    getdata();
  }

  void getdata() async {
    try {
      var rsp = await apiurl("/member/process", "expense.php", {
        "type": "view_allr",
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

  void gethtmldata(String billid) async {
    try {
      var rsp = await apiurl("/member/process", "purchase.php",
          {"type": "view", "bill_id": billid});
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            htmldata = rsp['data']['body'].toString();
            inprintermode = true;
            getdirectory();
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
  bool isclicked = false;
  final Dio _dio = Dio();
  Directory? appDocDir;
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

  bool filedownloading = false;
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

  Future getdirectory() async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/purchase/bills');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('in function 1');
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/purchase/bills';
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
        });
        await FlutterHtmlToPdf.convertFromHtmlContent(
            htmldata, dirPath, tstamp + ".pdf");
      } else {
        //debugPrint('in function 2');
        final Directory _appDocNewFolder =
            await _appDocDirFolder.create(recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/purchase/bills';
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
        });
        await FlutterHtmlToPdf.convertFromHtmlContent(
            htmldata, dirPath, tstamp + ".pdf");
      }
    }
  }

  Future<void> shareFile(String number, String filepath) async {
    await WhatsappShare.shareFile(
      text: 'Please find the bill here',
      phone: number,
      filePath: [filepath],
    );
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(htmldata));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
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
    dummySearchList.addAll(purchase);
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if (item['vch_no']
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
              .indexWhere((element) => element['vch_no'] == items[i]['vch_no']);
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
    return WillPopScope(
      onWillPop: () async => false,
      child: new NotificationListener(
        child: Container(
          height: MediaQuery.of(context).size.height - 35,
          width: MediaQuery.of(context).size.width,
          color: purchase.isNotEmpty ? AppBarColor : Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  if (showloader == true)
                    Container(
                      height: MediaQuery.of(context).size.height - 175,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.7,
                        ),
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
                              labelText: "Search using voucher no",
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: "Search using voucher no",
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
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
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
                                          showalertdetail = false;
                                          pdfPath = "";
                                          selectedbillno = "";
                                          selectedbillno = purchase[index]
                                                  ['vch_no']
                                              .toString();
                                          gethtmldata(
                                              purchase[index]['id'].toString());
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Vch No : ",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                          Text(
                                                            purchase[index]
                                                                    ['vch_no']
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
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
                                                                'Amount :',
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
                                                                " ₹" +
                                                                    " " +
                                                                    purchase[index]
                                                                            [
                                                                            'vch_amount']
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
                                                                'Vch Date :',
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
                                                                    purchase[index]
                                                                            [
                                                                            'vch_date']
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
                                                                'Supplier :',
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
                                                                            'supplier']
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
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
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
                                          showalertdetail = false;
                                          pdfPath = "";
                                          selectedbillno = "";
                                          selectedbillno =
                                              items[index]['vch_no'].toString();
                                          gethtmldata(
                                              items[index]['id'].toString());
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Vch No : ",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                          Text(
                                                            items[index]
                                                                    ['vch_no']
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
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
                                                                'Amount :',
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
                                                                " ₹" +
                                                                    " " +
                                                                    items[index]
                                                                            [
                                                                            'vch_amount']
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
                                                                'Vch Date :',
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
                                                                            'vch_date']
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
                                                                'Supplier :',
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
                                                                            'supplier']
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
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'No voucher found',
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  if (showloader == false &&
                      items.isNotEmpty &&
                      isbillfound == false)
                    Container(
                      height: showalertdetail == false && purchase.isNotEmpty
                          ? MediaQuery.of(context).size.height - 235
                          : showalertdetail == false && purchase.isEmpty
                              ? MediaQuery.of(context).size.height - 235
                              : 440,
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
                                          showalertdetail = false;
                                          pdfPath = "";
                                          selectedbillno = "";
                                          selectedbillno =
                                              items[index]['vch_no'].toString();
                                          gethtmldata(
                                              items[index]['id'].toString());
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
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Vch No : ",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                          Text(
                                                            items[index]
                                                                    ['vch_no']
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
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
                                                                'Amount :',
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
                                                                " ₹" +
                                                                    " " +
                                                                    items[index]
                                                                            [
                                                                            'vch_amount']
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
                                                                'Vch Date :',
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
                                                                            'vch_date']
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
                                                                'Supplier :',
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
                                                                            'supplier']
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
            ],
          ),
        ),
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            widget.setOffsetMethod(notification.metrics.pixels);
          }
          return true;
        },
      ),
    );
  }
}
