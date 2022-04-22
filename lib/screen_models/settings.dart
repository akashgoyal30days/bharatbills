import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import '../shared preference singleton.dart';
import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/screen_models/about.dart';
import 'package:bbills/screen_models/category.dart';
import 'package:bbills/screen_models/dashboard.dart';
import 'package:bbills/screen_models/reports_screen/gst_reports_type_view.dart';
import 'package:bbills/screen_models/reports_screen/sales_purchase_ledger_view.dart';
import 'package:bbills/screen_models/visit_cards.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bbills/app_constants/api_constants.dart';
import '../app_constants/appbarconstant/appbarconst.dart';
import '../change_pass.dart';
import '../main.dart';
import '../toast_messeger.dart';
import 'Terms_conditions_add.dart';
import 'account_details.dart';
import 'add_bank.dart';
import 'bill_format.dart';
import 'login.dart';

class Settings_Screen extends StatefulWidget {
  @override
  _Settings_ScreenState createState() => _Settings_ScreenState();
}

class _Settings_ScreenState extends State<Settings_Screen>
    with TickerProviderStateMixin {
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');

  bool showloader = false;
  String logo = '';
  String sign = '';
  int bottomSelectedIndex = 0;
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pagenController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  PageController pagenController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  void initState() {
    super.initState();
    getlogoImg();
    getSignImg();
  }

  File? _imagelogo;
  File? croppedFile;
  File? croppedFile2;
  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image != null) {
      croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Set Logo Size',
              toolbarColor: AppBarColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      setState(() {
        _imagelogo = croppedFile;
      });
    }
  }

  File? _imageSign;

  _imgFromGallerySign() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image != null) {
      croppedFile2 = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
          androidUiSettings: AndroidUiSettings(
              hideBottomControls: true,
              toolbarTitle: 'Set Signature Size',
              toolbarColor: AppBarColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      setState(() {
        _imageSign = croppedFile2;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void LogOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Log Out",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              content: Text(
                "Are you sure you want to log out?",
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    logoutapi();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                  child: Text(
                    "Yes, Log out",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> logoutapi() async {
    String token = '';
    SharedPreferences userdetails = SharedPreferenceSingleton.sharedPreferences;
    setState(() {
      token = userdetails.getString("utoken").toString();
    });
    try {
      var rsp = await apiurl("/process", "logout.php", {"_req_token": token});
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        SharedPreferences userdetails =
            SharedPreferenceSingleton.sharedPreferences;
        setState(() {
          userdetails.clear();
          Navigator.popUntil(context, (_) => !Navigator.canPop(context));
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) => Login()));
        });
        if (rsp['status'].toString() == "true") {
          setState(() {});
        } else {
          //  showPrintedMessage(context, "Error", 'Failed to logout', Colors.white,Colors.red, Icons.info, true, "bottom");

        }
      }
    } catch (error) {
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      SharedPreferences userdetails =
          SharedPreferenceSingleton.sharedPreferences;
      setState(() {
        userdetails.clear();
        Navigator.popUntil(context, (_) => !Navigator.canPop(context));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => Login()));
      });
    }
  }

/*  Future uplogo() async{
    var a;
    setState(() {
      showloader = true;
      a = _imagelogo!.path.toString().split('/');
    });
    var url = "https://$baseurl/$suburl/member/process/firm.php";
    String token = "";
    var prefs = SharedPreferenceSingleton.sharedPreferences;
    if(prefs.getString("utoken")!=null){
      token = prefs.getString("utoken").toString();
    }
    Map<String, String> headers = new Map<String, String>();
    headers.putIfAbsent("Content-Type", () => "multipart/form-data");

    try {
      Dio dio = Dio();
      dio.options.contentType = Headers.textPlainContentType;
      FormData formData = new FormData.fromMap({
        "logo": await MultipartFile.fromFile(_imagelogo!.path,
            filename: a[a.length-1].toString()),
        'type': 'logo_add_app',
        '_req_from': reqfrom.toString(),
        'api_key': apikey.toString(),
        '_req_token': token.toString(),
      });
      Response response = await dio.post(
          url,
          data: formData,
          options: Options(headers: headers));
      //debugPrint(response.toString());
      var rsp = json.decode(response.data);
      //var rsp = response.body;
      //debugPrint(rsp.toString());
      //debugPrint(a[a.length-1].toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            showPrintedMessage(
                context,
                "Success",
                "Logo uploaded successfully",
                Colors.white,
                Colors.green,
                Icons.info,
                true,
                "top");
            getlogoImg();

          });

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showloader=false;

          showPrintedMessage(
              context,
              "Error",
              "Failed to upload logo",
              Colors.white,
              Colors.redAccent,
              Icons.info,
              true,
              "top");
        });
        if(rsp['error'].toString()=="invalid_auth"){
          Navigator.of(context).popUntil((route) => route.isFirst);
          showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
        }

        }
      }
     // Log.e("Response",response);
    } catch (e) {
      print(e);
    }
  }*/

  Future uplogo() async {
    var a;
    String? mimet;
    setState(() {
      showloader = true;
      a = _imagelogo!.path.toString().split('/');
      mimet = lookupMimeType(a[a.length - 1].toString());
    });
    final binary = ContentType("application", "octet-stream");
    //debugPrint(lookupMimeType(a[a.length-1].toString()));
    var url = "https://$baseurl/$suburl/member/process/firm.php";
    Map<String, String> headers = {
      'Accept': 'application/octet-stream',
      'Content-Type': mimet.toString()
    };
    String token = "";
    var prefs = SharedPreferenceSingleton.sharedPreferences;
    if (prefs.getString("utoken") != null) {
      token = prefs.getString("utoken").toString();
    }
    try {
      var request = new http.MultipartRequest("POST", Uri.parse(url));
      request.headers.addAll(headers);
      request.fields['type'] = 'logo_add_app';
      request.fields['_req_from'] = reqfrom.toString();
      request.fields['api_key'] = apikey.toString();
      request.fields['_req_token'] = token.toString();
      request.files.add(await http.MultipartFile(
        'logo',
        _imagelogo!.readAsBytes().asStream(),
        _imagelogo!.lengthSync(),
        filename: a[a.length - 1].toString(),
        contentType: new MediaType('image', 'jpg'),
      ));
      http.Response response =
          await http.Response.fromStream(await request.send());
      var rsp = json.decode(response.body);
      //var rsp = response.body;
      //debugPrint(rsp.toString());
      //debugPrint(a[a.length-1].toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            showPrintedMessage(context, "Success", "Logo uploaded successfully",
                Colors.white, Colors.green, Icons.info, true, "top");
            _imagelogo = null;
            getlogoImg();
          });
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;

            showPrintedMessage(context, "Error", "Failed to upload logo",
                Colors.white, Colors.redAccent, Icons.info, true, "top");
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
      //debugPrint(error.toString());
    }
  }

  void remove_Sign(String from) async {
    setState(() {
      showloader = true;
    });
    try {
      var rsp = await apiurl("/member/process", "firm.php", {
        "type": "remove_signature_app",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            if (from != 'upload') {
              showPrintedMessage(
                  context,
                  "Success",
                  "Signature removed successfully",
                  Colors.white,
                  Colors.green,
                  Icons.info,
                  true,
                  "top");
              getSignImg();
            } else {
              upSign();
            }
          });
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
            if (from != 'upload') {
              showPrintedMessage(context, "Error", "Failed to remove signature",
                  Colors.white, Colors.redAccent, Icons.info, true, "top");
            }
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

  void remove_Logo(String from) async {
    setState(() {
      showloader = true;
    });
    try {
      var rsp = await apiurl("/member/process", "firm.php", {
        "type": "remove_logo_app",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            if (from != 'upload') {
              showPrintedMessage(
                  context,
                  "Success",
                  "Logo removed successfully",
                  Colors.white,
                  Colors.green,
                  Icons.info,
                  true,
                  "top");
              getlogoImg();
            } else {
              uplogo();
            }
          });
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
            if (from != 'upload') {
              showPrintedMessage(context, "Error", "Failed to remove logo",
                  Colors.white, Colors.redAccent, Icons.info, true, "top");
            }
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

  Future upSign() async {
    var a;
    setState(() {
      showloader = true;
      a = _imageSign!.path.toString().split('/');
    });
    var url = "https://$baseurl/$suburl/member/process/firm.php";
    Map<String, String> headers = {'Accept': 'application/json'};
    String token = "";
    var prefs = SharedPreferenceSingleton.sharedPreferences;
    if (prefs.getString("utoken") != null) {
      token = prefs.getString("utoken").toString();
    }
    //debugPrint(token.toString());
    //debugPrint((formatter1.format(DateTime.now()).toString().replaceAll('/', '').toString().replaceAll(' ', '').toString().replaceAll(':', '').toString().replaceAll('-', ''))+'.jpg');

    try {
      var request = new http.MultipartRequest("POST", Uri.parse(url));
      request.headers.addAll(headers);
      request.fields['type'] = 'signature_app';
      request.fields['_req_from'] = reqfrom.toString();
      request.fields['_req_token'] = token.toString();
      request.fields['api_key'] = apikey.toString();
      request.files.add(await http.MultipartFile(
        'logo',
        _imageSign!.readAsBytes().asStream(),
        _imageSign!.lengthSync(),
        filename: a[a.length - 1].toString(),
        contentType: new MediaType('image', 'jpg'),
      ));
      http.Response response =
          await http.Response.fromStream(await request.send());
      //debugPrint(request.toString());
      var rsp = json.decode(response.body);
      // var rsp = response.body;
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            showPrintedMessage(
                context,
                "Success",
                "Signature uploaded successfully",
                Colors.white,
                Colors.green,
                Icons.info,
                true,
                "top");
            _imageSign = null;
            getSignImg();
          });
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;

            showPrintedMessage(context, "Error", "Failed to upload signature",
                Colors.white, Colors.redAccent, Icons.info, true, "top");
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
      //debugPrint(error.toString());
    }
  }

  UploadLogo(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Gallery"),
      onPressed: () {
        _imgFromGallery();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Update Logo"),
      content: Text("Update Logo Using"),
      actions: [cancelButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  UploadSign(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Gallery"),
      onPressed: () {
        _imgFromGallerySign();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Update Signature"),
      content: Text("Update Signature Using"),
      actions: [cancelButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void getlogoImg() async {
    setState(() {});
    try {
      var rsp = await apiurl("/member/process", "bill_nums.php", {
        "type": "logo",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {});
        if (rsp['status'].toString() == "true") {
          setState(() {
            logo = rsp['file'].toString();
          });
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            //  showloader=false;
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
        //  showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  void getSignImg() async {
    setState(() {});
    try {
      var rsp = await apiurl("/member/process", "bill_nums.php", {
        "type": "signature",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {});
        if (rsp['status'].toString() == "true") {
          setState(() {
            sign = rsp['file'].toString();
          });
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            //  showloader=false;
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
        //  showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(context,
            PageTransition(type: PageTransitionType.fade, child: Dashboard()));
        return false;
      },
      child: showloader == false
          ? SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                    toolbarHeight: 50,
                    backgroundColor: AppBarColor,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: Dashboard()));
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: HelpButton(helpURL: "settings_help"),
                      )
                    ]),
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 0),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          leading: Image.asset(
                            'assets/icons/fmaster.png',
                            color: AppBarColor,
                            height: report_icon_size,
                          ),
                          backgroundColor: Colors.white,
                          collapsedBackgroundColor: Colors.white,
                          title: Text(
                            "Firm Master",
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
                                        child: Accnt_Details(
                                          from: "settings",
                                        )));
                              },
                              contentPadding: const EdgeInsets.only(
                                left: 70,
                              ),
                              leading: Image.asset(
                                'assets/icons/fmaster.png',
                                color: AppBarColor,
                                height: report_icon_size,
                              ),
                              title: Text(
                                'Business Settings',
                                style: GoogleFonts.poppins(
                                    fontSize: title_font,
                                    color: AppBarColor,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 55, top: 8, bottom: 0),
                              child: ExpansionTile(
                                leading: Image.asset(
                                  'assets/icons/logo.png',
                                  color: AppBarColor,
                                  height: report_icon_size,
                                ),
                                backgroundColor: Colors.white,
                                collapsedBackgroundColor: Colors.white,
                                title: Text(
                                  "Logo",
                                  style: GoogleFonts.poppins(
                                      fontSize: title_font,
                                      color: AppBarColor,
                                      fontWeight: FontWeight.w400),
                                ),
                                children: <Widget>[
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 100,
                                                width: 100,
                                                margin:
                                                    const EdgeInsets.all(30.0),
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                  image: _imagelogo != null
                                                      ? DecorationImage(
                                                          image: FileImage(
                                                              _imagelogo!),
                                                          fit: BoxFit.fill,
                                                        )
                                                      : DecorationImage(
                                                          image: NetworkImage(
                                                              logo.toString()),
                                                          fit: BoxFit.fill,
                                                        ),
                                                  border: Border.all(),
                                                ), //             <--- BoxDecoration here
                                                child: _imagelogo == null
                                                    ? Center(
                                                        child: logo == ''
                                                            ? Text(
                                                                "Logo",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        30.0),
                                                              )
                                                            : Text(
                                                                "",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        30.0),
                                                              ),
                                                      )
                                                    : Center(),
                                              ),
                                              Column(
                                                children: [
                                                  RaisedButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      onPressed: () {
                                                        UploadLogo(context);
                                                      },
                                                      child: Text('Update',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white)),
                                                      elevation: 0,
                                                      color: Colors.blue),
                                                  SizedBox(height: 5),
                                                  RaisedButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      onPressed: () {
                                                        remove_Logo('remove');
                                                      },
                                                      child: Text('Remove',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white)),
                                                      elevation: 0,
                                                      color: Colors.red),
                                                ],
                                              )
                                            ],
                                          ),
                                          if (_imagelogo != null)
                                            Container(
                                              width: 100,
                                              margin: const EdgeInsets.only(
                                                  left: 30, right: 30),
                                              child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  onPressed: () {
                                                    remove_Logo('upload');
                                                  },
                                                  child: Text('Upload',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .white)),
                                                  elevation: 0,
                                                  color: Colors.blue),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 55, top: 8, bottom: 0),
                              child: ExpansionTile(
                                leading: Image.asset(
                                  'assets/icons/sign.png',
                                  color: AppBarColor,
                                  height: report_icon_size,
                                ),
                                backgroundColor: Colors.white,
                                collapsedBackgroundColor: Colors.white,
                                title: Text(
                                  "Signature",
                                  style: GoogleFonts.poppins(
                                      fontSize: title_font,
                                      color: AppBarColor,
                                      fontWeight: FontWeight.w400),
                                ),
                                children: <Widget>[
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 100,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: const EdgeInsets.all(30.0),
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              image: _imageSign != null
                                                  ? DecorationImage(
                                                      image: FileImage(
                                                          _imageSign!),
                                                      fit: BoxFit.fill,
                                                    )
                                                  : DecorationImage(
                                                      image: NetworkImage(
                                                          sign.toString()),
                                                      fit: BoxFit.fill,
                                                    ),
                                              border: Border.all(),
                                            ), //             <--- BoxDecoration here
                                            child: _imageSign == null
                                                ? Center(
                                                    child: sign == ''
                                                        ? Text(
                                                            "Signature",
                                                            style: TextStyle(
                                                                fontSize: 30.0),
                                                          )
                                                        : Text(
                                                            "",
                                                            style: TextStyle(
                                                                fontSize: 30.0),
                                                          ),
                                                  )
                                                : Center(),
                                          ),
                                          if (_imageSign != null)
                                            RaisedButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                onPressed: () {
                                                  remove_Sign('upload');
                                                },
                                                child: Text('Upload',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        color: Colors.white)),
                                                elevation: 0,
                                                color: Colors.blue),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  onPressed: () {
                                                    UploadSign(context);
                                                  },
                                                  child: Text('Update',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .white)),
                                                  elevation: 0,
                                                  color: Colors.blue),
                                              SizedBox(width: 5),
                                              RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  onPressed: () {
                                                    remove_Sign('remove');
                                                  },
                                                  child: Text('Remove',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .white)),
                                                  elevation: 0,
                                                  color: Colors.red),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
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
                                        child: Terms_Conds()));
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
                                'Terms and Conditions',
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
                                        child: Add_Bank()));
                              },
                              contentPadding: const EdgeInsets.only(
                                left: 70,
                              ),
                              leading: Image.asset(
                                'assets/icons/warehouse.png',
                                color: AppBarColor,
                                height: report_icon_size,
                              ),
                              title: Text(
                                'Add Bank',
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
                      /*              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 0),
                child: ExpansionTile(
                  leading: Image.asset('assets/icons/sales.png',color:AppBarColor, height: report_icon_size,),
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                  title: Text("Invoice Settings",style: GoogleFonts.poppins(
                      fontSize: title_font, color: AppBarColor,
                      fontWeight: FontWeight.w400
                  ),),
                  children: <Widget>[
            
            
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 0),
                child: ExpansionTile(
                  leading: Image.asset('assets/icons/sales.png',color:AppBarColor, height: report_icon_size,),
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                  title: Text("Configurations",style: GoogleFonts.poppins(
                      fontSize: title_font, color: AppBarColor,
                      fontWeight: FontWeight.w400
                  ),),
                  children: <Widget>[
            
                  ],
                ),
              ),*/
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 0),
                        child: Container(
                          color: Colors.white,
                          child: ListTile(
                            tileColor: Colors.white,
                            onTap: () {
                              /* Navigator.of(context)
                          .popUntil((route) =>
                      route.isFirst);
                      Navigator
                          .pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType
                                  .fade,
                              child: VisitCards()));*/
                              setState(() {
                                bottomSelectedIndex = 0;
                              });
                              showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20.0),
                                        topLeft: Radius.circular(20.0),
                                        bottomLeft: Radius.circular(00.0),
                                        bottomRight: Radius.circular(00.0))),
                                backgroundColor: Colors.white,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 400,
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: AppBarColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight: Radius
                                                              .circular(20.0),
                                                          topLeft:
                                                              Radius.circular(
                                                                  20.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  00.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  00.0))),
                                              height: 70,
                                              child: Center(
                                                child: Text(
                                                  'Select a card template',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 230,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: PageView.builder(
                                                  controller: pagenController,
                                                  onPageChanged: (index) {
                                                    setState(() {
                                                      pageChanged(index);
                                                    });
                                                  },
                                                  itemCount: 10,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          index) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                                route.isFirst);
                                                        Navigator
                                                            .pushReplacement(
                                                                context,
                                                                PageTransition(
                                                                    type: PageTransitionType
                                                                        .fade,
                                                                    child:
                                                                        VisitCards(
                                                                      index: index
                                                                          .toString(),
                                                                    )));
                                                      },
                                                      child: Container(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Card(
                                                            elevation: 10,
                                                            child: Container(
                                                              height: 100,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  20,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      "assets/cards/cardtem${index + 1}.png"),
                                                                  fit: BoxFit
                                                                      .fitWidth,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            )
                                          ],
                                        ),
                                        Positioned(
                                            top: 145,
                                            // left: 40,
                                            left: 24,
                                            child: Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(80.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: FloatingActionButton(
                                                  heroTag: null,
                                                  elevation: 0,
                                                  onPressed: () {
                                                    if (bottomSelectedIndex !=
                                                        0) {
                                                      setState(() {
                                                        bottomTapped(
                                                            bottomSelectedIndex -
                                                                1);
                                                      });
                                                    }
                                                  },
                                                  backgroundColor: Colors.blue
                                                      .withOpacity(0.3),
                                                  child: Center(
                                                      child: Icon(
                                                    Icons.arrow_back_ios,
                                                    size: 15,
                                                  )),
                                                ),
                                              ),
                                            )),
                                        Positioned(
                                            top: 145,
                                            // left: 40,
                                            right: 24,
                                            child: Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(80.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: FloatingActionButton(
                                                  heroTag: null,
                                                  elevation: 0,
                                                  onPressed: () {
                                                    if (bottomSelectedIndex !=
                                                        10) {
                                                      setState(() {
                                                        bottomTapped(
                                                            bottomSelectedIndex +
                                                                1);
                                                      });
                                                    }
                                                  },
                                                  backgroundColor: Colors.blue
                                                      .withOpacity(0.3),
                                                  child: Center(
                                                      child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 15,
                                                  )),
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  );
                                },
                                context: context,
                              );
                            },
                            leading: Image.asset(
                              'assets/icons/tools.png',
                              color: AppBarColor,
                              height: report_icon_size,
                            ),
                            title: Text(
                              'Digital Visiting Card',
                              style: GoogleFonts.poppins(
                                  fontSize: title_font,
                                  color: AppBarColor,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                      /* Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 0),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  leading: Image.asset('assets/icons/sales.png',color:AppBarColor, height: report_icon_size,),
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                  title: Text("Tools",style: GoogleFonts.poppins(
                      fontSize: title_font, color: AppBarColor,
                      fontWeight: FontWeight.w400
                  ),),
                  children: <Widget>[
                    ListTile(
                      onTap: (){ },
                      contentPadding:const EdgeInsets.only(left: 70,),
                      leading: Icon(Icons.contacts, size: report_icon_size,),
                      title: Text('Data Upload',style: GoogleFonts.poppins(
                          fontSize: title_font, color: AppBarColor,
                          fontWeight: FontWeight.w400
                      ),),
                    ),
                    ListTile(
                      onTap: (){ },
                      contentPadding:const EdgeInsets.only(left: 70,),
                      leading: Icon(Icons.contacts, size: report_icon_size,),
                      title: Text('Master Data',style: GoogleFonts.poppins(
                          fontSize: title_font, color: AppBarColor,
                          fontWeight: FontWeight.w400
                      ),),
                    ),
                    ListTile(
                      onTap: (){ },
                      contentPadding:const EdgeInsets.only(left: 70,),
                      leading: Icon(Icons.contacts, size: report_icon_size,),
                      title: Text('Rewrite Book',style: GoogleFonts.poppins(
                          fontSize: title_font, color: AppBarColor,
                          fontWeight: FontWeight.w400
                      ),),
                    ),
                  ],
                ),
              ),*/

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
                                      child: BillFormat()));
                            },
                            leading: Image.asset(
                              'assets/icons/reciept.png',
                              color: AppBarColor,
                              height: report_icon_size,
                            ),
                            title: Text(
                              'Bill Format',
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
                                      child: Cpass()));
                            },
                            leading: Image.asset(
                              'assets/icons/tools.png',
                              color: AppBarColor,
                              height: report_icon_size,
                            ),
                            title: Text(
                              'Change Password',
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
                                      child: About()));
                            },
                            leading: Icon(Icons.info_outline,
                                size: 20, color: AppBarColor),
                            title: Text(
                              'About',
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
                              LogOut(context);
                            },
                            leading: const Icon(Icons.logout_rounded,
                                size: 20, color: Colors.red),
                            title: Text(
                              'Log out',
                              style: GoogleFonts.poppins(
                                  fontSize: title_font,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.lightBlueAccent.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 0.7,
                  ),
                ),
              ),
            ),
    );
  }
}
