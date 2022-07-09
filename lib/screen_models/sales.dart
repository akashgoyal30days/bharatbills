import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:dio/dio.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../shared preference singleton.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/api_models/get_file_url_api.dart';
import 'package:bbills/app_constants/api_constants.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_share/whatsapp_share.dart';

import '../main.dart';
import '../toast_messeger.dart';
import 'add_screens/add_s_bill.dart';
import 'dashboard.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late String pdfPath = "";
  bool inprintermode = false;
  bool showloader = true;
  List sales = [];
  bool showalertdetail = false;
  String selectedbillno = "";
  String selectedbillid = "";
  String selectedseries = "";
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
  bool iserror = false;

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
    screen.setString("currentscreen", "salesscreen");
    debugPrint(screen.getString("currentscreen").toString());
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

  String? selectedfromdate;
  String? selectedtodate;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');

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

  void getdata() async {
    setState(() {
      iserror = false;
      allwise = true;
    });

    try {
      var rsp = await apiurl("/member/process", "sale.php", {
        "type": "view_all",
      });
      debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            sales = rsp['data'];
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
        iserror = true;
        showloader = false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      debugPrint(error.toString());
    }
  }

  bool allwise = true;
  void getdatawithdate() async {
    setState(() {
      allwise = false;
    });
    try {
      var rsp = await apiurl("/member/process", "sale.php", {
        "type": "view_all_date",
        "date_from": selectedfromdate.toString(),
        "date_to": selectedtodate.toString()
      });
      debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          sales.clear();
          items.clear();
          indexpostion.clear();
          isbillfound = true;
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            sales = rsp['data'];
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
      debugPrint(error.toString());
    }
  }

  void sendMail() async {
    showPrintedMessage(context, "Please wait", "Sending email..", Colors.white,
        Colors.blue, Icons.info, true, "bottom");
    String newbill = selectedbillno.replaceAll("/", "_");
    try {
      var rsp = await apiurl("/member", "bill_view_buttons.php", {
        "type": "f",
        "bill_num": newbill,
        "email": selectedemail,
        "head": "",
        "body": ""
      });
      debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        if (rsp['status'].toString() == "true") {
          showPrintedMessage(context, "Success", "Email successfully sent",
              Colors.white, Colors.green, Icons.info, true, "bottom");
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
          });
          showPrintedMessage(context, "Error!", rsp['error'].toString(),
              Colors.white, Colors.redAccent, Icons.info, true, "bottom");
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
      debugPrint(error.toString());
    }
  }

  void getFileUrl(bool shownotif, bool isprinter, bool issharing) async {
    setState(() {
      showloader = true;
    });
    var userdetails = SharedPreferenceSingleton.sharedPreferences;
    try {
      var rsp = await fileurlapi("/genbill", "file.php", {
        "api_key": bill_file_api_key,
        "type": "gen",
        "bill": selectedbillno,
        "dt": userdetails.getString("spc").toString(),
      });

      log({
        "api_key": bill_file_api_key,
        "type": "gen",
        "bill": selectedbillno,
        "dt": userdetails.getString("spc").toString(),
      }.toString());
      debugPrint(rsp.toString());
      // log(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            myselcetedfilename = rsp['file'].toString();
            getdirectory(
                rsp['link'].toString(), shownotif, isprinter, issharing);
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
          Colors.redAccent, Icons.info, true, "bottom");
      debugPrint(error.toString());
      setState(() {
        showloader = false;
      });
    }
  }

  void delete_file_from_server() async {
    var userdetails = SharedPreferenceSingleton.sharedPreferences;
    try {
      var rsp = await fileurlapi("/genbill", "file.php", {
        "api_key": bill_file_api_key,
        "type": "del",
        "file": myselcetedfilename,
      });
      debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        if (rsp['status'].toString() == "true") {
          setState(() {});
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
          Colors.redAccent, Icons.info, true, "bottom");
      debugPrint(error.toString());
    }
  }

  //delete challan api
  void delete() async {
    try {
      var rsp = await apiurl("/member/process", "sale.php", {
        "type": "deleteBill",
        "bill_no": selectedbillid,
      });
      debugPrint(rsp.toString());
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
          showPrintedMessage(
              context,
              "Failed",
              rsp['error'].toString().replaceAll('_', " "),
              Colors.white,
              Colors.redAccent,
              Icons.info,
              true,
              "top");
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
            showPrintedMessage(context, "Error", "This bill has data",
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
      debugPrint(error.toString());
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
      content: Text("Do you want to delete this bill?"),
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
    debugPrint(json);

    await flutterLocalNotificationsPlugin!.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess
            ? 'File has been downloaded successfully!'
            : 'There was an error while downloading the file.',
        platform,
        payload: json);
  }

  Future<void> _startDownload(String savePath, String url, bool shownotif,
      bool isprinter, bool issharing) async {
    setState(() {
      isclicked = true;
    });
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };
    try {
      final response = await _dio.download(url, savePath,
          onReceiveProgress: _onReceiveProgress);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      debugPrint('finally');
      delete_file_from_server();
      if (shownotif == true) {
        await _showNotification(result);
      }
      if (isprinter == true) {
        setState(() {
          inprintermode = true;
          pdfPath = savePath;
          OpenFile.open(pdfPath);
        });
      }
      if (issharing == true) {
        setState(() {
          inprintermode = false;
          pdfPath = savePath;
          shareFile(selectednumber, pdfPath);
        });
      }
    }
  }

  Future getdirectory(
      String url, bool shownotification, bool isprinter, bool issharing) async {
    setState(() {
      pdfPath = "";
    });
    debugPrint(url);
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/sales/bills');
      if (await _appDocDirFolder.exists()) {
        debugPrint('in function 1');
        debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/sales/bills';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        debugPrint(filePath.toString());
        final savePath = path.join(dirPath, myselcetedfilename);
        File(savePath.replaceAll(myselcetedfilename, "") + oldfname)
            .delete(recursive: true);
        bool a = await File(savePath).exists();
        debugPrint(a.toString());
        showPrintedMessage(context, "Please wait...", "Downloading file..",
            Colors.white, Colors.redAccent, Icons.info, true, "bottom");
        var ak = url;
        debugPrint("aman" + ak.toString());
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
          myspath = savePath.replaceAll(myselcetedfilename, "");
          oldfname = newfname + "." + newext[1];
          myspath = myspath + newfname + "." + newext[1];

          debugPrint(myspath.toString());
          debugPrint(savePath.toString());
        });
        await _startDownload(
            myspath, url, shownotification, isprinter, issharing);
      } else {
        debugPrint('in function 2');
        final Directory _appDocNewFolder =
            await _appDocDirFolder.create(recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/sales/bills';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        debugPrint(filePath.toString());
        final savePath = path.join(dirPath, myselcetedfilename);
        File(savePath.replaceAll(myselcetedfilename, "") + oldfname)
            .delete(recursive: true);
        bool a = await File(savePath).exists();
        debugPrint(a.toString());
        showPrintedMessage(context, "Please wait...", "Downloading file..",
            Colors.white, Colors.redAccent, Icons.info, true, "bottom");
        var ak = url;
        debugPrint("aman" + ak.toString());
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
          myspath = savePath.replaceAll(myselcetedfilename, "");
          oldfname = newfname + "." + newext[1];
          myspath = myspath + newfname + "." + newext[1];

          debugPrint(myspath.toString());
          debugPrint(savePath.toString());
        });
        await _startDownload(
            myspath, url, shownotification, isprinter, issharing);
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
    dummySearchList.addAll(sales);
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if (item['bill_no']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['bill_to_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['bill_to_contact']
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
        debugPrint(indexpostion.toString());
      });
      items.clear();
      for (var i = 0; i < indexpostion.length; i++) {
        items.add(sales[int.parse(indexpostion[i].toString())]);
        debugPrint(items.toString());
      }
      return;
    } else {
      setState(() {
        isbillfound = true;
        items.clear();
        items.addAll(sales);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return inprintermode == false
        ? WillPopScope(
            onWillPop: () async {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade, child: Dashboard()));

              return false;
            },
            child: Scaffold(
              backgroundColor:
                  sales.isNotEmpty ? scaffoldbackground : Colors.white,
              //   bottomNavigationBar: BottomBar(),
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: sales.isNotEmpty ? AppBarColor : Colors.white,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        ConstAppBar("sale_help"),
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
                                'Sales',
                                style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.white),
                              ),
                              Spacer(),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.fade,
                                          child: AddSBill()));
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor:
                                      MaterialStateProperty.all(secondarycolor),
                                ),
                                icon: Icon(Icons.add),
                                label: Text("Add Sale Bill"),
                              ),
                            ],
                          ),
                        ),
                        if (showloader == true)
                          Container(
                            height: MediaQuery.of(context).size.height - 140,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 0.7),
                            ),
                          ),
                        if (sales.isNotEmpty && showloader == false)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: editingController,
                              onChanged: (v) {
                                filterSearchResults(v.toString());
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  hintText:
                                      "Search using bill no, name, contact",
                                  fillColor: Colors.white,
                                  filled: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  // enabledBorder: OutlineInputBorder(
                                  //   borderSide: BorderSide(
                                  //       color: Colors.white, width: 1.0),
                                  // ),
                                  // focusedBorder: OutlineInputBorder(
                                  //   borderSide: BorderSide(
                                  //       color: Colors.blue, width: 1.0),
                                  // ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: secondarycolor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  )),
                            ),
                          ),
                        if (showloader == false)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width /
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
                                                        color: AppBarColor),
                                                    SizedBox(width: 5),
                                                    Text("From Date *",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black)),
                                                  ],
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("From Date *",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black)),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_today_sharp,
                                                            size: 20,
                                                            color: AppBarColor),
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
                                                    ),
                                                  ],
                                                ))),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.3,
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
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                ],
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("To Date *",
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black)),
                                                  Row(
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
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black)),
                                                    ],
                                                  ),
                                                ],
                                              )),
                                  )
                                ],
                              ),
                            ),
                          ),
                        if (showloader == false)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 100,
                                height: 35,
                                child: RaisedButton(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                              Container(
                                width: 60,
                                margin: EdgeInsets.all(8),
                                height: 35,
                                child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                              ),
                            ],
                          ),
                        if (showloader == false &&
                            items.isEmpty &&
                            isbillfound == true)
                          Expanded(
                            child: Container(
                              height: showalertdetail == false &&
                                      sales.isNotEmpty
                                  ? MediaQuery.of(context).size.height - 295
                                  : showalertdetail == false && sales.isEmpty
                                      ? MediaQuery.of(context).size.height - 295
                                      : 310,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: sales.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: sales.length,
                                          padding: EdgeInsets.zero,
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
                                                setState(() {
                                                  showalertdetail = true;
                                                  pdfPath = "";
                                                  selectedbillno = "";
                                                  selectedbilldate = "";
                                                  selectedemail = "";
                                                  selectedpartyname = "";
                                                  selectedvalue = "";
                                                  selectednumber = "";
                                                  selectedseries = "";
                                                  selectedseries = "";
                                                  selectedbillid = "";
                                                  selectedbillid = sales[index]
                                                          ['bill_id']
                                                      .toString();
                                                  selectedbillno = sales[index]
                                                          ['bill_no']
                                                      .toString();
                                                  selectedbilldate =
                                                      sales[index]['bill_date']
                                                          .toString();
                                                  selectedpartyname =
                                                      sales[index]
                                                              ['bill_to_name']
                                                          .toString();
                                                  selectedvalue = sales[index]
                                                          ['bill_value']
                                                      .toString();
                                                  selectednumber = sales[index]
                                                          ['bill_to_contact']
                                                      .toString();
                                                  selectedemail = sales[index]
                                                          ['bt_email']
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
                                                                const EdgeInsets
                                                                        .only(
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
                                                                        'Bill no :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.grey.withOpacity(0.7),
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            sales[index]['bill_no'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.grey.withOpacity(0.7),
                                                                            fontWeight: FontWeight.w500),
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
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            sales[index]['bill_value'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
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
                                                                        'Contact :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            sales[index]['bill_to_contact'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
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
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            sales[index]['bill_date'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Visibility(
                                                            visible: false,
                                                            child: Row(
                                                              mainAxisAlignment: sales[
                                                                              index]
                                                                          [
                                                                          'form_no'] ==
                                                                      ""
                                                                  ? MainAxisAlignment
                                                                      .end
                                                                  : MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                if (sales[index]
                                                                        [
                                                                        'form_no'] ==
                                                                    "")
                                                                  RaisedButton(
                                                                    onPressed:
                                                                        () {},
                                                                    elevation:
                                                                        0,
                                                                    child: Text(
                                                                      'Create EwayBill',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    color:
                                                                        AppBarColor,
                                                                  ),
                                                                if (sales[index]
                                                                        [
                                                                        'form_no'] !=
                                                                    "")
                                                                  RaisedButton(
                                                                    elevation:
                                                                        0,
                                                                    onPressed:
                                                                        () {},
                                                                    child: Text(
                                                                        'Cancel EwayBill',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white)),
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                if (sales[index]
                                                                        [
                                                                        'form_no'] !=
                                                                    "")
                                                                  RaisedButton(
                                                                    elevation:
                                                                        0,
                                                                    onPressed:
                                                                        () {},
                                                                    child: Text(
                                                                        'Print EwayBill',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white)),
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    if (index ==
                                                        sales.length - 1)
                                                      Container(
                                                        height: 130,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color: Colors.white,
                                                      ),
                                                    if (index !=
                                                        sales.length - 1)
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
                          ),
                        if (showloader == false &&
                            items.isNotEmpty &&
                            isbillfound == true)
                          Expanded(
                            child: Container(
                              height: showalertdetail == false &&
                                      sales.isNotEmpty
                                  ? MediaQuery.of(context).size.height - 295
                                  : showalertdetail == false && sales.isEmpty
                                      ? MediaQuery.of(context).size.height - 295
                                      : 310,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: items.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                          itemCount: items.length,
                                          shrinkWrap: true,
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
                                                setState(() {
                                                  showalertdetail = true;
                                                  pdfPath = "";
                                                  selectedbillno = "";
                                                  selectedbilldate = "";
                                                  selectedpartyname = "";
                                                  selectedvalue = "";
                                                  selectednumber = "";
                                                  selectedemail = "";
                                                  selectedbillid = "";
                                                  selectedbillid = items[index]
                                                          ['bill_id']
                                                      .toString();
                                                  selectedbillno = items[index]
                                                          ['bill_no']
                                                      .toString();
                                                  selectedbilldate =
                                                      items[index]['bill_date']
                                                          .toString();
                                                  selectedpartyname =
                                                      items[index]
                                                              ['bill_to_name']
                                                          .toString();
                                                  selectedvalue = items[index]
                                                          ['bill_value']
                                                      .toString();
                                                  selectednumber = items[index]
                                                          ['bill_to_contact']
                                                      .toString();
                                                  selectedemail = items[index]
                                                          ['bt_email']
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
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8,
                                                                    top: 8,
                                                                    bottom: 2),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                items[index][
                                                                        'bill_to_name']
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
                                                                        'Bill no :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.grey.withOpacity(0.7),
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['bill_no'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.grey.withOpacity(0.7),
                                                                            fontWeight: FontWeight.w500),
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
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['bill_value'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
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
                                                                        'Contact :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['bill_to_contact'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
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
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['bill_date'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
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
                                                    if (index ==
                                                        items.length - 1)
                                                      Container(
                                                        height: 130,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color: Colors.white,
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
                              height: showalertdetail == false &&
                                      sales.isNotEmpty
                                  ? MediaQuery.of(context).size.height - 295
                                  : showalertdetail == false && sales.isEmpty
                                      ? MediaQuery.of(context).size.height - 295
                                      : 310,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  'No bill found',
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
                              height: showalertdetail == false &&
                                      sales.isNotEmpty
                                  ? MediaQuery.of(context).size.height - 295
                                  : showalertdetail == false && sales.isEmpty
                                      ? MediaQuery.of(context).size.height - 295
                                      : 310,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: items.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: items.length,
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
                                                setState(() {
                                                  showalertdetail = true;
                                                  pdfPath = "";
                                                  selectedbillno = "";
                                                  selectedbilldate = "";
                                                  selectedpartyname = "";
                                                  selectedvalue = "";
                                                  selectednumber = "";
                                                  selectedemail = "";
                                                  selectedbillid = "";
                                                  selectedbillid = items[index]
                                                          ['bill_id']
                                                      .toString();
                                                  selectedbillno = items[index]
                                                          ['bill_no']
                                                      .toString();
                                                  selectedbilldate =
                                                      items[index]['bill_date']
                                                          .toString();
                                                  selectedpartyname =
                                                      items[index]
                                                              ['bill_to_name']
                                                          .toString();
                                                  selectedvalue = items[index]
                                                          ['bill_value']
                                                      .toString();
                                                  selectednumber = items[index]
                                                          ['bill_to_contact']
                                                      .toString();
                                                  selectedemail = items[index]
                                                          ['bt_email']
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
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8,
                                                                    top: 8,
                                                                    bottom: 2),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                items[index][
                                                                        'bill_to_name']
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
                                                                        'Bill no :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.grey.withOpacity(0.7),
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['bill_no'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.grey.withOpacity(0.7),
                                                                            fontWeight: FontWeight.w500),
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
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['bill_value'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
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
                                                                        'Contact :',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['bill_to_contact'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
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
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        " " +
                                                                            items[index]['bill_date'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w500),
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
                                                    if (index ==
                                                        sales.length - 1)
                                                      Container(
                                                        height: 130,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color: Colors.white,
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
                            height: 246,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  color: AppBarColor,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10, left: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Bill Details',
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.white),
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showalertdetail = false;
                                                selectedbilldate = "";
                                                selectedbillno = "";
                                                selectedpartyname = "";
                                                selectedvalue = "";
                                                pdfPath = "";
                                                selectedbillid = "";
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
                                            'Bill No :',
                                            style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
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
                                            'Bill Date :',
                                            style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            " " + selectedbilldate,
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
                                            'Party Name :',
                                            style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
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
                                            'Bill Value :',
                                            style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            " " + "₹" + " " + selectedvalue,
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
                                                fontWeight: FontWeight.bold),
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
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 45,
                                      child: FloatingActionButton(
                                        heroTag: null,
                                        onPressed: () {
                                          getFileUrl(false, true, false);
                                        },
                                        backgroundColor: Colors.white,
                                        elevation: 5,
                                        child: Center(
                                            child: Icon(Icons.remove_red_eye,
                                                color: Colors.red, size: 30)),
                                      ),
                                    ),
                                    /*Container(
                                height: 45,
                                child: FloatingActionButton(
                                  heroTag: null,
                                  onPressed: (){
                                  },
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  child: Image.asset('assets/icons/message.png', height: 35,),
                                ),
                              ),*/
                                    Container(
                                      height: 45,
                                      child: FloatingActionButton(
                                        heroTag: null,
                                        onPressed: () {
                                          if (pdfPath == "") {
                                            getFileUrl(false, false, true);
                                          } else {
                                            if (selectednumber == "" ||
                                                selectednumber.length < 10) {
                                              showPrintedMessage(
                                                  context,
                                                  "Error",
                                                  "Not a valid number",
                                                  Colors.white,
                                                  Colors.redAccent,
                                                  Icons.info,
                                                  true,
                                                  "bottom");
                                            } else {
                                              shareFile(
                                                  selectednumber, pdfPath);
                                            }
                                          }
                                        },
                                        backgroundColor: Colors.white,
                                        elevation: 5,
                                        child: Image.asset(
                                          'assets/icons/whatsapp.png',
                                          height: 35,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 45,
                                      child: FloatingActionButton(
                                        heroTag: null,
                                        onPressed: () {
                                          if (selectedemail == "" ||
                                              selectedemail.contains('.') ==
                                                  false ||
                                              selectedemail.contains('@') ==
                                                  false) {
                                            showPrintedMessage(
                                                context,
                                                "Error",
                                                "Not a valid email id",
                                                Colors.white,
                                                Colors.redAccent,
                                                Icons.info,
                                                true,
                                                "bottom");
                                          } else {
                                            sendMail();
                                          }
                                        },
                                        backgroundColor: Colors.white,
                                        elevation: 5,
                                        child: Image.asset(
                                          'assets/icons/email.png',
                                          height: 35,
                                        ),
                                      ),
                                    ),
                                    // Container(
                                    //   height: 45,
                                    //   child: FloatingActionButton(
                                    //     heroTag: null,
                                    //     onPressed: () {},
                                    //     backgroundColor: Colors.white,
                                    //     elevation: 5,
                                    //     child: Icon(
                                    //         Icons.local_shipping_outlined,
                                    //         color: Colors.red),
                                    //   ),
                                    // ),
                                    Container(
                                      height: 45,
                                      child: FloatingActionButton(
                                        heroTag: null,
                                        onPressed: () {
                                          showAlertDialog(context);
                                        },
                                        backgroundColor: Colors.red,
                                        elevation: 5,
                                        child: Icon(Icons.delete,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                /*    RaisedButton(
                            elevation: 10,
                            color: AppBarColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Text('Delete Bill',style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),),
                            onPressed: (){},
                          )*/
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
                          lastscreen: "salesscreen",
                        ),
                      ),
                    Visibility(
                      visible: false,
                      child: Positioned(
                        top: 130,
                        left: 330,
                        right: 0,
                        child: iserror == false
                            ? Container(
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
                                              child: AddSBill()));
                                    },
                                    child: Icon(
                                      Icons.add,
                                      color: AppBarColor,
                                    )),
                              )
                            : Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : WillPopScope(
            onWillPop: () async {
              setState(() {
                inprintermode = false;
              });
              return false;
            },
            child: Scaffold(
              body: PDFViewerScaffold(
                  appBar: AppBar(
                    title: Text("Document"),
                    actions: [
                      IconButton(
                          onPressed: () {
                            bluetoothPrint.startScan(
                                timeout: Duration(seconds: 4));
                          },
                          icon: Icon(Icons.print))
                    ],
                    backgroundColor: AppBarColor,
                  ),
                  path: pdfPath),
            ),
          );
  }
}
