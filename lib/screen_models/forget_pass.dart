import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../main.dart';
import '../toast_messeger.dart';
import 'login.dart';

class forget_screen extends StatefulWidget {
  const forget_screen({Key? key}) : super(key: key);

  @override
  _forget_screenState createState() => _forget_screenState();
}

class _forget_screenState extends State<forget_screen> {
  bool showloader = false;
  dynamic fpassusernameController = TextEditingController();
  void fpass() async {
    try {
      var rsp = await apiurl("/process", "recovery.php", {
        "type": "recover_pass",
        "uname": fpassusernameController.text.toString(),
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
                "New password is sent to your Email ID",
                Colors.white,
                Colors.green,
                Icons.info,
                true,
                "top");
          });
          Navigator.pushReplacement(context,
              PageTransition(type: PageTransitionType.fade, child: Login()));
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(context,
              PageTransition(type: PageTransitionType.fade, child: Login()));
          return false;
        },
        child: Scaffold(
          backgroundColor: scaffoldbgcolor,
          body: Padding(
            padding: const EdgeInsets.all(50.0),
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.30,
                  child: Image.asset("assets/forgot.png"),
                ),
                Container(
                  child: Text(
                    "Reset Password",
                    style: TextStyle(fontSize: 35),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Enter the Email associated with your account to receive password on your email ",
                      style: TextStyle(fontSize: 23, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Container(
                  child: TextFormField(
                    cursorColor: secondarycolor,
                    controller: fpassusernameController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Enter registered email *",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
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
                                borderRadius: BorderRadius.circular(10.0),
                              )),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  secondarycolor),
                            ),
                            onPressed: () {
                              if (fpassusernameController.text.isEmpty) {
                                showPrintedMessage(
                                    context,
                                    "Alert",
                                    "Please enter your email id",
                                    Colors.white,
                                    Colors.red,
                                    Icons.info,
                                    true,
                                    "top");
                              } else {
                                setState(() {
                                  showloader = true;
                                });
                                fpass();
                              }
                            },
                            child: Text(
                              "Generate Password",
                              style: TextStyle(fontSize: 16),
                            ))
                        : Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 0.85,
                            ),
                          ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
