import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:page_transition/page_transition.dart';

import '../toast_messeger.dart';
import 'login.dart';

class registration_screen extends StatefulWidget {
  registration_screen({Key? key}) : super(key: key);

  @override
  State<registration_screen> createState() => _registration_screenState();
}

class _registration_screenState extends State<registration_screen> {
  @override
  void initState() {
    super.initState();
  }

  String? otppin;
  bool showloader = false;
  dynamic fullnameController = TextEditingController();
  dynamic emailController = TextEditingController();
  dynamic contController = TextEditingController();
  dynamic compnameController = TextEditingController();
  dynamic referralCodeController = TextEditingController();
  OtpFieldController otpController = OtpFieldController();

  bool showotp = false;

  void register() async {
    setState(() {
      showloader = true;
    });
    try {
      var rsp = await regurl("/register/api", "register.php", {
        "name": fullnameController.text.toString(),
        "email": emailController.text.toString(),
        "phone": contController.text.toString(),
        "company": compnameController.text.toString(),
        "version": "2",
        "ref": "0"
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          showPrintedMessage(
              context,
              "Success",
              "Added Successfully, OTP sent to your email account",
              Colors.white,
              Colors.green,
              Icons.info,
              true,
              "top");
          setState(() {
            showotp = true;
          });
        } else if (rsp['status'].toString() == "false") {
          setState(() {
            showPrintedMessage(context, "Failed", rsp['error'].toString(),
                Colors.white, Colors.redAccent, Icons.info, true, "top");
            showloader = false;
          });
        }
        if (rsp['status'].toString() == "already_exist") {
          showPrintedMessage(context, "Failed", "Already Exist", Colors.white,
              Colors.redAccent, Icons.info, true, "bottom");
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

  void otpverif() async {
    setState(() {
      showloader = true;
    });
    try {
      var rsp = await regurl("/register", "activateapp.php", {
        'u': emailController.text.toString(),
        'c': otppin.toString(),
        'code': referralCodeController.text,
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "false") {
          setState(() {
            showPrintedMessage(
                context,
                "Failed",
                rsp['error'].toString().replaceAll("_", " "),
                Colors.white,
                Colors.redAccent,
                Icons.info,
                true,
                "top");
            showloader = false;
          });
        } else {
          showPrintedMessage(
              context,
              "Success",
              "Account Verified Successfully",
              Colors.white,
              Colors.green,
              Icons.info,
              true,
              "top");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) => Login()));
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

  Widget? signupinputfields(String hinttext, IconData icon,
      TextEditingController control, String ktype,
      {bool isEmail = false}) {
    return TextFormField(
      controller: control,
      cursorColor: secondarycolor,
      textInputAction: TextInputAction.next,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : ktype == "number"
              ? TextInputType.phone
              : TextInputType.name,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.grey,
          size: 20,
        ),
        fillColor: Colors.white,
        filled: true,
        hintText: hinttext,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: loginbordercolor),
          borderRadius: BorderRadius.circular(10),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: loginbordercolor),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: loginbordercolor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showotp == true) {
          setState(() {
            showotp = false;
          });
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(context,
              PageTransition(type: PageTransitionType.fade, child: Login()));
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: scaffoldbgcolor,
          body: Column(
            children: [
              Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.70,
                      color: Colors.white,
                      child: Image.asset('assets/icons/bbillslogo.png'),
                    ),
                  )),
              Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50.r),
                            topLeft: Radius.circular(50.r)),
                        color: secondarycolor),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(50.w, 0.w, 50.w, 0.w),
                      child: showotp == false
                          ? ListView(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child: Form(
                                    child: Column(children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.10.h,
                                      ),
                                      Container(
                                          height: 50,
                                          child: Center(
                                            child: signupinputfields(
                                                "Full Name *",
                                                Icons.person,
                                                fullnameController,
                                                ""),
                                          )),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06.h,
                                      ),
                                      Container(
                                          height: 50,
                                          child: Center(
                                            child: signupinputfields(
                                                "Email Adress *",
                                                Icons.email,
                                                emailController,
                                                "",
                                                isEmail: true),
                                          )),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06.h,
                                      ),
                                      Container(
                                          height: 50,
                                          child: Center(
                                            child: signupinputfields(
                                                "Contact No *",
                                                Icons.phone,
                                                contController,
                                                "number"),
                                          )),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06.h,
                                      ),
                                      Container(
                                          height: 50,
                                          child: Center(
                                            child: signupinputfields(
                                                "Company Name *",
                                                Icons.business,
                                                compnameController,
                                                ""),
                                          )),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06.h,
                                      ),
                                      Container(
                                          height: 50,
                                          child: Center(
                                            child: signupinputfields(
                                                "Referral Code",
                                                Icons.offline_share,
                                                referralCodeController,
                                                ""),
                                          )),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06.h,
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          height: 42,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.90.w,
                                          child: showloader == false
                                              ? ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Color(0xfff95f1d),
                                                  ),
                                                  onPressed: () {
                                                    if (fullnameController
                                                            .text.isNotEmpty &&
                                                        emailController
                                                            .text.isNotEmpty &&
                                                        contController
                                                            .text.isNotEmpty &&
                                                        compnameController
                                                            .text.isNotEmpty) {
                                                      setState(() {
                                                        showloader = true;
                                                        register();
                                                      });
                                                    } else {
                                                      showPrintedMessage(
                                                          context,
                                                          "Alert",
                                                          "Please fill all required fields",
                                                          Colors.white,
                                                          Colors.red,
                                                          Icons.info,
                                                          true,
                                                          "top");
                                                    }
                                                  },
                                                  child: Text(
                                                    "Proceed",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ))
                                              : Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 0.85,
                                                  ),
                                                )),
                                      Container(
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10.w),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Already have an account? ",
                                                style: TextStyle(
                                                    fontSize: 30.sp,
                                                    color: Colors.white60),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Login()));
                                                },
                                                child: Text(
                                                  "Sign in ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 30.sp),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            )
                          : ListView(
                              children: [
                                SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text('Enter OTP',
                                      style: TextStyle(
                                          fontSize: 30, color: Colors.white)),
                                ),
                                OTPTextField(
                                    controller: otpController,
                                    otpFieldStyle: OtpFieldStyle(
                                        borderColor: Colors.white,
                                        backgroundColor: Colors.white),
                                    length: 4,
                                    width: MediaQuery.of(context).size.width,
                                    textFieldAlignment:
                                        MainAxisAlignment.spaceAround,
                                    fieldWidth: 55,
                                    fieldStyle: FieldStyle.box,
                                    outlineBorderRadius: 15,
                                    style: TextStyle(fontSize: 17),
                                    onChanged: (pin) {
                                      print("Changed: " + pin);
                                    },
                                    onCompleted: (pin) {
                                      //debugPrint("Completed: " + pin);
                                      setState(() {
                                        otppin = pin;
                                      });
                                    }),
                                SizedBox(height: 30),
                                Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    height: 42,
                                    child: showloader == false
                                        ? ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Color(0xfff95f1d),
                                            ),
                                            onPressed: () {
                                              if (otppin!.length == 4) {
                                                setState(() {
                                                  showloader = true;
                                                  otpverif();
                                                });
                                              } else {
                                                showPrintedMessage(
                                                    context,
                                                    "Alert",
                                                    "Enter valid OTP",
                                                    Colors.white,
                                                    Colors.red,
                                                    Icons.info,
                                                    true,
                                                    "top");
                                              }
                                            },
                                            child: Text(
                                              "Verify",
                                              style: TextStyle(fontSize: 16),
                                            ))
                                        : Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 0.85,
                                            ),
                                          )),
                              ],
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
