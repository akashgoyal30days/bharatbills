import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/screen_models/category.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../main.dart';
import '../../toast_messeger.dart';

class EditCategory extends StatefulWidget {
  EditCategory({required this.catname,required this.catdisc,required this.allparent, required this.catid});
  final String catname;
  final String catdisc;
  final List allparent;
  final String catid;
  @override
  _EditCategoryState createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {

  //required controllers
  dynamic categorynameController = TextEditingController();
  dynamic catdescriptionController = TextEditingController();
  String? parentcat;

  bool showloader = false;
  //get states
  void update () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "category.php", {
        "type":"update",
        "name": categorynameController.text.toString(),
        "cat_desc":catdescriptionController.text.toString(),
        "par_id":parentcat.toString(),
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Updated Successfully", Colors.white,Colors.green, Icons.info, true, "top");
          setState(() {
            Navigator.of(context)
                .popUntil((route) =>
            route.isFirst);
            Navigator
                .pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType
                        .fade,
                    child: CategoryScreen()));
          }
          );

        }else if(rsp['status'].toString()=="false"){  setState(() {
        showloader=false;
      });
          showPrintedMessage(context, "Error", "Failed", Colors.white,Colors.redAccent, Icons.info, true, "top");
          if(rsp['error'].toString()=="invalid_auth"){
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
          }

        }
        else if(rsp['status'].toString()=="already_exist"){
          showPrintedMessage(context, "Failed", "Category already exist", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
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

  @override
  void initState() {
  setval();
  super.initState();
  }

  void setval(){
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        categorynameController.text = widget.catname;
        catdescriptionController.text = widget.catdisc;
      });
      if(widget.catid!="0") {
        setState(() {
          parentcat = widget.catid;
        });
      }

    });

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
                child: CategoryScreen()));
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 40,
            elevation: 0,
            title: Text('Update Category', style: GoogleFonts.poppins(fontSize: 16),),
            backgroundColor: AppBarColor,
          ),
          backgroundColor: Colors.white,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child:  showloader==false?Stack(
              children: [
                ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                      child:  Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0)),),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: TextFormField(
                            decoration: new InputDecoration(
                                          isDense: true,labelText: "Caregory Name *",
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 14, color: AppBarColor
                              ),
                              fillColor: Colors.white.withOpacity(0.5),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              //fillColor: Colors.green
                            ),
                            controller: categorynameController,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                      child:  Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0)),),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: TextFormField(
                            decoration: new InputDecoration(
                                          isDense: true,labelText: "Caregory Description",
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 14, color: AppBarColor
                              ),
                              fillColor: Colors.white.withOpacity(0.5),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              //fillColor: Colors.green
                            ),
                            controller: catdescriptionController,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child:  Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0)),),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              child: DropdownButton<String>(
                                dropdownColor: Colors.white,
                                elevation: 0,
                                focusColor:Colors.transparent,
                                value: parentcat,
                                //elevation: 5,
                                style: TextStyle(color: AppBarColor),
                                iconEnabledColor:AppBarColor,
                                items: widget.allparent?.map((item) {
                                  return new DropdownMenuItem(
                                    child: new Text(item['name'],style: TextStyle(fontSize: 18, color: AppBarColor),),
                                    value: item['cat_id'].toString(),
                                  );
                                })?.toList() ??
                                    [],
                                hint:Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    "Choose Parent Category",
                                    style: GoogleFonts.poppins(
                                        color: AppBarColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                onChanged: (String? value) {
                                  FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                  FocusScopeNode currentFocus = FocusScope.of(context);

                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  setState(() {
                                    parentcat = value.toString();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: RaisedButton(
                        color: AppBarColor.withOpacity(0.9),
                        splashColor: AppBarColor.withOpacity(0.9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        onPressed: (){
                          if(categorynameController.text.isEmpty){
                            showPrintedMessage(context, "Alert", "Please fill category name fields to submit", Colors.white,Colors.redAccent, Icons.info, true, "top");
                          }else{
                            update();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Submit', style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.w500,
                                color: Colors.white
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ):Center(
              child: CircularProgressIndicator(
                strokeWidth: 0.7,
              ),
            ),
          )),
    );
  }
}
