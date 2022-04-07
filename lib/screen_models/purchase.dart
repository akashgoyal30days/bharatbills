import 'dart:convert';
import 'dart:io';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:dio/dio.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/api_models/get_file_url_api.dart';
import 'package:bbills/app_constants/api_constants.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import '../shared preference singleton.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../main.dart';
import '../toast_messeger.dart';
import 'add_screens/add_p_bill.dart';
import 'dashboard.dart';

class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  late String pdfPath="";
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
  bool iserror = false;


  @override
  void initState() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true
    );
    final initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin!.initialize(initSettings, onSelectNotification: _onSelectNotification);
    super.initState();
    setscreenposition();
  }
  void setscreenposition() async{
    var screen = SharedPreferenceSingleton.sharedPreferences;
    screen.setString("currentscreen", "purchasescreen");
    //debugPrint(screen.getString("currentscreen").toString());
    setdates();
  }
  void setdates (){
    var date = new DateTime.now();
    var newDate = new DateTime(date.year, date.month - 1, date.day);
    setState(() {
      selectedtodate = formatter.format(DateTime.now());
      selectedfromdate = formatter.format(newDate);
    });
    getdatawithdate();
  }
  void getdata () async{
    setState((){
      iserror = false;
      allwise = true;
    });

    try{
      var rsp = await apiurl("/member/process", "purchase.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            purchase = rsp['data'];
          });

        }else if(rsp['status'].toString()=="false"){  setState(() {
        showloader=false;
      });
          if(rsp['error'].toString()=="invalid_auth"){
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
          }

        }
      }
    }catch(error){
      setState(() {
        showloader=false;
        iserror = true;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }
  bool allwise = true;
  void getdatawithdate () async{
    setState(() {
      allwise = false;
    });
    try{
      var rsp = await apiurl("/member/process", "purchase.php", {
        "type": "view_all_date",
        "date_from":selectedfromdate.toString(),
        "date_to":selectedtodate.toString()
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          purchase.clear();
          items.clear();
          indexpostion.clear();
          isbillfound = true;
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            purchase = rsp['data'];
          });

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showloader=false;
        });
        if(rsp['error'].toString()=="invalid_auth"){
          Navigator.of(context).popUntil((route) => route.isFirst);
          showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
        }

        }
      }
    }catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  void gethtmldata (String billid) async{
    try{
      var rsp = await apiurl("/member/process", "purchase.php", {
        "type": "view",
        "bill_id": billid
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            htmldata = rsp['data']['body'].toString();
            inprintermode = true;
            getdirectory();
          });

        }else if(rsp['status'].toString()=="false"){  setState(() {
        showloader=false;
      });
          if(rsp['error'].toString()=="invalid_auth"){
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
          }

        }
      }
    }catch(error){
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
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
    if(from=="From"){
      if (selected != null )
        setState(() {
          selectedfromdate = formatter.format(selected);
        });
    }else{
      if (selected != null )
        setState(() {
          selectedtodate = formatter.format(selected);
        });
    }
  }

  //Downloading section
  bool isclicked = false;
  final Dio _dio = Dio();
  Directory? appDocDir;
  String? filePath;
  Future<Directory?> _getDownloadDirectory() async{
    if(Platform.isAndroid){
      return await DownloadsPathProvider.downloadsDirectory;
    }
    return await getApplicationDocumentsDirectory();
  }
  Future<bool> _requestPermissions() async{
    var permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);

    if(permission != PermissionStatus.granted){
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
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
      if(isclicked == true) {
        OpenFile.open(obj['filePath']);
      }
    } else {
      if (isclicked == true) {
        showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
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
        'channel id',
        'channel name',
        'channel description',
        priority: Priority.High,
        importance: Importance.Max
    );
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android, iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];
    //debugPrint(json);

    await flutterLocalNotificationsPlugin!.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess ? 'File has been downloaded successfully!' : 'There was an error while downloading the file.',
        platform,
        payload: json
    );
  }

  String filepaths = '';
  Future getdirectory() async {
    setState(() {
      filepaths = "";
    });
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if(isPermissionStatusGranted){
      final Directory _appDocDirFolder = Directory('${dir!.path}/$Appname/purchase/bills');
      if(await _appDocDirFolder.exists()){
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
          tstamp= tstamp.replaceAll(":", "");
          tstamp=tstamp.replaceAll(".", "");
          newfname = tstamp;
          //debugPrint(myspath.toString());
          filepaths = dirPath+'/'+tstamp+".pdf";

        });
        await FlutterHtmlToPdf.convertFromHtmlContent(
            htmldata, dirPath, tstamp).then((v)=>[
          // if(from!='Share'){
          //      showPrintedMessage(context, "Success", "File Downloading completed, can be found at Downloads/Bharat Bills/Sale Return", Colors.white,Colors.green, Icons.info, false, "top"),
          // },
          OpenFile.open(filepaths)

        ], onError: (e) =>[
          //debugPrint(e.toString()),
          //  if(from!='Share'){
          showPrintedMessage(context, "Error", "Failed to download file", Colors.white,Colors.red, Icons.info, true, "top"),
          // }
        ]);
      }
      else{
        //debugPrint('in function 2');
        final Directory _appDocNewFolder = await _appDocDirFolder.create(recursive: true);
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
          tstamp= tstamp.replaceAll(":", "");
          tstamp=tstamp.replaceAll(".", "");
          newfname = tstamp;
          //debugPrint(myspath.toString());
          filepaths = dirPath+'/'+tstamp+".pdf";

        });
        await FlutterHtmlToPdf.convertFromHtmlContent(
            htmldata, dirPath, tstamp).then((v)=>[
         // if(from!='Share'){
            //      showPrintedMessage(context, "Success", "File Downloading completed, can be found at Downloads/Bharat Bills/Sale Return", Colors.white,Colors.green, Icons.info, false, "top"),
         // },
          OpenFile.open(filepaths)

        ], onError: (e) =>[
          //debugPrint(e.toString()),
        //  if(from!='Share'){
            showPrintedMessage(context, "Error", "Failed to download file", Colors.white,Colors.red, Icons.info, true, "top"),
         // }
        ]);
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
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if(item['bill_no'].toString().toLowerCase().contains(query.toLowerCase())||item['bill_from_name'].toString().toLowerCase().contains(query.toLowerCase())||item['bill_from_contact'].toString().toLowerCase().contains(query.toLowerCase())) {
          setState(() {
            dummyListData.add(item);
            isbillfound = true;
          });
        }else{
          setState((){
            isbillfound = false;
          });
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
        indexpostion.clear();
        for(var i=0; i<items.length; i++){
          final index = dummySearchList.indexWhere((element) =>
          element['bill_no'] == items[i]['bill_no']);
          indexpostion.add(index);
        }
        ////debugPrint(indexpostion.toString());
      });
      items.clear();
      for(var i=0; i<indexpostion.length; i++){
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
    return inprintermode==false?WillPopScope(
      onWillPop: ()async{
            Navigator.of(context)
                .popUntil((route) =>
            route.isFirst);
            Navigator
                .pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType
                        .fade,
                    child: Dashboard()));

        return false;
      },
      child: Scaffold(
        backgroundColor: purchase.isNotEmpty?scaffoldbackground:Colors.white,
        //   bottomNavigationBar: BottomBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: purchase.isNotEmpty?AppBarColor:Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  ConstAppBar("purchase_help"),
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
                              Icon(Icons.circle, color: Colors.white,size: 15,),
                              SizedBox(width: 10,),
                              Text('Purchase', style: GoogleFonts.poppins(
                                  fontSize: 15, color: Colors.white
                              ),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if(showloader==true)
                    Container(
                      height: MediaQuery.of(context).size.height-140,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.7,

                        ),
                      ),
                    ),
                  if(purchase.isNotEmpty&&showloader==false)
                    Container(
                      color: AppBarColor,
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: editingController,
                          onChanged: (v){
                            filterSearchResults(v.toString());
                          },
                          decoration: InputDecoration(
                              labelText: "Search using bill no, name, contact",
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: "Search using bill no, name, contact",
                              hintStyle: TextStyle(color: Colors.white),
                              fillColor: Colors.white,
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blue, width: 1.0),
                              ),
                              prefixIcon: Icon(Icons.search, color: Colors.white,),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if(showloader==false)
                    Container(
                      color: AppBarColor,
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color:Colors.white,
                          child: Container(
                            height: 55,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey.withOpacity(0.2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width: MediaQuery.of(context).size.width/2.3,
                                    child: TextButton(
                                        onPressed: (){
                                          _selectDate(context, "From");
                                        },
                                        child: selectedfromdate==null?Row(
                                          children: [
                                            Icon(Icons.calendar_today_sharp, size : 20, color: AppBarColor),
                                            SizedBox(width:5),
                                            Text("From Date *", style:GoogleFonts.poppins(fontSize: 15, color: Colors.black)),
                                          ],
                                        ):Row(
                                          children: [
                                            Icon(Icons.calendar_today_sharp, size : 20, color: AppBarColor),
                                            SizedBox(width:5),
                                            Text(selectedfromdate.toString(), style:GoogleFonts.poppins(fontSize: 15, color: Colors.black)),
                                          ],
                                        )
                                    )),
                                Container(
                                  width: MediaQuery.of(context).size.width/2.3,
                                  child: TextButton(
                                      onPressed: (){
                                        _selectDate(context, "To");
                                      },
                                      child: selectedtodate==null?Row(
                                        children: [
                                          Icon(Icons.calendar_today_sharp, size : 20, color: AppBarColor),
                                          SizedBox(width:5),
                                          Text("To Date *", style:GoogleFonts.poppins(fontSize: 15, color: Colors.black)),
                                        ],
                                      ):Row(
                                        children: [
                                          Icon(Icons.calendar_today_sharp, size : 20, color: AppBarColor),
                                          SizedBox(width:5),
                                          Text(selectedtodate.toString(), style:GoogleFonts.poppins(fontSize: 15, color: Colors.black)),
                                        ],
                                      )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if(showloader==false)
                    Container(
                      color:Colors.white,
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
                                  onPressed:(){
                                    setState(() {
                                      showloader = true;
                                    });
                                    getdata();

                                  },
                                  child: Text('View All', style: GoogleFonts.poppins(
                                      fontSize: 15, color: Colors.white
                                  ))
                              ),
                            ),
                            SizedBox(width:10),
                            Container(
                              width: 60,
                              height: 35,
                              child: RaisedButton(
                                  elevation: 0,
                                  color: Colors.green,
                                  onPressed:(){
                                    if(selectedfromdate==null||selectedtodate==null){
                                      showPrintedMessage(context, "Error", "Please select from date and to date", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                    }else{
                                      setState(() {
                                        showloader = true;
                                      });
                                      getdatawithdate();
                                    }

                                  },
                                  child: Text('Go', style: GoogleFonts.poppins(
                                      fontSize: 15, color: Colors.white
                                  ))
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  if(showloader==false&&items.isEmpty&&isbillfound == true)
                    Container(
                      height: showalertdetail==false&&purchase.isNotEmpty?MediaQuery.of(context).size.height-295:showalertdetail==false&&purchase.isEmpty?MediaQuery.of(context).size.height-295:310,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: purchase.isNotEmpty?Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: purchase.length,
                            itemBuilder: (BuildContext context, index){
                              return GestureDetector(
                                onTap: (){
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  setState(() {
                                    showalertdetail=false;
                                    pdfPath = "";
                                    selectedbillno = "";
                                    selectedbillno = purchase[index]['bill_no'].toString();
                                    gethtmldata(purchase[index]['bill_id'].toString());
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
                                              padding: const EdgeInsets.only(left:8, top:8,bottom: 2),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(purchase[index]['bill_from_name'].toString(), style: GoogleFonts.poppins(
                                                    fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500
                                                ),),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left:8, top:0,bottom: 2, right: 8),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Bill no :', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.grey.withOpacity(0.7), fontWeight: FontWeight.w500
                                                        ),),
                                                        Text(" "+purchase[index]['bill_no'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.grey.withOpacity(0.7), fontWeight: FontWeight.w500
                                                        ),),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text('₹', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                        Text(" "+purchase[index]['bill_total'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left:8, top:0,bottom: 2, right: 8),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Contact :', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w400
                                                        ),),
                                                        Text(" "+purchase[index]['bill_from_contact'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w400
                                                        ),),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text('Bill Date :', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                        Text(" "+purchase[index]['bill_date'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if(index==purchase.length-1)
                                        Container(
                                          height: 130,
                                          width: MediaQuery.of(context).size.width,
                                          color: Colors.white,
                                        ),
                                      if(index!=purchase.length-1)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 50, right: 50),
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
                      ):Center(
                        child: Text('No data found', style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.black
                        ),),
                      ),
                    ),
                  if(showloader==false&&items.isNotEmpty&&isbillfound == true)
                    Container(
                      height: showalertdetail==false&&purchase.isNotEmpty?MediaQuery.of(context).size.height-295:showalertdetail==false&&purchase.isEmpty?MediaQuery.of(context).size.height-295:310,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: items.isNotEmpty?Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: items.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, index){
                              return GestureDetector(
                                onTap: (){
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  setState(() {
                                    showalertdetail=false;
                                    pdfPath = "";
                                    selectedbillno = "";
                                    selectedbillno = items[index]['bill_no'].toString();
                                    gethtmldata(items[index]['bill_id'].toString());
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
                                              padding: const EdgeInsets.only(left:8, top:8,bottom: 2),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(items[index]['bill_from_name'].toString(), style: GoogleFonts.poppins(
                                                    fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500
                                                ),),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left:8, top:0,bottom: 2, right: 8),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Bill no :', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.grey.withOpacity(0.7), fontWeight: FontWeight.w500
                                                        ),),
                                                        Text(" "+items[index]['bill_no'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.grey.withOpacity(0.7), fontWeight: FontWeight.w500
                                                        ),),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text('₹', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                        Text(" "+items[index]['bill_total'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left:8, top:0,bottom: 2, right: 8),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Contact :', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w400
                                                        ),),
                                                        Text(" "+items[index]['bill_from_contact'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w400
                                                        ),),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text('Bill Date :', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                        Text(" "+items[index]['bill_date'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if(index!=items.length-1)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 50, right: 50),
                                          child: Divider(
                                            color: Colors.blueAccent,
                                            thickness: 0.2,
                                          ),
                                        ),
                                      if(index==items.length-1)
                                        Container(
                                          height: 130,
                                          width: MediaQuery.of(context).size.width,
                                          color: Colors.white,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ):Center(
                        child: Text('No data found', style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.black
                        ),),
                      ),
                    ),
                  if(showloader==false&&items.isEmpty&&isbillfound == false)
                    Container(
                      height: showalertdetail==false&&purchase.isNotEmpty?MediaQuery.of(context).size.height-295:showalertdetail==false&&purchase.isEmpty?MediaQuery.of(context).size.height-295:310,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: Text('No bill found', style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.black
                        ),),
                      ),
                    ),
                  if(showloader==false&&items.isNotEmpty&&isbillfound == false)
                    Container(
                      height: showalertdetail==false&&purchase.isNotEmpty?MediaQuery.of(context).size.height-295:showalertdetail==false&&purchase.isEmpty?MediaQuery.of(context).size.height-295:310,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: items.isNotEmpty?Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: items.length,
                            itemBuilder: (BuildContext context, index){
                              return GestureDetector(
                                onTap: (){
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  setState(() {
                                    showalertdetail=false;
                                    pdfPath = "";
                                    selectedbillno = "";
                                    selectedbillno = items[index]['bill_no'].toString();
                                    gethtmldata(items[index]['bill_id'].toString());
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
                                              padding: const EdgeInsets.only(left:8, top:8,bottom: 2),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(items[index]['bill_from_name'].toString(), style: GoogleFonts.poppins(
                                                    fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500
                                                ),),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left:8, top:0,bottom: 2, right: 8),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Bill no :', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.grey.withOpacity(0.7), fontWeight: FontWeight.w500
                                                        ),),
                                                        Text(" "+items[index]['bill_no'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.grey.withOpacity(0.7), fontWeight: FontWeight.w500
                                                        ),),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text('₹', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                        Text(" "+items[index]['bill_total'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left:8, top:0,bottom: 2, right: 8),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Contact :', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w400
                                                        ),),
                                                        Text(" "+items[index]['bill_from_contact'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w400
                                                        ),),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text('Bill Date :', style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                        Text(" "+items[index]['bill_date'].toString(), style: GoogleFonts.poppins(
                                                            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if(index!=items.length-1)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 50, right: 50),
                                          child: Divider(
                                            color: Colors.blueAccent,
                                            thickness: 0.2,
                                          ),
                                        ),
                                      if(index==purchase.length-1)
                                        Container(
                                          height: 130,
                                          width: MediaQuery.of(context).size.width,
                                          color: Colors.white,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ):Center(
                        child: Text('No data found', style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.black
                        ),),
                      ),
                    ),
                ],
              ),
              if(showalertdetail==false)
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: BottomBar(lastscreen: "purchasescreen",),
                ),
              Positioned(
                top: 100,
                left: 330,
                right: 0,
                child: iserror==false?Container(
                  width: 50,
                  height: 30,
                  child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      onPressed:(){
                        Navigator.of(context)
                            .popUntil((route) =>
                        route.isFirst);
                        Navigator
                            .pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType
                                    .fade,
                                child: AddPBill()));
                      },
                      child: Icon(Icons.add, color: AppBarColor,)
                  ),
                ):Container(),
              ),
            ],
          ),

        ),),):
    WillPopScope(
      onWillPop: ()async{
        setState(() {
          inprintermode = false;
          pdfPath = "";
          filepaths = "";
        });
        return false;
      },
      child:Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){
              setState(() {
                inprintermode = false;
                pdfPath = "";
                filepaths = "";
              });
            },
            icon: Icon(Icons.arrow_back, color:Colors.white),
          ),
          title: Text('Purchase'),
          elevation:0,
          backgroundColor: AppBarColor,
          centerTitle: false,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Container(
            height: MediaQuery.of(context).size.height-10,
            width: MediaQuery.of(context).size.width,
            child: Zoom(
              maxZoomWidth: 1800,
              maxZoomHeight: 1800,
              child: WebView(
              initialUrl: Uri.dataFromString('$htmldata', mimeType: 'text/html').toString()
              ),
            ),
          ),
        )
      ),
    );
  }
}
