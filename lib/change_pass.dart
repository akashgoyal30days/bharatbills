import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/screen_models/dashboard.dart';
import 'package:bbills/screen_models/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../../shared preference singleton.dart';
import '../main.dart';
import '../toast_messeger.dart';
import 'app_constants/appbarconstant/appbarconst.dart';
import 'app_constants/bottom_bar.dart';

class Cpass extends StatefulWidget {
  const Cpass({Key? key}) : super(key: key);

  @override
  _CpassState createState() => _CpassState();
}

class _CpassState extends State<Cpass> {
  bool showloader = false;
  dynamic oldpassController = TextEditingController();
  dynamic fnewpassController = TextEditingController();
  dynamic confpassController = TextEditingController();
  Future<void> logoutapi() async {
    String token = '';
    var userdetails = SharedPreferenceSingleton.sharedPreferences;
    setState(() {
      token = userdetails.getString("utoken").toString();
    });
    try {
      var rsp = await apiurl("/process", "logout.php", {"_req_token": token});
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        var userdetails = SharedPreferenceSingleton.sharedPreferences;
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
      var userdetails = SharedPreferenceSingleton.sharedPreferences;
      setState(() {
        userdetails.clear();
        Navigator.popUntil(context, (_) => !Navigator.canPop(context));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => Login()));
      });
    }
  }

  void CpassApi() async {
    setState(() {
      showloader = true;
    });

    try {
      var rsp = await apiurl("/member/process", "settings.php", {
        "type": "password",
        "cpass": oldpassController.text.toString(),
        "npass": fnewpassController.text.toString(),
        "cnpass": confpassController.text.toString(),
      });
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
                "Passowrd reset successfully",
                Colors.white,
                Colors.green,
                Icons.info,
                true,
                "top");
          });
          logoutapi();
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showloader = false;
          });
          if (rsp['error'].toString() == "invalid_auth") {
            showPrintedMessage(context, "Error", "Old password is not correct",
                Colors.white, Colors.redAccent, Icons.info, true, "bottom");
          }
          if (rsp['error'].toString() == "cpass") {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: Dashboard()));
          return false;
        },
        child: Scaffold(
          backgroundColor: scaffoldbackground,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: AppBarColor,
            child: Stack(
              children: [
                Column(children: [
                  ConstAppBar("change_password_help"),
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
                                'Change Password',
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
                  if (showloader == false)
                    Expanded(
                        child: Container(
                      color: Colors.white,
                      child: ListView(
                        children: [
                          SizedBox(
                            height: 35,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: TextFormField(
                                cursorColor: secondarycolor,
                                controller: oldpassController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Old Password *",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 18),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: TextFormField(
                                cursorColor: secondarycolor,
                                controller: fnewpassController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "New Password *",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 18),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: TextFormField(
                                cursorColor: secondarycolor,
                                controller: confpassController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Confirm Password *",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 18),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: secondarycolor,
                                ),
                                height: 50,
                                width: MediaQuery.of(context).size.width * 0.80,
                                child: showloader == false
                                    ? ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  secondarycolor),
                                        ),
                                        onPressed: () {
                                          if (oldpassController.text.isEmpty ||
                                              confpassController.text.isEmpty ||
                                              fnewpassController.text.isEmpty) {
                                            showPrintedMessage(
                                                context,
                                                "Alert",
                                                "Please fill all reured fields",
                                                Colors.white,
                                                Colors.red,
                                                Icons.info,
                                                true,
                                                "top");
                                          } else {
                                            if (fnewpassController.text ==
                                                confpassController.text) {
                                              CpassApi();
                                            } else {
                                              showPrintedMessage(
                                                  context,
                                                  "Alert",
                                                  "New Password and confirm password are not same",
                                                  Colors.white,
                                                  Colors.red,
                                                  Icons.info,
                                                  true,
                                                  "top");
                                            }
                                          }
                                        },
                                        child: Text(
                                          "Submit",
                                          style: TextStyle(fontSize: 16),
                                        ))
                                    : Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 0.85,
                                        ),
                                      )),
                          )
                        ],
                      ),
                    )),
                ]),
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: BottomBar(lastscreen: "ChangePass"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
