import 'package:bbills/app_constants/api_constants.dart';
import 'package:bbills/screen_models/register.dart';
import 'package:bbills/shared%20preference%20singleton.dart';
import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../p_policy.dart';
import '../toast_messeger.dart';
import 'dashboard.dart';
import 'forget_pass.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    setscreenposition();
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });

    _handleSignOut();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      //debugPrint(error.toString());
    }
  }

  Future<void> _handleSignOut() async {
    setState(() {
      _currentUser = null;
    });
    _googleSignIn.disconnect();
  }

  GoogleSignInAccount? user;
  Widget? _buildBody() {
    setState(() {
      user = _currentUser;
    });
    //  glogin();
    if (user != null) {
      return null;
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[],
      );
    }
  }

  Future<void> glogin() async {
    try {
      setState(() {
        // issubmitclicked = true;
      });
      var rsp = await apiurl("/process", "login.php", {
        "uname": _currentUser!.email.toString(),
        "upass": "",
        "glogin": glogkey,
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          issubmitclicked = false;
        });
        if (rsp['status'].toString() == "true") {
          _handleSignOut();
          //showPrintedMessage(context, "Success", "Logged in successfully", Colors.white,Colors.blueAccent, Icons.info, true, "top");
          var userdetails = SharedPreferenceSingleton.sharedPreferences;
          userdetails.setString("utoken", rsp['token'].toString());
          userdetails.setString("spc", rsp['spc'].toString());
          userdetails.setString("st", rsp['st'].toString());

          //Help video links
          var apphelp = rsp['apphelp'];
          userdetails.setString(
              "intro_help", apphelp['intro']?.toString() ?? "");
          userdetails.setString(
              "customers_help", apphelp['customers']?.toString() ?? "");
          userdetails.setString(
              "suppliers_help", apphelp['suppliers']?.toString() ?? "");
          userdetails.setString("product_category_help",
              apphelp['product_category']?.toString() ?? "");
          userdetails.setString(
              "products_help", apphelp['products']?.toString() ?? "");
          userdetails.setString(
              "bank_book_help", apphelp['bank_book']?.toString() ?? "");
          userdetails.setString(
              "warehouse_help", apphelp['warehouse']?.toString() ?? "");
          userdetails.setString("sale_help", apphelp['sale']?.toString() ?? "");
          userdetails.setString(
              "purchase_help", apphelp['purchase']?.toString() ?? "");
          userdetails.setString(
              "receipt_help", apphelp['receipt']?.toString() ?? "");
          userdetails.setString(
              "payment_help", apphelp['payment']?.toString() ?? "");
          userdetails.setString(
              "sale_return_help", apphelp['sale_return']?.toString() ?? "");
          userdetails.setString("purchase_return_help",
              apphelp['purchase_return']?.toString() ?? "");
          userdetails.setString("delivery_challan_help",
              apphelp['delivery_challan']?.toString() ?? "");
          userdetails.setString("stock_transfer_help",
              apphelp['stock_transfer']?.toString() ?? "");
          userdetails.setString(
              "reports_help", apphelp['reports']?.toString() ?? "");
          userdetails.setString(
              "settings_help", apphelp['settings']?.toString() ?? "");
          // cant find firm settings screen
          userdetails.setString(
              "firm_settings_help", apphelp['firm_settings']?.toString() ?? "");
          userdetails.setString(
              "digital_vcard_help", apphelp['digital_vcard']?.toString() ?? "");
          userdetails.setString(
              "bill_format_help", apphelp['bill_format']?.toString() ?? "");
          userdetails.setString("change_password_help",
              apphelp['change_password']?.toString() ?? "");

          if (rsp['companies'].toString().contains('~')) {
            var a = rsp['companies'].toString().split("~");
            userdetails.setStringList("companieslist", a);
            userdetails.setString("companies", rsp['companies'].toString());
          } else {
            userdetails.setString("companies", rsp['companies'].toString());
          }
          if (rsp['databases'].toString().contains('~')) {
            var a = rsp['databases'].toString().split("~");
            userdetails.setStringList("databaseslist", a);
            userdetails.setString("databases", rsp['databases'].toString());
          } else {
            userdetails.setString("databases", rsp['databases'].toString());
          }
          aftrlogin();
        } else {
          if (rsp['error'].toString() == 'already_loggedin') {
            logoutapi(rsp['hash'].toString(), "glogin");
          } else {
            //showPrintedMessage(context, "Error", loginfailed, Colors.white,Colors.red, Icons.info, true, "top");
            _handleSignOut();
          }
          setState(() {
            issubmitclicked = false;
          });
        }
      }
    } catch (error) {
//     showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "top");
      setState(() {
        issubmitclicked = false;
      });
      _handleSignOut();
    }
  }

  Future<void> aftrlogin() async {
    try {
      setState(() {
        issubmitclicked = true;
      });
      var rsp = await apiurl("/member/process", "dashboard.php", {
        "type": "updateFile",
      });
      //debugPrint('after log - ' + jsonEncode(rsp).toString());
      if (rsp.containsKey('status')) {
        setState(() {
          issubmitclicked = false;
        });
        if (rsp['status'].toString() == "true") {
          showPrintedMessage(context, "Success", "Logged in successfully",
              Colors.white, Colors.blueAccent, Icons.info, true, "top");
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => Dashboard()));
        } else {
          showPrintedMessage(
              context,
              "ERR CODE - #2031 FAILED UPDT",
              'Failed to log in',
              Colors.white,
              Colors.red,
              Icons.info,
              true,
              "top");
          if (rsp['error'].toString() == 'already_loggedin') {
          } else {
//            showPrintedMessage(context, "Error", loginfailed, Colors.white,Colors.red, Icons.info, true, "top");

          }
          setState(() {
            issubmitclicked = false;
          });
        }
      }
    } catch (error) {
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "top");
      setState(() {
        issubmitclicked = false;
      });
      // _handleSignOut();
    }
  }

  Future<void> normal() async {
    try {
      setState(() {
        issubmitclicked = true;
      });
      var rsp = await apiurl("/process", "login.php", {
        "uname": usernameController.text,
        "upass": passwordController.text,
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          issubmitclicked = false;
        });
        if (rsp['status'].toString() == "true") {
          var userdetails = SharedPreferenceSingleton.sharedPreferences;
          userdetails.setString("utoken", rsp['token'].toString());
          userdetails.setString("spc", rsp['spc'].toString());
          userdetails.setString("st", rsp['st'].toString());

          //Help video links
          var apphelp = rsp['apphelp'];
          userdetails.setString(
              "intro_help", apphelp['intro']?.toString() ?? "");
          userdetails.setString(
              "customers_help", apphelp['customers']?.toString() ?? "");
          userdetails.setString(
              "suppliers_help", apphelp['suppliers']?.toString() ?? "");
          userdetails.setString("product_category_help",
              apphelp['product_category']?.toString() ?? "");
          userdetails.setString(
              "products_help", apphelp['products']?.toString() ?? "");
          userdetails.setString(
              "bank_book_help", apphelp['bank_book']?.toString() ?? "");
          userdetails.setString(
              "warehouse_help", apphelp['warehouse']?.toString() ?? "");
          userdetails.setString("sale_help", apphelp['sale']?.toString() ?? "");
          userdetails.setString(
              "purchase_help", apphelp['purchase']?.toString() ?? "");
          userdetails.setString(
              "receipt_help", apphelp['receipt']?.toString() ?? "");
          userdetails.setString(
              "payment_help", apphelp['payment']?.toString() ?? "");
          userdetails.setString(
              "sale_return_help", apphelp['sale_return']?.toString() ?? "");
          userdetails.setString("purchase_return_help",
              apphelp['purchase_return']?.toString() ?? "");
          userdetails.setString("delivery_challan_help",
              apphelp['delivery_challan']?.toString() ?? "");
          userdetails.setString("stock_transfer_help",
              apphelp['stock_transfer']?.toString() ?? "");
          userdetails.setString(
              "reports_help", apphelp['reports']?.toString() ?? "");
          userdetails.setString(
              "settings_help", apphelp['settings']?.toString() ?? "");
          // cant find firm settings screen
          userdetails.setString(
              "firm_settings_help", apphelp['firm_settings']?.toString() ?? "");
          userdetails.setString(
              "digital_vcard_help", apphelp['digital_vcard']?.toString() ?? "");
          userdetails.setString(
              "bill_format_help", apphelp['bill_format']?.toString() ?? "");
          userdetails.setString("change_password_help",
              apphelp['change_password']?.toString() ?? "");

          if (rsp['companies'].toString().contains('~')) {
            var a = rsp['companies'].toString().split("~");
            userdetails.setStringList("companieslist", a);
            userdetails.setString("companies", rsp['companies'].toString());
          } else {
            userdetails.setString("companies", rsp['companies'].toString());
          }
          if (rsp['databases'].toString().contains('~')) {
            var a = rsp['databases'].toString().split("~");
            userdetails.setStringList("databaseslist", a);
            userdetails.setString("databases", rsp['databases'].toString());
          } else {
            userdetails.setString("databases", rsp['databases'].toString());
          }
          aftrlogin();
          /* Navigator.of(context).popUntil((route) => route.isFirst);
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Dashboard()));
*/
        } else {
          // showPrintedMessage(context, "Error", loginfailed, Colors.white,Colors.red, Icons.info, true, "top");
          if (rsp['error'].toString() == 'already_loggedin') {
            logoutapi(rsp['hash'].toString(), "normal");
          } else {
            setState(() {
              showPrintedMessage(context, "Error", loginfailed, Colors.white,
                  Colors.red, Icons.info, true, "top");
              issubmitclicked = false;
            });
          }
        }
      }
    } catch (error) {
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "top");
      setState(() {
        issubmitclicked = false;
      });
    }
  }

  int hit_Count = 0;

  Future<void> flogoutapi(String token, String from, String uname) async {
    try {
      setState(() {
        issubmitclicked = true;
      });
      var rsp = await apiurl(
          "/process", "flogout.php", {"_req_token": token, "uname": uname});
      //debugPrint('hhh');
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          issubmitclicked = false;
        });
        if (rsp['status'].toString() == "true") {
          if (from == 'normal') {
            normal();
          } else {
            glogin();
          }
        } else {
          showPrintedMessage(context, "Error", loginfailed, Colors.white,
              Colors.red, Icons.info, true, "top");
          setState(() {
            issubmitclicked = false;
          });
        }
      }
    } catch (error) {
      showPrintedMessage(context, "Error", error.toString(), Colors.white,
          Colors.blueAccent, Icons.info, true, "top");
      setState(() {
        issubmitclicked = false;
      });
    }
  }

  Future<void> logoutapi(String token, String from) async {
    setState(() {
      hit_Count = hit_Count + 1;
    });
    try {
      setState(() {
        issubmitclicked = true;
      });
      var rsp = await apiurl("/process", "logout.php", {"_req_token": token});
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          issubmitclicked = false;
        });
        if (rsp['status'].toString() == "true") {
          if (hit_Count <= 2) {
            if (from == 'normal') {
              normal();
            } else {
              glogin();
            }
          } else {
            if (from == 'normal') {
              flogoutapi(token, from, usernameController.text.toString());
            } else {
              flogoutapi(token, from, _currentUser!.email.toString());
            }
          }
        } else {
          showPrintedMessage(context, "Error", loginfailed, Colors.white,
              Colors.red, Icons.info, true, "top");
          setState(() {
            issubmitclicked = false;
          });
        }
      }
    } catch (error) {
      setState(() {
        issubmitclicked = false;
      });
    }
  }

  bool issubmitclicked = false;
  dynamic usernameController = TextEditingController();
  dynamic passwordController = TextEditingController();
  bool obscureText = true;
  //inputfieldforlogin
  inputfields(String hinttext, TextEditingController? control, bool val) {
    return TextFormField(
      cursorColor: secondarycolor,
      controller: control,
      obscureText: val ? obscureText : false,
      textInputAction: val ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: val
          ? (_) async {
              if (usernameController.text.toString().isNotEmpty &&
                  passwordController.text.toString().isNotEmpty) {
                normal();
                // aftrlogin();
              } else {
                showPrintedMessage(context, "Alert", "Please fill all fields",
                    Colors.white, Colors.red, Icons.info, true, "top");
              }
            }
          : null,
      decoration: InputDecoration(
        isDense: true,
        fillColor: Colors.white,
        filled: true,
        hintText: hinttext,
        hintStyle: TextStyle(color: Colors.grey),
        suffixIcon: val
            ? IconButton(
                onPressed: () => setState(() => obscureText = !obscureText),
                icon: obscureText
                    ? Icon(
                        Icons.visibility,
                        color: secondarycolor,
                      )
                    : Icon(Icons.visibility_off, color: secondarycolor))
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: loginbordercolor),
          borderRadius: BorderRadius.circular(15),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: loginbordercolor),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: loginbordercolor),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  void setscreenposition() async {
    var screen = SharedPreferenceSingleton.sharedPreferences;
    setState(() {
      screen.setString("currentscreen", "login");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      glogin();
      /* return AlertDialog(
        backgroundColor: Colors.white,
        elevation: 30,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))
        ),
        title: Center(child: Text('Approve Login',style: TextStyle(fontWeight: FontWeight.bold))),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Align(
                  alignment: Alignment.center,
                  child: Center(child: Text("Login with"))),
              Align(
                  alignment: Alignment.center,
                  child: Center(child: Text("${_currentUser!.email}"))),
              Divider(),

            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.amber) ),
            onPressed: () {
              glogin();
              Login();
            },
            child: Center(
              child: Row(
                children: [
                  Container(child: Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,)),
                  Center(
                    child: Text(
                      "Proceed To Login",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red) ),
            onPressed: () {
              _handleSignOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                    return Login();
                  }));
            },
            child: Row(
              children: [
                Icon(Icons.cancel),
                Text(
                  "Choose Another Email",
                  style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2.2,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      );*/
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: scaffoldbgcolor,
        body: Container(
          child: Column(
            children: [
              Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      width: MediaQuery.of(context).size.width * 0.60,
                      color: Colors.white,
                      child: Image.asset('assets/icons/bbillslogo.png'),
                    ),
                  )),
              Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(35),
                            topLeft: Radius.circular(35)),
                        color: secondarycolor),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                      child: Container(
                        child: Form(
                          child: Column(children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.06,
                            ),
                            Container(
                                height: 50,
                                child: Center(
                                  child: inputfields(
                                      "Username", usernameController, false),
                                )),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Container(
                                height: 50,
                                child: Center(
                                  child: inputfields(
                                      "Password", passwordController, true),
                                )),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        forget_screen()));

                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(builder: (context) => const SecondRoute()),
                                        // );
                                      },
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: secondarycolor,
                              ),
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.80,
                              child: issubmitclicked == false
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        if (usernameController.text
                                                .toString()
                                                .isNotEmpty &&
                                            passwordController.text
                                                .toString()
                                                .isNotEmpty) {
                                          normal();
                                          // aftrlogin();
                                        } else {
                                          showPrintedMessage(
                                              context,
                                              "Alert",
                                              "Please fill all fields",
                                              Colors.white,
                                              Colors.red,
                                              Icons.info,
                                              true,
                                              "top");
                                        }
                                      },
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(fontSize: 16),
                                      ))
                                  : const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 0.85,
                                      ),
                                    ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.80,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                      color: loginbordercolor,
                                    )),
                                    Container(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            "or",
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.5)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Divider(
                                      color: loginbordercolor,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.80,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                ),
                                onPressed: _handleSignIn,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/google.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                    Container(width: 20),
                                    Text(
                                      "Sign In With Google",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an acoount?   ",
                                      style: TextStyle(color: logintextcolor),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        registration_screen()));
                                      },
                                      child: Text(
                                        "Create Account",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        Ppolicy(
                                                          url:
                                                              "https://bharatbills.com/privacy-policy",
                                                        )));
                                      },
                                      child: Text(
                                        "Privacy Policy",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
