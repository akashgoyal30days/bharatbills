import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/screen_models/dashboard.dart';
import 'package:bbills/screen_models/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared preference singleton.dart';

import '../../main.dart';
import '../../toast_messeger.dart';
import '../ui_constants.dart';

class ConstAppBar extends StatefulWidget {
  ConstAppBar([this.helpURL]);
  // help URL is the youtube link keyword for sharedpreferences
  // Added by BALA
  final String? helpURL;

  @override
  _ConstAppBarState createState() => _ConstAppBarState();
}

String? choosencomp;
String? choosencomd;

class _ConstAppBarState extends State<ConstAppBar> {
  //----Variables-----------------------------//
  String? _chosenValue;
  bool showdropdown = false;

  String? choosendb;

  //----InitState function--------------------//
  @override
  void initState() {
    saveddata();
    super.initState();
    getlogoImg();
  }

  List<String> compname = [''];
  List<String> compdblist = [''];
  String mycurrentscreen = "";

  //----functions to get all saved data-------//
  void getScreen() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(context,
        PageTransition(type: PageTransitionType.fade, child: Dashboard()));
  }

  void saveddata() async {
    SharedPreferences userdetails = SharedPreferenceSingleton.sharedPreferences;
    setState(() {
      _chosenValue = userdetails.getString("spc");
    });
    if (userdetails.getString("companies").toString().contains('~')) {
      setState(() {
        showdropdown = true;
        compname = userdetails.getStringList("companieslist")!;
        compdblist = userdetails.getStringList("databaseslist")!;
        showdropdown = true;
      });
      print(compname);
      print(compdblist);
      print(_chosenValue);
    } else {
      setState(() {
        showdropdown = false;
        choosencomp = userdetails.getString("companies");
        if (choosencomp == "") {
          firmdata();
        }
        choosendb = userdetails.getString("databases");
        //debugPrint(choosencomp);
        //debugPrint(choosencomp);
      });
    }
  }

  var logo = 'https://bharatbills.in/bb/images/logo.png';
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
  void dispose() {
    super.dispose();
  }

  void firmdata() async {
    try {
      var rsp = await apiurl("/member/process", "firm.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {});
        if (rsp['status'].toString() == "true") {
          SharedPreferences userdetails =
              SharedPreferenceSingleton.sharedPreferences;
          setState(() {
            setState(() {
              userdetails.setString(
                  "companies", rsp['data'][0]['name'].toString());
            });
            saveddata();
          });
        } else if (rsp['status'].toString() == "false") {
          if (rsp['error'].toString() == 'firm_not_found') {}
          setState(() {});
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            //showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: MyHomePage()));
          }
        }
      }
    } catch (error) {
      setState(() {});
      setState(() {});
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
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

  void changecomp() async {
    try {
      var rsp = await apiurl("/member", "switch_company.php", {
        "c": compdblist.indexOf(_chosenValue!).toString(),
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        if (rsp['status'] == true) {
          getScreen();
          SharedPreferences userdetails =
              SharedPreferenceSingleton.sharedPreferences;
          setState(() {
            userdetails.setString("spc", rsp['db'].toString());
          });
        }
      }
    } catch (error) {
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
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

  //----ui function-----
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 70,
      toolbarHeight: 70,
      leading: GestureDetector(
        onTap: () async {
          SharedPreferences screen =
              SharedPreferenceSingleton.sharedPreferences;
          if (screen.getString("currentscreen").toString() != "dashboard") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: Dashboard()));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 150,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(logo), fit: BoxFit.fill),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50.0),
                    topLeft: Radius.circular(50.0),
                    bottomLeft: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0))),
          ),
        ),
      ),
      centerTitle: false,
      backgroundColor: AppBarColor,
      elevation: 0,
      title: showdropdown == true
          ? Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    child: DropdownButton<String>(
                      dropdownColor: AppBarColor,
                      elevation: 0,
                      focusColor: Colors.transparent,
                      value: _chosenValue,
                      //elevation: 5,
                      style: TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.white,
                      items: compname.map((item) {
                            return new DropdownMenuItem(
                              child: new Text(item),
                              value: compdblist[compname.indexOf(item)],
                            );
                          }).toList() ??
                          [],
                      hint: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          "Switch company",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _chosenValue = value.toString();
                          changecomp();
                          //debugPrint(_chosenValue);
                        });
                      },
                    ),
                  ),
                ),
              ),
            )
          : Text(
              choosencomp.toString(),
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
            ),
      actions: [
        if (widget.helpURL != null) HelpButton(helpURL: widget.helpURL!),
      ],
    );
  }
}

// creates help button on appbar, added by bala

class HelpButton extends StatefulWidget {
  HelpButton({required this.helpURL});
  final String helpURL;
  @override
  _HelpButtonState createState() => _HelpButtonState();
}

class _HelpButtonState extends State<HelpButton> {
  bool available = false;
  String? url;
  @override
  void initState() {
    checkAvailability();
    super.initState();
  }

  checkAvailability() async {
    SharedPreferences helpAvailability =
        SharedPreferenceSingleton.sharedPreferences;
    url = helpAvailability.getString(widget.helpURL) ?? "";
    print("URL for " + widget.helpURL + " is " + (url ?? ""));
    if (url == "") return;
    available = true;
    print("available for " + widget.helpURL);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return available
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child: Center(
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(3, 2, 3, 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.help_outlined,
                              color: AppBarColor,
                              size: 20,
                            ),
                            Text("Help",
                                style: TextStyle(
                                    color: AppBarColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ))),
              onTap: () {
                print("The url is " + url!);
                launch(url);
              },
            ),
          )
        : SizedBox();
  }
}
