// @dart = 2.9
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/screen_models/settings.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart' as path;
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_share/whatsapp_share.dart';

import '../main.dart';
import '../toast_messeger.dart';

class VisitCards extends StatefulWidget {
  VisitCards({Key key, @required this.index}) : super(key: key);
  final String index;
  @override
  _VisitCardsState createState() => _VisitCardsState();
}

class _VisitCardsState extends State<VisitCards> {
  String name ="";
  String companyname = "";
  String desig = "";
  String phn = "";
  String email = "";
  String web = "";
  String address = "";
  String logo = "";
  String selectedindex = "";
  GlobalKey _globalKey = new GlobalKey();
  String finalbase;

  Future<Directory> _getDownloadDirectory() async{
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

  @override
  void initState(){
    super.initState();
    getdata();
  }

  void getlogoImg() async{
    setState(() {

    });
    try{
      var rsp = await apiurl("/member/process", "bill_nums.php", {
        "type": "logo",

      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {

        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            logo = rsp['file'].toString();
          }
          );

        }else if(rsp['status'].toString()=="false"){  setState(() {
          //  showloader=false;
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
        //  showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  void getdata () async{
    try{
      var rsp = await apiurl("/member/process", "firm.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){

        if(rsp['status'].toString()=="true"){
          setState(() {
            name ="";
            companyname = "";
            desig = "";
            phn = "";
            email = "";
            web = "";
            address = "";
            logo = "";
            name = rsp['data'][0]['firm_person'].toString();
            companyname = rsp['data'][0]['name'].toString();
            address = rsp['data'][0]['address'].toString();
            phn = rsp['data'][0]['phone'].toString();
            email = rsp['data'][0]['email'].toString();
            web = rsp['data'][0]['web'].toString();
            desig = rsp['data'][0]['desig'].toString().replaceAll('amp;', '');
          });
          getlogoImg();
        }else if(rsp['status'].toString()=="false"){  setState(() {

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

      });
      setState(() {

      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
      _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
      setState(() {
        finalbase = bs64;
      });
      _createFileFromString();
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }
  Future<void> shareFile(String number, String filepath) async {
    //debugPrint(filepath.toString());
    await WhatsappShare.shareFile(
      text: 'Hello,\nThis is my digital card, created through BharatBills App.\nTo create your own digital visiting card and manage your'
          ' complete business visit www.bharatbills.com',
      phone: "9548830505",
      filePath: [filepath],
    );
  }

  Directory appDocDir;
  String filePath;
  Future<String> _createFileFromString() async {
    final encodedStr = finalbase;
    Uint8List bytes = base64.decode(encodedStr);
   // String dir = (await getApplicationDocumentsDirectory()).path;
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if(isPermissionStatusGranted){
      final Directory _appDocDirFolder = Directory('${dir.path}/$Appname/cards');
      if(await _appDocDirFolder.exists()){
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir.path}/$Appname/cards';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        //debugPrint(filePath.toString());
        File file = File(
            "$filePath/" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg");
        await file.writeAsBytes(bytes);
        shareFile("",file.path);
      }
      else{
        //debugPrint('in function 2');
        final Directory _appDocNewFolder = await _appDocDirFolder.create(recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir.path}/$Appname/cards';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        //debugPrint(filePath.toString());
        File file = File(
            "$filePath/" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg");
        await file.writeAsBytes(bytes);
        shareFile("",file.path);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.of(context)
            .popUntil((route) =>
        route.isFirst);
        Navigator
            .pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType
                    .fade,
                child: Settings_Screen()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
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
                  child: Settings_Screen()));
            },
            icon: Icon(Icons.arrow_back, size:30, )
          ),
          title: Text('Digital Visiting Card',style: TextStyle(fontSize: 18, color:AppBarColor),),
          iconTheme: IconThemeData(
            color: AppBarColor, //change your color here
          ),
          actions:[
            HelpButton(helpURL: "digital_vcard_help")
          ]
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: ListView(
            children: [
              if(widget.index=="0")
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      height: 210,
                      width: MediaQuery.of(context).size.width-20,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/cards/cardtem1.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [

                            ],
                          ),
                          Positioned(
                            top: 25,
                            // left: 40,
                            left: 34,
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(80.0),
                                image: DecorationImage(
                                  image: NetworkImage(logo),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(),
                              ),
                            )
                          ),
                          Positioned(
                            top: 120,
                            // left: 40,
                            left: 24,
                            child: Container(
                              width: 100,
                              child: Text(companyname, style: GoogleFonts.montserrat(
                                  fontSize: 15, color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),textAlign: TextAlign.center,),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            // left: 40,
                            left: 174,
                            child: Text(desig, style: GoogleFonts.montserrat(
                                fontSize: 13, color: Colors.orangeAccent,
                                fontWeight: FontWeight.w400
                            ),),
                          ),
                          Positioned(
                            top: 50,
                           // left: 40,
                            left: 174,
                            child: Text(name, style: GoogleFonts.montserrat(
                              fontSize: 20, color: Color(0xff114C70),
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                          Positioned(
                            top: 93,
                            // left: 40,
                            left: 194,
                            child: Text(phn, style: GoogleFonts.poppins(
                                fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                            ),),
                          ),
                          Positioned(
                            top: 118,
                            // left: 40,
                            left: 194,
                            child: Text(email, style: GoogleFonts.poppins(
                                fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                            ),),
                          ),
                          Positioned(
                            top: 141,
                            // left: 40,
                            left: 194,
                            child: Text(web, style: GoogleFonts.poppins(
                                fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                            ),),
                          ),
                          Positioned(
                            top: 166,
                            // left: 40,
                            left: 194,
                            child: Container(
                              width: MediaQuery.of(context).size.width-230,
                              child: Wrap(
                                children: [
                                  Text(address, style: GoogleFonts.poppins(
                                      fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                                  ),),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if(widget.index=="1")
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      height: 210,
                      width: MediaQuery.of(context).size.width-20,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/cards/cardtem2.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [

                            ],
                          ),
                          Positioned(
                            top: 0,
                            // left: 40,
                            left: 4,
                            child: Container(
                              height: 50,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(80.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: Image.network(logo)),
                              ),
                            )
                          ),
                          Positioned(
                            top: 40,
                            // left: 40,
                            left: 15,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(companyname, style: GoogleFonts.montserrat(
                                    fontSize: 18, color: Colors.black,
                                    fontWeight: FontWeight.bold
                                ),textAlign: TextAlign.center,),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 80,
                            // left: 40,
                            left: 50,
                            child: Text(desig, style: GoogleFonts.montserrat(
                                fontSize: 13, color: Colors.orangeAccent,
                                fontWeight: FontWeight.w400
                            ),),
                          ),
                          Positioned(
                            top: 95,
                           // left: 40,
                            left: 50,
                            child: Text(name, style: GoogleFonts.montserrat(
                              fontSize: 20, color: Color(0xff114C70),
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                          Positioned(
                            top: 132,
                            // left: 40,
                            left: 65,
                            child: Text(phn, style: GoogleFonts.poppins(
                                fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                            ),),
                          ),
                          Positioned(
                            top: 132,
                            // left: 40,
                            left: 158,
                            child: Text(email, style: GoogleFonts.poppins(
                                fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                            ),),
                          ),
                          Positioned(
                            top: 157,
                            // left: 40,
                            left: 65,
                            child: Text(web, style: GoogleFonts.poppins(
                                fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                            ),),
                          ),
                          Positioned(
                            top: 157,
                            // left: 40,
                            left: 158,
                            child: Container(
                              width: MediaQuery.of(context).size.width-240,
                              child: Wrap(
                                children: [
                                  Text(address, style: GoogleFonts.poppins(
                                      fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                                  ),),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if(widget.index=="2")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        height: 210,
                        width: MediaQuery.of(context).size.width-20,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/cards/cardtem3.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [

                              ],
                            ),
                            Positioned(
                                top: 0,
                                // left: 40,
                                left: 4,
                                child: Container(
                                  height: 50,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(80.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: Image.network(logo)),
                                  ),
                                )
                            ),
                            Positioned(
                              top: 40,
                              // left: 40,
                              left: 15,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(companyname, style: GoogleFonts.montserrat(
                                      fontSize: 18, color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),textAlign: TextAlign.center,),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 70,
                              // left: 40,
                              left: 30,
                              child: Text(desig, style: GoogleFonts.montserrat(
                                  fontSize: 13, color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w400
                              ),),
                            ),
                            Positioned(
                              top: 80,
                              // left: 40,
                              left: 30,
                              child: Text(name, style: GoogleFonts.montserrat(
                                  fontSize: 20, color: Color(0xff114C70),
                                  fontWeight: FontWeight.bold
                              ),),
                            ),
                            Positioned(
                              top: 104,
                              // left: 40,
                              left: 55,
                              child: Text(phn, style: GoogleFonts.poppins(
                                  fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 124,
                              // left: 40,
                              left: 55,
                              child: Text(email, style: GoogleFonts.poppins(
                                  fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 144,
                              // left: 40,
                              left: 55,
                              child: Text(web, style: GoogleFonts.poppins(
                                  fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 163,
                              // left: 40,
                              left: 55,
                              child: Container(
                                width: MediaQuery.of(context).size.width-240,
                                child: Wrap(
                                  children: [
                                    Text(address, style: GoogleFonts.poppins(
                                        fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                                    ),),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if(widget.index=="3")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        height: 210,
                        width: MediaQuery.of(context).size.width-20,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/cards/cardtem4.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [

                              ],
                            ),
                            Positioned(
                                top: 25,
                                // left: 40,
                                left: 34,
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(80.0),
                                    image: DecorationImage(
                                      image: NetworkImage(logo),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(),
                                  ),
                                )
                            ),
                            Positioned(
                              top: 120,
                              // left: 40,
                              left: 24,
                              child: Container(
                                width: 100,
                                child: Text(companyname, style: GoogleFonts.montserrat(
                                    fontSize: 15, color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),textAlign: TextAlign.center,),
                              ),
                            ),
                            Positioned(
                              top: 30,
                              // left: 40,
                              left: 174,
                              child: Text(desig, style: GoogleFonts.montserrat(
                                  fontSize: 13, color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w400
                              ),),
                            ),
                            Positioned(
                              top: 50,
                              // left: 40,
                              left: 174,
                              child: Text(name, style: GoogleFonts.montserrat(
                                  fontSize: 20, color: Color(0xff114C70),
                                  fontWeight: FontWeight.bold
                              ),),
                            ),
                            Positioned(
                              top: 110,
                              // left: 40,
                              left: 185,
                              child: Text(phn, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 137,
                              // left: 40,
                              left: 185,
                              child: Text(email, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 10,
                              // left: 40,
                              right: 10,
                              child: Text(web, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 165,
                              // left: 40,
                              left: 186,
                              child: Container(
                                width: MediaQuery.of(context).size.width-220,
                                child: Wrap(
                                  children: [
                                    Text(address, style: GoogleFonts.poppins(
                                        fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                                    ),),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if(widget.index=="4")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        height: 210,
                        width: MediaQuery.of(context).size.width-20,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/cards/cardtem5.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [

                              ],
                            ),
                            Positioned(
                                top: 25,
                                // left: 40,
                                left: 34,
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(80.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: Image.network(logo)),
                                  ),
                                )
                            ),
                            Positioned(
                              top: 100,
                              // left: 40,
                              left: 24,
                              child: Container(
                                width: 100,
                                child: Text(companyname, style: GoogleFonts.montserrat(
                                    fontSize: 15, color: Colors.black,
                                    fontWeight: FontWeight.bold
                                ),textAlign: TextAlign.center,),
                              ),
                            ),
                            Positioned(
                              top: 30,
                              // left: 40,
                              left: 174,
                              child: Text(desig, style: GoogleFonts.montserrat(
                                  fontSize: 13, color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w400
                              ),),
                            ),
                            Positioned(
                              top: 50,
                              // left: 40,
                              left: 174,
                              child: Text(name, style: GoogleFonts.montserrat(
                                  fontSize: 20, color: Color(0xff114C70),
                                  fontWeight: FontWeight.bold
                              ),),
                            ),
                            Positioned(
                              top: 103,
                              // left: 40,
                              left: 215,
                              child: Text(phn, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 130,
                              // left: 40,
                              left: 217,
                              child: Text(email, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 10,
                              // left: 40,
                              right: 10,
                              child: Text(web, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 160,
                              // left: 40,
                              left: 217,
                              child: Container(
                                width: MediaQuery.of(context).size.width-250,
                                child: Wrap(
                                  children: [
                                    Text(address, style: GoogleFonts.poppins(
                                        fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                                    ),),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if(widget.index=="5")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        height: 210,
                        width: MediaQuery.of(context).size.width-20,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/cards/cardtem6.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [

                              ],
                            ),
                            Positioned(
                                top: 25,
                                // left: 40,
                                left: 34,
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(80.0),
                                    image: DecorationImage(
                                      image: NetworkImage(logo),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(),
                                  ),
                                )
                            ),
                            Positioned(
                              top: 110,
                              // left: 40,
                              left: 24,
                              child: Container(
                                width: 100,
                                child: Text(companyname, style: GoogleFonts.montserrat(
                                    fontSize: 15, color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),textAlign: TextAlign.center,),
                              ),
                            ),
                            Positioned(
                              top: 100,
                              // left: 40,
                              right: 35,
                              child: Text(desig, style: GoogleFonts.montserrat(
                                  fontSize: 13, color: Colors.white,
                                  fontWeight: FontWeight.w400
                              ),),
                            ),
                            Positioned(
                              top: 120,
                              // left: 40,
                              right: 35,
                              child: Text(name, style: GoogleFonts.montserrat(
                                  fontSize: 20, color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),),
                            ),
                            Positioned(
                              top: 147,
                              // left: 40,
                              right: 35,
                              child: Text(phn, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white
                              ),),
                            ),
                            Positioned(
                              top: 167,
                              // left: 40,
                              right: 35,
                              child: Text(email, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white
                              ),),
                            ),
                            Positioned(
                              top: 10,
                              // left: 40,
                              right: 10,
                              child: Text(web, style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 157,
                              // left: 40,
                              left: 27,
                              child: Container(
                                width: MediaQuery.of(context).size.width-225,
                                child: Wrap(
                                  children: [
                                    Text(address, style: GoogleFonts.poppins(
                                        fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white
                                    ),),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if(widget.index=="6")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        height: 210,
                        width: MediaQuery.of(context).size.width-20,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/cards/cardtem7.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [

                              ],
                            ),
                            Positioned(
                                top: 25,
                                // left: 40,
                                left: 34,
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(80.0),
                                    image: DecorationImage(
                                      image: NetworkImage(logo),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(),
                                  ),
                                )
                            ),
                            Positioned(
                              top: 110,
                              // left: 40,
                              left: 24,
                              child: Container(
                                width: 100,
                                child: Text(companyname, style: GoogleFonts.montserrat(
                                    fontSize: 15, color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),textAlign: TextAlign.center,),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              // left: 40,
                              right: 10,
                              child: Text(desig, style: GoogleFonts.montserrat(
                                  fontSize: 13, color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w400
                              ),),
                            ),
                            Positioned(
                              top: 22,
                              // left: 40,
                              right: 10,
                              child: Container(
                                width: 200,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(name, style: GoogleFonts.montserrat(
                                      fontSize: 20, color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 105,
                              // left: 40,
                              left: 202,
                              child: Text(phn, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 125,
                              // left: 40,
                              left: 202,
                              child: Text(email, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 150,
                              // left: 40,
                              left: 202,
                              child: Text(web, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 175,
                              // left: 40,
                              left: 202,
                              child: Container(
                                width: MediaQuery.of(context).size.width-225,
                                child: Wrap(
                                  children: [
                                    Text(address, style: GoogleFonts.poppins(
                                        fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                                    ),),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if(widget.index=="7")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        height: 210,
                        width: MediaQuery.of(context).size.width-20,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/cards/cardtem8.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [

                              ],
                            ),
                            Positioned(
                                top: 25,
                                // left: 40,
                                left: 34,
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(80.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: Image.network(logo)),
                                  ),
                                )
                            ),
                            Positioned(
                              top: 100,
                              // left: 40,
                              left: 24,
                              child: Container(
                                width: 100,
                                child: Text(companyname, style: GoogleFonts.montserrat(
                                    fontSize: 15, color: Colors.black,
                                    fontWeight: FontWeight.bold
                                ),textAlign: TextAlign.center,),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              // left:40,
                              right: 10,
                              child: Text(desig, style: GoogleFonts.montserrat(
                                  fontSize: 13, color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w400
                              ),),
                            ),
                            Positioned(
                              bottom: 30,
                              // left: 40,
                              right: 10,
                              child: Container(
                                width: 150,
                                child: Align(
                                  alignment:Alignment.centerRight,
                                  child: Text(name, style: GoogleFonts.montserrat(
                                      fontSize: 20, color: Color(0xff114C70),
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 36,
                              // left: 40,
                              left: 222,
                              child: Text(phn, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 53,
                              // left: 40,
                              left: 222,
                              child: Text(email, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 70,
                              // left: 40,
                              left: 222,
                              child: Text(web, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 85,
                              // left: 40,
                              left: 222,
                              child: Container(
                                width: MediaQuery.of(context).size.width-250,
                                child: Wrap(
                                  children: [
                                    Text(address, style: GoogleFonts.poppins(
                                        fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                                    ),),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if(widget.index=="8")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        height: 210,
                        width: MediaQuery.of(context).size.width-20,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/cards/cardtem9.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [

                              ],
                            ),
                            Positioned(
                                top: 25,
                                // left: 40,
                                left: 34,
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(80.0),
                                    image: DecorationImage(
                                      image: NetworkImage(logo),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(),
                                  ),
                                )
                            ),
                            Positioned(
                              top: 120,
                              // left: 40,
                              left: 24,
                              child: Container(
                                width: 100,
                                child: Text(companyname, style: GoogleFonts.montserrat(
                                    fontSize: 15, color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),textAlign: TextAlign.center,),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              // left:40,
                              right: 10,
                              child: Text(desig, style: GoogleFonts.montserrat(
                                  fontSize: 13, color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w400
                              ),),
                            ),
                            Positioned(
                              top: 20,
                              // left: 40,
                              right: 10,
                              child: Container(
                                width: 210,
                                child: Align(
                                  alignment:Alignment.centerRight,
                                  child: Text(name, style: GoogleFonts.montserrat(
                                      fontSize: 20, color: Color(0xff114C70),
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 133,
                              // left: 40,
                              left: 217,
                              child: Text(phn, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 110,
                              // left: 40,
                              left: 217,
                              child: Text(email, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 8,
                              // left: 40,
                              left: 10,
                              child: Text(web, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white
                              ),),
                            ),
                            Positioned(
                              top: 155,
                              // left: 40,
                              left: 217,
                              child: Container(
                                width: MediaQuery.of(context).size.width-250,
                                child: Wrap(
                                  children: [
                                    Text(address, style: GoogleFonts.poppins(
                                        fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                                    ),),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if(widget.index=="9")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        height: 210,
                        width: MediaQuery.of(context).size.width-20,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/cards/cardtem10.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [

                              ],
                            ),
                            Positioned(
                                top: 25,
                                // left: 40,
                                left: 34,
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(80.0),
                                    image: DecorationImage(
                                      image: NetworkImage(logo),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(),
                                  ),
                                )
                            ),
                            Positioned(
                              top: 120,
                              // left: 40,
                              left: 24,
                              child: Container(
                                width: 100,
                                child: Text(companyname, style: GoogleFonts.montserrat(
                                    fontSize: 15, color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),textAlign: TextAlign.center,),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              // left:40,
                              right: 10,
                              child: Text(desig, style: GoogleFonts.montserrat(
                                  fontSize: 13, color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w400
                              ),),
                            ),
                            Positioned(
                              top: 20,
                              // left: 40,
                              right: 10,
                              child: Container(
                                width: 130,
                                child: Align(
                                  alignment:Alignment.centerRight,
                                  child: Text(name, style: GoogleFonts.montserrat(
                                      fontSize: 20, color: Color(0xff114C70),
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 130,
                              // left: 40,
                              left: 240,
                              child: Text(phn, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 114,
                              // left: 40,
                              left: 240,
                              child: Text(email, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 144,
                              // left: 40,
                              left: 240,
                              child: Text(web, style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                              ),),
                            ),
                            Positioned(
                              top: 163,
                              // left: 40,
                              left: 240,
                              child: Container(
                                width: MediaQuery.of(context).size.width-250,
                                child: Wrap(
                                  children: [
                                    Text(address, style: GoogleFonts.poppins(
                                        fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff114C70)
                                    ),),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton:  FloatingActionButton(
          onPressed: (){
            _capturePng();
          },
          backgroundColor: Colors.green,
          child: Center(
            child: Image.asset('assets/icons/whatsapp.png', color:Colors.white, height: 40,),
          ),
        ),
      ),
    );
  }
}
