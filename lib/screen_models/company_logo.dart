import 'package:bbills/app_constants/appbarconstant/appbarconst.dart';
import 'package:bbills/app_constants/bottom_bar.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared preference singleton.dart';

class CompLogo extends StatefulWidget {
  @override
  _CompLogoState createState() => _CompLogoState();
}

class _CompLogoState extends State<CompLogo> {

  @override
  void initState(){
    setscreenposition();
    super.initState();
  }


  void setscreenposition() async{
    var screen = SharedPreferenceSingleton.sharedPreferences;
    setState(() {
      screen.setString("currentscreen", "complogo");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldbackground,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: AppBarColor,
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
                           Icon(Icons.circle, color: Colors.white,size: 15,),
                           SizedBox(width: 10,),
                           Text('Company Logo', style: GoogleFonts.poppins(
                               fontSize: 15, color: Colors.white
                           ),),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
               Container(
                 height: MediaQuery.of(context).size.height-140,
                 width: MediaQuery.of(context).size.width,
                 color: Colors.white,
               )
             ],
           ),
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: BottomBar(lastscreen: "complogo"),
            ),
          ],
        ),

      ),
    );
  }
}
