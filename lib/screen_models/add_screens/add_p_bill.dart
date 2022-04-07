import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../shared preference singleton.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../../bbills_functional_const.dart';
import '../../main.dart';
import '../../toast_messeger.dart';
import '../all_customer.dart';
import '../all_suppliers.dart';
import 'package:dio/dio.dart';
import 'package:bbills/app_constants/api_constants.dart';

import '../purchase.dart';
import '../sales.dart';

class AddPBill extends StatefulWidget {
  @override
  _AddPBillState createState() => _AddPBillState();
}

class _AddPBillState extends State<AddPBill> {

  //-------for user type-----//
  bool isregistered =  true;

  //-------gst none or gst------//
  String gst_type = 'exclu';

  //for remembering selected additional charges gst for inclusive and exclusive
  List lastgstval = [];

  bool showaddpartyloader = false;

  List config_name = [];
  List config_val = [];

  List discountflat = [];
  List discountperct = [];
  List description = [];

  List uom1_list = [];
  List uom2_list = [];
  List ratewithout_disc = [];
  List prod_descrp = [];

  bool isnegative_stock_allowed = true;

  String selected_cloud_contact_id = '0';
  String selected_cloud_provide_discount = '0';
  bool showbill_loader = false;


  dynamic producuts_rate_Controller = TextEditingController();
  AddAmount(String pid, BuildContext context, String Product, int index, String amount, String from) {
    setState((){
      producuts_rate_Controller.text = amount.toString();
    });

    // set up the button
    Widget okButton = TextButton(
      child: Text("Save"),
      onPressed: () {
        if(from == 'main list') {
          setState(() {
            products[index]['pur_rate'] = producuts_rate_Controller.text.toString();
            // products[index]['controller'].text = '0.0';
            // products[index]['value']='0.0';

          });
        }else{
          setState(() {
            itemsprod[index]['pur_rate'] = producuts_rate_Controller.text.toString();
            // itemsprod[index]['controller'].text = '0.0';
            // itemsprod[index]['value']='0.0';
          });
        }
        Navigator.pop(context);
        setval_rate();

      },
    );
    Widget cancelButton = TextButton(
      child: Text("Discard"),
      onPressed: () {
        Navigator.pop(context);

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(Product),
      content: Container(
          height: 120,
          child: Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Text("Add Amount", style:TextStyle(fontSize:18, fontWeight:FontWeight.w500, color:Colors.black)),
              Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 2, top: 10, right:20),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child:Container(
                    width: MediaQuery.of(context).size.width,
                    child:Container(
                      height: 80,
                      width:MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5.0),
                              topLeft: Radius.circular(5.0),
                              bottomLeft: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0))),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: TextFormField(
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                            MyNumberTextInputFormatter(digit: 4),
                          ],

                          onChanged: (v){

                          },
                          decoration: new InputDecoration(
                            isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: "",
                            fillColor: Colors.white.withOpacity(0.5),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1.0,
                              ),
                            ),
                            //fillColor: Colors.green
                          ),
                          controller: producuts_rate_Controller,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
      actions: [
        okButton,
        cancelButton
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //generate bill
  void generate_Bill() async{
    setState((){
      showbill_loader = true;
    });
    List<String> subtotal = [];
    List<String> rateo = [];
    setState(() {
      for(var i=0; i<totalselected_id.length; i++) {
        subtotal.add((double.parse(total_elementwise_exclu_rate[i].toString())-double.parse(total_elementwise_exclu_tax_val[i].toString())).toStringAsFixed(2));
        rateo.add('uom1');
      }
    });
    String token = "";
    var userdetails = SharedPreferenceSingleton.sharedPreferences;
    if(userdetails.getString("utoken")!=null){
      token = userdetails.getString("utoken").toString();
    }
    try{
      FormData formData = new FormData();
      formData = FormData.fromMap({
        "_req_from": reqfrom,
        "api_key": apikey,
        "_req_token": token,
        "type":"add",
        "supplier_id": selected_cloud_contact_id,
        // "series": "manual",
        "bill_no": billno,
        "bill_date": formateddate,
        "stores": "1",
        "product": totalselected_id,
        "uom1": totalselected_val,
        "uom2":totalselected_val,
        // "list_rate":total_base_rate,
        if(gst_type!="inclu")
          "prod_rate":prod_rate_with_discount
        else
          "prod_rate": totalselected_rate,
        "disc":discountflat,
        "dis_per":discountperct,
        "description": description,
        "gst_value": totalselected_tax,
        "ftotal": total_elementwise_exclu_rate,
        "subtotal":subtotal,
        "rateo":rateo,
        if(additional_charges.isNotEmpty&&additional_charges[0]['charge_value_controller'].text.isNotEmpty)
          "freight": additional_charges[0]['charge_value_controller'].text.toString()
        else
          "freight": '0.0',
        if(additional_charges.isNotEmpty&&additional_charges[1]['charge_value_controller'].text.isNotEmpty)
          "ins": additional_charges[1]['charge_value_controller'].text.toString()
        else
          "ins": '0.0',
        if(additional_charges.isNotEmpty&&additional_charges[2]['charge_value_controller'].text.isNotEmpty)
          "pack": additional_charges[2]['charge_value_controller'].text.toString()
        else
          "pack": '0.0',
        if(additional_charges.isNotEmpty)
          "freight_gst": additional_charges[0]['sel_gst_val']
        else
          "freight_gst": gstpercent.toString(),
        if(additional_charges.isNotEmpty)
          "ins_gst": additional_charges[1]['sel_gst_val']
        else
          "ins_gst": gstpercent.toString(),
        if(additional_charges.isNotEmpty)
          "pack_gst": additional_charges[2]['sel_gst_val']
        else
          "pack_gst": gstpercent.toString(),
        "remarks": total_remarks_Controller.text.toString(),
        if(double.parse(total_amount_after_additional.toString())>double.parse(total_exclusive_val.toString()))
          "gtotal": total_amount_after_additional.toString()
        else
          "gtotal":total_exclusive_val.toString(),
        if(double.parse(total_amount_after_additional.toString())>double.parse(total_exclusive_val.toString()))
          "round": total_amount_after_additional.toString()
        else
          "round":total_exclusive_val,
        "po":"",
        "vehicle":"",
        "transported":"",
        "gr":"",
        "t_date":"",
        "form_no":"",
        if(gst_type=="exclu")
          "inc_st":"e",
        if(gst_type=="inclu")
          "inc_st":"i",
        if(gst_type=="gst-non")
          "inc_st":"n",
        "cess":[],
        "cess_per":[]
      });

      var rsp = await gbill("/member/process", "purchase.php", formData);
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showbill_loader=false;
        });
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Bill Generated Successfully", Colors.white,Colors.green, Icons.info, true, "top");
          Navigator.of(context)
              .popUntil((route) =>
          route.isFirst);
          Navigator
              .pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType
                      .fade,
                  child: PurchaseScreen()));
        }else if(rsp['status'].toString()=="false"){  setState(() {
          showcreateitemloader=false;
          showPrintedMessage(context, "Error", rsp['error'].toString(), Colors.white,Colors.red, Icons.info, true, "top");
        });
        if(rsp['error'].toString()=="invalid_auth"){
          Navigator.of(context).popUntil((route) => route.isFirst);
          showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
        }

        }
        else if(rsp['status'].toString()=="already_exist"){
          showPrintedMessage(context, "Failed", "Item not added", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
        }
      }
    }catch(error, stacktrace){
      setState(() {
        showbill_loader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.red, Icons.info, true, "bottom");
      //debugPrint('Stacktrace: ' + stacktrace.toString());
      //debugPrint(error.toString());
    }
  }





  //add party
  void addParty () async{
    setState(() {
      showaddpartyloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "supplier.php", {
        "type":"add",
        if(state!=null)
          "state": state.toString()
        else
          "state":"",
        "name": pnamedetController.text.toString(),
        "address":addressController.text.toString(),
        "phone":phoneController.text.toString(),
        "email":'',
        "city":'',
        "pin":'',
        "pan":panController.text.toString(),
        "tan":tanController.text.toString(),
        "cin":cinController.text.toString(),
        "distance":distanceController.text.toString(),
        "gst_status":'',
        "gst":gstnoController.text.toString(),
        if(isrecieve==true)
          "bal_type": "Debit (Receivable)"
        else
          "bal_type": "Credit (Payable)",
        "open_bal": openbalController.text.toString()
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showaddpartyloader=false;
        });
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Added Successfully", Colors.white,Colors.green, Icons.info, true, "top");
          setState(() {
            selectedids.clear();
            cloudcontact.clear();
            allcontact.clear();
            allcont_name.clear();
            selectednumber.clear();
            contacttype.clear();
            getSupplier();
            is_adddetails_clicked = false;
            ismoredetailclicked = false;
            phoneController.clear();
            gstnoController.clear();
            panController.clear();
            tanController.clear();
            cinController.clear();
            distanceController.clear();
            addressController.clear();
            state = null;
            isrecieve = true;
            openbalController.clear();
            items.clear();
            indexpostion.clear();
            selectednumber.clear();
            contacttype.clear();
            pnameController.clear();
            showadddetails = false;

          });

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showaddpartyloader=false;
        });
        if(rsp['error'].toString()=="invalid_auth"){
          Navigator.of(context).popUntil((route) => route.isFirst);
          showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
        }

        }
        else if(rsp['status'].toString()=="already_exist"){
          showPrintedMessage(context, "Failed", "Already Exist", Colors.white,Colors.redAccent, Icons.info, true, "top");
        }
      }
    }catch(error){
      setState(() {
        showaddpartyloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "top");
      //debugPrint(error.toString());
    }
  }

  bool showcreateitemloader = false;

  //add new item
  void addItem() async{
    setState(() {
      showcreateitemloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "product.php", {
        "type":"add",
        "cat_id": catname.toString(),
        "item_code":create_item_code_Controller.text.toString(),
        'name': add_item_name_Controller.text.toString(),
        "item_desc": remarks_Controller.text.toString(),
        "uom1": uom1.toString(),
        "uom2": '',
        "conversion": '1',
        "rate": sale_price_Controller.text.toString(),
        "pur_rate": purchase_price_Controller.text.toString(),
        "gst": gstpercent.toString(),
        "hsn_code": create_item_hsn_Controller.text.toString(),
        "pr_type": item_type.toString(),
        "min_level":'',
        "max_level":'',
        "re_level":'',
        "rate_on": "uom1",
        "open_quant": create_item_open_stock_Controller.text.toString(),
        "open_amt": create_item_open_amount_Controller.text.toString(),

      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showcreateitemloader=false;
        });
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Added Successfully", Colors.white,Colors.green, Icons.info, true, "top");
          setState(() {
            if(isnegative_stock_allowed==true){
              products.add({'iid': int.parse(rsp['iid'].toString()), 'cat_id': int.parse(catname.toString()), 'cat_name': Catlist[catname!.indexOf(catname.toString())]['name'].toString(),
                'item_code': create_item_code_Controller.text.toString(), 'name': add_item_name_Controller.text.toString(),
                'item_desc': remarks_Controller.text.toString(),
                'uom1': uom1, 'uom2': uom1,
                if(sale_price_Controller.text.isEmpty)
                  'rate': 0
                else
                  'rate': int.parse(sale_price_Controller.text.toString()),
                if(purchase_price_Controller.text.isEmpty)
                  'pur_rate': 0
                else
                  'pur_rate': int.parse(purchase_price_Controller.text.toString()),
                if(gstpercent==null)
                  'gst': 0
                else
                  'gst': int.parse(gstpercent.toString()),
                if(create_item_hsn_Controller.text.isEmpty)
                  'hsn_code': 0
                else
                  'hsn_code':int.parse(create_item_hsn_Controller.text.toString()),
                'conversion': 1, 'rate_on': 'uom1',
                'pr_type': item_type,
                'cur_bal': 0, 'cess_per': 1.00,
                'cess_on': 'taxable', 'is_active': 1, 'open_quant': 0, 'open_amt': 0, 'value': '0.0', 'controller':TextEditingController()});
            }
            else{
              if(item_type=="Stockable"){
                products.add({'iid':int.parse(rsp['iid'].toString()), 'cat_id': int.parse(catname.toString()), 'cat_name': Catlist[catname!.indexOf(catname.toString())]['name'].toString(),
                  'item_code': create_item_code_Controller.text.toString(), 'name': add_item_name_Controller.text.toString(),
                  'item_desc': remarks_Controller.text.toString(),
                  'uom1': uom1, 'uom2': uom1,
                  if(sale_price_Controller.text.isEmpty)
                    'rate': 0
                  else
                    'rate': int.parse(sale_price_Controller.text.toString()),
                  if(purchase_price_Controller.text.isEmpty)
                    'pur_rate': 0
                  else
                    'pur_rate': int.parse(purchase_price_Controller.text.toString()),
                  if(gstpercent==null)
                    'gst': 0
                  else
                    'gst': int.parse(gstpercent.toString()),
                  if(create_item_hsn_Controller.text.isEmpty)
                    'hsn_code': 0
                  else
                    'hsn_code':int.parse(create_item_hsn_Controller.text.toString()),
                  'conversion': 1, 'rate_on': 'uom1',
                  'pr_type': item_type,
                  'cur_bal': 0, 'cess_per': 1.00,
                  'cess_on': 'taxable', 'is_active': 1, 'open_quant': 0, 'open_amt': 0, 'value': '0.0', 'controller':TextEditingController()});
              }
            }
            show_create_item_screen=false;
            add_item_name_Controller.clear();
            sale_price_Controller.clear();
            purchase_price_Controller.clear();
            uom1=null;
            create_item_hsn_Controller.clear();
            newitemgstper=null;
            create_item_open_stock_Controller.clear();
            create_item_open_amount_Controller.clear();
            create_item_code_Controller.clear();
            remarks_Controller.clear();
            item_type = 'Product';
            selectedrow = 'pricing';
          }
          );

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showcreateitemloader=false;
        });
        showPrintedMessage(context, "Failed", rsp['error'].toString(), Colors.white,Colors.redAccent, Icons.info, true, "top");
        if(rsp['error'].toString()=="invalid_auth"){
          Navigator.of(context).popUntil((route) => route.isFirst);
          showPrintedMessage(context, "Error", "Session expired", Colors.white,Colors.redAccent, Icons.info, true, "bottom");
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: MyHomePage()));
        }

        }

      }
    }catch(error){
      setState(() {
        showcreateitemloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  //remembering unround value
  String un_round_items_subtotal = '';
  String un_round_items_total = '';
  List cloudcontact = [];
  String? state;
  dynamic panController = TextEditingController();
  dynamic tanController = TextEditingController();
  dynamic cinController = TextEditingController();
  dynamic distanceController = TextEditingController();

  //variables for inclusive in discount case
  String edit_total_amount_inclu_case = '0.0';
  String edit_total_tax_rate_inclu_case = '0.0';
  String edit_prod_mult_quant_iclu_case = '0.0';

  //total round
  bool isamountround = false;

  dynamic invoice_date_Controller = TextEditingController();
  dynamic start_serial_Controller = TextEditingController();

  //---------create new items variable start---------------//
  bool show_create_item_screen = false;
  dynamic add_item_name_Controller = TextEditingController();
  dynamic sale_price_Controller = TextEditingController();
  dynamic purchase_price_Controller = TextEditingController();
  dynamic create_item_hsn_Controller = TextEditingController();
  dynamic create_item_open_stock_Controller = TextEditingController();
  dynamic create_item_code_Controller = TextEditingController();
  dynamic create_item_open_amount_Controller = TextEditingController();
  dynamic remarks_Controller = TextEditingController();
  List Catlist = [];
  bool isproduct=true;
  String item_type = 'Stockable';
  String selectedrow = 'pricing';
  List uoms = [];
  String? catname;
  String? uom1;
  int initailpage = 0;
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  void bottomTapped(int index) {
    setState(() {
      initailpage = index;
      pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }
  //get uom
  void uomdrop () async{

    try{
      var rsp = await apiurl("/member/process", "product.php", {
        "type": "units",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            uoms=rsp['data'];
          }
          );

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
  //get type
  void getCat() async{
    try {
      var rsp = await apiurl("/member/process", "category.php", {
        "type": "view",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            Catlist = rsp['data'];
          });
        } else if (rsp['status'].toString() == "false") {
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(
                context,
                "Error",
                "Session expired",
                Colors.white,
                Colors.redAccent,
                Icons.info,
                true,
                "bottom");
            Navigator.pushReplacement(context, PageTransition(
                type: PageTransitionType.fade, child: MyHomePage()));
          }
        }
      }
    } catch (error) {
      showPrintedMessage(
          context,
          "Error",
          error.toString(),
          Colors.white,
          Colors.blueAccent,
          Icons.info,
          true,
          "bottom");
      //debugPrint(error.toString());
    }
  }
  //---------create new items variable end--------------//

  List? stateslist;
  String labelpan = "Pan";
  String labeltan = "Tan";
  String labelcin = "Cin";
  //get states api
  void getStates () async{
    try{
      var rsp = await apiurl("/member/process", "customer.php", {
        "type": "find_state",
        "state": "all"
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            //debugPrint(rsp['state'].length.toString());
            stateslist = rsp['state'];
            labelpan = rsp['labels']['pan'].toString();
            labeltan = rsp['labels']['tan'].toString();
            labelcin = rsp['labels']['cin'].toString();
            //debugPrint(rsp['labels'].toString());
          }
          );

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

  //get customer name from cloud
  void getSupplier () async{
    setState((){
      showfirstloader = true;
    });
    try{
      var rsp = await apiurl("/member/process", "supplier.php", {
        "type": "view_alls",
      });
      //debugPrint("customers - "+rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showfirstloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            for(var i=0; i<rsp['data'].length; i++){
              if(rsp['data'][i]['is_active'].toString()!='0') {
                cloudcontact.add(rsp['data'][i]);
                allcontact.add(0000);
                allcont_name.add(rsp['data'][i]['name'].toString());
                selectednumber.add(rsp['data'][i]['phone'].toString());
                contacttype.add('Cloud');
              }
            }
          });
          setpartyfieldheight();
          if(isphonebook_allowed == true) {
            _fetchContacts();
          }

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showfirstloader=false;
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
        showfirstloader=false;
      });
      setState(() {
        showloader=false;
      });
      showPrintedMessage(context, "Error", error.toString(), Colors.white,Colors.blueAccent, Icons.info, true, "bottom");
      //debugPrint(error.toString());
    }
  }

  //---------edit selected item variable starts-------//
  PersistentBottomSheetController? _bottomcontroller;
  PersistentBottomSheetController? _invoicecontroller;
  double heightOfeditinvoicebottom = 500.0;
  void _invoicebottosheetincrement(){
    _invoicecontroller!.setState!(
            (){
          heightOfeditinvoicebottom += 0;
        }
    );
  }

  bool ispercent = true;
  String edit_product_base_price = '0.0';
  String edit_product_tax_val = '0.0';
  String edit_product_quant = '0.0';
  String edit_product_base_with_quant = '0.0';
  dynamic new_price_Controller = TextEditingController();
  dynamic total_remarks_Controller = TextEditingController();
  dynamic edit_quant_Controller = TextEditingController();
  dynamic edit_unit_Controller = TextEditingController();
  dynamic edit_discount_percent_Controller = TextEditingController();
  dynamic edit_discount_amount_Controller = TextEditingController();
  dynamic edit_gst_Controller = TextEditingController();
  dynamic edit_item_code_Controller = TextEditingController();
  dynamic edit_item_descrip_Controller = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double heightOfModalBottomSheet = 500.0;
  void _incrementBottomSheet(){
    _bottomcontroller!.setState!(
            (){
          heightOfModalBottomSheet += 0;
        }
    );
  }
  int initailpagebottom = 0;
  PageController pageControllerbottom = PageController(
    initialPage: 0,
    keepPage: true,
  );
  String selectedrowbottom = 'pricing';
  void bottomTappedbottom(int index) {
    setState(() {
      initailpagebottom = index;
      pageControllerbottom.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }


  void on_unregistered(){
    if(isregistered==false) {
      setState(() {
        gst_type = 'gst-non';
      });
    }
  }



  bool is_adddetails_clicked= false;
  double partyname = 0.0;
  double insidecardheight = 0.0;
  double add_det_height = 0.0;
  double discountheight = 0.0;

  bool isreadonly = true;

  List allcontact = [];
  List contacttype = [];
  List allcont_name = [];
  var selectedcontact;
  List selectedids = [];
  List selectednumber = [];
  bool ismoredetailclicked = false;
  bool isrecieve=true;
  bool showadddetails = true;
  String totalitems = '0.0';
  String totalvalue = '0.0';

  bool allinclu = false;
  bool showdiscountfield = false;

  List<TextEditingController> _controller = [];
  dynamic pnameController = TextEditingController();
  dynamic pnamedetController = TextEditingController();
  dynamic phoneController = TextEditingController();
  dynamic gstnoController = TextEditingController();
  dynamic addressController = TextEditingController();
  dynamic openbalController = TextEditingController();

  dynamic discountController = TextEditingController();
  dynamic discount_percent_Controller = TextEditingController();


  List<Contact>? _contacts;
  bool _permissionDenied = false;
  @override
  void initState(){
    super.initState();
    //setting unregistered for testing
    get_status();
    format_current_date();
    getStates();
    getgstper();
    uomdrop();
    getCat();
    if(isphonebook_allowed == true) {
      _askPermissions(null);
    }

    getSupplier();
  }
  Contact? fullContact;
  Future _fetchContacts() async {

    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true,
          deduplicateProperties:true,
          sorted: true,
          withAccounts:false);
      setState(() => _contacts = contacts);
      ////debugPrint(_contacts.toString());

      for(var i =0; i<_contacts!.length; i++) {
        allcontact.add(_contacts![i].id);
        allcont_name.add(_contacts![i].displayName.toString());
        contacttype.add('Phonebook');
      }

      //debugPrint(allcontact.toString());
      //debugPrint(allcont_name.toString());
      //debugPrint(allcont_name.length.toString());


    }


  }
  Future _getContactById() async {
    setState(() {
      showadddetails = true;
    });
    if(isphonebook_allowed == true) {
      for (var i = 0; i < selectedids.length; i++) {
        if (int.parse(selectedids[i].toString()) > 0) {
          if (!await FlutterContacts.requestPermission(readonly: true)) {
            setState(() => _permissionDenied = true);
          } else {
            setState(() {

            });
            final Contact? contact = await FlutterContacts.getContact(
                selectedids[i].toString());
            try {
              if (contact != []) {
                //debugPrint(contact!.phones.first.number.toString());
                if (contact!.phones.first.number.toString() !=
                    'Bad state: No element') {
                  selectednumber.add(contact!.phones.first.number.toString());
                  contacttype.add('Phonebook');
                }
                //debugPrint(selectednumber.toString());
              }
            } catch (error) {
              //debugPrint(error.toString());
            }
          }
        } else {
          setState((){
            selectednumber.add(cloudcontact[i]['phone'].toString());
            contacttype.add('Cloud');
          });

        }
      }
    }else {
      for (var i = 0; i < selectedids.length; i++) {
        setState(() {
          selectednumber.add(cloudcontact[i]['phone'].toString());
          contacttype.add('Cloud');
        });
      }
    }
  }

  void setval_rate(){
    List aval = [];
    List rateval = [];
    setState((){
      for(var i=0; i<products.length; i++){
        if(products[i]['value']!='0.0') {
          aval.add(double.parse(products[i]['value'].toString()));
          rateval.add(double.parse(products[i]['pur_rate'].toString())*double.parse(products[i]['value'].toString()));
        }else{
          totalitems = '0.0';
          totalvalue = '0.0';
        }
      }
      totalitems = aval.reduce((a, b) => a + b).toString();
      totalvalue = rateval.reduce((a, b) => a + b).toString();
    });
    //debugPrint(aval.toString());
    //debugPrint(rateval.toString());

  }

  //setting bill date
  String formateddate = '';
  String billno = '';
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  void format_current_date() {
    final DateTime now = DateTime.now();

    final String formatted = formatter.format(now);
    setState((){
      formateddate = formatted;
      invoice_date_Controller.text = formateddate;
      start_serial_Controller.text = billno;
    });
  }
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        formateddate = formatter.format(selectedDate);
        invoice_date_Controller.text = formateddate;
      });
  }
  String total_exclusive_val = '0.0';

  double subtotalheight = 100.0;
  double addchargeheight = 0.0;

  List additional_charges = [];


  void set_exclu_rate(){
    List aval = [];
    setState((){
      for(var i=0; i<total_elementwise_exclu_rate.length; i++){
        aval.add(double.parse(total_elementwise_exclu_rate[i].toString()));
      }
      total_exclusive_val = aval.reduce((a, b) => a + b).toStringAsFixed(2);
      un_round_items_subtotal = total_exclusive_val.toString();
    });
    //debugPrint(aval.toString());
  }
  String total_amount_after_additional = '0.0';
  void sum_additional_charge(){
    List aval = [];
    setState((){
      total_amount_after_additional = '0.0';
      for(var i=0; i<additional_charges.length; i++){
        if(gst_type!='gst-non') {
          aval.add(double.parse(additional_charges[i]['val'].toString()));
        }else{
          if(additional_charges[i]['charge_value_controller'].text.isNotEmpty) {
            aval.add(double.parse(
                additional_charges[i]['charge_value_controller'].text
                    .toString()));
          }else{
            aval.add(double.parse('0.0'));
          }
        }
      }
      if(aval.isNotEmpty) {
        total_amount_after_additional = aval.reduce((a, b) => a + b).toString();

        total_amount_after_additional =
            (double.parse(total_exclusive_val.toString()) +
                double.parse(total_amount_after_additional.toString()))
                .toStringAsFixed(2);

      }else{
        total_amount_after_additional = '0.0';
        //debugPrint(total_amount_after_additional.toString());
      }
      un_round_items_total = total_amount_after_additional.toString();
      isamountround = false;
    });

  }

  List totalselected_id = [];
  List totalselected_name = [];
  List totalselected_val = [];
  List totalselected_rate = [];
  List totalselected_tax = [];
  List totalselected_uom = [];
  List totalselected_tax_type = [];//false == inclusive , true == exclusive

  List total_elementwise_inclu_rate = [];
  List total_elementwise_exclu_rate = [];
  List prod_rate_with_discount = [];

  List total_elementwise_inclu_tax_val = [];
  List total_elementwise_exclu_tax_val = [];
  List total_base_rate = [];
  List intrim_prod_base_rate = [];
  void saveselectedlist(){
    setState((){
      //clearing discount section on every next button press; user have to set the discount again
      discountController.text = '0.0';
      discount_percent_Controller.text = '0.0';
      sum_additional_charge();
      totalselected_id.clear();
      discountflat.clear();
      discountperct.clear();
      description.clear();
      totalselected_name.clear();
      totalselected_val.clear();
      totalselected_rate.clear();
      prod_rate_with_discount.clear();
      totalselected_tax.clear();
      totalselected_uom.clear();
      allids.clear();
      total_base_rate.clear();
      intrim_prod_base_rate.clear();
      totalselected_tax_type.clear();
      total_elementwise_exclu_rate.clear();
      prod_rate_with_discount.clear();
      total_elementwise_inclu_rate.clear();
      total_elementwise_inclu_tax_val.clear();
      total_elementwise_exclu_tax_val.clear();
      for(var i=0; i<products.length; i++){
        allids.add(products[i]['iid'].toString());
        if(products[i]['value']!='0.0') {
          totalselected_id.add(products[i]['iid'].toString());
          discountflat.add('0');
          description.add(products[i]['item_desc'].toString());
          discountperct.add('0');
          totalselected_name.add(products[i]['name'].toString());
          totalselected_val.add(products[i]['value'].toString());
          total_base_rate.add(products[i]['pur_rate'].toString());
          intrim_prod_base_rate.add(products[i]['pur_rate'].toString());
          prod_rate_with_discount.add(products[i]['pur_rate'].toString());
          // intrim_prod_base_rate.add((double.parse(products[i]['pur_rate'].toString())*double.parse(products[i]['value'].toString())).toStringAsFixed(2));
          //   prod_rate_with_discount.add((double.parse(products[i]['pur_rate'].toString())*double.parse(products[i]['value'].toString())).toStringAsFixed(2));
          if(gst_type!='gst-non') {
            totalselected_tax.add(products[i]['gst'].toString());
          }else{
            totalselected_tax.add('0.0');
          }
          if(gst_type!='inclu') {
            totalselected_rate.add(products[i]['pur_rate'].toString());
          }else{
            totalselected_rate.add((double.parse(products[i]['pur_rate'].toString())/(1+(double.parse(products[i]['gst'].toString())/100))).toStringAsFixed(2));
          }

          totalselected_uom.add(products[i]['uom1'].toString());
          totalselected_tax_type.add(true);
          //debugPrint(' rate '+totalselected_rate.toString());
        }
      }
      if(gst_type=='inclu') {
        for (var i = 0; i < totalselected_rate.length; i++) {
          total_elementwise_exclu_rate.add(
              ((double.parse(total_base_rate[i].toString()) *
                  double.parse(totalselected_val[i].toString()))).toStringAsFixed(2));
          total_elementwise_exclu_tax_val.add(
              ((double.parse(totalselected_tax[i].toString()) / 100) *
                  (double.parse(totalselected_rate[i].toString()) *
                      double.parse(totalselected_val[i].toString())))
                  .toStringAsFixed(2));
          if(additional_charges.isNotEmpty) {
            for (var i = 0; i < additional_charges.length; i++) {
              additional_charges[i]['sel_gst_val'] =
              lastgstval[i];
            }
          }
        }
      }
      if(gst_type=='exclu') {
        for (var i = 0; i < totalselected_rate.length; i++) {
          total_elementwise_exclu_rate.add(
              ((double.parse(totalselected_rate[i].toString()) *
                  double.parse(totalselected_val[i].toString())) + double.parse(
                  ((double.parse(totalselected_tax[i].toString()) / 100) *
                      (double.parse(totalselected_rate[i].toString()) *
                          double.parse(totalselected_val[i].toString())))
                      .toStringAsFixed(2))).toStringAsFixed(2));
          total_elementwise_exclu_tax_val.add(
              ((double.parse(totalselected_tax[i].toString()) / 100) *
                  (double.parse(totalselected_rate[i].toString()) *
                      double.parse(totalselected_val[i].toString())))
                  .toStringAsFixed(2));
        }

        if(additional_charges.isNotEmpty) {
          for (var i = 0; i < additional_charges.length; i++) {
            additional_charges[i]['sel_gst_val'] =
            lastgstval[i];

          }
        }
      }
      if(gst_type=='gst-non') {
        for (var i = 0; i < totalselected_rate.length; i++) {
          total_elementwise_exclu_rate.add(
              ((double.parse(totalselected_rate[i].toString()) *
                  double.parse(totalselected_val[i].toString())) + double.parse(
                  ((double.parse(totalselected_tax[i].toString()) / 100) *
                      (double.parse(totalselected_rate[i].toString()) *
                          double.parse(totalselected_val[i].toString())))
                      .toStringAsFixed(2))).toStringAsFixed(2));
          total_elementwise_exclu_tax_val.add(
              ((double.parse('0.0') / 100) *
                  (double.parse(totalselected_rate[i].toString()) *
                      double.parse(totalselected_val[i].toString())))
                  .toStringAsFixed(2));
        }
        String? a;
        if(additional_charges.isNotEmpty) {
          for (var i = 0; i < additional_charges.length; i++) {
            additional_charges[i]['sel_gst_val'] = a;

          }
        }
      }
      isadditem_clicked = false;
      showadddetails = true;
      partyname+=535;
    });
    set_exclu_rate();
    //debugPrint(totalselected_id.toString());
    //debugPrint(totalselected_name.toString());
    //debugPrint(totalselected_val.toString());
    //debugPrint(' rate '+totalselected_rate.toString());
    //debugPrint(totalselected_tax.toString());
    //debugPrint(totalselected_uom.toString());
    //debugPrint(totalselected_tax_type.toString());
    //debugPrint(total_elementwise_exclu_rate.toString());
    //debugPrint(total_elementwise_exclu_tax_val.toString());
    sum_additional_charge();
  }


  String? gstpercent;
  String? newitemgstper;

  double searchheight = 0.0;
  TextEditingController itemproductlistController = TextEditingController();

  //search function
  var items = [];
  var indexpostion = [];
  bool isbillfound = true;
  void filterSearchResults(String query) async{

    indexpostion.clear();
    List dummySearchList = [];
    dummySearchList.addAll(allcont_name);
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if(item.toString().toLowerCase().contains(query.toLowerCase())) {
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
          element == items[i]);
          indexpostion.add(index);
        }
        ////debugPrint(indexpostion.toString());
      });
      items.clear();
      searchheight = 50.0;
      selectedids.clear();
      selectednumber.clear();
      contacttype.clear();
      for(var i=0; i<indexpostion.length; i++){
        setState(() {
          items.add(allcont_name[int.parse(indexpostion[i].toString())]);
          selectedids.add(allcontact[indexpostion[i]]);
        });

      }

      for(var i=0; i<items.length; i++){
        setState(() {
          if(searchheight < MediaQuery.of(context).size.height/3) {
            searchheight = searchheight + 45;
            if(partyname < 500) {
              partyname = partyname + 50;
            }
          }
        });
      }
      // //debugPrint(selectedids.toString());
      // //debugPrint(selectedcontact.toString());
      // //debugPrint(selectednumber.toString());
      if(indexpostion.isNotEmpty){
        setState(() {
          insidecardheight = 50;
          _getContactById();
        });
      }else{
        setState(() {
          selectednumber.clear();
          contacttype.clear();
          searchheight = 50.0;
          partyname=265;
          insidecardheight = 0;
        });
      }
      ////debugPrint(items.toString());
      //debugPrint(selectedids.toString());
      return;
    } else {
      setState(() {
        isbillfound = true;
        items.clear();
        selectedids.clear();
        selectednumber.clear();
        contacttype.clear();
        searchheight = 50.0;
        partyname=265;
        insidecardheight = 0;
      });
    }
  }


  //getting gst_per
  List gstperlist = [];
  List gstperlist1 = [];
  List aliases = [];
  List whole_allias_array = [];
  void get_status() async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "dashboard.php", {
        "type": "billsettings",
      });
      //debugPrint('status of user - '+rsp.toString());

      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });

        if(rsp['status'].toString()=="true"){
          setState(() {
            whole_allias_array = rsp['aliases'];
            //debugPrint(whole_allias_array.toString());
            if(rsp['gst_status'].toString() == 'Registered'){
              isregistered = true;
              on_unregistered();
            }else{
              isregistered = false;
              on_unregistered();
            }
            config_name.clear();
            config_val.clear();

            for(var i=0; i<3; i++){
              Map a = {'charge_name_controller': TextEditingController(),
                'charge_value_controller': TextEditingController(),
                'val':'0.0','gst_pers':gstperlist, 'sel_gst_val': gstpercent};
              additional_charges.add(a);
              lastgstval.add(gstpercent);
            }



            for(var i=0; i<rsp['config'].length; i++){
              config_name.add(rsp['config'][i]['fieldoption'].toString());
              config_val.add(rsp['config'][i]['value'].toString());
            }
            for(var i = 0; i<rsp['aliases'].length-1; i++){
              aliases.add(rsp['aliases'][i]['original'].toString());
            }

            if(additional_charges.isNotEmpty){
              var ab = aliases.indexOf('Freight');
              var b = aliases.indexOf('Insurance');
              var c = aliases.indexOf('Packaging');
              additional_charges[0]['charge_name_controller'].text = whole_allias_array[ab]['aliase'].toString();
              additional_charges[1]['charge_name_controller'].text = whole_allias_array[b]['aliase'].toString();
              additional_charges[2]['charge_name_controller'].text = whole_allias_array[c]['aliase'].toString();
            }
            //  //debugPrint(whole_allias_array[a]['aliase'].toString());



            //debugPrint('aliases - ' + rsp['aliases'].toString());
            //debugPrint(aliases.toString());
            //debugPrint(config_name.toString());
            if(config_name.isNotEmpty){
              var a = config_name.indexOf('NSTOCK');
              //debugPrint(a.toString());
              if(config_val[a].toString()=='1'){
                isnegative_stock_allowed = true;
              }else{
                isnegative_stock_allowed = false;
              }
            }else{
              isnegative_stock_allowed = true;
            }
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


  void getgstper () async{
    setState(() {
      showloader=true;
    });
    try{
      var rsp = await apiurl("/member/process", "common.php", {
        "type": "get_gst_per",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        //debugPrint(rsp['data'].length.toString());
        if(rsp['status'].toString()=="true"){
          setState(() {
            gstperlist1 = rsp['data'];
            for(var i=0; i<rsp['data'].length; i++){
              gstperlist.add(rsp['data'][i]['gst']);
            }
            //debugPrint(gstperlist.toString());
          }

          );

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



  Future<bool> _requestPermissions() async{
    var permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    if(permission != PermissionStatus.granted){
      await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
      permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
    }
    return permission == PermissionStatus.granted;
  }
  Future<void> _askPermissions(String? routeName) async {
    bool permissionStatus = await _requestPermissions();
    if (permissionStatus == PermissionStatus.granted) {
      if (routeName != null) {
        Navigator.of(context).pushNamed(routeName);
      }
    } else {
      // _handleInvalidPermissions(permissionStatus);
    }
  }
  void _handleInvalidPermissions(PermissionStatus? permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> back_from_add_item(BuildContext context) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CupertinoAlertDialog(
              title: Text('Discard Changes ?'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                    },
                    child: Text('Stay')),
                FlatButton(
                    onPressed: () {

                      setState(() {
                        totalselected_id.clear();
                        discountflat.clear();
                        description.clear();
                        discountperct.clear();
                        totalselected_name.clear();
                        totalselected_val.clear();
                        totalselected_rate.clear();
                        prod_rate_with_discount.clear();
                        totalselected_tax.clear();
                        totalselected_uom.clear();
                        totalselected_tax_type.clear();
                        totalitems = '0.0';
                        totalvalue = '0.0';
                        isadditem_clicked = false;
                        showadddetails = true;
                        indexpostionprod.clear();
                        isbillfoundprod = true;
                        partyname = 265;
                        additional_charges.clear();
                        lastgstval.clear();
                        for(var i=0; i<3; i++){
                          Map a = {'charge_name_controller': TextEditingController(),
                            'charge_value_controller': TextEditingController(),
                            'val':'0.0','gst_pers':gstperlist, 'sel_gst_val': gstpercent};
                          additional_charges.add(a);
                          lastgstval.add(gstpercent);
                        }
                        if(additional_charges.isNotEmpty){
                          var ab = aliases.indexOf('Freight');
                          var b = aliases.indexOf('Insurance');
                          var c = aliases.indexOf('Packaging');
                          additional_charges[0]['charge_name_controller'].text = whole_allias_array[ab]['aliase'].toString();
                          additional_charges[1]['charge_name_controller'].text = whole_allias_array[b]['aliase'].toString();
                          additional_charges[2]['charge_name_controller'].text = whole_allias_array[c]['aliase'].toString();
                        }
                        discountController.text = '0.0';
                        total_exclusive_val = '0';
                        total_amount_after_additional = '';
                        total_base_rate.clear();
                        intrim_prod_base_rate.clear();
                        discount_percent_Controller.text = '0.0';
                        for(var i=0; i<products.length; i++){
                          products[i]['controller'].clear();
                          products[i]['value']='0.0';

                        }
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('Go Back'))
              ],
            ),
          );
        });
  }


  bool showpartyfields = false;


  bool isadditem_clicked = false;

  void setpartyfieldheight(){
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        partyname = 230;
      });
      Future.delayed(const Duration(milliseconds: 430), () {
        setState(() {
          showpartyfields = true;
        });
      });
    });

  }

  //product getapi
  bool showloader = false;
  bool showfirstloader = false;
  List products = [];
  List allids = [];
  void getproduct() async {
    setState(() {
      showloader = true;
    });
    try {
      Map rsp = await apiurl("/member/process", "product.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        setState(() {
          showloader = false;
        });
        if (rsp['status'].toString() == "true") {
          setState(() {
            for(var i=0; i<rsp['data'].length; i++){
              setState((){
                rsp['data'][i].addAll({'value':'0.0', 'controller':TextEditingController()});
              });
            }
            //debugPrint(rsp['data'].toString());
            for(var i=0; i<rsp['data'].length; i++) {
              if(rsp['data'][i]['is_active'].toString()=="1") {
                products.add(rsp['data'][i]);
              }
            }
            //debugPrint(products.toString());
          });
        } else if (rsp['status'].toString() == "false") {
          if (rsp['error'].toString() == "invalid_auth") {
            Navigator.of(context).popUntil((route) => route.isFirst);
            showPrintedMessage(
                context,
                "Error",
                "Session expired",
                Colors.white,
                Colors.redAccent,
                Icons.info,
                true,
                "bottom");
            Navigator.pushReplacement(context, PageTransition(
                type: PageTransitionType.fade, child: MyHomePage()));
          }
        }
      }
    } catch (error) {
      showPrintedMessage(
          context,
          "Error",
          error.toString(),
          Colors.white,
          Colors.blueAccent,
          Icons.info,
          true,
          "bottom");
      //debugPrint(error.toString());
    }
  }
  var itemsprod = [];
  var indexpostionprod = [];
  bool isbillfoundprod = true;
  void filterProductsResults(String query) {

    indexpostionprod.clear();
    List dummySearchList = [];
    dummySearchList.addAll(products);
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if(item['name'].toString().toLowerCase().contains(query.toLowerCase())||item['cat_name'].toString().toLowerCase().contains(query.toLowerCase())||item['hsn_code'].toString().toLowerCase().contains(query.toLowerCase())) {
          setState(() {
            dummyListData.add(item);
            isbillfoundprod = true;
          });
        }else{
          setState((){
            isbillfoundprod = false;
          });
        }
      });
      setState(() {
        itemsprod.clear();
        itemsprod.addAll(dummyListData);
        indexpostionprod.clear();
        for(var i=0; i<itemsprod.length; i++){
          final index = dummySearchList.indexWhere((element) =>
          element['name'] == itemsprod[i]['name']);
          indexpostionprod.add(index);
        }
        ////debugPrint(indexpostion.toString());
      });
      itemsprod.clear();
      for(var i=0; i<indexpostionprod.length; i++){
        itemsprod.add(products[int.parse(indexpostionprod[i].toString())]);
        ////debugPrint(items.toString());
      }
      return;
    } else {
      setState(() {
        isbillfoundprod = true;
        itemsprod.clear();
        itemsprod.addAll(products);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return showbill_loader==false?WillPopScope(
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
                  child: PurchaseScreen()));
          return false;
        },
        child: isadditem_clicked==false?Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0,
              leadingWidth: 20,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.circle, size: 15, color: Colors.white,),
              ),
              centerTitle: false,
              backgroundColor: AppBarColor,
              title:Text('Add Purchase Bill', style: GoogleFonts.poppins(fontSize: 16),),
            ),
            backgroundColor: Colors.white,
            bottomNavigationBar: totalselected_id.isNotEmpty?Container(
                height: 70,
                width:MediaQuery.of(context).size.width,
                color:Colors.white,
                child: RaisedButton(
                    elevation:0,
                    color:AppBarColor,
                    onPressed:(){
                      if(billno!='') {
                        generate_Bill();
                      }else{
                        showPrintedMessage(context, "Error", "Please enter bill number", Colors.white, Colors.redAccent, Icons.info, true, "top");
                      }

                    },
                    child:Text('Generate Bill', style:TextStyle(
                        fontSize: 15, color:Colors.white
                    ))
                )
            ):Container(
                height:0
            ),
            body: totalselected_id.isNotEmpty?Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color:Colors.blue.withOpacity(0.1),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: totalselected_id.length,
                  itemBuilder: (BuildContext context, index) {
                    return Container(
                      color:Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 1),
                        child: AnimatedContainer(
                          width: MediaQuery.of(context).size.width,
                          color:Colors.white,
                          duration: Duration(seconds: 1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(index==0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.white,// BoxShape.circle or BoxShape.retangle
                                        //color: const Color(0xFF66BB6A),
                                        boxShadow: [BoxShadow(
                                          color: Colors.lightBlueAccent.withOpacity(0.2),
                                          blurRadius: 5.0,
                                        ),]
                                    ),

                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width-110,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8, top: 8),
                                                child: Row(
                                                  children: [

                                                    Text('Invoice ', style: GoogleFonts.poppins(fontSize: 15, color: Colors.blueAccent),),
                                                    Text(billno, style: GoogleFonts.poppins(fontSize: 15, color: Colors.blueAccent),),

                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8, top: 2, bottom: 8),
                                                child: Row(
                                                  children: [
                                                    Text('Date - ', style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),),
                                                    Text(formateddate, style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 80,
                                          child: TextButton(
                                            onPressed: ()async{
                                              setState((){
                                                start_serial_Controller.text = billno;
                                                heightOfeditinvoicebottom = MediaQuery.of(context).size.height-10;
                                              });
                                              _invoicecontroller = await _scaffoldKey.currentState!.showBottomSheet(
                                                      (context) {
                                                    return new Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(0.0),
                                                              topLeft: Radius.circular(0.0),
                                                              bottomLeft: Radius.circular(0.0),
                                                              bottomRight: Radius.circular(0.0)),
                                                          color: Colors.white,
                                                        ),
                                                        width:MediaQuery.of(context).size.width,
                                                        height: heightOfeditinvoicebottom,
                                                        child: Center(
                                                          child: Column(
                                                              children:[
                                                                Container(
                                                                    height: 50,
                                                                    width:MediaQuery.of(context).size.width,
                                                                    child:Row(
                                                                        children:[
                                                                          Container(
                                                                            width: 80,
                                                                            child: IconButton(
                                                                                onPressed:(){
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                icon: Icon(Icons.arrow_back, size:20)),
                                                                          ),
                                                                          Container(

                                                                              width:MediaQuery.of(context).size.width-100,
                                                                              child: Row(
                                                                                children: [
                                                                                  TextButton(
                                                                                      onPressed:null,
                                                                                      child: Text('Edit Invoice Date & Number', style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.w600, letterSpacing: 0))),
                                                                                ],
                                                                              )),

                                                                        ]
                                                                    )),
                                                                Divider(),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                  child: Row(
                                                                    children: [
                                                                      Text('Invoice Date', style: GoogleFonts.poppins(
                                                                          fontSize: 15, fontWeight: FontWeight.w500
                                                                      ),),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                                                  child:  Container(
                                                                    height: 50,
                                                                    width:MediaQuery.of(context).size.width-10,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        shape: BoxShape.rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            topRight: Radius.circular(5.0),
                                                                            topLeft: Radius.circular(5.0),
                                                                            bottomLeft: Radius.circular(5.0),
                                                                            bottomRight: Radius.circular(5.0))),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                      child: TextFormField(
                                                                        readOnly:true,
                                                                        onTap: (){
                                                                          _selectDate(context);
                                                                        },
                                                                        decoration: new InputDecoration(

                                                                          suffixIconConstraints: BoxConstraints(
                                                                            minWidth: 15,
                                                                            minHeight: 48,
                                                                          ),

                                                                          suffixIcon: IconButton(onPressed:(){},
                                                                              icon:Icon(Icons.calendar_today_sharp, color:Colors.blue)),
                                                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                          labelText: "",
                                                                          fillColor: Colors.white.withOpacity(0.5),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                            borderSide: BorderSide(
                                                                              color: Colors.grey.withOpacity(0.3),
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                            borderSide: BorderSide(
                                                                              color: Colors.grey.withOpacity(0.3),
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          //fillColor: Colors.green
                                                                        ),
                                                                        controller: invoice_date_Controller,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                  child: Row(
                                                                    children: [
                                                                      Text('Invoice Number', style: GoogleFonts.poppins(
                                                                          fontSize: 15, fontWeight: FontWeight.w500
                                                                      ),),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                                                  child:  Container(
                                                                    height: 50,
                                                                    width:MediaQuery.of(context).size.width-10,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        shape: BoxShape.rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            topRight: Radius.circular(5.0),
                                                                            topLeft: Radius.circular(5.0),
                                                                            bottomLeft: Radius.circular(5.0),
                                                                            bottomRight: Radius.circular(5.0))),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                      child: TextFormField(

                                                                        readOnly:false,
                                                                        onTap: (){

                                                                        },
                                                                        decoration: new InputDecoration(


                                                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                          labelText: "",
                                                                          fillColor: Colors.white.withOpacity(0.5),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                            borderSide: BorderSide(
                                                                              color: Colors.grey.withOpacity(0.3),
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                            borderSide: BorderSide(
                                                                              color: Colors.grey.withOpacity(0.3),
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          //fillColor: Colors.green
                                                                        ),
                                                                        controller: start_serial_Controller,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Container(
                                                                    height: 50,
                                                                    width: MediaQuery.of(context).size.width,
                                                                    child: RaisedButton(
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(10)),
                                                                      elevation: 0,
                                                                      color: AppBarColor,
                                                                      onPressed: (){
                                                                        setState((){
                                                                          Navigator.pop(context);
                                                                          billno = start_serial_Controller.text.toString();
                                                                        });
                                                                      },
                                                                      child: Text('Save Invoice No', style:TextStyle(fontSize:16, color:Colors.white)),
                                                                    ),
                                                                  ),
                                                                ),

                                                                SizedBox(height:10),

                                                              ]
                                                          ),
                                                        )
                                                    );
                                                  },
                                                  backgroundColor: Colors.transparent,
                                                  elevation: 30
                                              );
                                            },
                                            child: Text('Edit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              if(index==0)
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      insidecardheight=0.0;
                                      searchheight = 0.0;
                                      indexpostion.clear();
                                      if(totalselected_id.isEmpty) {
                                        partyname = 265;
                                      }

                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 500),
                                    decoration: BoxDecoration(
                                        color: Colors.white,// BoxShape.circle or BoxShape.retangle
                                        //color: const Color(0xFF66BB6A),
                                        boxShadow: [BoxShadow(
                                          color: Colors.lightBlueAccent.withOpacity(0.2),
                                          blurRadius: 5.0,
                                        ),]
                                    ),
                                    child: showpartyfields==true?Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                          child: Row(
                                            children: [
                                              Text('PARTY NAME', style: GoogleFonts.poppins(
                                                  fontSize: 15, fontWeight: FontWeight.w500
                                              ),),
                                              Text(' *', style: GoogleFonts.poppins(
                                                  fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red
                                              ),),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                          child:  Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(5.0),
                                                    topLeft: Radius.circular(5.0),
                                                    bottomLeft: Radius.circular(5.0),
                                                    bottomRight: Radius.circular(5.0))),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                              child: TextFormField(
                                                onChanged: (v){
                                                  if(v.isEmpty){
                                                    setState(() {
                                                      items.clear();
                                                      indexpostion.clear();
                                                      selectednumber.clear();
                                                      contacttype.clear();
                                                      if(totalselected_id.isNotEmpty){
                                                        partyname = 800;
                                                      }
                                                    });
                                                  }
                                                  filterSearchResults(v.toString());
                                                },
                                                decoration: new InputDecoration(
                                                  prefixIcon: Icon(Icons.perm_identity_sharp, color: Colors.grey.withOpacity(0.9),size: 25,),
                                                  isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                  labelText: "Name",
                                                  fillColor: Colors.white.withOpacity(0.5),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey.withOpacity(0.3),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey.withOpacity(0.3),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  //fillColor: Colors.green
                                                ),
                                                controller: pnameController,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if(showadddetails==true)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(15, 8, 20, 8),
                                            child: AnimatedContainer(
                                              height: pnameController.text.isNotEmpty?searchheight+50:searchheight,
                                              width: MediaQuery.of(context).size.width,
                                              duration: Duration(milliseconds: 400),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,// BoxShape.circle or BoxShape.retangle
                                                  //color: const Color(0xFF66BB6A),
                                                  boxShadow: [BoxShadow(
                                                    color: Colors.black.withOpacity(0.2),
                                                    blurRadius: 5.0,
                                                  ),]
                                              ),
                                              child: Column(
                                                children: [
                                                  AnimatedContainer(
                                                    height: pnameController.text.isNotEmpty?50:0,
                                                    duration: Duration(milliseconds: 400),
                                                    color: AppBarColor,
                                                    child: pnameController.text.isNotEmpty? TextButton(
                                                        onPressed: (){
                                                          setState(() {
                                                            add_det_height = 350;
                                                            is_adddetails_clicked = true;
                                                            pnamedetController.text = pnameController.text.toString();
                                                          });
                                                        },
                                                        child:Row(
                                                          children: [
                                                            SizedBox(width:5),
                                                            Icon(Icons.add, size: 18, color:Colors.white),
                                                            SizedBox(width:5),
                                                            Text('Add details for'+' '+pnameController.text.toString(), style: TextStyle(color:Colors.white, fontSize:15),),
                                                          ],
                                                        )
                                                    ):Center(),
                                                  ),
                                                  AnimatedContainer(
                                                    height: searchheight,
                                                    duration: Duration(milliseconds: 400),
                                                    width: MediaQuery.of(context).size.width,
                                                    child: selectednumber.isNotEmpty?ListView.builder(
                                                        itemCount: selectednumber.length,
                                                        itemBuilder: (BuildContext context, index){
                                                          return GestureDetector(
                                                            onTap:(){
                                                              FocusScopeNode currentFocus = FocusScope.of(context);

                                                              if (!currentFocus.hasPrimaryFocus) {
                                                                currentFocus.unfocus();
                                                              }
                                                              if(contacttype[index].toString()!='Cloud'){
                                                                setState(() {
                                                                  add_det_height = 350;
                                                                  is_adddetails_clicked = true;
                                                                  pnamedetController.text = items[index].toString();
                                                                  phoneController.text = selectednumber[index].toString().replaceAll(' ', '').toString().trim();

                                                                });
                                                              }else{
                                                                setState(() {
                                                                  showadddetails = false;
                                                                  add_det_height = 0;
                                                                  insidecardheight = 0;

                                                                  searchheight = 0;
                                                                  is_adddetails_clicked = false;
                                                                  pnameController.text = items[index].toString();
                                                                  var a = allcont_name.indexOf(items[index].toString());
                                                                  selected_cloud_contact_id = cloudcontact[a]['cid'].toString();
                                                                  //debugPrint(selected_cloud_contact_id);
                                                                });
                                                              }
                                                            },
                                                            child: AnimatedContainer(
                                                              height: insidecardheight,
                                                              duration: Duration(seconds: 1),
                                                              decoration: BoxDecoration(
                                                                  color: Colors.white,// BoxShape.circle or BoxShape.retangle
                                                                  //color: const Color(0xFF66BB6A),
                                                                  boxShadow: [BoxShadow(
                                                                    color: Colors.black.withOpacity(0.2),
                                                                    blurRadius: 1.0,
                                                                  ),]
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  if(items.isNotEmpty&& items.indexOf(items[index].toString())!=-1)
                                                                    Container(
                                                                      height: 30,
                                                                      child: FloatingActionButton(
                                                                        elevation:0,
                                                                        backgroundColor: Colors.black,
                                                                        onPressed: null, child: Center(
                                                                        child: Text(items[index].toString()[0].toString().toUpperCase(), style: TextStyle(color: Colors.white),),
                                                                      ),),
                                                                    ),
                                                                  if(items.isNotEmpty&& items.indexOf(items[index].toString())!=-1)
                                                                    Container(
                                                                        width: MediaQuery.of(context).size.width-95,
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                                width: MediaQuery.of(context).size.width-150,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Text(items[index].toString(), style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),),
                                                                                    //   if(selectednumber.isNotEmpty)
                                                                                    //  Text(selectednumber[index].toString().replaceAll(' ', '').toString().trim(), style: TextStyle(fontSize: 12, color: Colors.grey),),
                                                                                  ],
                                                                                )),
                                                                            if(items.isNotEmpty)
                                                                              Text(contacttype[index].toString(), style: TextStyle(fontSize: 12, color: Colors.grey),),

                                                                          ],
                                                                        )),

                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }):Center(
                                                      child: pnameController.text.isEmpty?Text('Enter name', style: TextStyle(color:Colors.black, fontSize:15)):Text('Contact not available', style: TextStyle(color:Colors.black, fontSize:15)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Text('ITEMS', style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width,
                                            child: RaisedButton(
                                                elevation: 0,
                                                color: Colors.indigo.withOpacity(0.2),
                                                onPressed:(){
                                                  setState(() {
                                                    if(products.isEmpty) {
                                                      getproduct();
                                                    }
                                                    showadddetails=false;
                                                    partyname = 265.0;
                                                    isadditem_clicked = true;
                                                  });
                                                },
                                                child:Text('Add Items', style: TextStyle(fontSize:18, color:AppBarColor),)
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                                            child: isregistered==true?Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 90,
                                                  child: RaisedButton(
                                                    splashColor: Colors.transparent,
                                                    highlightColor: Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(00)),
                                                    elevation: 0,
                                                    color: Colors.white,
                                                    onPressed: (){
                                                      setState(() {
                                                        gst_type='exclu';
                                                      });
                                                      saveselectedlist();
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        Positioned(
                                                          top: 15,
                                                          left: 0,
                                                          right: 0,
                                                          child: Text('Exclusive', style:TextStyle(fontSize:12, color:Colors.black)),
                                                        ),

                                                        if(gst_type=='exclu')
                                                          Positioned(
                                                            top: 00,
                                                            left: 40,
                                                            right: 0,
                                                            child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(width:5),
                                                Container(
                                                  height: 40,
                                                  width: 90,
                                                  child: RaisedButton(
                                                    splashColor: Colors.transparent,
                                                    highlightColor: Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(00)),
                                                    elevation: 0,
                                                    color: Colors.white,
                                                    onPressed: (){
                                                      setState(() {
                                                        gst_type='inclu';
                                                      });
                                                      saveselectedlist();
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        Positioned(
                                                          top: 15,
                                                          left: 0,
                                                          right: 0,
                                                          child: Text('Inclusive', style:TextStyle(fontSize:12, color:Colors.black)),
                                                        ),

                                                        if(gst_type=='inclu')
                                                          Positioned(
                                                            top: 00,
                                                            left: 40,
                                                            right: 0,
                                                            child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if(isregistered==true)
                                                  SizedBox(width:5),
                                                if(isregistered==true)
                                                  Container(
                                                    height: 40,
                                                    width: 100,
                                                    child: RaisedButton(
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(00)),
                                                      elevation: 0,
                                                      color: Colors.white,
                                                      onPressed: (){
                                                        setState(() {
                                                          gst_type='gst-non';
                                                        });
                                                        saveselectedlist();
                                                      },
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            top: 15,
                                                            left: 0,
                                                            right: 0,
                                                            child: Text('GST - None', style:TextStyle(fontSize:12, color:Colors.black)),
                                                          ),

                                                          if(gst_type=='gst-non')
                                                            Positioned(
                                                              top: 00,
                                                              left: 40,
                                                              right: 0,
                                                              child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ):Container(),
                                          ),
                                        ),
                                        if(totalselected_id.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 15, right: 15),
                                            child: Divider(
                                              color: AppBarColor.withOpacity(0.3),
                                              thickness: 0.2,
                                            ),
                                          ),
                                      ],
                                    ):Container(
                                      child:Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 0.7,

                                        ),
                                      ),
                                    ),

                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, bottom: 2, top: 8, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(

                                        width:MediaQuery.of(context).size.width-180,
                                        child: Text(totalselected_name[index].toString(), style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.w600, letterSpacing: 0))),
                                    Container(
                                      width: 130,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text('₹', style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.w600, letterSpacing: 0)),
                                          Text(total_elementwise_exclu_rate[index].toString(), style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.bold, letterSpacing: 0)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left:10,top: 4, bottom: 4, right: 10),
                                child: Row(
                                  children: [
                                    Container(
                                        width:80,
                                        child: Text('Qty x Rate', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0))),
                                    Container(
                                        width:MediaQuery.of(context).size.width-180,
                                        child: Row(
                                          children: [
                                            Text(totalselected_val[index].toString(), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                            Text(totalselected_uom[index].toString(), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                            Text(' x ', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                            Text('₹', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                            Text(totalselected_rate[index].toString(), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                          ],
                                        )),
                                    Container(
                                        width: 45,
                                        height: 33,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.rectangle,
                                            border: Border.all(color: Colors.blueAccent),
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(5.0),
                                                topLeft: Radius.circular(5.0),
                                                bottomLeft: Radius.circular(5.0),
                                                bottomRight: Radius.circular(5.0))),
                                        child: TextButton(
                                            onPressed:() async{
                                              setState((){
                                                heightOfModalBottomSheet = MediaQuery.of(context).size.height - 10;
                                                edit_discount_percent_Controller.clear();
                                                discountflat[index] = '0';
                                                edit_item_descrip_Controller.text = description[index].toString();
                                                discountperct[index] = '0';
                                                edit_discount_amount_Controller.clear();
                                                if(gst_type!='inclu') {//this edit condition is for exclusive value or gst-non value on clicking on edit button
                                                  edit_discount_amount_Controller.clear();//clearing discount amount input field
                                                  edit_discount_percent_Controller.clear();//clearing discount percent input field
                                                  new_price_Controller.text = (double.parse(totalselected_rate[index].toString()) + double.parse(total_elementwise_exclu_tax_val[index].toString())).toStringAsFixed(2);//setting new price value
                                                  edit_product_base_price = totalselected_rate[index].toString();//setting product base price
                                                  edit_product_quant = totalselected_val[index].toString();//setting product selected quantinity
                                                  edit_product_base_with_quant = (double.parse(totalselected_val[index].toString()) * double.parse(totalselected_rate[index].toString())).toStringAsFixed(2); //setting value of product = base price * quantity
                                                  edit_quant_Controller.text = totalselected_val[index].toString();//setting product selected quantity into controller
                                                  edit_unit_Controller.text = totalselected_uom[index].toString();//setting product unit controller
                                                  if (gst_type != 'gst-non') {//condition if gst type is not inclu and gst_none
                                                    edit_gst_Controller.text = totalselected_tax[index].toString() + ' ' + '%';//setting gst selected percentage
                                                    edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();//setting selected value after gst calculation
                                                  } else {
                                                    edit_gst_Controller.text = '0.0' + ' ' + '%';//setting gst_controller value to 0
                                                    edit_product_tax_val = '0.0';// setting tax value to 0
                                                  }
                                                }else{//this edit condition is for inclusive value on clicking on edit button
                                                  new_price_Controller.text =total_elementwise_exclu_rate[index].toString();//setting new price value
                                                  edit_gst_Controller.text = totalselected_tax[index].toString() + ' ' + '%';//setting gst selected percentage
                                                  edit_product_base_with_quant = (double.parse(totalselected_val[index].toString()) * double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);//setting value of product = base price * quantity
                                                  edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();//setting selected value after gst calculation
                                                  edit_product_quant = totalselected_val[index].toString();//setting product selected quantinity
                                                  edit_quant_Controller.text = totalselected_val[index].toString();//setting product selected quantity into controller
                                                  edit_total_amount_inclu_case = double.parse(total_elementwise_exclu_rate[index].toString()).toStringAsFixed(2);
                                                  edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                  edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                }
                                              });
                                              _bottomcontroller = await _scaffoldKey.currentState!.showBottomSheet((context) {
                                                return new Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                          topRight: Radius.circular(0.0),
                                                          topLeft: Radius.circular(0.0),
                                                          bottomLeft: Radius.circular(0.0),
                                                          bottomRight: Radius.circular(0.0)),
                                                      color: Colors.white,
                                                    ),
                                                    width:MediaQuery.of(context).size.width,
                                                    height: heightOfModalBottomSheet,
                                                    child: Center(
                                                      child: Column(
                                                          children:[
                                                            Container(
                                                                height: 30,
                                                                width:MediaQuery.of(context).size.width,
                                                                child:Row(
                                                                    children:[
                                                                      Container(
                                                                        width: 80,
                                                                        child: IconButton(
                                                                            onPressed:(){
                                                                              Navigator.pop(context);
                                                                            },
                                                                            icon: Icon(Icons.arrow_back, size:20)),
                                                                      ),
                                                                      Container(

                                                                          width:MediaQuery.of(context).size.width-100,
                                                                          child: Row(
                                                                            children: [
                                                                              TextButton(
                                                                                  onPressed:null,
                                                                                  child: Text(totalselected_name[index].toString(), style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.w600, letterSpacing: 0))),
                                                                            ],
                                                                          )),

                                                                    ]
                                                                )),
                                                            Divider(),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left:50, right: 50),
                                                              child: Container(
                                                                  height: 70,
                                                                  width:MediaQuery.of(context).size.width,
                                                                  child: Row(
                                                                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                                      children:[
                                                                        Container(
                                                                          height: 40,
                                                                          width: 130,
                                                                          decoration: BoxDecoration(
                                                                            border: Border(
                                                                              bottom: BorderSide(width: 3.0, color: selectedrowbottom=='pricing'?Colors.lightBlue.shade900:Colors.white),
                                                                            ),
                                                                            color: Colors.white,
                                                                          ),
                                                                          child: RaisedButton(

                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(00)),
                                                                            elevation: 0,
                                                                            color: Colors.white,
                                                                            onPressed: (){
                                                                              setState(() {
                                                                                selectedrowbottom='pricing';
                                                                                bottomTappedbottom(0);
                                                                              });
                                                                            },
                                                                            child: Text('Price & Discount', style:TextStyle(fontSize:15, color:Colors.black)),
                                                                          ),
                                                                        ),
                                                                        SizedBox(width:5),
                                                                        Container(
                                                                          height: 40,
                                                                          width: 130,
                                                                          decoration: BoxDecoration(
                                                                            border: Border(
                                                                              bottom: BorderSide(width: 3.0, color: selectedrowbottom=='other'?Colors.lightBlue.shade900:Colors.white),
                                                                            ),
                                                                            color: Colors.white,
                                                                          ),
                                                                          child: RaisedButton(

                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(00)),
                                                                            elevation: 0,
                                                                            color: Colors.white,
                                                                            onPressed: (){
                                                                              setState(() {
                                                                                selectedrowbottom='other';
                                                                                bottomTappedbottom(1);
                                                                              });
                                                                            },
                                                                            child: Text('Other Details', style:TextStyle(fontSize:15, color:Colors.black)),
                                                                          ),
                                                                        ),
                                                                      ]
                                                                  )

                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height: 300,
                                                                  width:MediaQuery.of(context).size.width,
                                                                  child:PageView.builder(
                                                                      onPageChanged: (v){
                                                                        setState((){
                                                                          if(v==0){
                                                                            selectedrowbottom='pricing';
                                                                          }
                                                                          if(v==1){
                                                                            selectedrowbottom='other';
                                                                          }
                                                                        });
                                                                        _incrementBottomSheet();
                                                                      },
                                                                      itemCount:2,
                                                                      scrollDirection: Axis.horizontal,
                                                                      controller: pageControllerbottom,
                                                                      itemBuilder: (BuildContext context, indexedit){
                                                                        return ListView(
                                                                            children:[
                                                                              if(indexedit==0)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Text('New Price (With Tax)', style: GoogleFonts.poppins(
                                                                                          fontSize: 15, fontWeight: FontWeight.w500
                                                                                      ),),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==0)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                                                                                  child:  Container(
                                                                                    height: 50,
                                                                                    width:MediaQuery.of(context).size.width-10,
                                                                                    decoration: BoxDecoration(
                                                                                        color: Colors.grey.withOpacity(0.3),
                                                                                        shape: BoxShape.rectangle,
                                                                                        borderRadius: BorderRadius.only(
                                                                                            topRight: Radius.circular(5.0),
                                                                                            topLeft: Radius.circular(5.0),
                                                                                            bottomLeft: Radius.circular(5.0),
                                                                                            bottomRight: Radius.circular(5.0))),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                      child: TextFormField(
                                                                                        readOnly:true,
                                                                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                        inputFormatters: <TextInputFormatter>[
                                                                                          FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                                          MyNumberTextInputFormatter(digit: 4),
                                                                                        ],
                                                                                        onChanged: (v){

                                                                                        },
                                                                                        decoration: new InputDecoration(

                                                                                          prefixIconConstraints: BoxConstraints(
                                                                                            minWidth: 15,
                                                                                            minHeight: 48,
                                                                                          ),

                                                                                          prefixIcon: TextButton(onPressed:null,
                                                                                              child:Text('₹', style:TextStyle(fontSize:30))),
                                                                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                          labelText: "",
                                                                                          fillColor: Colors.white.withOpacity(0.5),
                                                                                          focusedBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                            borderSide: BorderSide(
                                                                                              color: Colors.transparent,
                                                                                              width: 1.0,
                                                                                            ),
                                                                                          ),
                                                                                          enabledBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                            borderSide: BorderSide(
                                                                                              color: Colors.transparent,
                                                                                              width: 1.0,
                                                                                            ),
                                                                                          ),
                                                                                          //fillColor: Colors.green
                                                                                        ),
                                                                                        controller: new_price_Controller,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==0)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10, right:10),
                                                                                  child: Row(
                                                                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width/2.2,
                                                                                        child: Text('Quantity', style: GoogleFonts.poppins(
                                                                                            fontSize: 15, fontWeight: FontWeight.w500
                                                                                        ),),
                                                                                      ),
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width/2.2,
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.only(left: 0,),
                                                                                          child: Text('Unit', style: GoogleFonts.poppins(
                                                                                              fontSize: 15, fontWeight: FontWeight.w500
                                                                                          ),),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==0)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10, right:20),
                                                                                  child: Row(
                                                                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width/2.2,
                                                                                        child:Container(
                                                                                          height: 50,
                                                                                          width:MediaQuery.of(context).size.width/2.2,
                                                                                          decoration: BoxDecoration(
                                                                                              color: Colors.grey.withOpacity(0.3),
                                                                                              shape: BoxShape.rectangle,
                                                                                              borderRadius: BorderRadius.only(
                                                                                                  topRight: Radius.circular(5.0),
                                                                                                  topLeft: Radius.circular(5.0),
                                                                                                  bottomLeft: Radius.circular(5.0),
                                                                                                  bottomRight: Radius.circular(5.0))),
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                            child: TextFormField(
                                                                                              readOnly: true,
                                                                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                              inputFormatters: <TextInputFormatter>[
                                                                                                FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                                                MyNumberTextInputFormatter(digit: 4),

                                                                                              ],
                                                                                              onChanged: (v){
                                                                                                if(gst_type!='inclu'){
                                                                                                  setState((){
                                                                                                    edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();
                                                                                                    edit_product_base_with_quant = (double.parse(totalselected_val[index].toString())*double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);
                                                                                                  });
                                                                                                  if(v.isNotEmpty){
                                                                                                    setState((){
                                                                                                      edit_product_quant = v.toString();
                                                                                                      edit_product_tax_val = ((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString()))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2);
                                                                                                    });
                                                                                                  }
                                                                                                  else{
                                                                                                    String oneval = '0.0';
                                                                                                    setState((){
                                                                                                      edit_quant_Controller.text = '0.0';
                                                                                                      edit_product_quant = edit_quant_Controller.text.toString();
                                                                                                      oneval = (double.parse(edit_prod_mult_quant_iclu_case.toString())/double.parse(edit_product_quant.toString())).toStringAsFixed(2);
                                                                                                      edit_product_tax_val = ((double.parse(edit_product_base_price.toString())*double.parse('0.0'))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2);
                                                                                                    });
                                                                                                  }
                                                                                                  //debugPrint(edit_product_quant.toString());
                                                                                                  setState((){
                                                                                                    //on quantity change set discount to 0;
                                                                                                    edit_discount_percent_Controller.clear();
                                                                                                    edit_discount_amount_Controller.clear();
                                                                                                    edit_product_base_with_quant = (double.parse(edit_product_quant.toString())*double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);;
                                                                                                  });
                                                                                                }
                                                                                                else{
                                                                                                  setState((){
                                                                                                    edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();
                                                                                                    edit_product_base_with_quant = (double.parse(totalselected_val[index].toString())*double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);
                                                                                                  });
                                                                                                  if(v.isNotEmpty){
                                                                                                    setState((){
                                                                                                      edit_product_quant = v.toString();
                                                                                                      edit_product_tax_val = ((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString()))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2);
                                                                                                    });
                                                                                                  }else{
                                                                                                    setState((){
                                                                                                      edit_quant_Controller.text = '0.0';
                                                                                                      edit_product_quant = edit_quant_Controller.text.toString();
                                                                                                      edit_product_tax_val = ((double.parse(edit_product_base_price.toString())*double.parse('0.0'))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2);
                                                                                                    });
                                                                                                  }
                                                                                                  //debugPrint(edit_product_quant.toString());
                                                                                                  setState((){
                                                                                                    //on quantity change set discount to 0;
                                                                                                    edit_discount_percent_Controller.clear();
                                                                                                    edit_discount_amount_Controller.clear();
                                                                                                    edit_product_base_with_quant = (double.parse(edit_product_quant.toString())*double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);;
                                                                                                  });
                                                                                                }
                                                                                                _incrementBottomSheet();
                                                                                              },
                                                                                              decoration: new InputDecoration(
                                                                                                isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                labelText: "",
                                                                                                fillColor: Colors.white.withOpacity(0.5),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors.transparent,
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                ),
                                                                                                enabledBorder: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors.transparent,
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                ),
                                                                                                //fillColor: Colors.green
                                                                                              ),
                                                                                              controller: edit_quant_Controller,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width/2.2,
                                                                                        child:Container(
                                                                                          height: 50,
                                                                                          width:MediaQuery.of(context).size.width/2.2,
                                                                                          decoration: BoxDecoration(
                                                                                              color: Colors.grey.withOpacity(0.3),
                                                                                              shape: BoxShape.rectangle,
                                                                                              borderRadius: BorderRadius.only(
                                                                                                  topRight: Radius.circular(5.0),
                                                                                                  topLeft: Radius.circular(5.0),
                                                                                                  bottomLeft: Radius.circular(5.0),
                                                                                                  bottomRight: Radius.circular(5.0))),
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                            child: TextFormField(
                                                                                              readOnly: true,
                                                                                              onChanged: (v){

                                                                                              },
                                                                                              decoration: new InputDecoration(
                                                                                                isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                labelText: "",
                                                                                                fillColor: Colors.grey.withOpacity(0.3),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors.transparent,
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                ),
                                                                                                enabledBorder: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors.transparent,
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                ),
                                                                                                //fillColor: Colors.green
                                                                                              ),
                                                                                              controller: edit_unit_Controller,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==0)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Text('Discount', style: GoogleFonts.poppins(
                                                                                          fontSize: 15, fontWeight: FontWeight.w500
                                                                                      ),),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==0)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                                                                  child:  Container(
                                                                                    height: 50,
                                                                                    width:MediaQuery.of(context).size.width-10,
                                                                                    decoration: BoxDecoration(
                                                                                        color: Colors.white,
                                                                                        shape: BoxShape.rectangle,
                                                                                        borderRadius: BorderRadius.only(
                                                                                            topRight: Radius.circular(5.0),
                                                                                            topLeft: Radius.circular(5.0),
                                                                                            bottomLeft: Radius.circular(5.0),
                                                                                            bottomRight: Radius.circular(5.0))),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                      child: ispercent == true?TextFormField(
                                                                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                        inputFormatters: <TextInputFormatter>[
                                                                                          FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                                          MyNumberTextInputFormatter(digit: 4),
                                                                                        ],
                                                                                        onChanged: (v){
                                                                                          if(gst_type!='inclu'){
                                                                                            setState(() {
                                                                                              edit_product_base_with_quant = (double.parse(edit_product_quant.toString())*double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);
                                                                                              edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();

                                                                                            });
                                                                                            if(v.isNotEmpty){
                                                                                              setState((){

                                                                                                if((double.parse(v.toString())<=100)){
                                                                                                  edit_discount_amount_Controller.text = ((double.parse(v.toString())/100)*double.parse(edit_product_base_with_quant.toString())).toStringAsFixed(2);
                                                                                                  edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString())-double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2);;

                                                                                                }else{
                                                                                                  edit_discount_amount_Controller.clear();
                                                                                                  edit_discount_percent_Controller.clear();
                                                                                                  edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString())-double.parse('0.0'.toString())).toStringAsFixed(2);;

                                                                                                }
                                                                                              });
                                                                                            }else{
                                                                                              setState((){
                                                                                                edit_discount_percent_Controller.clear();
                                                                                                edit_discount_amount_Controller.clear();
                                                                                                edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString())-double.parse('0.0'.toString())).toStringAsFixed(2);;


                                                                                              });
                                                                                            }
                                                                                            setState((){
                                                                                              edit_product_tax_val = ((double.parse(edit_product_base_with_quant.toString()))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2);

                                                                                            });
                                                                                          }
                                                                                          else{
                                                                                            setState((){
                                                                                              edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                              edit_total_amount_inclu_case = double.parse(total_elementwise_exclu_rate[index].toString()).toStringAsFixed(2);
                                                                                              edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                              if(v.isNotEmpty){
                                                                                                if((double.parse(v.toString())<=100)){
                                                                                                  edit_discount_amount_Controller.text = ((double.parse(v.toString())/100)*double.parse(edit_total_amount_inclu_case.toString())).toStringAsFixed(2);
                                                                                                  edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2);
                                                                                                  edit_total_tax_rate_inclu_case = (double.parse(edit_total_amount_inclu_case.toString())-double.parse((double.parse(edit_total_amount_inclu_case.toString())/(1+double.parse((double.parse(edit_gst_Controller.text.toString().replaceAll('%', ''))/100).toStringAsFixed(2)))).toStringAsFixed(2))).toStringAsFixed(2);
                                                                                                  edit_prod_mult_quant_iclu_case = double.parse((double.parse(edit_total_amount_inclu_case.toString())/(1+double.parse((double.parse(edit_gst_Controller.text.toString().replaceAll('%', ''))/100).toStringAsFixed(2)))).toStringAsFixed(2)).toStringAsFixed(2);
                                                                                                }else{
                                                                                                  edit_discount_amount_Controller.clear();
                                                                                                  edit_discount_percent_Controller.clear();
                                                                                                  edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0')).toStringAsFixed(2);
                                                                                                  edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                                  edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse('0.0')).toStringAsFixed(2);
                                                                                                  edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                                }
                                                                                              }else{
                                                                                                edit_discount_amount_Controller.clear();
                                                                                                edit_discount_percent_Controller.clear();
                                                                                                edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0')).toStringAsFixed(2);
                                                                                                edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                                edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse('0.0')).toStringAsFixed(2);
                                                                                                edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                              }
                                                                                            });

                                                                                          }
                                                                                          _incrementBottomSheet();
                                                                                        },
                                                                                        decoration: new InputDecoration(
                                                                                          suffixIconConstraints: BoxConstraints(
                                                                                            minWidth: 70,
                                                                                            minHeight: 28,
                                                                                          ),

                                                                                          suffixIcon: Container(
                                                                                              width:140,
                                                                                              height: 28,
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.only(right:10),
                                                                                                child: Row(
                                                                                                  children: [
                                                                                                    if(ispercent == true)
                                                                                                      Text('%',style:TextStyle(fontSize:15, color:Colors.black))
                                                                                                    else
                                                                                                      Text('a',style:TextStyle(fontSize:15, color:Colors.white)),
                                                                                                    SizedBox(width:10),
                                                                                                    RaisedButton(
                                                                                                        shape: RoundedRectangleBorder(
                                                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                                                            side: BorderSide(color: Colors.grey.withOpacity(0.3))
                                                                                                        ),
                                                                                                        highlightColor: Colors.transparent,
                                                                                                        splashColor:Colors.transparent,
                                                                                                        onPressed:(){
                                                                                                          setState((){
                                                                                                            if(ispercent==true){
                                                                                                              ispercent = false;
                                                                                                            }else{
                                                                                                              ispercent = true;
                                                                                                            }
                                                                                                            _incrementBottomSheet();
                                                                                                          }
                                                                                                          );
                                                                                                        }, elevation:0, color:Colors.white, child:ispercent==true?Text('Percentage'):Text('Amount')),
                                                                                                  ],
                                                                                                ),
                                                                                              )),
                                                                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                          labelText: "",
                                                                                          fillColor: Colors.white.withOpacity(0.5),
                                                                                          focusedBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                            borderSide: BorderSide(
                                                                                              color: Colors.grey.withOpacity(0.3),
                                                                                              width: 1.0,
                                                                                            ),
                                                                                          ),
                                                                                          enabledBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                            borderSide: BorderSide(
                                                                                              color: Colors.grey.withOpacity(0.3),
                                                                                              width: 1.0,
                                                                                            ),
                                                                                          ),
                                                                                          //fillColor: Colors.green
                                                                                        ),
                                                                                        controller: edit_discount_percent_Controller,
                                                                                      ):TextFormField(
                                                                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                        inputFormatters: <TextInputFormatter>[
                                                                                          FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                                          MyNumberTextInputFormatter(digit: 4),
                                                                                        ],
                                                                                        onChanged: (v){
                                                                                          if(gst_type!='inclu') {
                                                                                            setState(() {
                                                                                              edit_product_base_with_quant = (double.parse(edit_product_quant.toString()) * double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);
                                                                                              edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();
                                                                                            });
                                                                                            if (v.isNotEmpty) {
                                                                                              setState(() {
                                                                                                if ((double.parse(v.toString()) <= double.parse(edit_product_base_with_quant.toString()))) {
                                                                                                  edit_discount_percent_Controller.text = ((double.parse(v.toString()) / double.parse(totalselected_rate[index].toString())) * 100).toStringAsFixed(4);
                                                                                                  edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2);
                                                                                                } else {
                                                                                                  showPrintedMessage(context, "Error", "Discount should not be more than total basic amount", Colors.white, Colors.redAccent, Icons.info, true, "top");
                                                                                                  edit_discount_amount_Controller.clear();
                                                                                                  edit_discount_percent_Controller.clear();
                                                                                                  edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0'.toString())).toStringAsFixed(2);
                                                                                                }
                                                                                              });
                                                                                            }
                                                                                            else {
                                                                                              setState(() {
                                                                                                edit_discount_percent_Controller.clear();
                                                                                                edit_discount_amount_Controller.clear();
                                                                                                edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0'.toString())).toStringAsFixed(2);
                                                                                              });
                                                                                            }
                                                                                            setState(() {
                                                                                              edit_product_tax_val = ((double.parse(edit_product_base_with_quant.toString())) * (double.parse(edit_gst_Controller.text.toString().replaceAll(' %', '')) / 100)).toStringAsFixed(2);
                                                                                            });
                                                                                          }
                                                                                          else{
                                                                                            setState((){
                                                                                              edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                              edit_total_amount_inclu_case = double.parse(total_elementwise_exclu_rate[index].toString()).toStringAsFixed(2);
                                                                                              edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                              if (v.isNotEmpty) {
                                                                                                setState(() {
                                                                                                  if ((double.parse(v.toString()) <= double.parse((((double.parse(edit_total_amount_inclu_case.toString())*double.parse(edit_product_quant.toString()))+double.parse(edit_product_tax_val.toString()))-double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2)))) {
                                                                                                    edit_discount_percent_Controller.text = ((double.parse(v.toString()) / double.parse(edit_total_amount_inclu_case.toString())) * 100).toStringAsFixed(4);
                                                                                                    edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2);
                                                                                                    edit_total_tax_rate_inclu_case = (double.parse(edit_total_amount_inclu_case.toString())-double.parse((double.parse(edit_total_amount_inclu_case.toString())/(1+double.parse((double.parse(edit_gst_Controller.text.toString().replaceAll('%', ''))/100).toStringAsFixed(2)))).toStringAsFixed(2))).toStringAsFixed(2);
                                                                                                    edit_prod_mult_quant_iclu_case = double.parse((double.parse(edit_total_amount_inclu_case.toString())/(1+double.parse((double.parse(edit_gst_Controller.text.toString().replaceAll('%', ''))/100).toStringAsFixed(2)))).toStringAsFixed(2)).toStringAsFixed(2);
                                                                                                  } else {
                                                                                                    showPrintedMessage(context, "Error", "Discount should not be more than total amount", Colors.white, Colors.redAccent, Icons.info, true, "top");
                                                                                                    edit_discount_amount_Controller.clear();
                                                                                                    edit_discount_percent_Controller.clear();
                                                                                                    edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0')).toStringAsFixed(2);
                                                                                                    edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                                    edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse('0.0')).toStringAsFixed(2);
                                                                                                    edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                                  }
                                                                                                });
                                                                                              }else {
                                                                                                setState(() {
                                                                                                  edit_discount_amount_Controller.clear();
                                                                                                  edit_discount_percent_Controller.clear();
                                                                                                  edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0')).toStringAsFixed(2);
                                                                                                  edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                                  edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse('0.0')).toStringAsFixed(2);
                                                                                                  edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                                });
                                                                                              }
                                                                                              ////debugPrint(edit_total_tax_rate_inclu_case);
                                                                                            });
                                                                                          }
                                                                                          _incrementBottomSheet();
                                                                                        },
                                                                                        decoration: new InputDecoration(
                                                                                          suffixIconConstraints: BoxConstraints(
                                                                                            minWidth: 70,
                                                                                            minHeight: 28,
                                                                                          ),

                                                                                          suffixIcon: Container(
                                                                                              width:140,
                                                                                              height: 28,
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.only(right:10),
                                                                                                child: Row(
                                                                                                  children: [
                                                                                                    if(ispercent == true)
                                                                                                      Text('%',style:TextStyle(fontSize:15, color:Colors.black))
                                                                                                    else
                                                                                                      Text('a',style:TextStyle(fontSize:15, color:Colors.white)),
                                                                                                    SizedBox(width:10),
                                                                                                    RaisedButton(
                                                                                                        shape: RoundedRectangleBorder(
                                                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                                                            side: BorderSide(color: Colors.grey.withOpacity(0.3))
                                                                                                        ),
                                                                                                        highlightColor: Colors.transparent,
                                                                                                        splashColor:Colors.transparent,
                                                                                                        onPressed:(){
                                                                                                          setState((){
                                                                                                            if(ispercent==true){
                                                                                                              ispercent = false;
                                                                                                            }else{
                                                                                                              ispercent = true;
                                                                                                            }
                                                                                                            _incrementBottomSheet();
                                                                                                          }
                                                                                                          );
                                                                                                        }, elevation:0, color:Colors.white, child:ispercent==true?Text('Percentage'):Text('Amount')),
                                                                                                  ],
                                                                                                ),
                                                                                              )),
                                                                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                          labelText: "",
                                                                                          fillColor: Colors.white.withOpacity(0.5),
                                                                                          focusedBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                            borderSide: BorderSide(
                                                                                              color: Colors.grey.withOpacity(0.3),
                                                                                              width: 1.0,
                                                                                            ),
                                                                                          ),
                                                                                          enabledBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                            borderSide: BorderSide(
                                                                                              color: Colors.grey.withOpacity(0.3),
                                                                                              width: 1.0,
                                                                                            ),
                                                                                          ),
                                                                                          //fillColor: Colors.green
                                                                                        ),
                                                                                        controller: edit_discount_amount_Controller,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==0&&isregistered==true)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Text('Tax Rate', style: GoogleFonts.poppins(
                                                                                          fontSize: 15, fontWeight: FontWeight.w500
                                                                                      ),),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==0&&isregistered==true)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                                                                                  child:  Container(
                                                                                    height: 50,
                                                                                    width:MediaQuery.of(context).size.width-10,
                                                                                    decoration: BoxDecoration(
                                                                                        color: Colors.grey.withOpacity(0.3),
                                                                                        shape: BoxShape.rectangle,
                                                                                        borderRadius: BorderRadius.only(
                                                                                            topRight: Radius.circular(5.0),
                                                                                            topLeft: Radius.circular(5.0),
                                                                                            bottomLeft: Radius.circular(5.0),
                                                                                            bottomRight: Radius.circular(5.0))),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                      child: TextFormField(
                                                                                        readOnly:true,
                                                                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                        inputFormatters: <TextInputFormatter>[
                                                                                          FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                                          MyNumberTextInputFormatter(digit: 4),
                                                                                        ],
                                                                                        onChanged: (v){

                                                                                        },
                                                                                        decoration: new InputDecoration(

                                                                                          prefixIconConstraints: BoxConstraints(
                                                                                            minWidth: 15,
                                                                                            minHeight: 48,
                                                                                          ),

                                                                                          prefixIcon: TextButton(onPressed:null,
                                                                                              child:Text('GST @', style:TextStyle(fontSize:18, color:Colors.black))),
                                                                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                          labelText: "",
                                                                                          fillColor: Colors.white.withOpacity(0.5),
                                                                                          focusedBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                            borderSide: BorderSide(
                                                                                              color: Colors.transparent,
                                                                                              width: 1.0,
                                                                                            ),
                                                                                          ),
                                                                                          enabledBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                            borderSide: BorderSide(
                                                                                              color: Colors.transparent,
                                                                                              width: 1.0,
                                                                                            ),
                                                                                          ),
                                                                                          //fillColor: Colors.green
                                                                                        ),
                                                                                        controller: edit_gst_Controller,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==1)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Text('Item Code', style: GoogleFonts.poppins(
                                                                                          fontSize: 15, fontWeight: FontWeight.w500
                                                                                      ),),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==1)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 0, bottom: 2, top: 10, right:0),
                                                                                  child: Row(
                                                                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width,
                                                                                        child:Container(
                                                                                          height: 50,
                                                                                          width:MediaQuery.of(context).size.width-10,
                                                                                          decoration: BoxDecoration(
                                                                                              color: Colors.white,
                                                                                              shape: BoxShape.rectangle,
                                                                                              borderRadius: BorderRadius.only(
                                                                                                  topRight: Radius.circular(5.0),
                                                                                                  topLeft: Radius.circular(5.0),
                                                                                                  bottomLeft: Radius.circular(5.0),
                                                                                                  bottomRight: Radius.circular(5.0))),
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                                                                                            child: TextFormField(

                                                                                              onChanged: (v){

                                                                                              },
                                                                                              decoration: new InputDecoration(
                                                                                                isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                labelText: "",
                                                                                                fillColor: Colors.white.withOpacity(0.5),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors.grey.withOpacity(0.3),
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                ),
                                                                                                enabledBorder: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors.grey.withOpacity(0.3),
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                ),
                                                                                                //fillColor: Colors.green
                                                                                              ),
                                                                                              controller: edit_item_code_Controller,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==1)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Text('Item Description', style: GoogleFonts.poppins(
                                                                                          fontSize: 15, fontWeight: FontWeight.w500
                                                                                      ),),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              if(indexedit==1)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 0, bottom: 2, top: 10, right:0),
                                                                                  child: Row(
                                                                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width,
                                                                                        child:Container(
                                                                                          height: 50,
                                                                                          width:MediaQuery.of(context).size.width-10,
                                                                                          decoration: BoxDecoration(
                                                                                              color: Colors.white,
                                                                                              shape: BoxShape.rectangle,
                                                                                              borderRadius: BorderRadius.only(
                                                                                                  topRight: Radius.circular(5.0),
                                                                                                  topLeft: Radius.circular(5.0),
                                                                                                  bottomLeft: Radius.circular(5.0),
                                                                                                  bottomRight: Radius.circular(5.0))),
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                                                                                            child: TextFormField(

                                                                                              onChanged: (v){

                                                                                              },
                                                                                              decoration: new InputDecoration(
                                                                                                isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                labelText: "",
                                                                                                fillColor: Colors.white.withOpacity(0.5),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors.grey.withOpacity(0.3),
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                ),
                                                                                                enabledBorder: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors.grey.withOpacity(0.3),
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                ),
                                                                                                //fillColor: Colors.green
                                                                                              ),
                                                                                              controller: edit_item_descrip_Controller,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),

                                                                            ]
                                                                        );
                                                                      })
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                                                              child:  Container(
                                                                height: isregistered==true?110:80,
                                                                width:MediaQuery.of(context).size.width-10,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.grey.withOpacity(0.1),
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.only(
                                                                        topRight: Radius.circular(10.0),
                                                                        topLeft: Radius.circular(10.0),
                                                                        bottomLeft: Radius.circular(10.0),
                                                                        bottomRight: Radius.circular(10.0))),
                                                                child: Padding(
                                                                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                                    child: Container(
                                                                        child:Column(
                                                                            children:[
                                                                              Row(
                                                                                  children:[
                                                                                    Container(width:140,
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Text('Product Basic Price ',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                          Text('*',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                          Text(' Qty',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Container(width:MediaQuery.of(context).size.width-190,
                                                                                      child: Row(
                                                                                        mainAxisAlignment:MainAxisAlignment.end,
                                                                                        children: [
                                                                                          Text('₹ ',style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                          // Text((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString())).toStringAsFixed(2),style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                          if(gst_type!='inclu')
                                                                                            Text(edit_product_base_with_quant.toString(),style:TextStyle(fontSize:16, color:Colors.grey))
                                                                                          else
                                                                                            Text(edit_prod_mult_quant_iclu_case.toString(),style:TextStyle(fontSize:16, color:Colors.grey)),

                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  ]
                                                                              ),
                                                                              if(isregistered==true)
                                                                                SizedBox(height:5),
                                                                              if(isregistered==true)
                                                                                Row(
                                                                                    children:[
                                                                                      Container(width:140,
                                                                                        child: Row(
                                                                                          children: [
                                                                                            Text('Tax Rate ',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                            Text('(%)',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      Container(width:MediaQuery.of(context).size.width-190,
                                                                                        child: Row(
                                                                                          mainAxisAlignment:MainAxisAlignment.end,
                                                                                          children: [
                                                                                            Text('('+edit_gst_Controller.text.toString()+')',style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                            Text(' ₹ ',style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                            // Text(((double.parse(totalselected_rate[index].toString())*double.parse(edit_quant_Controller.text.toString()))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2),style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                            if(gst_type!='inclu')
                                                                                              Text(edit_product_tax_val.toString(),style:TextStyle(fontSize:16, color:Colors.grey))
                                                                                            else
                                                                                              Text(edit_total_tax_rate_inclu_case.toString(),style:TextStyle(fontSize:16, color:Colors.grey)),

                                                                                          ],
                                                                                        ),
                                                                                      )
                                                                                    ]
                                                                                ),
                                                                              SizedBox(height:5),
                                                                              Row(
                                                                                  children:[
                                                                                    Container(width:140,
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Text('Discount ',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Container(width:MediaQuery.of(context).size.width-190,
                                                                                      child: Row(
                                                                                        mainAxisAlignment:MainAxisAlignment.end,
                                                                                        children: [
                                                                                          if(edit_discount_percent_Controller.text.isNotEmpty)
                                                                                            Text('('+edit_discount_percent_Controller.text.toString()+'%'+')',style:TextStyle(fontSize:16, color:Colors.grey))
                                                                                          else
                                                                                            Text('('+'0.0'+'%'+')',style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                          Text(' ₹ ',style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                          if(edit_discount_amount_Controller.text.isNotEmpty)
                                                                                            Text(edit_discount_amount_Controller.text.toString(),style:TextStyle(fontSize:16, color:Colors.grey))
                                                                                          else
                                                                                            Text('0.0',style:TextStyle(fontSize:16, color:Colors.grey)), ],
                                                                                      ),
                                                                                    )
                                                                                  ]
                                                                              ),
                                                                              SizedBox(height:5),
                                                                              Row(
                                                                                  children:[
                                                                                    Container(width:140,
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Text('Total Amount ',style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold)),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Container(width:MediaQuery.of(context).size.width-190,
                                                                                      child: gst_type!='inclu'?Row(
                                                                                        mainAxisAlignment:MainAxisAlignment.end,
                                                                                        children: [
                                                                                          Text(' ₹ ',style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold)),
                                                                                          if(edit_discount_amount_Controller.text.isNotEmpty)
                                                                                            Text((((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString()))+double.parse(edit_product_tax_val.toString()))-double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2),style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold))
                                                                                          else
                                                                                            Text((((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString()))+double.parse(edit_product_tax_val.toString()))).toStringAsFixed(2),style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold))
                                                                                        ],
                                                                                      ):Row(
                                                                                        mainAxisAlignment:MainAxisAlignment.end,
                                                                                        children: [
                                                                                          Text(' ₹ ',style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold)),
                                                                                          Text(edit_total_amount_inclu_case.toString(),style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold))
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  ]
                                                                              )
                                                                            ]
                                                                        )
                                                                    )
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 20, 8),
                                                              child:  Container(
                                                                height: 50,
                                                                width:MediaQuery.of(context).size.width-10,
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.rectangle,),
                                                                child: RaisedButton(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(10)),
                                                                  onPressed:(){
                                                                    setState((){
                                                                      prod_rate_with_discount[index] = intrim_prod_base_rate[index].toString();
                                                                    });
                                                                    if(gst_type!='inclu'){
                                                                      setState((){
                                                                        totalselected_val[index] = edit_product_quant.toString();
                                                                        total_elementwise_exclu_tax_val[index] = edit_product_tax_val.toString();
                                                                        if(edit_discount_amount_Controller.text.isNotEmpty) {
                                                                          total_elementwise_exclu_rate[index] = (((double.parse(edit_product_base_price.toString()) * double.parse(edit_product_quant.toString())) + double.parse(edit_product_tax_val.toString())) - double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2);
                                                                        }
                                                                        else{
                                                                          total_elementwise_exclu_rate[index] = (((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString()))+double.parse(edit_product_tax_val.toString()))).toStringAsFixed(2);
                                                                        }
                                                                        var i = allids.indexOf(totalselected_id[index]);
                                                                        //debugPrint(i.toString());
                                                                        products[i]['value']= edit_product_quant.toString();
                                                                        products[i]['controller'].text= edit_product_quant.toString();
                                                                        setval_rate();
                                                                        List aval = [];
                                                                        List additional = [];
                                                                        if(additional_charges.isNotEmpty){
                                                                          for(var i=0; i<totalselected_id.length; i++){
                                                                            aval.add(double.parse(total_elementwise_exclu_rate[i].toString()));
                                                                          }
                                                                          total_exclusive_val=aval.reduce((a, b) => a + b).toString();
                                                                          un_round_items_subtotal = total_exclusive_val.toString();
                                                                          for(var i=0; i<additional_charges.length; i++){
                                                                            if(gst_type!='gst-non') {
                                                                              additional.add(double.parse(additional_charges[i]['val'].toString()));
                                                                            }else{
                                                                              if(additional_charges[i]['charge_value_controller'].text.isNotEmpty) {
                                                                                additional.add(double.parse(
                                                                                    additional_charges[i]['charge_value_controller'].text
                                                                                        .toString()));
                                                                              }else{
                                                                                additional.add(double.parse('0.0'));
                                                                              }
                                                                            }
                                                                          }
                                                                          if(additional.isNotEmpty) {
                                                                            total_amount_after_additional = additional.reduce((a, b) => a + b).toString();

                                                                            total_amount_after_additional =
                                                                                (double.parse(total_exclusive_val.toString()) +
                                                                                    double.parse(total_amount_after_additional.toString()))
                                                                                    .toStringAsFixed(2);

                                                                          }else{
                                                                            total_amount_after_additional = '0.0';
                                                                            //debugPrint(total_amount_after_additional.toString());
                                                                          }
                                                                          un_round_items_total = total_amount_after_additional.toString();
                                                                        }else{
                                                                          for(var i=0; i<totalselected_id.length; i++){
                                                                            aval.add(double.parse(total_elementwise_exclu_rate[i].toString()));
                                                                          }
                                                                          total_exclusive_val=aval.reduce((a, b) => a + b).toString();
                                                                          un_round_items_subtotal = total_exclusive_val.toString();
                                                                          total_amount_after_additional = total_exclusive_val.toString();
                                                                          un_round_items_total = total_amount_after_additional.toString();
                                                                        }

                                                                      });
                                                                    }
                                                                    else{
                                                                      setState((){
                                                                        total_elementwise_exclu_rate[index]= edit_total_amount_inclu_case.toString();
                                                                        totalselected_rate[index] = double.parse((double.parse(edit_prod_mult_quant_iclu_case.toString())/double.parse(totalselected_val[index].toString())).toStringAsFixed(2)).toStringAsFixed(2);
                                                                        total_elementwise_exclu_tax_val[index] = edit_total_tax_rate_inclu_case.toString();
                                                                        var i = allids.indexOf(totalselected_id[index]);
                                                                        //debugPrint(i.toString());
                                                                        products[i]['value']= edit_product_quant.toString();
                                                                        products[i]['controller'].text= edit_product_quant.toString();
                                                                        setval_rate();
                                                                        List aval = [];
                                                                        List additional = [];
                                                                        if(additional_charges.isNotEmpty){
                                                                          for(var i=0; i<totalselected_id.length; i++){
                                                                            aval.add(double.parse(total_elementwise_exclu_rate[i].toString()));
                                                                          }
                                                                          total_exclusive_val=aval.reduce((a, b) => a + b).toString();
                                                                          un_round_items_subtotal = total_exclusive_val.toString();
                                                                          for(var i=0; i<additional_charges.length; i++){
                                                                            if(gst_type!='gst-non') {
                                                                              additional.add(double.parse(additional_charges[i]['val'].toString()));
                                                                            }else{
                                                                              if(additional_charges[i]['charge_value_controller'].text.isNotEmpty) {
                                                                                additional.add(double.parse(
                                                                                    additional_charges[i]['charge_value_controller'].text
                                                                                        .toString()));
                                                                              }else{
                                                                                additional.add(double.parse('0.0'));
                                                                              }
                                                                            }
                                                                          }
                                                                          if(additional.isNotEmpty) {
                                                                            total_amount_after_additional = additional.reduce((a, b) => a + b).toString();

                                                                            total_amount_after_additional =
                                                                                (double.parse(total_exclusive_val.toString()) +
                                                                                    double.parse(total_amount_after_additional.toString()))
                                                                                    .toStringAsFixed(2);

                                                                          }else{
                                                                            total_amount_after_additional = '0.0';
                                                                            //debugPrint(total_amount_after_additional.toString());
                                                                          }
                                                                          un_round_items_total = total_amount_after_additional.toString();
                                                                        }else{
                                                                          for(var i=0; i<totalselected_id.length; i++){
                                                                            aval.add(double.parse(total_elementwise_exclu_rate[i].toString()));
                                                                          }
                                                                          total_exclusive_val=aval.reduce((a, b) => a + b).toString();
                                                                          un_round_items_subtotal = total_exclusive_val.toString();
                                                                          total_amount_after_additional = total_exclusive_val.toString();
                                                                          un_round_items_total = total_amount_after_additional.toString();
                                                                        }

                                                                      });
                                                                    }
                                                                    if(edit_discount_amount_Controller.text.isNotEmpty){
                                                                      setState((){
                                                                        discountflat[index] = (double.parse(edit_discount_amount_Controller.text.toString())/double.parse(edit_quant_Controller.text.toString())).toStringAsFixed(2);
                                                                        discountperct[index] = (double.parse((double.parse(discountflat[index].toString())/double.parse(total_base_rate[index].toString())).toString())*100).toStringAsFixed(2);
                                                                      });
                                                                    }else{
                                                                      setState((){
                                                                        discountflat[index] = '0';
                                                                        discountperct[index] = '0';
                                                                      });
                                                                    }
                                                                    setState((){
                                                                      prod_rate_with_discount[index] = (double.parse(prod_rate_with_discount[index].toString())-double.parse(discountflat[index].toString())).toStringAsFixed(2);
                                                                      if(edit_item_descrip_Controller.text.isNotEmpty){
                                                                        description[index] = edit_item_descrip_Controller.text.toString();
                                                                      }else{
                                                                        description[index] = '';
                                                                      }
                                                                    });
                                                                    //debugPrint(discountflat.toString());
                                                                    //debugPrint(discountperct.toString());
                                                                    Navigator.pop(context);
                                                                  },
                                                                  color:Colors.indigo,
                                                                  child: Text('Done', style:TextStyle(fontSize: 17, color:Colors.white)),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height:10),

                                                          ]
                                                      ),
                                                    )
                                                );
                                              },
                                                  backgroundColor: Colors.transparent,
                                                  elevation: 30
                                              );
                                            },
                                            child:Text('Edit', style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.w400),)
                                        )
                                    ),

                                  ],
                                ),
                              ),
                              if(isregistered==true)
                                Padding(
                                  padding: const EdgeInsets.only(left:10,top: 4, bottom: 4, right: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                          width:80,
                                          child: Text('Tax', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0))),
                                      Container(
                                          width:MediaQuery.of(context).size.width-132,

                                          child: Row(
                                            children: [
                                              Text(totalselected_tax[index].toString(), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                              Text('%', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                              Text(' = ', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                              Text('₹', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                              //Text(((double.parse(totalselected_tax[index].toString())/100)*(double.parse(totalselected_rate[index].toString())*double.parse(totalselected_val[index].toString()))).toStringAsFixed(2), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                              Text(total_elementwise_exclu_tax_val[index].toString(), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              if(index!=totalselected_id.length-1)
                                Padding(
                                  padding: const EdgeInsets.only(left: 50, right: 50),
                                  child: Divider(
                                    color: AppBarColor,
                                    thickness: 0.2,
                                  ),
                                ),
                              if(index==totalselected_id.length-1&&isregistered == false)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(right:10),
                                            child: Text('Round Off : ', style:TextStyle(
                                                color: Colors.indigo, fontSize:18, fontWeight:FontWeight.w600
                                            ))
                                        ),
                                        Container(
                                          width: 100,
                                          height: 40,
                                          child: Row(
                                            children: [
                                              Text('No',style: TextStyle(fontSize:12, color:AppBarColor),),
                                              Switch(
                                                onChanged: (v){
                                                  setState((){
                                                    isamountround = v;
                                                    if(v==true){
                                                      total_exclusive_val = double.parse(total_exclusive_val.toString()).round().toString();
                                                      total_amount_after_additional = double.parse(total_amount_after_additional.toString()).round().toString();
                                                    }else{
                                                      total_amount_after_additional=un_round_items_total.toString();
                                                      total_exclusive_val=un_round_items_subtotal.toString();
                                                    }
                                                  });

                                                },
                                                value: isamountround,
                                                activeColor: AppBarColor,
                                                activeTrackColor: AppBarColor.withOpacity(0.3),
                                                inactiveThumbColor: AppBarColor.withOpacity(0.3),
                                                inactiveTrackColor: AppBarColor,
                                              ),
                                              Text('Yes',style: TextStyle(fontSize:12, color:AppBarColor),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              if(index==totalselected_id.length-1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:15),
                                      child: Container(
                                          width: 100,
                                          child: Text('Items Subtotal',style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),)),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width-115,
                                      height: 40,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right:30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text('₹',style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),),
                                            SizedBox(width:5),
                                            Text(total_exclusive_val.toString(),style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),


                              if(index==totalselected_id.length-1)
                                Padding(
                                  padding: const EdgeInsets.only(left:15, right:15),
                                  child: AnimatedContainer(
                                    height: isregistered==true?subtotalheight:0.0,
                                    duration: Duration(seconds:1),
                                    color:Colors.indigo.withOpacity(0.2),
                                    child: ListView(
                                        children: [
                                          if(additional_charges.isEmpty)
                                            Container(
                                              height: 35,
                                              child: TextButton(
                                                  onPressed:null,
                                                  child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children:[
                                                        Text('Additional Charges', style:TextStyle(
                                                            color: Colors.indigo, fontSize:18
                                                        ))
                                                      ]
                                                  )
                                              ),
                                            ),
                                          if(additional_charges.isNotEmpty)
                                            Row(
                                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width:MediaQuery.of(context).size.width-230,
                                                  child: RaisedButton(
                                                    elevation:0,
                                                    color:Colors.transparent,
                                                    onPressed:(){
                                                      //debugPrint(addchargeheight.toString());
                                                      setState((){
                                                        if(addchargeheight>0){
                                                          addchargeheight = 0;
                                                          subtotalheight = 100;
                                                          partyname = 990;
                                                        }else{
                                                          addchargeheight = 60;
                                                          for(var i=0; i<additional_charges.length-1; i++){
                                                            addchargeheight = addchargeheight+60;
                                                            subtotalheight += 50;
                                                            partyname = 990;
                                                          }
                                                          subtotalheight += 70;
                                                          partyname = 990;
                                                        }
                                                      });
                                                    },
                                                    child:  Row(
                                                      children: [
                                                        if(addchargeheight>0)
                                                          Icon(Icons.arrow_circle_up, size:20, color:Colors.indigo)
                                                        else
                                                          Icon(Icons.arrow_circle_down, size:20, color:Colors.indigo),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width:200,
                                                  child: TextButton(
                                                      onPressed:null,
                                                      child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children:[

                                                            Text('Additional Charges', style:TextStyle(
                                                                color: Colors.indigo, fontSize:18
                                                            ))
                                                          ]
                                                      )
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if(additional_charges.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(left:5, right:5),
                                              child: AnimatedContainer(
                                                  height: addchargeheight,
                                                  duration: Duration(seconds:1),
                                                  child:ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: additional_charges.length,
                                                      itemBuilder: (BuildContext context, index) {
                                                        return Padding(
                                                          padding: const EdgeInsets.only(top: 5, bottom: 1),
                                                          child: AnimatedContainer(
                                                              width: MediaQuery.of(context).size.width,
                                                              duration: Duration(seconds: 1),
                                                              child: Row(
                                                                  children:[
                                                                    Padding(
                                                                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                                      child:  Container(
                                                                        height: 50,
                                                                        width: 120,
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.transparent,
                                                                            shape: BoxShape.rectangle,
                                                                            borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(5.0),
                                                                                topLeft: Radius.circular(5.0),
                                                                                bottomLeft: Radius.circular(5.0),
                                                                                bottomRight: Radius.circular(5.0))),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                                          child: TextFormField(
                                                                            readOnly : true,
                                                                            decoration: new InputDecoration(
                                                                              contentPadding:
                                                                              EdgeInsets.only(left: 5, right: 1, top: 0, bottom: 0),
                                                                              prefixIconConstraints: BoxConstraints(
                                                                                minWidth: 5,
                                                                                minHeight: 48,
                                                                              ),
                                                                              prefixIcon: Icon(Icons.edit, color: Colors.transparent,size: 5,),
                                                                              isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                              labelText: index==0?whole_allias_array[aliases.indexOf('Freight')]['aliase'].toString():index==1?whole_allias_array[aliases.indexOf('Packaging')]['aliase'].toString():whole_allias_array[aliases.indexOf('Insurance')]['aliase'].toString(),
                                                                              labelStyle: TextStyle(fontSize:13),
                                                                              fillColor: Colors.white.withOpacity(0.5),
                                                                              focusedBorder: UnderlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.transparent,
                                                                                  width: 1.0,
                                                                                ),
                                                                              ),
                                                                              enabledBorder: UnderlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.transparent,
                                                                                  width: 1.0,
                                                                                ),
                                                                              ),
                                                                              //fillColor: Colors.green
                                                                            ),
                                                                            controller: additional_charges[index]['charge_name_controller'],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                                      child:  Container(
                                                                        height: 50,
                                                                        width: 70,
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.transparent,
                                                                            shape: BoxShape.rectangle,
                                                                            borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(5.0),
                                                                                topLeft: Radius.circular(5.0),
                                                                                bottomLeft: Radius.circular(5.0),
                                                                                bottomRight: Radius.circular(5.0))),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                                          child: TextFormField(
                                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                            inputFormatters: <TextInputFormatter>[
                                                                              FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                              MyNumberTextInputFormatter(digit: 2),
                                                                            ],
                                                                            onChanged: (v){
                                                                              if(v.isNotEmpty){
                                                                                setState((){
                                                                                  //total_exclusive_val
                                                                                  additional_charges[index]['val'] = v.toString();
                                                                                  //debugPrint(additional_charges[index]['val'].toString());
                                                                                  if(additional_charges[index]['sel_gst_val']!=null){
                                                                                    setState(() {
                                                                                      //debugPrint(additional_charges[index]['val'].toString());
                                                                                      additional_charges[index]['val'] = additional_charges[index]['charge_value_controller'].text.toString();
                                                                                      additional_charges[index]['val'] = (((double.parse(additional_charges[index]['sel_gst_val'].toString())/100)*(double.parse(additional_charges[index]['val'].toString())))+(double.parse(additional_charges[index]['val'].toString()))).toStringAsFixed(2);
                                                                                    });
                                                                                    //debugPrint(additional_charges[index]['val'].toString());
                                                                                    sum_additional_charge();
                                                                                  }
                                                                                });
                                                                              }else{
                                                                                setState((){
                                                                                  additional_charges[index]['val'] = '0.0';
                                                                                  //debugPrint(additional_charges[index]['val'].toString());
                                                                                });
                                                                              }
                                                                              sum_additional_charge();
                                                                              // total_exclusive_val = (double.parse(total_exclusive_val.toString())+double.parse(additional_charges[index]['val'].toString())).toStringAsFixed(2);
                                                                            },
                                                                            decoration: new InputDecoration(
                                                                              contentPadding:
                                                                              EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                                                              prefixIconConstraints: BoxConstraints(
                                                                                minWidth: 25,
                                                                                minHeight: 25,
                                                                              ),
                                                                              prefixIcon: Container(
                                                                                width:25,
                                                                                child: TextButton(
                                                                                    onPressed:null,
                                                                                    child: Text('₹', style:TextStyle(fontSize:20, color:Colors.black, fontWeight:FontWeight.bold))),
                                                                              ),
                                                                              isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                              labelText: "0.0",
                                                                              fillColor: Colors.white.withOpacity(0.5),
                                                                              focusedBorder: UnderlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.white,
                                                                                  width: 1.0,
                                                                                ),
                                                                              ),
                                                                              enabledBorder: UnderlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.white,
                                                                                  width: 1.0,
                                                                                ),
                                                                              ),
                                                                              //fillColor: Colors.green
                                                                            ),
                                                                            controller: additional_charges[index]['charge_value_controller'],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                                      child:  Container(
                                                                        height: 48,
                                                                        width: 65,
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.transparent,
                                                                          shape: BoxShape.rectangle,
                                                                        ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                                          child: DropdownButtonHideUnderline(
                                                                            child: ButtonTheme(
                                                                              child: DropdownButton<String>(
                                                                                dropdownColor: Colors.white,
                                                                                elevation: 0,
                                                                                focusColor:Colors.transparent,
                                                                                value: additional_charges[index]['sel_gst_val'],
                                                                                //elevation: 5,
                                                                                style: TextStyle(color: AppBarColor),
                                                                                iconEnabledColor:AppBarColor,
                                                                                items: additional_charges[index]['gst_pers'].map<DropdownMenuItem<String>>((item) =>
                                                                                new DropdownMenuItem<String>(
                                                                                  child: new Text(item.toString()+" "+ "%",style: TextStyle(fontSize: 18, color: AppBarColor),),
                                                                                  value: item.toString(),
                                                                                )
                                                                                ).toList(),

                                                                                hint:Padding(
                                                                                  padding: const EdgeInsets.only(left: 5),
                                                                                  child: Text(
                                                                                    "GST %",
                                                                                    style: GoogleFonts.poppins(
                                                                                        color: AppBarColor,
                                                                                        fontSize: 15,
                                                                                        fontWeight: FontWeight.w400),
                                                                                  ),
                                                                                ),
                                                                                onChanged: double.parse(additional_charges[index]['val'].toString()) == 0||gst_type=='gst-non'?null:(String? value) {
                                                                                  setState(() {
                                                                                    //debugPrint(additional_charges[index]['val'].toString());
                                                                                    additional_charges[index]['val'] = additional_charges[index]['charge_value_controller'].text.toString();
                                                                                    lastgstval[index]=value.toString();
                                                                                    additional_charges[index]['sel_gst_val'] = value.toString();
                                                                                    additional_charges[index]['val'] = (((double.parse(value.toString())/100)*(double.parse(additional_charges[index]['val'].toString())))+(double.parse(additional_charges[index]['val'].toString()))).toStringAsFixed(2);
                                                                                  });
                                                                                  //debugPrint(additional_charges[index]['val'].toString());
                                                                                  sum_additional_charge();
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    IconButton(
                                                                      onPressed:(){
                                                                        setState(() {
                                                                          additional_charges[index]['charge_value_controller'].text = '0.0';
                                                                          lastgstval[index] = gstpercent;
                                                                          additional_charges[index]['sel_gst_val'] = gstpercent;
                                                                          additional_charges[index]['val'] = '0.0';
                                                                          //debugPrint(addchargeheight.toString());
                                                                          //debugPrint(additional_charges.length.toString());
                                                                          sum_additional_charge();
                                                                        });
                                                                      },
                                                                      icon:Icon(Icons.cancel, color:Colors.white),
                                                                    )
                                                                  ]
                                                              )
                                                          ),
                                                        );
                                                      }

                                                  )
                                              ),
                                            ),
                                          /*     if(showdiscountfield==false)
                                        Container(
                                            height:30,
                                          child: TextButton(
                                              onPressed:(){
                                               setState((){
                                                 discountheight = 60.0;
                                                 showdiscountfield=true;
                                               });
                                              },
                                              child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children:[
                                                    Icon(Icons.add, size:18, color:Colors.indigo),
                                                    Text('Discount', style:TextStyle(
                                                        color: Colors.indigo, fontSize:18
                                                    ))
                                                  ]
                                              )
                                          ),
                                        ),
                                        if(showdiscountfield==true)
                                        Padding(
                                          padding: const EdgeInsets.only(left:10, right:20),
                                          child: AnimatedContainer(
                                              width: MediaQuery.of(context).size.width,
                                              height: discountheight,
                                              duration: Duration(seconds: 1),
                                              child: Row(
                                                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(10, 5, 5, 0),
                                                    child: Text('Discount', style:TextStyle(
                                                        color: Colors.indigo, fontSize:18
                                                    )),
                                                  ),
                                                  Row(
                                                       mainAxisAlignment:MainAxisAlignment.center,
                                                      children:[
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                          child:  Container(
                                                            height: 50,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                color: Colors.transparent,
                                                                shape: BoxShape.rectangle,
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius.circular(5.0),
                                                                    topLeft: Radius.circular(5.0),
                                                                    bottomLeft: Radius.circular(5.0),
                                                                    bottomRight: Radius.circular(5.0))),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                              child: TextFormField(
                                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                inputFormatters: <TextInputFormatter>[
                                                                  FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                  MyNumberTextInputFormatter(digit: 4),
                                                                ],
                                                                onChanged: (v){
                                                                  if(v.isNotEmpty){
                                                                    setState((){

                                                                      if((double.parse(v.toString())<=double.parse(total_exclusive_val.toString()))){
                                                                        set_exclu_rate();
                                                                        discount_percent_Controller.text = ((double.parse(v.toString())/double.parse(total_exclusive_val.toString()))*100).toStringAsFixed(4);
                                                                        total_exclusive_val = (double.parse(total_exclusive_val.toString())-double.parse(v.toString())).toStringAsFixed(2);
                                                                        sum_additional_charge();
                                                                      }else{
                                                                        showPrintedMessage(context, "Error", "Discount should not be more than Item Subtotal", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                                                        discountController.text = '0.0';
                                                                        discount_percent_Controller.text = '0.0';
                                                                        set_exclu_rate();
                                                                        sum_additional_charge();
                                                                      }
                                                                      });
                                                                  }else{
                                                                    setState((){
                                                                      discount_percent_Controller.text = '0.0';
                                                                      set_exclu_rate();
                                                                      sum_additional_charge();
                                                                    });
                                                                  }

                                                                },
                                                                decoration: new InputDecoration(
                                                                  contentPadding:
                                                                  EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                                                  prefixIconConstraints: BoxConstraints(
                                                                    minWidth: 25,
                                                                    minHeight: 25,
                                                                  ),
                                                                  prefixIcon: Container(
                                                                    width:25,
                                                                    child: TextButton(
                                                                        onPressed:null,
                                                                        child: Text('₹', style:TextStyle(fontSize:20, color:Colors.black, fontWeight:FontWeight.bold))),
                                                                  ),
                                                                  isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                  labelText: "0.0",
                                                                  fillColor: Colors.white.withOpacity(0.5),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.white,
                                                                      width: 1.0,
                                                                    ),
                                                                  ),
                                                                  enabledBorder: UnderlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.white,
                                                                      width: 1.0,
                                                                    ),
                                                                  ),
                                                                  //fillColor: Colors.green
                                                                ),
                                                                controller: discountController,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                          child:  Container(
                                                            height: 50,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                color: Colors.transparent,
                                                                shape: BoxShape.rectangle,
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius.circular(5.0),
                                                                    topLeft: Radius.circular(5.0),
                                                                    bottomLeft: Radius.circular(5.0),
                                                                    bottomRight: Radius.circular(5.0))),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                              child: TextFormField(
                                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                inputFormatters: <TextInputFormatter>[
                                                                  FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                  MyNumberTextInputFormatter(digit: 4),
                                                                ],
                                                                onChanged: (v){
                                                                  if(v.isNotEmpty){
                                                                    if(double.parse(v.toString())>=0&&double.parse(v.toString())<=100){
                                                                      setState((){
                                                                        set_exclu_rate();
                                                                        discountController.text = ((double.parse(v.toString())/100)*double.parse(total_exclusive_val.toString())).toStringAsFixed(2);
                                                                        total_exclusive_val = (double.parse(total_exclusive_val.toString())-double.parse(discountController.text.toString())).toStringAsFixed(2);
                                                                        sum_additional_charge();
                                                                      });
                                                                    }else{
                                                                      setState((){
                                                                        discount_percent_Controller.text = '100.0';
                                                                        set_exclu_rate();
                                                                        v='';
                                                                        discountController.text=total_exclusive_val.toString();
                                                                        total_exclusive_val = (double.parse(total_exclusive_val.toString())-double.parse(discountController.text.toString())).toStringAsFixed(2);
                                                                        sum_additional_charge();
                                                                      });
                                                                    }
                                                                  }else{
                                                                    setState((){
                                                                      discountController.text='0.0';
                                                                      total_exclusive_val = (double.parse(total_exclusive_val.toString())-double.parse(discountController.text.toString())).toStringAsFixed(2);
                                                                      set_exclu_rate();
                                                                      sum_additional_charge();
                                                                    });
                                                                  }

                                                               },
                                                                decoration: new InputDecoration(
                                                                  contentPadding:
                                                                  EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                                                  suffixIconConstraints: BoxConstraints(
                                                                    minWidth: 25,
                                                                    minHeight: 25,
                                                                  ),
                                                                  suffixIcon: Container(
                                                                    width:25,
                                                                    child: TextButton(
                                                                        onPressed:null,
                                                                        child: Text('%', style:TextStyle(fontSize:20, color:Colors.black, fontWeight:FontWeight.bold))),
                                                                  ),
                                                                  isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                  labelText: "0.0",
                                                                  fillColor: Colors.white.withOpacity(0.5),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.white,
                                                                      width: 1.0,
                                                                    ),
                                                                  ),
                                                                  enabledBorder: UnderlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.white,
                                                                      width: 1.0,
                                                                    ),
                                                                  ),
                                                                  //fillColor: Colors.green
                                                                ),
                                                                controller: discount_percent_Controller,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed:(){
                                                           setState(() {
                                                             discountheight = 0.0;
                                                             showdiscountfield=false;
                                                             //addchargeheight = addchargeheight-60;
                                                               discountController.text = '0.0';
                                                               discount_percent_Controller.text = '0.0';
                                                               set_exclu_rate();
                                                               sum_additional_charge();
                                                           });
                                                          },
                                                          icon:Icon(Icons.cancel, color:Colors.white),
                                                        )
                                                      ]
                                                  ),
                                                ],
                                              )
                                          ),
                                        ),*/
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.only(right:10),
                                                  child: Text('Round Off : ', style:TextStyle(
                                                      color: Colors.indigo, fontSize:18, fontWeight:FontWeight.w600
                                                  ))
                                              ),
                                              Container(
                                                width: 100,
                                                height: 40,
                                                child: Row(
                                                  children: [
                                                    Text('No',style: TextStyle(fontSize:12, color:AppBarColor),),
                                                    Switch(
                                                      onChanged: (v){

                                                        setState((){
                                                          isamountround = v;
                                                          if(v==true){
                                                            total_exclusive_val = double.parse(total_exclusive_val.toString()).round().toString();
                                                            total_amount_after_additional = double.parse(total_amount_after_additional.toString()).round().toString();
                                                          }else{
                                                            total_amount_after_additional=un_round_items_total.toString();
                                                            total_exclusive_val=un_round_items_subtotal.toString();
                                                          }
                                                        });

                                                      },
                                                      value: isamountround,
                                                      activeColor: AppBarColor,
                                                      activeTrackColor: AppBarColor.withOpacity(0.3),
                                                      inactiveThumbColor: AppBarColor.withOpacity(0.3),
                                                      inactiveTrackColor: AppBarColor,
                                                    ),
                                                    Text('Yes',style: TextStyle(fontSize:12, color:AppBarColor),),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                        ]
                                    ),
                                  ),
                                ),
                              if(index==totalselected_id.length-1)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  child: Divider(
                                    color: AppBarColor.withOpacity(0.3),
                                    thickness: 0.2,
                                  ),
                                ),
                              if(index==totalselected_id.length-1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:15),
                                      child: Container(
                                          width: 100,
                                          child: Text('Total',style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),)),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width-115,
                                      height: 40,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right:30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text('₹',style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),),
                                            SizedBox(width:5),
                                            if(double.parse(total_amount_after_additional.toString())>double.parse(total_exclusive_val.toString()))
                                              Text(total_amount_after_additional.toString(),style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),)
                                            else
                                              Text(total_exclusive_val.toString(),style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if(index==totalselected_id.length-1)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                                  child:  Container(
                                    height: 50,
                                    width:MediaQuery.of(context).size.width-10,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(5.0),
                                            topLeft: Radius.circular(5.0),
                                            bottomLeft: Radius.circular(5.0),
                                            bottomRight: Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      child: TextFormField(
                                        readOnly:false,
                                        onChanged: (v){

                                        },
                                        decoration: new InputDecoration(

                                          prefixIconConstraints: BoxConstraints(
                                            minWidth: 15,
                                            minHeight: 48,
                                          ),

                                          prefixIcon: IconButton(onPressed:null,
                                              icon:Icon(Icons.ballot_outlined,size:20, color:Colors.grey)),
                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                          labelText: "Remarks",
                                          fillColor: Colors.white.withOpacity(0.5),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey.withOpacity(0.3),
                                              width: 1.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey.withOpacity(0.3),
                                              width: 1.0,
                                            ),
                                          ),
                                          //fillColor: Colors.green
                                        ),
                                        controller: total_remarks_Controller,
                                      ),
                                    ),
                                  ),
                                ),
                              if(index==totalselected_id.length-1)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  child: Divider(
                                    color: AppBarColor.withOpacity(0.3),
                                    thickness: 0.2,
                                  ),
                                ),
                              if(index==totalselected_id.length-1)
                                Container(
                                    height: 100
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
              ),
            ):Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color:Colors.blue.withOpacity(0.1),
                child: is_adddetails_clicked==false?ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                            color: Colors.white,// BoxShape.circle or BoxShape.retangle
                            //color: const Color(0xFF66BB6A),
                            boxShadow: [BoxShadow(
                              color: Colors.lightBlueAccent.withOpacity(0.2),
                              blurRadius: 5.0,
                            ),]
                        ),

                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width-110,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, top: 8),
                                    child: Row(
                                      children: [
                                        Text('Invoice ', style: GoogleFonts.poppins(fontSize: 15, color: Colors.blueAccent),),
                                        Text(billno, style: GoogleFonts.poppins(fontSize: 15, color: Colors.blueAccent),),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, top: 2, bottom: 8),
                                    child: Row(
                                      children: [
                                        Text('Date - ', style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),),
                                        Text(formateddate, style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: 80,
                              child: TextButton(
                                onPressed: ()async{
                                  setState((){
                                    start_serial_Controller.text = billno;
                                    heightOfeditinvoicebottom = MediaQuery.of(context).size.height-10;
                                  });
                                  _invoicecontroller = await _scaffoldKey.currentState!.showBottomSheet(
                                          (context) {
                                        return new Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(0.0),
                                                  topLeft: Radius.circular(0.0),
                                                  bottomLeft: Radius.circular(0.0),
                                                  bottomRight: Radius.circular(0.0)),
                                              color: Colors.white,
                                            ),
                                            width:MediaQuery.of(context).size.width,
                                            height: heightOfeditinvoicebottom,
                                            child: Center(
                                              child: Column(
                                                  children:[
                                                    Container(
                                                        height: 30,
                                                        width:MediaQuery.of(context).size.width,
                                                        child:Row(
                                                            children:[
                                                              Container(
                                                                width: 80,
                                                                child: IconButton(
                                                                    onPressed:(){
                                                                      Navigator.pop(context);
                                                                    },
                                                                    icon: Icon(Icons.arrow_back, size:20)),
                                                              ),
                                                              Container(

                                                                  width:MediaQuery.of(context).size.width-100,
                                                                  child: Row(
                                                                    children: [
                                                                      TextButton(
                                                                          onPressed:null,
                                                                          child: Text('Edit Invoice Date & Number', style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.w600, letterSpacing: 0))),
                                                                    ],
                                                                  )),

                                                            ]
                                                        )),
                                                    Divider(),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                      child: Row(
                                                        children: [
                                                          Text('Invoice Date', style: GoogleFonts.poppins(
                                                              fontSize: 15, fontWeight: FontWeight.w500
                                                          ),),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                                      child:  Container(
                                                        height: 50,
                                                        width:MediaQuery.of(context).size.width-10,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            shape: BoxShape.rectangle,
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(5.0),
                                                                topLeft: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0))),
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                          child: TextFormField(
                                                            readOnly:true,
                                                            onTap: (){
                                                              _selectDate(context);
                                                            },
                                                            decoration: new InputDecoration(

                                                              suffixIconConstraints: BoxConstraints(
                                                                minWidth: 15,
                                                                minHeight: 48,
                                                              ),

                                                              suffixIcon: IconButton(onPressed:(){},
                                                                  icon:Icon(Icons.calendar_today_sharp, color:Colors.blue)),
                                                              isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                              labelText: "",
                                                              fillColor: Colors.white.withOpacity(0.5),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide(
                                                                  color: Colors.grey.withOpacity(0.3),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide(
                                                                  color: Colors.grey.withOpacity(0.3),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              //fillColor: Colors.green
                                                            ),
                                                            controller: invoice_date_Controller,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                      child: Row(
                                                        children: [
                                                          Text('Invoice Number', style: GoogleFonts.poppins(
                                                              fontSize: 15, fontWeight: FontWeight.w500
                                                          ),),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                                      child:  Container(
                                                        height: 50,
                                                        width:MediaQuery.of(context).size.width-10,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            shape: BoxShape.rectangle,
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(5.0),
                                                                topLeft: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0))),
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                          child: TextFormField(

                                                            readOnly:false,
                                                            onTap: (){

                                                            },
                                                            decoration: new InputDecoration(


                                                              isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                              labelText: "",
                                                              fillColor: Colors.white.withOpacity(0.5),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide(
                                                                  color: Colors.grey.withOpacity(0.3),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide(
                                                                  color: Colors.grey.withOpacity(0.3),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              //fillColor: Colors.green
                                                            ),
                                                            controller: start_serial_Controller,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Container(
                                                        height: 50,
                                                        width: MediaQuery.of(context).size.width,
                                                        child: RaisedButton(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10)),
                                                          elevation: 0,
                                                          color: AppBarColor,
                                                          onPressed: (){
                                                            setState((){
                                                              Navigator.pop(context);
                                                              billno = start_serial_Controller.text.toString();
                                                            });
                                                          },
                                                          child: Text('Save Invoice No', style:TextStyle(fontSize:16, color:Colors.white)),
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(height:10),

                                                  ]
                                              ),
                                            )
                                        );
                                      },
                                      backgroundColor: Colors.transparent,
                                      elevation: 30
                                  );
                                },
                                child: Text('Edit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if(showfirstloader==false)
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            insidecardheight=0.0;
                            searchheight = 0.0;
                            indexpostion.clear();
                            if(totalselected_id.isEmpty) {
                              partyname = 265;
                            }

                          });
                        },
                        child: AnimatedContainer(
                          //height: totalselected_id.isNotEmpty?915:searchheight!=0?915+searchheight:partyname,
                          duration: Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                              color: Colors.white,// BoxShape.circle or BoxShape.retangle
                              //color: const Color(0xFF66BB6A),
                              boxShadow: [BoxShadow(
                                color: Colors.lightBlueAccent.withOpacity(0.2),
                                blurRadius: 5.0,
                              ),]
                          ),
                          child: showpartyfields==true?Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                child: Row(
                                  children: [
                                    Text('PARTY NAME', style: GoogleFonts.poppins(
                                        fontSize: 15, fontWeight: FontWeight.w500
                                    ),),
                                    Text(' *', style: GoogleFonts.poppins(
                                        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red
                                    ),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                child:  Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5.0),
                                          topLeft: Radius.circular(5.0),
                                          bottomLeft: Radius.circular(5.0),
                                          bottomRight: Radius.circular(5.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: TextFormField(
                                      onChanged: (v){
                                        if(v.isEmpty){
                                          setState(() {
                                            items.clear();
                                            indexpostion.clear();
                                            selectednumber.clear();
                                            contacttype.clear();
                                            if(totalselected_id.isNotEmpty){
                                              partyname = 800;
                                            }
                                          });
                                        }
                                        filterSearchResults(v.toString());
                                      },
                                      decoration: new InputDecoration(
                                        prefixIcon: Icon(Icons.perm_identity_sharp, color: Colors.grey.withOpacity(0.9),size: 25,),
                                        isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                        labelText: "Name",
                                        fillColor: Colors.white.withOpacity(0.5),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.3),
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.3),
                                            width: 1.0,
                                          ),
                                        ),
                                        //fillColor: Colors.green
                                      ),
                                      controller: pnameController,
                                    ),
                                  ),
                                ),
                              ),
                              if(showadddetails==true)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(15, 8, 20, 8),
                                  child: AnimatedContainer(
                                    height: pnameController.text.isNotEmpty?searchheight+50:searchheight,
                                    width: MediaQuery.of(context).size.width,
                                    duration: Duration(milliseconds: 400),
                                    decoration: BoxDecoration(
                                        color: Colors.white,// BoxShape.circle or BoxShape.retangle
                                        //color: const Color(0xFF66BB6A),
                                        boxShadow: [BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5.0,
                                        ),]
                                    ),
                                    child: Column(
                                      children: [
                                        AnimatedContainer(
                                          height: pnameController.text.isNotEmpty?50:0,
                                          duration: Duration(milliseconds: 400),
                                          color: AppBarColor,
                                          child: pnameController.text.isNotEmpty? TextButton(
                                              onPressed: (){
                                                setState(() {
                                                  add_det_height = 350;
                                                  is_adddetails_clicked = true;
                                                  pnamedetController.text = pnameController.text.toString();
                                                });
                                              },
                                              child:Row(
                                                children: [
                                                  SizedBox(width:5),
                                                  Icon(Icons.add, size: 18, color:Colors.white),
                                                  SizedBox(width:5),
                                                  Text('Add details for'+' '+pnameController.text.toString(), style: TextStyle(color:Colors.white, fontSize:15),),
                                                ],
                                              )
                                          ):Center(),
                                        ),
                                        AnimatedContainer(
                                          height: searchheight,
                                          duration: Duration(milliseconds: 400),
                                          width: MediaQuery.of(context).size.width,
                                          child: items.isNotEmpty?ListView.builder(
                                              itemCount: selectednumber.length,
                                              itemBuilder: (BuildContext context, indexk){
                                                return GestureDetector(
                                                  onTap:(){
                                                    FocusScopeNode currentFocus = FocusScope.of(context);

                                                    if (!currentFocus.hasPrimaryFocus) {
                                                      currentFocus.unfocus();
                                                    }
                                                    if(contacttype[indexk].toString()!='Cloud'){
                                                      setState(() {
                                                        add_det_height = 350;
                                                        is_adddetails_clicked = true;
                                                        pnamedetController.text = items[indexk].toString();
                                                        phoneController.text = selectednumber[indexk].toString().replaceAll(' ', '').toString().trim();

                                                      });
                                                    }else{
                                                      setState(() {
                                                        showadddetails = false;
                                                        add_det_height = 0;
                                                        insidecardheight = 0;
                                                        searchheight = 0;
                                                        is_adddetails_clicked = false;
                                                        pnameController.text = items[indexk].toString();
                                                        var a = allcont_name.indexOf(items[indexk].toString());
                                                        selected_cloud_contact_id = cloudcontact[a]['cid'].toString();
                                                        //debugPrint(selected_cloud_contact_id);
                                                      });
                                                    }
                                                  },
                                                  child: AnimatedContainer(
                                                    height: insidecardheight,
                                                    duration: Duration(seconds: 1),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,// BoxShape.circle or BoxShape.retangle
                                                        //color: const Color(0xFF66BB6A),
                                                        boxShadow: [BoxShadow(
                                                          color: Colors.black.withOpacity(0.2),
                                                          blurRadius: 1.0,
                                                        ),]
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        if(items.isNotEmpty&& items.indexOf(items[indexk].toString())!=-1)
                                                          Container(
                                                            height: 30,
                                                            child: FloatingActionButton(
                                                              elevation:0,
                                                              backgroundColor: Colors.black,
                                                              onPressed: null, child: Center(
                                                              child: Text(items[indexk].toString()[0].toString().toUpperCase(), style: TextStyle(color: Colors.white),),
                                                            ),),
                                                          ),
                                                        if(items.isNotEmpty&& items.indexOf(items[indexk].toString())!=-1)
                                                          Container(
                                                              width: MediaQuery.of(context).size.width-95,
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Container(
                                                                      width: MediaQuery.of(context).size.width-150,
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(items[indexk].toString(), style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),),
                                                                          //   if(selectednumber.isNotEmpty)
                                                                          //  Text(selectednumber[index].toString().replaceAll(' ', '').toString().trim(), style: TextStyle(fontSize: 12, color: Colors.grey),),
                                                                        ],
                                                                      )),
                                                                  if(items.isNotEmpty)
                                                                    Text(contacttype[indexk].toString(), style: TextStyle(fontSize: 12, color: Colors.grey),),

                                                                ],
                                                              )),

                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }):Center(
                                            child: pnameController.text.isEmpty?Text('Enter name', style: TextStyle(color:Colors.black, fontSize:15)):Text('Contact not available', style: TextStyle(color:Colors.black, fontSize:15)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text('ITEMS', style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: RaisedButton(
                                      elevation: 0,
                                      color: Colors.indigo.withOpacity(0.2),
                                      onPressed:(){
                                        setState(() {
                                          if(products.isEmpty) {
                                            getproduct();
                                          }
                                          showadddetails=false;
                                          partyname = 265.0;
                                          isadditem_clicked = true;
                                        });
                                      },
                                      child:Text('Add Items', style: TextStyle(fontSize:18, color:AppBarColor),)
                                  ),
                                ),
                              ),
                              if(totalselected_id.isNotEmpty)
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                                    child: isregistered==true?Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 90,
                                          child: RaisedButton(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(00)),
                                            elevation: 0,
                                            color: Colors.white,
                                            onPressed: (){
                                              setState(() {
                                                gst_type='exclu';
                                              });
                                              saveselectedlist();
                                            },
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 15,
                                                  left: 0,
                                                  right: 0,
                                                  child: Text('Exclusive', style:TextStyle(fontSize:12, color:Colors.black)),
                                                ),

                                                if(gst_type=='exclu')
                                                  Positioned(
                                                    top: 00,
                                                    left: 40,
                                                    right: 0,
                                                    child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        SizedBox(width:5),
                                        Container(
                                          height: 40,
                                          width: 90,
                                          child: RaisedButton(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(00)),
                                            elevation: 0,
                                            color: Colors.white,
                                            onPressed: (){
                                              setState(() {
                                                gst_type='inclu';
                                              });
                                              saveselectedlist();
                                            },
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 15,
                                                  left: 0,
                                                  right: 0,
                                                  child: Text('Inclusive', style:TextStyle(fontSize:12, color:Colors.black)),
                                                ),

                                                if(gst_type=='inclu')
                                                  Positioned(
                                                    top: 00,
                                                    left: 40,
                                                    right: 0,
                                                    child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if(isregistered==true)
                                          SizedBox(width:5),
                                        if(isregistered==true)
                                          Container(
                                            height: 40,
                                            width: 100,
                                            child: RaisedButton(
                                              splashColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(00)),
                                              elevation: 0,
                                              color: Colors.white,
                                              onPressed: (){
                                                setState(() {
                                                  gst_type='gst-non';
                                                });
                                                saveselectedlist();
                                              },
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    top: 15,
                                                    left: 0,
                                                    right: 0,
                                                    child: Text('GST - None', style:TextStyle(fontSize:12, color:Colors.black)),
                                                  ),

                                                  if(gst_type=='gst-non')
                                                    Positioned(
                                                      top: 00,
                                                      left: 40,
                                                      right: 0,
                                                      child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ):Container(),
                                  ),
                                ),
                              if(totalselected_id.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  child: Divider(
                                    color: AppBarColor.withOpacity(0.3),
                                    thickness: 0.2,
                                  ),
                                ),
                              if(totalselected_id.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  child: AnimatedContainer(
                                    height: totalselected_id.length>=3?280:totalselected_id.length*100,
                                    width: MediaQuery.of(context).size.width,
                                    duration: Duration(seconds: 1),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: totalselected_id.length,
                                        itemBuilder: (BuildContext context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 1),
                                            child: AnimatedContainer(
                                              width: MediaQuery.of(context).size.width,
                                              duration: Duration(seconds: 1),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(

                                                          width:MediaQuery.of(context).size.width-180,
                                                          child: Text(totalselected_name[index].toString(), style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.w600, letterSpacing: 0))),
                                                      Container(
                                                        width: 130,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Text('₹', style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.w600, letterSpacing: 0)),
                                                            Text(total_elementwise_exclu_rate[index].toString(), style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.bold, letterSpacing: 0)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                            width:80,
                                                            child: Text('Qty x Rate', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0))),
                                                        Container(
                                                            width:MediaQuery.of(context).size.width-180,
                                                            child: Row(
                                                              children: [
                                                                Text(totalselected_val[index].toString(), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                                Text(totalselected_uom[index].toString(), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                                Text(' x ', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                                Text('₹', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                                Text(totalselected_rate[index].toString(), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                              ],
                                                            )),
                                                        Container(
                                                            width: 45,
                                                            height: 33,
                                                            decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                shape: BoxShape.rectangle,
                                                                border: Border.all(color: Colors.blueAccent),
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius.circular(5.0),
                                                                    topLeft: Radius.circular(5.0),
                                                                    bottomLeft: Radius.circular(5.0),
                                                                    bottomRight: Radius.circular(5.0))),
                                                            child: TextButton(
                                                                onPressed:() async{
                                                                  setState((){
                                                                    heightOfModalBottomSheet = MediaQuery.of(context).size.height - 10;
                                                                    edit_discount_percent_Controller.clear();
                                                                    discountflat[index] = '0';
                                                                    edit_item_descrip_Controller.text = description[index].toString();
                                                                    discountperct[index] = '0';
                                                                    edit_discount_amount_Controller.clear();
                                                                    if(gst_type!='inclu') {//this edit condition is for exclusive value or gst-non value on clicking on edit button
                                                                      edit_discount_amount_Controller.clear();//clearing discount amount input field
                                                                      edit_discount_percent_Controller.clear();//clearing discount percent input field
                                                                      new_price_Controller.text = (double.parse(totalselected_rate[index].toString()) + double.parse(total_elementwise_exclu_tax_val[index].toString())).toStringAsFixed(2);//setting new price value
                                                                      edit_product_base_price = totalselected_rate[index].toString();//setting product base price
                                                                      edit_product_quant = totalselected_val[index].toString();//setting product selected quantinity
                                                                      edit_product_base_with_quant = (double.parse(totalselected_val[index].toString()) * double.parse(totalselected_rate[index].toString())).toStringAsFixed(2); //setting value of product = base price * quantity
                                                                      edit_quant_Controller.text = totalselected_val[index].toString();//setting product selected quantity into controller
                                                                      edit_unit_Controller.text = totalselected_uom[index].toString();//setting product unit controller
                                                                      if (gst_type != 'gst-non') {//condition if gst type is not inclu and gst_none
                                                                        edit_gst_Controller.text = totalselected_tax[index].toString() + ' ' + '%';//setting gst selected percentage
                                                                        edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();//setting selected value after gst calculation
                                                                      } else {
                                                                        edit_gst_Controller.text = '0.0' + ' ' + '%';//setting gst_controller value to 0
                                                                        edit_product_tax_val = '0.0';// setting tax value to 0
                                                                      }
                                                                    }else{//this edit condition is for inclusive value on clicking on edit button
                                                                      new_price_Controller.text =total_elementwise_exclu_rate[index].toString();//setting new price value
                                                                      edit_gst_Controller.text = totalselected_tax[index].toString() + ' ' + '%';//setting gst selected percentage
                                                                      edit_product_base_with_quant = (double.parse(totalselected_val[index].toString()) * double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);//setting value of product = base price * quantity
                                                                      edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();//setting selected value after gst calculation
                                                                      edit_product_quant = totalselected_val[index].toString();//setting product selected quantinity
                                                                      edit_quant_Controller.text = totalselected_val[index].toString();//setting product selected quantity into controller
                                                                      edit_total_amount_inclu_case = double.parse(total_elementwise_exclu_rate[index].toString()).toStringAsFixed(2);
                                                                      edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                      edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                    }
                                                                  });
                                                                  _bottomcontroller = await _scaffoldKey.currentState!.showBottomSheet((context) {
                                                                    return new Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.only(
                                                                              topRight: Radius.circular(0.0),
                                                                              topLeft: Radius.circular(0.0),
                                                                              bottomLeft: Radius.circular(0.0),
                                                                              bottomRight: Radius.circular(0.0)),
                                                                          color: Colors.white,
                                                                        ),
                                                                        width:MediaQuery.of(context).size.width,
                                                                        height: heightOfModalBottomSheet,
                                                                        child: Center(
                                                                          child: Column(
                                                                              children:[
                                                                                Container(
                                                                                    height: 50,
                                                                                    width:MediaQuery.of(context).size.width,
                                                                                    child:Row(
                                                                                        children:[
                                                                                          Container(
                                                                                            width: 80,
                                                                                            child: IconButton(
                                                                                                onPressed:(){
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                icon: Icon(Icons.arrow_back, size:20)),
                                                                                          ),
                                                                                          Container(

                                                                                              width:MediaQuery.of(context).size.width-100,
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  TextButton(
                                                                                                      onPressed:null,
                                                                                                      child: Text(totalselected_name[index].toString(), style: TextStyle(fontSize:16, color:AppBarColor, fontWeight: FontWeight.w600, letterSpacing: 0))),
                                                                                                ],
                                                                                              )),

                                                                                        ]
                                                                                    )),
                                                                                Divider(),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left:50, right: 50),
                                                                                  child: Container(
                                                                                      height: 70,
                                                                                      width:MediaQuery.of(context).size.width,
                                                                                      child: Row(
                                                                                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                                                          children:[
                                                                                            Container(
                                                                                              height: 40,
                                                                                              width: 130,
                                                                                              decoration: BoxDecoration(
                                                                                                border: Border(
                                                                                                  bottom: BorderSide(width: 3.0, color: selectedrowbottom=='pricing'?Colors.lightBlue.shade900:Colors.white),
                                                                                                ),
                                                                                                color: Colors.white,
                                                                                              ),
                                                                                              child: RaisedButton(

                                                                                                shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(00)),
                                                                                                elevation: 0,
                                                                                                color: Colors.white,
                                                                                                onPressed: (){
                                                                                                  setState(() {
                                                                                                    selectedrowbottom='pricing';
                                                                                                    bottomTappedbottom(0);
                                                                                                  });
                                                                                                },
                                                                                                child: Text('Price & Discount', style:TextStyle(fontSize:15, color:Colors.black)),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(width:5),
                                                                                            Container(
                                                                                              height: 40,
                                                                                              width: 130,
                                                                                              decoration: BoxDecoration(
                                                                                                border: Border(
                                                                                                  bottom: BorderSide(width: 3.0, color: selectedrowbottom=='other'?Colors.lightBlue.shade900:Colors.white),
                                                                                                ),
                                                                                                color: Colors.white,
                                                                                              ),
                                                                                              child: RaisedButton(

                                                                                                shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(00)),
                                                                                                elevation: 0,
                                                                                                color: Colors.white,
                                                                                                onPressed: (){
                                                                                                  setState(() {
                                                                                                    selectedrowbottom='other';
                                                                                                    bottomTappedbottom(1);
                                                                                                  });
                                                                                                },
                                                                                                child: Text('Other Details', style:TextStyle(fontSize:15, color:Colors.black)),
                                                                                              ),
                                                                                            ),
                                                                                          ]
                                                                                      )

                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Container(
                                                                                      height: 300,
                                                                                      width:MediaQuery.of(context).size.width,
                                                                                      child:PageView.builder(
                                                                                          onPageChanged: (v){
                                                                                            setState((){
                                                                                              if(v==0){
                                                                                                selectedrowbottom='pricing';
                                                                                              }
                                                                                              if(v==1){
                                                                                                selectedrowbottom='other';
                                                                                              }
                                                                                            });
                                                                                            _incrementBottomSheet();
                                                                                          },
                                                                                          itemCount:2,
                                                                                          scrollDirection: Axis.horizontal,
                                                                                          controller: pageControllerbottom,
                                                                                          itemBuilder: (BuildContext context, indexedit){
                                                                                            return ListView(
                                                                                                children:[
                                                                                                  if(indexedit==0)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          Text('New Price (With Tax)', style: GoogleFonts.poppins(
                                                                                                              fontSize: 15, fontWeight: FontWeight.w500
                                                                                                          ),),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==0)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                                                                                                      child:  Container(
                                                                                                        height: 50,
                                                                                                        width:MediaQuery.of(context).size.width-10,
                                                                                                        decoration: BoxDecoration(
                                                                                                            color: Colors.grey.withOpacity(0.3),
                                                                                                            shape: BoxShape.rectangle,
                                                                                                            borderRadius: BorderRadius.only(
                                                                                                                topRight: Radius.circular(5.0),
                                                                                                                topLeft: Radius.circular(5.0),
                                                                                                                bottomLeft: Radius.circular(5.0),
                                                                                                                bottomRight: Radius.circular(5.0))),
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                                          child: TextFormField(
                                                                                                            readOnly:true,
                                                                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                                            inputFormatters: <TextInputFormatter>[
                                                                                                              FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                                                              MyNumberTextInputFormatter(digit: 4),
                                                                                                            ],
                                                                                                            onChanged: (v){

                                                                                                            },
                                                                                                            decoration: new InputDecoration(

                                                                                                              prefixIconConstraints: BoxConstraints(
                                                                                                                minWidth: 15,
                                                                                                                minHeight: 48,
                                                                                                              ),

                                                                                                              prefixIcon: TextButton(onPressed:null,
                                                                                                                  child:Text('₹', style:TextStyle(fontSize:30))),
                                                                                                              isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                              labelText: "",
                                                                                                              fillColor: Colors.white.withOpacity(0.5),
                                                                                                              focusedBorder: OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                                borderSide: BorderSide(
                                                                                                                  color: Colors.transparent,
                                                                                                                  width: 1.0,
                                                                                                                ),
                                                                                                              ),
                                                                                                              enabledBorder: OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                                borderSide: BorderSide(
                                                                                                                  color: Colors.transparent,
                                                                                                                  width: 1.0,
                                                                                                                ),
                                                                                                              ),
                                                                                                              //fillColor: Colors.green
                                                                                                            ),
                                                                                                            controller: new_price_Controller,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==0)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10, right:10),
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          Container(
                                                                                                            width: MediaQuery.of(context).size.width/2.2,
                                                                                                            child: Text('Quantity', style: GoogleFonts.poppins(
                                                                                                                fontSize: 15, fontWeight: FontWeight.w500
                                                                                                            ),),
                                                                                                          ),
                                                                                                          Container(
                                                                                                            width: MediaQuery.of(context).size.width/2.2,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.only(left: 0,),
                                                                                                              child: Text('Unit', style: GoogleFonts.poppins(
                                                                                                                  fontSize: 15, fontWeight: FontWeight.w500
                                                                                                              ),),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==0)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10, right:20),
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          Container(
                                                                                                            width: MediaQuery.of(context).size.width/2.2,
                                                                                                            child:Container(
                                                                                                              height: 50,
                                                                                                              width:MediaQuery.of(context).size.width/2.2,
                                                                                                              decoration: BoxDecoration(
                                                                                                                  color: Colors.grey.withOpacity(0.3),
                                                                                                                  shape: BoxShape.rectangle,
                                                                                                                  borderRadius: BorderRadius.only(
                                                                                                                      topRight: Radius.circular(5.0),
                                                                                                                      topLeft: Radius.circular(5.0),
                                                                                                                      bottomLeft: Radius.circular(5.0),
                                                                                                                      bottomRight: Radius.circular(5.0))),
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                                                child: TextFormField(
                                                                                                                  readOnly: true,
                                                                                                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                                                  inputFormatters: <TextInputFormatter>[
                                                                                                                    FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                                                                    MyNumberTextInputFormatter(digit: 4),

                                                                                                                  ],
                                                                                                                  onChanged: (v){
                                                                                                                    if(gst_type!='inclu'){
                                                                                                                      setState((){
                                                                                                                        edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();
                                                                                                                        edit_product_base_with_quant = (double.parse(totalselected_val[index].toString())*double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);
                                                                                                                      });
                                                                                                                      if(v.isNotEmpty){
                                                                                                                        setState((){
                                                                                                                          edit_product_quant = v.toString();
                                                                                                                          edit_product_tax_val = ((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString()))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2);
                                                                                                                        });
                                                                                                                      }
                                                                                                                      else{
                                                                                                                        String oneval = '0.0';
                                                                                                                        setState((){
                                                                                                                          edit_quant_Controller.text = '0.0';
                                                                                                                          edit_product_quant = edit_quant_Controller.text.toString();
                                                                                                                          oneval = (double.parse(edit_prod_mult_quant_iclu_case.toString())/double.parse(edit_product_quant.toString())).toStringAsFixed(2);
                                                                                                                          edit_product_tax_val = ((double.parse(edit_product_base_price.toString())*double.parse('0.0'))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2);
                                                                                                                        });
                                                                                                                      }
                                                                                                                      //debugPrint(edit_product_quant.toString());
                                                                                                                      setState((){
                                                                                                                        //on quantity change set discount to 0;
                                                                                                                        edit_discount_percent_Controller.clear();
                                                                                                                        edit_discount_amount_Controller.clear();
                                                                                                                        edit_product_base_with_quant = (double.parse(edit_product_quant.toString())*double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);;
                                                                                                                      });
                                                                                                                    }
                                                                                                                    else{
                                                                                                                      setState((){
                                                                                                                        edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();
                                                                                                                        edit_product_base_with_quant = (double.parse(totalselected_val[index].toString())*double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);
                                                                                                                      });
                                                                                                                      if(v.isNotEmpty){
                                                                                                                        setState((){
                                                                                                                          edit_product_quant = v.toString();
                                                                                                                          edit_product_tax_val = ((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString()))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2);
                                                                                                                        });
                                                                                                                      }else{
                                                                                                                        setState((){
                                                                                                                          edit_quant_Controller.text = '0.0';
                                                                                                                          edit_product_quant = edit_quant_Controller.text.toString();
                                                                                                                          edit_product_tax_val = ((double.parse(edit_product_base_price.toString())*double.parse('0.0'))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2);
                                                                                                                        });
                                                                                                                      }
                                                                                                                      //debugPrint(edit_product_quant.toString());
                                                                                                                      setState((){
                                                                                                                        //on quantity change set discount to 0;
                                                                                                                        edit_discount_percent_Controller.clear();
                                                                                                                        edit_discount_amount_Controller.clear();
                                                                                                                        edit_product_base_with_quant = (double.parse(edit_product_quant.toString())*double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);;
                                                                                                                      });
                                                                                                                    }
                                                                                                                    _incrementBottomSheet();
                                                                                                                  },
                                                                                                                  decoration: new InputDecoration(
                                                                                                                    isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                                    labelText: "",
                                                                                                                    fillColor: Colors.white.withOpacity(0.5),
                                                                                                                    focusedBorder: OutlineInputBorder(
                                                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                                                      borderSide: BorderSide(
                                                                                                                        color: Colors.transparent,
                                                                                                                        width: 1.0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    enabledBorder: OutlineInputBorder(
                                                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                                                      borderSide: BorderSide(
                                                                                                                        color: Colors.transparent,
                                                                                                                        width: 1.0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    //fillColor: Colors.green
                                                                                                                  ),
                                                                                                                  controller: edit_quant_Controller,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          Container(
                                                                                                            width: MediaQuery.of(context).size.width/2.2,
                                                                                                            child:Container(
                                                                                                              height: 50,
                                                                                                              width:MediaQuery.of(context).size.width/2.2,
                                                                                                              decoration: BoxDecoration(
                                                                                                                  color: Colors.grey.withOpacity(0.3),
                                                                                                                  shape: BoxShape.rectangle,
                                                                                                                  borderRadius: BorderRadius.only(
                                                                                                                      topRight: Radius.circular(5.0),
                                                                                                                      topLeft: Radius.circular(5.0),
                                                                                                                      bottomLeft: Radius.circular(5.0),
                                                                                                                      bottomRight: Radius.circular(5.0))),
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                                                child: TextFormField(
                                                                                                                  readOnly: true,
                                                                                                                  onChanged: (v){

                                                                                                                  },
                                                                                                                  decoration: new InputDecoration(
                                                                                                                    isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                                    labelText: "",
                                                                                                                    fillColor: Colors.grey.withOpacity(0.3),
                                                                                                                    focusedBorder: OutlineInputBorder(
                                                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                                                      borderSide: BorderSide(
                                                                                                                        color: Colors.transparent,
                                                                                                                        width: 1.0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    enabledBorder: OutlineInputBorder(
                                                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                                                      borderSide: BorderSide(
                                                                                                                        color: Colors.transparent,
                                                                                                                        width: 1.0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    //fillColor: Colors.green
                                                                                                                  ),
                                                                                                                  controller: edit_unit_Controller,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==0)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          Text('Discount', style: GoogleFonts.poppins(
                                                                                                              fontSize: 15, fontWeight: FontWeight.w500
                                                                                                          ),),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==0)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                                                                                      child:  Container(
                                                                                                        height: 50,
                                                                                                        width:MediaQuery.of(context).size.width-10,
                                                                                                        decoration: BoxDecoration(
                                                                                                            color: Colors.white,
                                                                                                            shape: BoxShape.rectangle,
                                                                                                            borderRadius: BorderRadius.only(
                                                                                                                topRight: Radius.circular(5.0),
                                                                                                                topLeft: Radius.circular(5.0),
                                                                                                                bottomLeft: Radius.circular(5.0),
                                                                                                                bottomRight: Radius.circular(5.0))),
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                                          child: ispercent == true?TextFormField(
                                                                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                                            inputFormatters: <TextInputFormatter>[
                                                                                                              FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                                                              MyNumberTextInputFormatter(digit: 4),
                                                                                                            ],
                                                                                                            onChanged: (v){
                                                                                                              if(gst_type!='inclu'){
                                                                                                                setState(() {
                                                                                                                  edit_product_base_with_quant = (double.parse(edit_product_quant.toString())*double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);
                                                                                                                  edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();

                                                                                                                });
                                                                                                                if(v.isNotEmpty){
                                                                                                                  setState((){

                                                                                                                    if((double.parse(v.toString())<=100)){
                                                                                                                      edit_discount_amount_Controller.text = ((double.parse(v.toString())/100)*double.parse(edit_product_base_with_quant.toString())).toStringAsFixed(2);
                                                                                                                      edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString())-double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2);;

                                                                                                                    }else{
                                                                                                                      edit_discount_amount_Controller.clear();
                                                                                                                      edit_discount_percent_Controller.clear();
                                                                                                                      edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString())-double.parse('0.0'.toString())).toStringAsFixed(2);;

                                                                                                                    }
                                                                                                                  });
                                                                                                                }else{
                                                                                                                  setState((){
                                                                                                                    edit_discount_percent_Controller.clear();
                                                                                                                    edit_discount_amount_Controller.clear();
                                                                                                                    edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString())-double.parse('0.0'.toString())).toStringAsFixed(2);;


                                                                                                                  });
                                                                                                                }
                                                                                                                setState((){
                                                                                                                  edit_product_tax_val = ((double.parse(edit_product_base_with_quant.toString()))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2);

                                                                                                                });
                                                                                                              }
                                                                                                              else{
                                                                                                                setState((){
                                                                                                                  edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                                                  edit_total_amount_inclu_case = double.parse(total_elementwise_exclu_rate[index].toString()).toStringAsFixed(2);
                                                                                                                  edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                                                  if(v.isNotEmpty){
                                                                                                                    if((double.parse(v.toString())<=100)){
                                                                                                                      edit_discount_amount_Controller.text = ((double.parse(v.toString())/100)*double.parse(edit_total_amount_inclu_case.toString())).toStringAsFixed(2);
                                                                                                                      edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2);
                                                                                                                      edit_total_tax_rate_inclu_case = (double.parse(edit_total_amount_inclu_case.toString())-double.parse((double.parse(edit_total_amount_inclu_case.toString())/(1+double.parse((double.parse(edit_gst_Controller.text.toString().replaceAll('%', ''))/100).toStringAsFixed(2)))).toStringAsFixed(2))).toStringAsFixed(2);
                                                                                                                      edit_prod_mult_quant_iclu_case = double.parse((double.parse(edit_total_amount_inclu_case.toString())/(1+double.parse((double.parse(edit_gst_Controller.text.toString().replaceAll('%', ''))/100).toStringAsFixed(2)))).toStringAsFixed(2)).toStringAsFixed(2);
                                                                                                                    }else{
                                                                                                                      edit_discount_amount_Controller.clear();
                                                                                                                      edit_discount_percent_Controller.clear();
                                                                                                                      edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0')).toStringAsFixed(2);
                                                                                                                      edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                                                      edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse('0.0')).toStringAsFixed(2);
                                                                                                                      edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                                                    }
                                                                                                                  }else{
                                                                                                                    edit_discount_amount_Controller.clear();
                                                                                                                    edit_discount_percent_Controller.clear();
                                                                                                                    edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0')).toStringAsFixed(2);
                                                                                                                    edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                                                    edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse('0.0')).toStringAsFixed(2);
                                                                                                                    edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                                                  }
                                                                                                                });

                                                                                                              }
                                                                                                              _incrementBottomSheet();
                                                                                                            },
                                                                                                            decoration: new InputDecoration(
                                                                                                              suffixIconConstraints: BoxConstraints(
                                                                                                                minWidth: 70,
                                                                                                                minHeight: 28,
                                                                                                              ),

                                                                                                              suffixIcon: Container(
                                                                                                                  width:140,
                                                                                                                  height: 28,
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsets.only(right:10),
                                                                                                                    child: Row(
                                                                                                                      children: [
                                                                                                                        if(ispercent == true)
                                                                                                                          Text('%',style:TextStyle(fontSize:15, color:Colors.black))
                                                                                                                        else
                                                                                                                          Text('a',style:TextStyle(fontSize:15, color:Colors.white)),
                                                                                                                        SizedBox(width:10),
                                                                                                                        RaisedButton(
                                                                                                                            shape: RoundedRectangleBorder(
                                                                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                                                                                side: BorderSide(color: Colors.grey.withOpacity(0.3))
                                                                                                                            ),
                                                                                                                            highlightColor: Colors.transparent,
                                                                                                                            splashColor:Colors.transparent,
                                                                                                                            onPressed:(){
                                                                                                                              setState((){
                                                                                                                                if(ispercent==true){
                                                                                                                                  ispercent = false;
                                                                                                                                }else{
                                                                                                                                  ispercent = true;
                                                                                                                                }
                                                                                                                                _incrementBottomSheet();
                                                                                                                              }
                                                                                                                              );
                                                                                                                            }, elevation:0, color:Colors.white, child:ispercent==true?Text('Percentage'):Text('Amount')),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  )),
                                                                                                              isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                              labelText: "",
                                                                                                              fillColor: Colors.white.withOpacity(0.5),
                                                                                                              focusedBorder: OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                                borderSide: BorderSide(
                                                                                                                  color: Colors.grey.withOpacity(0.3),
                                                                                                                  width: 1.0,
                                                                                                                ),
                                                                                                              ),
                                                                                                              enabledBorder: OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                                borderSide: BorderSide(
                                                                                                                  color: Colors.grey.withOpacity(0.3),
                                                                                                                  width: 1.0,
                                                                                                                ),
                                                                                                              ),
                                                                                                              //fillColor: Colors.green
                                                                                                            ),
                                                                                                            controller: edit_discount_percent_Controller,
                                                                                                          ):TextFormField(
                                                                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                                            inputFormatters: <TextInputFormatter>[
                                                                                                              FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                                                              MyNumberTextInputFormatter(digit: 4),
                                                                                                            ],
                                                                                                            onChanged: (v){
                                                                                                              if(gst_type!='inclu') {
                                                                                                                setState(() {
                                                                                                                  edit_product_base_with_quant = (double.parse(edit_product_quant.toString()) * double.parse(totalselected_rate[index].toString())).toStringAsFixed(2);
                                                                                                                  edit_product_tax_val = total_elementwise_exclu_tax_val[index].toString();
                                                                                                                });
                                                                                                                if (v.isNotEmpty) {
                                                                                                                  setState(() {
                                                                                                                    if ((double.parse(v.toString()) <= double.parse(edit_product_base_with_quant.toString()))) {
                                                                                                                      edit_discount_percent_Controller.text = ((double.parse(v.toString()) / double.parse(totalselected_rate[index].toString())) * 100).toStringAsFixed(4);
                                                                                                                      edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2);
                                                                                                                    } else {
                                                                                                                      showPrintedMessage(context, "Error", "Discount should not be more than total basic amount", Colors.white, Colors.redAccent, Icons.info, true, "top");
                                                                                                                      edit_discount_amount_Controller.clear();
                                                                                                                      edit_discount_percent_Controller.clear();
                                                                                                                      edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0'.toString())).toStringAsFixed(2);
                                                                                                                    }
                                                                                                                  });
                                                                                                                }
                                                                                                                else {
                                                                                                                  setState(() {
                                                                                                                    edit_discount_percent_Controller.clear();
                                                                                                                    edit_discount_amount_Controller.clear();
                                                                                                                    edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0'.toString())).toStringAsFixed(2);
                                                                                                                  });
                                                                                                                }
                                                                                                                setState(() {
                                                                                                                  edit_product_tax_val = ((double.parse(edit_product_base_with_quant.toString())) * (double.parse(edit_gst_Controller.text.toString().replaceAll(' %', '')) / 100)).toStringAsFixed(2);
                                                                                                                });
                                                                                                              }
                                                                                                              else{
                                                                                                                setState((){
                                                                                                                  edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                                                  edit_total_amount_inclu_case = double.parse(total_elementwise_exclu_rate[index].toString()).toStringAsFixed(2);
                                                                                                                  edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                                                  if (v.isNotEmpty) {
                                                                                                                    setState(() {
                                                                                                                      if ((double.parse(v.toString()) <= double.parse((((double.parse(edit_total_amount_inclu_case.toString())*double.parse(edit_product_quant.toString()))+double.parse(edit_product_tax_val.toString()))-double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2)))) {
                                                                                                                        edit_discount_percent_Controller.text = ((double.parse(v.toString()) / double.parse(edit_total_amount_inclu_case.toString())) * 100).toStringAsFixed(4);
                                                                                                                        edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2);
                                                                                                                        edit_total_tax_rate_inclu_case = (double.parse(edit_total_amount_inclu_case.toString())-double.parse((double.parse(edit_total_amount_inclu_case.toString())/(1+double.parse((double.parse(edit_gst_Controller.text.toString().replaceAll('%', ''))/100).toStringAsFixed(2)))).toStringAsFixed(2))).toStringAsFixed(2);
                                                                                                                        edit_prod_mult_quant_iclu_case = double.parse((double.parse(edit_total_amount_inclu_case.toString())/(1+double.parse((double.parse(edit_gst_Controller.text.toString().replaceAll('%', ''))/100).toStringAsFixed(2)))).toStringAsFixed(2)).toStringAsFixed(2);
                                                                                                                      } else {
                                                                                                                        showPrintedMessage(context, "Error", "Discount should not be more than total amount", Colors.white, Colors.redAccent, Icons.info, true, "top");
                                                                                                                        edit_discount_amount_Controller.clear();
                                                                                                                        edit_discount_percent_Controller.clear();
                                                                                                                        edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0')).toStringAsFixed(2);
                                                                                                                        edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                                                        edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse('0.0')).toStringAsFixed(2);
                                                                                                                        edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                                                      }
                                                                                                                    });
                                                                                                                  }else {
                                                                                                                    setState(() {
                                                                                                                      edit_discount_amount_Controller.clear();
                                                                                                                      edit_discount_percent_Controller.clear();
                                                                                                                      edit_product_base_with_quant = (double.parse(edit_product_base_with_quant.toString()) - double.parse('0.0')).toStringAsFixed(2);
                                                                                                                      edit_prod_mult_quant_iclu_case = edit_product_base_with_quant.toString();
                                                                                                                      edit_total_amount_inclu_case = ((double.parse(edit_total_amount_inclu_case.toString()))-double.parse('0.0')).toStringAsFixed(2);
                                                                                                                      edit_total_tax_rate_inclu_case = edit_product_tax_val.toString();
                                                                                                                    });
                                                                                                                  }
                                                                                                                  ////debugPrint(edit_total_tax_rate_inclu_case);
                                                                                                                });
                                                                                                              }
                                                                                                              _incrementBottomSheet();
                                                                                                            },
                                                                                                            decoration: new InputDecoration(
                                                                                                              suffixIconConstraints: BoxConstraints(
                                                                                                                minWidth: 70,
                                                                                                                minHeight: 28,
                                                                                                              ),

                                                                                                              suffixIcon: Container(
                                                                                                                  width:140,
                                                                                                                  height: 28,
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsets.only(right:10),
                                                                                                                    child: Row(
                                                                                                                      children: [
                                                                                                                        if(ispercent == true)
                                                                                                                          Text('%',style:TextStyle(fontSize:15, color:Colors.black))
                                                                                                                        else
                                                                                                                          Text('a',style:TextStyle(fontSize:15, color:Colors.white)),
                                                                                                                        SizedBox(width:10),
                                                                                                                        RaisedButton(
                                                                                                                            shape: RoundedRectangleBorder(
                                                                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                                                                                side: BorderSide(color: Colors.grey.withOpacity(0.3))
                                                                                                                            ),
                                                                                                                            highlightColor: Colors.transparent,
                                                                                                                            splashColor:Colors.transparent,
                                                                                                                            onPressed:(){
                                                                                                                              setState((){
                                                                                                                                if(ispercent==true){
                                                                                                                                  ispercent = false;
                                                                                                                                }else{
                                                                                                                                  ispercent = true;
                                                                                                                                }
                                                                                                                                _incrementBottomSheet();
                                                                                                                              }
                                                                                                                              );
                                                                                                                            }, elevation:0, color:Colors.white, child:ispercent==true?Text('Percentage'):Text('Amount')),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  )),
                                                                                                              isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                              labelText: "",
                                                                                                              fillColor: Colors.white.withOpacity(0.5),
                                                                                                              focusedBorder: OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                                borderSide: BorderSide(
                                                                                                                  color: Colors.grey.withOpacity(0.3),
                                                                                                                  width: 1.0,
                                                                                                                ),
                                                                                                              ),
                                                                                                              enabledBorder: OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                                borderSide: BorderSide(
                                                                                                                  color: Colors.grey.withOpacity(0.3),
                                                                                                                  width: 1.0,
                                                                                                                ),
                                                                                                              ),
                                                                                                              //fillColor: Colors.green
                                                                                                            ),
                                                                                                            controller: edit_discount_amount_Controller,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==0&&isregistered==true)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          Text('Tax Rate', style: GoogleFonts.poppins(
                                                                                                              fontSize: 15, fontWeight: FontWeight.w500
                                                                                                          ),),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==0&&isregistered==true)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                                                                                                      child:  Container(
                                                                                                        height: 50,
                                                                                                        width:MediaQuery.of(context).size.width-10,
                                                                                                        decoration: BoxDecoration(
                                                                                                            color: Colors.grey.withOpacity(0.3),
                                                                                                            shape: BoxShape.rectangle,
                                                                                                            borderRadius: BorderRadius.only(
                                                                                                                topRight: Radius.circular(5.0),
                                                                                                                topLeft: Radius.circular(5.0),
                                                                                                                bottomLeft: Radius.circular(5.0),
                                                                                                                bottomRight: Radius.circular(5.0))),
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                                          child: TextFormField(
                                                                                                            readOnly:true,
                                                                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                                            inputFormatters: <TextInputFormatter>[
                                                                                                              FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                                                              MyNumberTextInputFormatter(digit: 4),
                                                                                                            ],
                                                                                                            onChanged: (v){

                                                                                                            },
                                                                                                            decoration: new InputDecoration(

                                                                                                              prefixIconConstraints: BoxConstraints(
                                                                                                                minWidth: 15,
                                                                                                                minHeight: 48,
                                                                                                              ),

                                                                                                              prefixIcon: TextButton(onPressed:null,
                                                                                                                  child:Text('GST @', style:TextStyle(fontSize:18, color:Colors.black))),
                                                                                                              isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                              labelText: "",
                                                                                                              fillColor: Colors.white.withOpacity(0.5),
                                                                                                              focusedBorder: OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                                borderSide: BorderSide(
                                                                                                                  color: Colors.transparent,
                                                                                                                  width: 1.0,
                                                                                                                ),
                                                                                                              ),
                                                                                                              enabledBorder: OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                                borderSide: BorderSide(
                                                                                                                  color: Colors.transparent,
                                                                                                                  width: 1.0,
                                                                                                                ),
                                                                                                              ),
                                                                                                              //fillColor: Colors.green
                                                                                                            ),
                                                                                                            controller: edit_gst_Controller,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==1)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          Text('Item Code', style: GoogleFonts.poppins(
                                                                                                              fontSize: 15, fontWeight: FontWeight.w500
                                                                                                          ),),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==1)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 0, bottom: 2, top: 10, right:0),
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          Container(
                                                                                                            width: MediaQuery.of(context).size.width,
                                                                                                            child:Container(
                                                                                                              height: 50,
                                                                                                              width:MediaQuery.of(context).size.width-10,
                                                                                                              decoration: BoxDecoration(
                                                                                                                  color: Colors.white,
                                                                                                                  shape: BoxShape.rectangle,
                                                                                                                  borderRadius: BorderRadius.only(
                                                                                                                      topRight: Radius.circular(5.0),
                                                                                                                      topLeft: Radius.circular(5.0),
                                                                                                                      bottomLeft: Radius.circular(5.0),
                                                                                                                      bottomRight: Radius.circular(5.0))),
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                                                                                                                child: TextFormField(

                                                                                                                  onChanged: (v){

                                                                                                                  },
                                                                                                                  decoration: new InputDecoration(
                                                                                                                    isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                                    labelText: "",
                                                                                                                    fillColor: Colors.white.withOpacity(0.5),
                                                                                                                    focusedBorder: OutlineInputBorder(
                                                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                                                      borderSide: BorderSide(
                                                                                                                        color: Colors.grey.withOpacity(0.3),
                                                                                                                        width: 1.0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    enabledBorder: OutlineInputBorder(
                                                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                                                      borderSide: BorderSide(
                                                                                                                        color: Colors.grey.withOpacity(0.3),
                                                                                                                        width: 1.0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    //fillColor: Colors.green
                                                                                                                  ),
                                                                                                                  controller: edit_item_code_Controller,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==1)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          Text('Item Description', style: GoogleFonts.poppins(
                                                                                                              fontSize: 15, fontWeight: FontWeight.w500
                                                                                                          ),),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  if(indexedit==1)
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 0, bottom: 2, top: 10, right:0),
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          Container(
                                                                                                            width: MediaQuery.of(context).size.width,
                                                                                                            child:Container(
                                                                                                              height: 50,
                                                                                                              width:MediaQuery.of(context).size.width-10,
                                                                                                              decoration: BoxDecoration(
                                                                                                                  color: Colors.white,
                                                                                                                  shape: BoxShape.rectangle,
                                                                                                                  borderRadius: BorderRadius.only(
                                                                                                                      topRight: Radius.circular(5.0),
                                                                                                                      topLeft: Radius.circular(5.0),
                                                                                                                      bottomLeft: Radius.circular(5.0),
                                                                                                                      bottomRight: Radius.circular(5.0))),
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                                                                                                                child: TextFormField(

                                                                                                                  onChanged: (v){

                                                                                                                  },
                                                                                                                  decoration: new InputDecoration(
                                                                                                                    isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                                    labelText: "",
                                                                                                                    fillColor: Colors.white.withOpacity(0.5),
                                                                                                                    focusedBorder: OutlineInputBorder(
                                                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                                                      borderSide: BorderSide(
                                                                                                                        color: Colors.grey.withOpacity(0.3),
                                                                                                                        width: 1.0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    enabledBorder: OutlineInputBorder(
                                                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                                                      borderSide: BorderSide(
                                                                                                                        color: Colors.grey.withOpacity(0.3),
                                                                                                                        width: 1.0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    //fillColor: Colors.green
                                                                                                                  ),
                                                                                                                  controller: edit_item_descrip_Controller,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),

                                                                                                ]
                                                                                            );
                                                                                          })
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                                                                                  child:  Container(
                                                                                    height: isregistered==true?110:80,
                                                                                    width:MediaQuery.of(context).size.width-10,
                                                                                    decoration: BoxDecoration(
                                                                                        color: Colors.grey.withOpacity(0.1),
                                                                                        shape: BoxShape.rectangle,
                                                                                        borderRadius: BorderRadius.only(
                                                                                            topRight: Radius.circular(10.0),
                                                                                            topLeft: Radius.circular(10.0),
                                                                                            bottomLeft: Radius.circular(10.0),
                                                                                            bottomRight: Radius.circular(10.0))),
                                                                                    child: Padding(
                                                                                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                                                        child: Container(
                                                                                            child:Column(
                                                                                                children:[
                                                                                                  Row(
                                                                                                      children:[
                                                                                                        Container(width:140,
                                                                                                          child: Row(
                                                                                                            children: [
                                                                                                              Text('Product Basic Price ',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                                              Text('*',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                                              Text(' Qty',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                        Container(width:MediaQuery.of(context).size.width-190,
                                                                                                          child: Row(
                                                                                                            mainAxisAlignment:MainAxisAlignment.end,
                                                                                                            children: [
                                                                                                              Text('₹ ',style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                                              // Text((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString())).toStringAsFixed(2),style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                                              if(gst_type!='inclu')
                                                                                                                Text(edit_product_base_with_quant.toString(),style:TextStyle(fontSize:16, color:Colors.grey))
                                                                                                              else
                                                                                                                Text(edit_prod_mult_quant_iclu_case.toString(),style:TextStyle(fontSize:16, color:Colors.grey)),

                                                                                                            ],
                                                                                                          ),
                                                                                                        )
                                                                                                      ]
                                                                                                  ),
                                                                                                  if(isregistered==true)
                                                                                                    SizedBox(height:5),
                                                                                                  if(isregistered==true)
                                                                                                    Row(
                                                                                                        children:[
                                                                                                          Container(width:140,
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                Text('Tax Rate ',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                                                Text('(%)',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                          Container(width:MediaQuery.of(context).size.width-190,
                                                                                                            child: Row(
                                                                                                              mainAxisAlignment:MainAxisAlignment.end,
                                                                                                              children: [
                                                                                                                Text('('+edit_gst_Controller.text.toString()+')',style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                                                Text(' ₹ ',style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                                                // Text(((double.parse(totalselected_rate[index].toString())*double.parse(edit_quant_Controller.text.toString()))*(double.parse(edit_gst_Controller.text.toString().replaceAll(' %',''))/100)).toStringAsFixed(2),style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                                                if(gst_type!='inclu')
                                                                                                                  Text(edit_product_tax_val.toString(),style:TextStyle(fontSize:16, color:Colors.grey))
                                                                                                                else
                                                                                                                  Text(edit_total_tax_rate_inclu_case.toString(),style:TextStyle(fontSize:16, color:Colors.grey)),

                                                                                                              ],
                                                                                                            ),
                                                                                                          )
                                                                                                        ]
                                                                                                    ),
                                                                                                  SizedBox(height:5),
                                                                                                  Row(
                                                                                                      children:[
                                                                                                        Container(width:140,
                                                                                                          child: Row(
                                                                                                            children: [
                                                                                                              Text('Discount ',style:TextStyle(fontSize:14, color:Colors.grey)),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                        Container(width:MediaQuery.of(context).size.width-190,
                                                                                                          child: Row(
                                                                                                            mainAxisAlignment:MainAxisAlignment.end,
                                                                                                            children: [
                                                                                                              if(edit_discount_percent_Controller.text.isNotEmpty)
                                                                                                                Text('('+edit_discount_percent_Controller.text.toString()+'%'+')',style:TextStyle(fontSize:16, color:Colors.grey))
                                                                                                              else
                                                                                                                Text('('+'0.0'+'%'+')',style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                                              Text(' ₹ ',style:TextStyle(fontSize:16, color:Colors.grey)),
                                                                                                              if(edit_discount_amount_Controller.text.isNotEmpty)
                                                                                                                Text(edit_discount_amount_Controller.text.toString(),style:TextStyle(fontSize:16, color:Colors.grey))
                                                                                                              else
                                                                                                                Text('0.0',style:TextStyle(fontSize:16, color:Colors.grey)), ],
                                                                                                          ),
                                                                                                        )
                                                                                                      ]
                                                                                                  ),
                                                                                                  SizedBox(height:5),
                                                                                                  Row(
                                                                                                      children:[
                                                                                                        Container(width:140,
                                                                                                          child: Row(
                                                                                                            children: [
                                                                                                              Text('Total Amount ',style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold)),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                        Container(width:MediaQuery.of(context).size.width-190,
                                                                                                          child: gst_type!='inclu'?Row(
                                                                                                            mainAxisAlignment:MainAxisAlignment.end,
                                                                                                            children: [
                                                                                                              Text(' ₹ ',style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold)),
                                                                                                              if(edit_discount_amount_Controller.text.isNotEmpty)
                                                                                                                Text((((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString()))+double.parse(edit_product_tax_val.toString()))-double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2),style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold))
                                                                                                              else
                                                                                                                Text((((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString()))+double.parse(edit_product_tax_val.toString()))).toStringAsFixed(2),style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold))
                                                                                                            ],
                                                                                                          ):Row(
                                                                                                            mainAxisAlignment:MainAxisAlignment.end,
                                                                                                            children: [
                                                                                                              Text(' ₹ ',style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold)),
                                                                                                              Text(edit_total_amount_inclu_case.toString(),style:TextStyle(fontSize:16, color:Colors.black, fontWeight:FontWeight.bold))
                                                                                                            ],
                                                                                                          ),
                                                                                                        )
                                                                                                      ]
                                                                                                  )
                                                                                                ]
                                                                                            )
                                                                                        )
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(10, 5, 20, 8),
                                                                                  child:  Container(
                                                                                    height: 50,
                                                                                    width:MediaQuery.of(context).size.width-10,
                                                                                    decoration: BoxDecoration(
                                                                                      shape: BoxShape.rectangle,),
                                                                                    child: RaisedButton(
                                                                                      shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(10)),
                                                                                      onPressed:(){
                                                                                        setState((){
                                                                                          prod_rate_with_discount[index] = intrim_prod_base_rate[index].toString();
                                                                                        });
                                                                                        if(gst_type!='inclu'){
                                                                                          setState((){
                                                                                            totalselected_val[index] = edit_product_quant.toString();
                                                                                            total_elementwise_exclu_tax_val[index] = edit_product_tax_val.toString();
                                                                                            if(edit_discount_amount_Controller.text.isNotEmpty) {
                                                                                              total_elementwise_exclu_rate[index] = (((double.parse(edit_product_base_price.toString()) * double.parse(edit_product_quant.toString())) + double.parse(edit_product_tax_val.toString())) - double.parse(edit_discount_amount_Controller.text.toString())).toStringAsFixed(2);
                                                                                            }
                                                                                            else{
                                                                                              total_elementwise_exclu_rate[index] = (((double.parse(edit_product_base_price.toString())*double.parse(edit_product_quant.toString()))+double.parse(edit_product_tax_val.toString()))).toStringAsFixed(2);
                                                                                            }
                                                                                            var i = allids.indexOf(totalselected_id[index]);
                                                                                            //debugPrint(i.toString());
                                                                                            products[i]['value']= edit_product_quant.toString();
                                                                                            products[i]['controller'].text= edit_product_quant.toString();
                                                                                            setval_rate();
                                                                                            List aval = [];
                                                                                            List additional = [];
                                                                                            if(additional_charges.isNotEmpty){
                                                                                              for(var i=0; i<totalselected_id.length; i++){
                                                                                                aval.add(double.parse(total_elementwise_exclu_rate[i].toString()));
                                                                                              }
                                                                                              total_exclusive_val=aval.reduce((a, b) => a + b).toString();
                                                                                              un_round_items_subtotal = total_exclusive_val.toString();
                                                                                              for(var i=0; i<additional_charges.length; i++){
                                                                                                if(gst_type!='gst-non') {
                                                                                                  additional.add(double.parse(additional_charges[i]['val'].toString()));
                                                                                                }else{
                                                                                                  if(additional_charges[i]['charge_value_controller'].text.isNotEmpty) {
                                                                                                    additional.add(double.parse(
                                                                                                        additional_charges[i]['charge_value_controller'].text
                                                                                                            .toString()));
                                                                                                  }else{
                                                                                                    additional.add(double.parse('0.0'));
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                              if(additional.isNotEmpty) {
                                                                                                total_amount_after_additional = additional.reduce((a, b) => a + b).toString();

                                                                                                total_amount_after_additional =
                                                                                                    (double.parse(total_exclusive_val.toString()) +
                                                                                                        double.parse(total_amount_after_additional.toString()))
                                                                                                        .toStringAsFixed(2);

                                                                                              }else{
                                                                                                total_amount_after_additional = '0.0';
                                                                                                //debugPrint(total_amount_after_additional.toString());
                                                                                              }
                                                                                              un_round_items_total = total_amount_after_additional.toString();
                                                                                            }else{
                                                                                              for(var i=0; i<totalselected_id.length; i++){
                                                                                                aval.add(double.parse(total_elementwise_exclu_rate[i].toString()));
                                                                                              }
                                                                                              total_exclusive_val=aval.reduce((a, b) => a + b).toString();
                                                                                              un_round_items_subtotal = total_exclusive_val.toString();
                                                                                              total_amount_after_additional = total_exclusive_val.toString();
                                                                                              un_round_items_total = total_amount_after_additional.toString();
                                                                                            }

                                                                                          });
                                                                                        }
                                                                                        else{
                                                                                          setState((){
                                                                                            total_elementwise_exclu_rate[index]= edit_total_amount_inclu_case.toString();
                                                                                            totalselected_rate[index] = double.parse((double.parse(edit_prod_mult_quant_iclu_case.toString())/double.parse(totalselected_val[index].toString())).toStringAsFixed(2)).toStringAsFixed(2);
                                                                                            total_elementwise_exclu_tax_val[index] = edit_total_tax_rate_inclu_case.toString();
                                                                                            var i = allids.indexOf(totalselected_id[index]);
                                                                                            //debugPrint(i.toString());
                                                                                            products[i]['value']= edit_product_quant.toString();
                                                                                            products[i]['controller'].text= edit_product_quant.toString();
                                                                                            setval_rate();
                                                                                            List aval = [];
                                                                                            List additional = [];
                                                                                            if(additional_charges.isNotEmpty){
                                                                                              for(var i=0; i<totalselected_id.length; i++){
                                                                                                aval.add(double.parse(total_elementwise_exclu_rate[i].toString()));
                                                                                              }
                                                                                              total_exclusive_val=aval.reduce((a, b) => a + b).toString();
                                                                                              un_round_items_subtotal = total_exclusive_val.toString();
                                                                                              for(var i=0; i<additional_charges.length; i++){
                                                                                                if(gst_type!='gst-non') {
                                                                                                  additional.add(double.parse(additional_charges[i]['val'].toString()));
                                                                                                }else{
                                                                                                  if(additional_charges[i]['charge_value_controller'].text.isNotEmpty) {
                                                                                                    additional.add(double.parse(
                                                                                                        additional_charges[i]['charge_value_controller'].text
                                                                                                            .toString()));
                                                                                                  }else{
                                                                                                    additional.add(double.parse('0.0'));
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                              if(additional.isNotEmpty) {
                                                                                                total_amount_after_additional = additional.reduce((a, b) => a + b).toString();

                                                                                                total_amount_after_additional =
                                                                                                    (double.parse(total_exclusive_val.toString()) +
                                                                                                        double.parse(total_amount_after_additional.toString()))
                                                                                                        .toStringAsFixed(2);

                                                                                              }else{
                                                                                                total_amount_after_additional = '0.0';
                                                                                                //debugPrint(total_amount_after_additional.toString());
                                                                                              }
                                                                                              un_round_items_total = total_amount_after_additional.toString();
                                                                                            }else{
                                                                                              for(var i=0; i<totalselected_id.length; i++){
                                                                                                aval.add(double.parse(total_elementwise_exclu_rate[i].toString()));
                                                                                              }
                                                                                              total_exclusive_val=aval.reduce((a, b) => a + b).toString();
                                                                                              un_round_items_subtotal = total_exclusive_val.toString();
                                                                                              total_amount_after_additional = total_exclusive_val.toString();
                                                                                              un_round_items_total = total_amount_after_additional.toString();
                                                                                            }

                                                                                          });
                                                                                        }
                                                                                        if(edit_discount_amount_Controller.text.isNotEmpty){
                                                                                          setState((){
                                                                                            discountflat[index] = (double.parse(edit_discount_amount_Controller.text.toString())/double.parse(edit_quant_Controller.text.toString())).toStringAsFixed(2);
                                                                                            discountperct[index] = (double.parse((double.parse(discountflat[index].toString())/double.parse(total_base_rate[index].toString())).toString())*100).toStringAsFixed(2);
                                                                                          });
                                                                                        }else{
                                                                                          setState((){
                                                                                            discountflat[index] = '0';
                                                                                            discountperct[index] = '0';
                                                                                          });
                                                                                        }
                                                                                        setState((){
                                                                                          prod_rate_with_discount[index] = (double.parse(prod_rate_with_discount[index].toString())-double.parse(discountflat[index].toString())).toStringAsFixed(2);
                                                                                          if(edit_item_descrip_Controller.text.isNotEmpty){
                                                                                            description[index] = edit_item_descrip_Controller.text.toString();
                                                                                          }else{
                                                                                            description[index] = '';
                                                                                          }
                                                                                        });
                                                                                        //debugPrint(discountflat.toString());
                                                                                        //debugPrint(discountperct.toString());
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      color:Colors.indigo,
                                                                                      child: Text('Done', style:TextStyle(fontSize: 17, color:Colors.white)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height:10),

                                                                              ]
                                                                          ),
                                                                        )
                                                                    );
                                                                  },
                                                                      backgroundColor: Colors.transparent,
                                                                      elevation: 30
                                                                  );
                                                                },
                                                                child:Text('Edit', style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.w400),)
                                                            )
                                                        ),

                                                      ],
                                                    ),
                                                  ),
                                                  if(isregistered==true)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                              width:80,
                                                              child: Text('Tax', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0))),
                                                          Container(
                                                              width:MediaQuery.of(context).size.width-132,

                                                              child: Row(
                                                                children: [
                                                                  Text(totalselected_tax[index].toString(), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                                  Text('%', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                                  Text(' = ', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                                  Text('₹', style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                                  //Text(((double.parse(totalselected_tax[index].toString())/100)*(double.parse(totalselected_rate[index].toString())*double.parse(totalselected_val[index].toString()))).toStringAsFixed(2), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                                  Text(total_elementwise_exclu_tax_val[index].toString(), style: TextStyle(fontSize:16, color:Colors.grey.withOpacity(0.9), fontWeight: FontWeight.w400, letterSpacing: 0)),
                                                                ],
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  if(index!=totalselected_id.length-1)
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 50, right: 50),
                                                      child: Divider(
                                                        color: AppBarColor,
                                                        thickness: 0.2,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                    ),
                                  ),
                                ),
                              if(totalselected_id.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  child: Divider(
                                    color: AppBarColor.withOpacity(0.3),
                                    thickness: 0.2,
                                  ),
                                ),
                              if(totalselected_id.isNotEmpty&&isregistered == false)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(right:10),
                                            child: Text('Round Off : ', style:TextStyle(
                                                color: Colors.indigo, fontSize:18, fontWeight:FontWeight.w600
                                            ))
                                        ),
                                        Container(
                                          width: 100,
                                          height: 40,
                                          child: Row(
                                            children: [
                                              Text('No',style: TextStyle(fontSize:12, color:AppBarColor),),
                                              Switch(
                                                onChanged: (v){
                                                  setState((){
                                                    isamountround = v;
                                                    if(v==true){
                                                      total_exclusive_val = double.parse(total_exclusive_val.toString()).round().toString();
                                                      total_amount_after_additional = double.parse(total_amount_after_additional.toString()).round().toString();
                                                    }else{
                                                      total_amount_after_additional=un_round_items_total.toString();
                                                      total_exclusive_val=un_round_items_subtotal.toString();
                                                    }
                                                  });

                                                },
                                                value: isamountround,
                                                activeColor: AppBarColor,
                                                activeTrackColor: AppBarColor.withOpacity(0.3),
                                                inactiveThumbColor: AppBarColor.withOpacity(0.3),
                                                inactiveTrackColor: AppBarColor,
                                              ),
                                              Text('Yes',style: TextStyle(fontSize:12, color:AppBarColor),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              if(totalselected_id.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:15),
                                      child: Container(
                                          width: 100,
                                          child: Text('Items Subtotal',style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),)),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width-115,
                                      height: 40,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right:30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text('₹',style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),),
                                            SizedBox(width:5),
                                            Text(total_exclusive_val.toString(),style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),


                              if(totalselected_id.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left:15, right:15),
                                  child: AnimatedContainer(
                                    height: isregistered==true?subtotalheight:0.0,
                                    duration: Duration(seconds:1),
                                    color:Colors.indigo.withOpacity(0.2),
                                    child: ListView(
                                        children: [
                                          if(additional_charges.isEmpty)
                                            Container(
                                              height: 35,
                                              child: TextButton(
                                                  onPressed:null,
                                                  child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children:[
                                                        Icon(Icons.add, size:20, color:Colors.indigo),
                                                        Text('Additional Charges', style:TextStyle(
                                                            color: Colors.indigo, fontSize:18
                                                        ))
                                                      ]
                                                  )
                                              ),
                                            ),
                                          if(additional_charges.isNotEmpty)
                                            Row(
                                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width:MediaQuery.of(context).size.width-230,
                                                  child: RaisedButton(
                                                    elevation:0,
                                                    color:Colors.transparent,
                                                    onPressed:(){
                                                      //debugPrint(addchargeheight.toString());
                                                      setState((){
                                                        if(addchargeheight>0){
                                                          addchargeheight = 0;
                                                          subtotalheight = 100;
                                                          partyname = 990;
                                                        }else{
                                                          addchargeheight = 60;
                                                          for(var i=0; i<additional_charges.length-1; i++){
                                                            addchargeheight = addchargeheight+60;
                                                            subtotalheight += 50;
                                                            partyname = 990;
                                                          }
                                                          subtotalheight += 70;
                                                          partyname = 990;
                                                        }
                                                      });
                                                    },
                                                    child:  Row(
                                                      children: [
                                                        if(addchargeheight>0)
                                                          Icon(Icons.arrow_circle_up, size:20, color:Colors.indigo)
                                                        else
                                                          Icon(Icons.arrow_circle_down, size:20, color:Colors.indigo),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width:200,
                                                  child: TextButton(
                                                      onPressed:null,
                                                      child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children:[
                                                            Icon(Icons.add, size:25, color:Colors.indigo),
                                                            Text('Additional Charges', style:TextStyle(
                                                                color: Colors.indigo, fontSize:18
                                                            ))
                                                          ]
                                                      )
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if(additional_charges.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(left:5, right:5),
                                              child: AnimatedContainer(
                                                  height: addchargeheight,
                                                  duration: Duration(seconds:1),
                                                  child:ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: additional_charges.length,
                                                      itemBuilder: (BuildContext context, index) {
                                                        return Padding(
                                                          padding: const EdgeInsets.only(top: 5, bottom: 1),
                                                          child: AnimatedContainer(
                                                              width: MediaQuery.of(context).size.width,
                                                              duration: Duration(seconds: 1),
                                                              child: Row(
                                                                  children:[
                                                                    Padding(
                                                                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                                      child:  Container(
                                                                        height: 50,
                                                                        width: 120,
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.transparent,
                                                                            shape: BoxShape.rectangle,
                                                                            borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(5.0),
                                                                                topLeft: Radius.circular(5.0),
                                                                                bottomLeft: Radius.circular(5.0),
                                                                                bottomRight: Radius.circular(5.0))),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                                          child: TextFormField(
                                                                            readOnly : true,
                                                                            decoration: new InputDecoration(
                                                                              contentPadding:
                                                                              EdgeInsets.only(left: 5, right: 1, top: 0, bottom: 0),
                                                                              prefixIconConstraints: BoxConstraints(
                                                                                minWidth: 5,
                                                                                minHeight: 48,
                                                                              ),
                                                                              prefixIcon: Icon(Icons.edit, color: Colors.transparent,size: 5,),
                                                                              isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                              labelText: index==0?whole_allias_array[aliases.indexOf('Freight')]['aliase'].toString():index==1?whole_allias_array[aliases.indexOf('Packaging')]['aliase'].toString():whole_allias_array[aliases.indexOf('Insurance')]['aliase'].toString(),
                                                                              labelStyle: TextStyle(fontSize:13),
                                                                              fillColor: Colors.white.withOpacity(0.5),
                                                                              focusedBorder: UnderlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.transparent,
                                                                                  width: 1.0,
                                                                                ),
                                                                              ),
                                                                              enabledBorder: UnderlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.transparent,
                                                                                  width: 1.0,
                                                                                ),
                                                                              ),
                                                                              //fillColor: Colors.green
                                                                            ),
                                                                            controller: additional_charges[index]['charge_name_controller'],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                                      child:  Container(
                                                                        height: 50,
                                                                        width: 70,
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.transparent,
                                                                            shape: BoxShape.rectangle,
                                                                            borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(5.0),
                                                                                topLeft: Radius.circular(5.0),
                                                                                bottomLeft: Radius.circular(5.0),
                                                                                bottomRight: Radius.circular(5.0))),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                                          child: TextFormField(
                                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                            inputFormatters: <TextInputFormatter>[
                                                                              FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                              MyNumberTextInputFormatter(digit: 2),
                                                                            ],
                                                                            onChanged: (v){
                                                                              if(v.isNotEmpty){
                                                                                setState((){
                                                                                  //total_exclusive_val
                                                                                  additional_charges[index]['val'] = v.toString();
                                                                                  //debugPrint(additional_charges[index]['val'].toString());
                                                                                  if(additional_charges[index]['sel_gst_val']!=null){
                                                                                    setState(() {
                                                                                      //debugPrint(additional_charges[index]['val'].toString());
                                                                                      additional_charges[index]['val'] = additional_charges[index]['charge_value_controller'].text.toString();
                                                                                      additional_charges[index]['val'] = (((double.parse(additional_charges[index]['sel_gst_val'].toString())/100)*(double.parse(additional_charges[index]['val'].toString())))+(double.parse(additional_charges[index]['val'].toString()))).toStringAsFixed(2);
                                                                                    });
                                                                                    //debugPrint(additional_charges[index]['val'].toString());
                                                                                    sum_additional_charge();
                                                                                  }
                                                                                });
                                                                              }else{
                                                                                setState((){
                                                                                  additional_charges[index]['val'] = '0.0';
                                                                                  //debugPrint(additional_charges[index]['val'].toString());
                                                                                });
                                                                              }
                                                                              sum_additional_charge();
                                                                              // total_exclusive_val = (double.parse(total_exclusive_val.toString())+double.parse(additional_charges[index]['val'].toString())).toStringAsFixed(2);
                                                                            },
                                                                            decoration: new InputDecoration(
                                                                              contentPadding:
                                                                              EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                                                              prefixIconConstraints: BoxConstraints(
                                                                                minWidth: 25,
                                                                                minHeight: 25,
                                                                              ),
                                                                              prefixIcon: Container(
                                                                                width:25,
                                                                                child: TextButton(
                                                                                    onPressed:null,
                                                                                    child: Text('₹', style:TextStyle(fontSize:20, color:Colors.black, fontWeight:FontWeight.bold))),
                                                                              ),
                                                                              isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                              labelText: "0.0",
                                                                              fillColor: Colors.white.withOpacity(0.5),
                                                                              focusedBorder: UnderlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.white,
                                                                                  width: 1.0,
                                                                                ),
                                                                              ),
                                                                              enabledBorder: UnderlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.white,
                                                                                  width: 1.0,
                                                                                ),
                                                                              ),
                                                                              //fillColor: Colors.green
                                                                            ),
                                                                            controller: additional_charges[index]['charge_value_controller'],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                                      child:  Container(
                                                                        height: 48,
                                                                        width: 65,
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.transparent,
                                                                          shape: BoxShape.rectangle,
                                                                        ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                                          child: DropdownButtonHideUnderline(
                                                                            child: ButtonTheme(
                                                                              child: DropdownButton<String>(
                                                                                dropdownColor: Colors.white,
                                                                                elevation: 0,
                                                                                focusColor:Colors.transparent,
                                                                                value: additional_charges[index]['sel_gst_val'],
                                                                                //elevation: 5,
                                                                                style: TextStyle(color: AppBarColor),
                                                                                iconEnabledColor:AppBarColor,
                                                                                items: additional_charges[index]['gst_pers'].map<DropdownMenuItem<String>>((item) =>
                                                                                new DropdownMenuItem<String>(
                                                                                  child: new Text(item.toString()+" "+ "%",style: TextStyle(fontSize: 18, color: AppBarColor),),
                                                                                  value: item.toString(),
                                                                                )
                                                                                ).toList(),

                                                                                hint:Padding(
                                                                                  padding: const EdgeInsets.only(left: 5),
                                                                                  child: Text(
                                                                                    "GST %",
                                                                                    style: GoogleFonts.poppins(
                                                                                        color: AppBarColor,
                                                                                        fontSize: 15,
                                                                                        fontWeight: FontWeight.w400),
                                                                                  ),
                                                                                ),
                                                                                onChanged: double.parse(additional_charges[index]['val'].toString()) == 0||gst_type=='gst-non'?null:(String? value) {
                                                                                  FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                                                                  FocusScopeNode currentFocus = FocusScope.of(context);

                                                                                  if (!currentFocus.hasPrimaryFocus) {
                                                                                    currentFocus.unfocus();
                                                                                  }
                                                                                  setState(() {
                                                                                    //debugPrint(additional_charges[index]['val'].toString());
                                                                                    additional_charges[index]['val'] = additional_charges[index]['charge_value_controller'].text.toString();
                                                                                    lastgstval[index]=value.toString();
                                                                                    additional_charges[index]['sel_gst_val'] = value.toString();
                                                                                    additional_charges[index]['val'] = (((double.parse(value.toString())/100)*(double.parse(additional_charges[index]['val'].toString())))+(double.parse(additional_charges[index]['val'].toString()))).toStringAsFixed(2);
                                                                                  });
                                                                                  //debugPrint(additional_charges[index]['val'].toString());
                                                                                  sum_additional_charge();
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    IconButton(
                                                                      onPressed:(){
                                                                        setState(() {
                                                                          additional_charges[index]['charge_value_controller'].text = '0.0';
                                                                          lastgstval[index] = gstpercent;
                                                                          additional_charges[index]['sel_gst_val'] = gstpercent;
                                                                          additional_charges[index]['val'] = '0.0';
                                                                          //debugPrint(addchargeheight.toString());
                                                                          //debugPrint(additional_charges.length.toString());
                                                                          sum_additional_charge();
                                                                        });
                                                                      },
                                                                      icon:Icon(Icons.cancel, color:Colors.white),
                                                                    )
                                                                  ]
                                                              )
                                                          ),
                                                        );
                                                      }

                                                  )
                                              ),
                                            ),
                                          /*     if(showdiscountfield==false)
                                        Container(
                                            height:30,
                                          child: TextButton(
                                              onPressed:(){
                                               setState((){
                                                 discountheight = 60.0;
                                                 showdiscountfield=true;
                                               });
                                              },
                                              child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children:[
                                                    Icon(Icons.add, size:18, color:Colors.indigo),
                                                    Text('Discount', style:TextStyle(
                                                        color: Colors.indigo, fontSize:18
                                                    ))
                                                  ]
                                              )
                                          ),
                                        ),
                                        if(showdiscountfield==true)
                                        Padding(
                                          padding: const EdgeInsets.only(left:10, right:20),
                                          child: AnimatedContainer(
                                              width: MediaQuery.of(context).size.width,
                                              height: discountheight,
                                              duration: Duration(seconds: 1),
                                              child: Row(
                                                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(10, 5, 5, 0),
                                                    child: Text('Discount', style:TextStyle(
                                                        color: Colors.indigo, fontSize:18
                                                    )),
                                                  ),
                                                  Row(
                                                       mainAxisAlignment:MainAxisAlignment.center,
                                                      children:[
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                          child:  Container(
                                                            height: 50,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                color: Colors.transparent,
                                                                shape: BoxShape.rectangle,
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius.circular(5.0),
                                                                    topLeft: Radius.circular(5.0),
                                                                    bottomLeft: Radius.circular(5.0),
                                                                    bottomRight: Radius.circular(5.0))),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                              child: TextFormField(
                                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                inputFormatters: <TextInputFormatter>[
                                                                  FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                  MyNumberTextInputFormatter(digit: 4),
                                                                ],
                                                                onChanged: (v){
                                                                  if(v.isNotEmpty){
                                                                    setState((){

                                                                      if((double.parse(v.toString())<=double.parse(total_exclusive_val.toString()))){
                                                                        set_exclu_rate();
                                                                        discount_percent_Controller.text = ((double.parse(v.toString())/double.parse(total_exclusive_val.toString()))*100).toStringAsFixed(4);
                                                                        total_exclusive_val = (double.parse(total_exclusive_val.toString())-double.parse(v.toString())).toStringAsFixed(2);
                                                                        sum_additional_charge();
                                                                      }else{
                                                                        showPrintedMessage(context, "Error", "Discount should not be more than Item Subtotal", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                                                        discountController.text = '0.0';
                                                                        discount_percent_Controller.text = '0.0';
                                                                        set_exclu_rate();
                                                                        sum_additional_charge();
                                                                      }
                                                                      });
                                                                  }else{
                                                                    setState((){
                                                                      discount_percent_Controller.text = '0.0';
                                                                      set_exclu_rate();
                                                                      sum_additional_charge();
                                                                    });
                                                                  }

                                                                },
                                                                decoration: new InputDecoration(
                                                                  contentPadding:
                                                                  EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                                                  prefixIconConstraints: BoxConstraints(
                                                                    minWidth: 25,
                                                                    minHeight: 25,
                                                                  ),
                                                                  prefixIcon: Container(
                                                                    width:25,
                                                                    child: TextButton(
                                                                        onPressed:null,
                                                                        child: Text('₹', style:TextStyle(fontSize:20, color:Colors.black, fontWeight:FontWeight.bold))),
                                                                  ),
                                                                  isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                  labelText: "0.0",
                                                                  fillColor: Colors.white.withOpacity(0.5),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.white,
                                                                      width: 1.0,
                                                                    ),
                                                                  ),
                                                                  enabledBorder: UnderlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.white,
                                                                      width: 1.0,
                                                                    ),
                                                                  ),
                                                                  //fillColor: Colors.green
                                                                ),
                                                                controller: discountController,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                          child:  Container(
                                                            height: 50,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                color: Colors.transparent,
                                                                shape: BoxShape.rectangle,
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius.circular(5.0),
                                                                    topLeft: Radius.circular(5.0),
                                                                    bottomLeft: Radius.circular(5.0),
                                                                    bottomRight: Radius.circular(5.0))),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                              child: TextFormField(
                                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                inputFormatters: <TextInputFormatter>[
                                                                  FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                                  MyNumberTextInputFormatter(digit: 4),
                                                                ],
                                                                onChanged: (v){
                                                                  if(v.isNotEmpty){
                                                                    if(double.parse(v.toString())>=0&&double.parse(v.toString())<=100){
                                                                      setState((){
                                                                        set_exclu_rate();
                                                                        discountController.text = ((double.parse(v.toString())/100)*double.parse(total_exclusive_val.toString())).toStringAsFixed(2);
                                                                        total_exclusive_val = (double.parse(total_exclusive_val.toString())-double.parse(discountController.text.toString())).toStringAsFixed(2);
                                                                        sum_additional_charge();
                                                                      });
                                                                    }else{
                                                                      setState((){
                                                                        discount_percent_Controller.text = '100.0';
                                                                        set_exclu_rate();
                                                                        v='';
                                                                        discountController.text=total_exclusive_val.toString();
                                                                        total_exclusive_val = (double.parse(total_exclusive_val.toString())-double.parse(discountController.text.toString())).toStringAsFixed(2);
                                                                        sum_additional_charge();
                                                                      });
                                                                    }
                                                                  }else{
                                                                    setState((){
                                                                      discountController.text='0.0';
                                                                      total_exclusive_val = (double.parse(total_exclusive_val.toString())-double.parse(discountController.text.toString())).toStringAsFixed(2);
                                                                      set_exclu_rate();
                                                                      sum_additional_charge();
                                                                    });
                                                                  }

                                                               },
                                                                decoration: new InputDecoration(
                                                                  contentPadding:
                                                                  EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                                                  suffixIconConstraints: BoxConstraints(
                                                                    minWidth: 25,
                                                                    minHeight: 25,
                                                                  ),
                                                                  suffixIcon: Container(
                                                                    width:25,
                                                                    child: TextButton(
                                                                        onPressed:null,
                                                                        child: Text('%', style:TextStyle(fontSize:20, color:Colors.black, fontWeight:FontWeight.bold))),
                                                                  ),
                                                                  isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                  labelText: "0.0",
                                                                  fillColor: Colors.white.withOpacity(0.5),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.white,
                                                                      width: 1.0,
                                                                    ),
                                                                  ),
                                                                  enabledBorder: UnderlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.white,
                                                                      width: 1.0,
                                                                    ),
                                                                  ),
                                                                  //fillColor: Colors.green
                                                                ),
                                                                controller: discount_percent_Controller,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed:(){
                                                           setState(() {
                                                             discountheight = 0.0;
                                                             showdiscountfield=false;
                                                             //addchargeheight = addchargeheight-60;
                                                               discountController.text = '0.0';
                                                               discount_percent_Controller.text = '0.0';
                                                               set_exclu_rate();
                                                               sum_additional_charge();
                                                           });
                                                          },
                                                          icon:Icon(Icons.cancel, color:Colors.white),
                                                        )
                                                      ]
                                                  ),
                                                ],
                                              )
                                          ),
                                        ),*/
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.only(right:10),
                                                  child: Text('Round Off : ', style:TextStyle(
                                                      color: Colors.indigo, fontSize:18, fontWeight:FontWeight.w600
                                                  ))
                                              ),
                                              Container(
                                                width: 100,
                                                height: 40,
                                                child: Row(
                                                  children: [
                                                    Text('No',style: TextStyle(fontSize:12, color:AppBarColor),),
                                                    Switch(
                                                      onChanged: (v){

                                                        setState((){
                                                          isamountround = v;
                                                          if(v==true){
                                                            total_exclusive_val = double.parse(total_exclusive_val.toString()).round().toString();
                                                            total_amount_after_additional = double.parse(total_amount_after_additional.toString()).round().toString();
                                                          }else{
                                                            total_amount_after_additional=un_round_items_total.toString();
                                                            total_exclusive_val=un_round_items_subtotal.toString();
                                                          }
                                                        });

                                                      },
                                                      value: isamountround,
                                                      activeColor: AppBarColor,
                                                      activeTrackColor: AppBarColor.withOpacity(0.3),
                                                      inactiveThumbColor: AppBarColor.withOpacity(0.3),
                                                      inactiveTrackColor: AppBarColor,
                                                    ),
                                                    Text('Yes',style: TextStyle(fontSize:12, color:AppBarColor),),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                        ]
                                    ),
                                  ),
                                ),
                              if(totalselected_id.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  child: Divider(
                                    color: AppBarColor.withOpacity(0.3),
                                    thickness: 0.2,
                                  ),
                                ),
                              if(totalselected_id.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:15),
                                      child: Container(
                                          width: 100,
                                          child: Text('Total',style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),)),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width-115,
                                      height: 40,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right:30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text('₹',style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),),
                                            SizedBox(width:5),
                                            if(double.parse(total_amount_after_additional.toString())>double.parse(total_exclusive_val.toString()))
                                              Text(total_amount_after_additional.toString(),style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),)
                                            else
                                              Text(total_exclusive_val.toString(),style: TextStyle(fontSize:15, color:AppBarColor, fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if(totalselected_id.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                                  child:  Container(
                                    height: 50,
                                    width:MediaQuery.of(context).size.width-10,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(5.0),
                                            topLeft: Radius.circular(5.0),
                                            bottomLeft: Radius.circular(5.0),
                                            bottomRight: Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      child: TextFormField(
                                        readOnly:false,
                                        onChanged: (v){

                                        },
                                        decoration: new InputDecoration(

                                          prefixIconConstraints: BoxConstraints(
                                            minWidth: 15,
                                            minHeight: 48,
                                          ),

                                          prefixIcon: IconButton(onPressed:null,
                                              icon:Icon(Icons.ballot_outlined,size:20, color:Colors.grey)),
                                          isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                          labelText: "Remarks",
                                          fillColor: Colors.white.withOpacity(0.5),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey.withOpacity(0.3),
                                              width: 1.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey.withOpacity(0.3),
                                              width: 1.0,
                                            ),
                                          ),
                                          //fillColor: Colors.green
                                        ),
                                        controller: total_remarks_Controller,
                                      ),
                                    ),
                                  ),
                                ),
                              if(totalselected_id.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  child: Divider(
                                    color: AppBarColor.withOpacity(0.3),
                                    thickness: 0.2,
                                  ),
                                ),
                            ],
                          ):Container(
                            child:Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 0.7,

                              ),
                            ),
                          ),

                        ),
                      ),
                    if(showfirstloader==true)
                      Container(
                          height: 200,
                          width:MediaQuery.of(context).size.width,
                          child:Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 0.7,

                            ),
                          )
                      )
                  ],
                ):
                ListView(
                  children: [
                    AnimatedContainer(
                      height: add_det_height,
                      width: MediaQuery.of(context).size.width,
                      duration: Duration(seconds: 1),
                      decoration: BoxDecoration(
                          color: Colors.white,// BoxShape.circle or BoxShape.retangle
                          //color: const Color(0xFF66BB6A),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5.0,
                          ),]
                      ),
                      child: showaddpartyloader==false?ListView(
                        children: [
                          Row(
                            mainAxisAlignment:MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed:(){
                                    setState((){
                                      is_adddetails_clicked = false;
                                      pnamedetController.clear();
                                      phoneController.clear();
                                      ismoredetailclicked=false;
                                      isrecieve=true;
                                      phoneController.clear();
                                      gstnoController.clear();
                                      panController.clear();
                                      tanController.clear();
                                      cinController.clear();
                                      distanceController.clear();
                                      addressController.clear();
                                      state = null;
                                      isrecieve = true;
                                      openbalController.clear();
                                    });
                                  },
                                  icon: Icon(Icons.cancel_outlined, size: 30,)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                            child: Row(
                              children: [
                                Text('PARTY NAME', style: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.w500
                                ),),
                                Text(' *', style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red
                                ),),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                            child:  Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5.0),
                                      topLeft: Radius.circular(5.0),
                                      bottomLeft: Radius.circular(5.0),
                                      bottomRight: Radius.circular(5.0))),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  onChanged: (v){

                                  },
                                  decoration: new InputDecoration(
                                    prefixIcon: Icon(Icons.perm_identity_sharp, color: Colors.grey.withOpacity(0.9),size: 25,),
                                    isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                    labelText: "Name",
                                    fillColor: Colors.white.withOpacity(0.5),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1.0,
                                      ),
                                    ),
                                    //fillColor: Colors.green
                                  ),
                                  controller: pnamedetController,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                            child: Row(
                              children: [
                                Text('Phone Number', style: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.w500
                                ),),
                                Text(' (Optional)', style: GoogleFonts.poppins(
                                    fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey
                                ),),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                            child:  Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5.0),
                                      topLeft: Radius.circular(5.0),
                                      bottomLeft: Radius.circular(5.0),
                                      bottomRight: Radius.circular(5.0))),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: TextFormField(
                                  onChanged: (v){

                                  },
                                  decoration: new InputDecoration(
                                    prefixIcon: Icon(Icons.phone_android, color: Colors.grey.withOpacity(0.9),size: 25,),
                                    isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                    labelText: "Phone",
                                    fillColor: Colors.white.withOpacity(0.5),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1.0,
                                      ),
                                    ),
                                    //fillColor: Colors.green
                                  ),
                                  controller: phoneController,
                                ),
                              ),
                            ),
                          ),
                          if(ismoredetailclicked==false)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width-167,
                                    child: Row(
                                      children: [
                                        RaisedButton(
                                          elevation: 0,
                                          color: Colors.transparent,
                                          onPressed: (){
                                            setState(() {
                                              add_det_height = MediaQuery.of(context).size.height-91;
                                              ismoredetailclicked = true;
                                            });
                                          },
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Text('Add More Details', style:TextStyle(fontSize:16, color:Colors.indigoAccent)),
                                              Text('Balance, Credit....', style:TextStyle(fontSize:16, color:Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 50,
                                    width: 100,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                      color: AppBarColor,
                                      onPressed: (){
                                        if(pnamedetController.text.isEmpty){
                                          showPrintedMessage(context, "Alert", "Please fill all required fields to submit", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                        }else{
                                          addParty();
                                        }
                                      },
                                      child: Text('Save Party', style:TextStyle(fontSize:16, color:Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                              child: Row(
                                children: [
                                  Text('Optional Details', style: GoogleFonts.poppins(
                                      fontSize: 18, fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                              child: Row(
                                children: [
                                  Text('GST DETAILS', style: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                              child:  Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5.0),
                                        topLeft: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0))),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: TextFormField(
                                    onChanged: (v){

                                    },
                                    decoration: new InputDecoration(
                                      prefixIcon: TextButton(
                                          onPressed:null,
                                          child: Text('GST', style:TextStyle(fontSize:20, color:Colors.grey, fontWeight: FontWeight.bold))),
                                      isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                      labelText: "GSTIN",
                                      fillColor: Colors.white.withOpacity(0.5),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    controller: gstnoController,
                                  ),
                                ),
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                              child: Row(
                                children: [
                                  Text(labelpan.toString(), style: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                              child:  Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5.0),
                                        topLeft: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0))),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: TextFormField(
                                    decoration: new InputDecoration(
                                      isDense: true,labelText: labelpan.toString(),
                                      labelStyle: GoogleFonts.poppins(
                                          fontSize: 14, color: AppBarColor
                                      ),
                                      prefixIcon: IconButton(
                                          onPressed: null,
                                          icon: Icon(Icons.payment)
                                      ),
                                      fillColor: Colors.white.withOpacity(0.5),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    controller: panController,
                                  ),
                                ),
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                              child: Row(
                                children: [
                                  Text(labeltan.toString(), style: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                              child:  Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5.0),
                                        topLeft: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0))),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: TextFormField(
                                    decoration: new InputDecoration(
                                      isDense: true,labelText: labeltan.toString(),
                                      labelStyle: GoogleFonts.poppins(
                                          fontSize: 14, color: AppBarColor
                                      ),
                                      prefixIcon: IconButton(
                                          onPressed: null,
                                          icon: Icon(Icons.payment)
                                      ),
                                      fillColor: Colors.white.withOpacity(0.5),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    controller: tanController,
                                  ),
                                ),
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                              child: Row(
                                children: [
                                  Text(labelcin.toString(), style: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                              child:  Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5.0),
                                        topLeft: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0))),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: TextFormField(
                                    decoration: new InputDecoration(
                                      isDense: true,labelText: labelcin.toString(),
                                      labelStyle: GoogleFonts.poppins(
                                          fontSize: 14, color: AppBarColor
                                      ),
                                      prefixIcon: IconButton(
                                          onPressed: null,
                                          icon: Icon(Icons.payment)
                                      ),
                                      fillColor: Colors.white.withOpacity(0.5),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    controller: cinController,
                                  ),
                                ),
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                              child: Row(
                                children: [
                                  Text('Distance (In Km)', style: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                              child:  Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5.0),
                                        topLeft: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0))),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: TextFormField(
                                    decoration: new InputDecoration(
                                      isDense: true,labelText: 'Distance (In Km)',
                                      labelStyle: GoogleFonts.poppins(
                                          fontSize: 14, color: AppBarColor
                                      ),
                                      prefixIcon: IconButton(
                                          onPressed: null,
                                          icon: Icon(Icons.payment)
                                      ),
                                      fillColor: Colors.white.withOpacity(0.5),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    controller: distanceController,
                                  ),
                                ),
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                              child: Row(
                                children: [
                                  Text('ADDRESS DETAILS', style: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                              child:  Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5.0),
                                        topLeft: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0))),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: TextFormField(
                                    onChanged: (v){

                                    },
                                    decoration: new InputDecoration(
                                      prefixIcon: Icon(Icons.map, color: Colors.grey.withOpacity(0.9),size: 25,),
                                      isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                      labelText: "Billing Address",
                                      fillColor: Colors.white.withOpacity(0.5),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    controller: addressController,
                                  ),
                                ),
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                              child: Row(
                                children: [
                                  Text('State', style: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                              child:  Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5.0),
                                        topLeft: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0))),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.white,
                                        elevation: 0,
                                        focusColor:Colors.transparent,
                                        value: state,
                                        //elevation: 5,
                                        style: TextStyle(color: AppBarColor),
                                        iconEnabledColor:AppBarColor,
                                        items: stateslist?.map((item) {
                                          return new DropdownMenuItem(
                                            child: new Text(item['state_name'],style: TextStyle(fontSize: 18, color: AppBarColor),),
                                            value: item['state_name'].toString(),
                                          );
                                        })?.toList() ??
                                            [],
                                        hint:Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: Text(
                                            "State",
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
                                            state = value.toString();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                              child: Row(
                                children: [
                                  Text('Opening Balance', style: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                              child:  Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5.0),
                                        topLeft: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0))),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: TextFormField(
                                    onChanged: (v){

                                    },
                                    decoration: new InputDecoration(
                                      prefixIcon: TextButton(
                                          onPressed:null,
                                          child: Text('₹', style:TextStyle(fontSize:30, color:Colors.grey, fontWeight: FontWeight.bold))),
                                      suffixIcon: Container(
                                        width: 208,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 80,
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(50)),
                                                  elevation: 0,
                                                  color: isrecieve==true?AppBarColor:Colors.grey.withOpacity(0.3),
                                                  onPressed: (){
                                                    setState(() {
                                                      isrecieve=true;
                                                    });
                                                  },
                                                  child: Text('I Receive', style:TextStyle(fontSize:12, color:isrecieve==true?Colors.white:Colors.black)),
                                                ),
                                              ),
                                              SizedBox(width:5),
                                              Container(
                                                height: 40,
                                                width: 80,
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(50)),
                                                  elevation: 0,
                                                  color: isrecieve==false?AppBarColor:Colors.grey.withOpacity(0.3),
                                                  onPressed: (){
                                                    setState(() {
                                                      isrecieve=false;
                                                    });
                                                  },
                                                  child: Text('I Pay', style:TextStyle(fontSize:12, color:isrecieve==false?Colors.white:Colors.black)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                      labelText: "GSTIN",
                                      fillColor: Colors.white.withOpacity(0.5),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    controller: openbalController,
                                  ),
                                ),
                              ),
                            ),
                          if(ismoredetailclicked==true)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width-40,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                      color: AppBarColor,
                                      onPressed: (){
                                        if(pnamedetController.text.isEmpty){
                                          showPrintedMessage(context, "Alert", "Please fill all required fields to submit", Colors.white,Colors.redAccent, Icons.info, true, "top");
                                        }else{
                                          addParty();
                                        }
                                      },
                                      child: Text('Save', style:TextStyle(fontSize:16, color:Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ):Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.7,
                        ),
                      ),
                    ),
                  ],
                )

            )
        ):
        Scaffold(
            appBar: show_create_item_screen==false?AppBar(
              elevation: 1,
              backgroundColor: Colors.white,
              centerTitle: false,
              leading: IconButton(
                  onPressed:(){
                    if(double.parse(totalitems.toString())>0.0){
                      back_from_add_item(context);

                    }else{
                      setState(() {
                        totalselected_id.clear();
                        discountflat.clear();
                        discountperct.clear();
                        totalselected_name.clear();
                        totalselected_val.clear();
                        totalselected_rate.clear();
                        prod_rate_with_discount.clear();
                        totalselected_tax.clear();
                        totalselected_uom.clear();
                        totalselected_tax_type.clear();
                        total_base_rate.clear();
                        intrim_prod_base_rate.clear();
                        totalitems = '0.0';
                        totalvalue = '0.0';
                        isadditem_clicked = false;
                        showadddetails = true;
                        indexpostionprod.clear();
                        isbillfoundprod = true;
                        partyname = 265;
                        additional_charges.clear();
                        lastgstval.clear();
                        for(var i=0; i<3; i++){
                          Map a = {'charge_name_controller': TextEditingController(),
                            'charge_value_controller': TextEditingController(),
                            'val':'0.0','gst_pers':gstperlist, 'sel_gst_val': gstpercent};
                          additional_charges.add(a);
                          lastgstval.add(gstpercent);
                        }
                        if(additional_charges.isNotEmpty){
                          var ab = aliases.indexOf('Freight');
                          var b = aliases.indexOf('Insurance');
                          var c = aliases.indexOf('Packaging');
                          additional_charges[0]['charge_name_controller'].text = whole_allias_array[ab]['aliase'].toString();
                          additional_charges[1]['charge_name_controller'].text = whole_allias_array[b]['aliase'].toString();
                          additional_charges[2]['charge_name_controller'].text = whole_allias_array[c]['aliase'].toString();
                        }
                        discountController.text = '0.0';
                        total_exclusive_val = '0';
                        total_amount_after_additional = '';
                        discount_percent_Controller.text = '0.0';
                        for(var i=0; i<products.length; i++){
                          products[i]['controller'].clear();
                          products[i]['value']='0.0';
                        }
                      });
                    }

                  },
                  icon:Icon(Icons.arrow_back, size:20, color:AppBarColor)
              ),
              title: Container(
                color: Colors.transparent,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: itemproductlistController,
                    onChanged: (v){
                      filterProductsResults(v.toString());
                    },
                    decoration: InputDecoration(
                        labelText: "Search using name, hsn no, category",
                        labelStyle: TextStyle(color: AppBarColor),
                        hintText: "Search using name, hsn no, category",
                        hintStyle: TextStyle(color: AppBarColor),
                        fillColor: Colors.white,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3), width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3), width: 1.0),
                        ),
                        prefixIcon: Icon(Icons.search, color: AppBarColor,),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(35.0)))),
                    style: TextStyle(color: AppBarColor),
                  ),
                ),
              ),
              actions: [

              ],
            ):
            AppBar(
              elevation: 1,
              backgroundColor: Colors.white,
              centerTitle: false,
              leading: showcreateitemloader==false?IconButton(
                  onPressed:(){
                    setState(() {
                      show_create_item_screen = false;
                      selectedrow = 'pricing';
                      show_create_item_screen=false;
                      add_item_name_Controller.clear();
                      sale_price_Controller.clear();
                      purchase_price_Controller.clear();
                      uom1=null;
                      create_item_hsn_Controller.clear();
                      newitemgstper=null;
                      create_item_open_stock_Controller.clear();
                      create_item_open_amount_Controller.clear();
                      create_item_code_Controller.clear();
                      remarks_Controller.clear();
                      item_type = 'Product';
                      /*        products.clear();
                      totalselected_id.clear();
                      discountflat.clear();
                      discountperct.clear();
                      totalselected_name.clear();
                      totalselected_val.clear();
                      totalselected_rate.clear();
                      prod_rate_with_discount.clear();
                      totalselected_tax.clear();
                      totalselected_uom.clear();
                      totalselected_tax_type.clear();
                      totalitems = '0.0';
                      totalvalue = '0.0';
                      isadditem_clicked = false;
                      showadddetails = true;
                      indexpostionprod.clear();
                      isbillfoundprod = true;
                      partyname = 265;
                      additional_charges.clear();
                      lastgstval.clear();
                      for(var i=0; i<3; i++){
                        Map a = {'charge_name_controller': TextEditingController(),
                          'charge_value_controller': TextEditingController(),
                          'val':'0.0','gst_pers':gstperlist, 'sel_gst_val': gstpercent};
                        additional_charges.add(a);
                        lastgstval.add(gstpercent);
                      }
                      if(additional_charges.isNotEmpty){
                        var ab = aliases.indexOf('Freight');
                        var b = aliases.indexOf('Insurance');
                        var c = aliases.indexOf('Packaging');
                        additional_charges[0]['charge_name_controller'].text = whole_allias_array[ab]['aliase'].toString();
                        additional_charges[1]['charge_name_controller'].text = whole_allias_array[b]['aliase'].toString();
                        additional_charges[2]['charge_name_controller'].text = whole_allias_array[c]['aliase'].toString();
                      }
                      discountController.text = '0.0';
                      total_exclusive_val = '0';
                      total_amount_after_additional = '';
                      total_base_rate.clear();
                      intrim_prod_base_rate.clear();
                      discount_percent_Controller.text = '0.0';*/


                    });
                  },
                  icon:Icon(Icons.arrow_back, size:20, color:AppBarColor)
              ):Container(),
              title: Text('Create New Items',style: TextStyle(
                fontSize:18, color:AppBarColor,
              ),),
              actions: [

              ],
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color:Colors.white,
              child: show_create_item_screen==false?
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8,bottom: 8),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,// BoxShape.circle or BoxShape.retangle
                          //color: const Color(0xFF66BB6A),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 1.0,
                          ),]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 35,
                              width: 160,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                elevation: 0,
                                color: Colors.lightBlueAccent.withOpacity(0.2),
                                onPressed: (){
                                  setState(() {
                                    show_create_item_screen = true;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.add, size: 15, color: Colors.black,),
                                    Text('Create New Item', style:TextStyle(fontSize:15, color:Colors.black, fontWeight: FontWeight.w400)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if(showloader == true)
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height - 237,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.7,

                        ),
                      ),
                    ),
                  if(showloader==false&&itemsprod.isEmpty&&isbillfoundprod == true)
                    Container(
                      width:MediaQuery.of(context).size.width,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height - 237,
                      color: Colors.white,
                      child: products.isNotEmpty ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: products.length,
                            itemBuilder: (BuildContext context, index) {
                              return GestureDetector(
                                onTap: () {
                                  FocusScopeNode currentFocus = FocusScope.of(
                                      context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }


                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      Card(
                                        elevation: 0,
                                        child: Container(
                                          child: Container(
                                            width:MediaQuery.of(context).size.width,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8, top: 8, bottom: 2),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width:MediaQuery.of(context).size.width-162,
                                                        child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Text(products[index]['name'].toString(), style: GoogleFonts.poppins(
                                                              fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500
                                                          ),),
                                                        ),
                                                      ),
                                                      Container(
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape.rectangle,
                                                              color:Colors.white,
                                                              border: Border.all(color: AppBarColor),
                                                              borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(30.0),
                                                                  topLeft: Radius.circular(30.0),
                                                                  bottomLeft: Radius.circular(30.0),
                                                                  bottomRight: Radius.circular(30.0))),
                                                          width:110,

                                                          child:TextFormField(
                                                            readOnly: products[index]['pr_type'].toString()=='Service'||products[index]['cur_bal'].toString()=='N/A'?false:isreadonly,
                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                            inputFormatters: <TextInputFormatter>[
                                                              FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                              MyNumberTextInputFormatter(digit: 4),
                                                            ],
                                                            autofocus: false,
                                                            maxLines: 1,
                                                            minLines: 1,
                                                            onTap:(){
                                                              if(isnegative_stock_allowed==false){
                                                                if(products[index]['cur_bal'].toString().contains('-')||double.parse(products[index]['cur_bal'].toString())==0){
                                                                  setState((){
                                                                    isreadonly = true;
                                                                  });
                                                                  showPrintedMessage(context, "Error", "Negative stock billing is not allowed", Colors.white,Colors.red, Icons.info, true, "top");
                                                                }if(double.parse(products[index]['cur_bal'].toString())>0){
                                                                  setState(() {
                                                                    isreadonly = false;
                                                                  });
                                                                }}else{
                                                                setState((){
                                                                  isreadonly = false;
                                                                });
                                                              }
                                                            },
                                                            onChanged: (v){
                                                              if(isnegative_stock_allowed==true){
                                                                if(v.isNotEmpty) {
                                                                  setState(() {
                                                                    products[index]['value'] = v.toString();
                                                                    setval_rate();
                                                                  });
                                                                }else{
                                                                  setState(() {
                                                                    products[index]['value'] = '0.0';
                                                                    setval_rate();
                                                                  });
                                                                }
                                                              }else{
                                                                if(v.isNotEmpty) {
                                                                  if(double.parse(v.toString())>double.parse(products[index]['cur_bal'].toString())){
                                                                    setState(() {
                                                                      showPrintedMessage(context, "Error", "Exceeding Stock Limit", Colors.white,Colors.red, Icons.info, true, "top");
                                                                      products[index]['controller'].text = products[index]['cur_bal'].toString();
                                                                      v = products[index]['cur_bal'].toString();
                                                                      products[index]['value'] = v.toString();
                                                                      setval_rate();
                                                                    });
                                                                  }else{
                                                                    setState(() {
                                                                      products[index]['value'] = v.toString();
                                                                      setval_rate();
                                                                    });
                                                                  }
                                                                }else{
                                                                  setState(() {
                                                                    products[index]['value'] = '0.0';
                                                                    setval_rate();
                                                                  });
                                                                }
                                                              }
                                                            },
                                                            decoration: new InputDecoration(
                                                              contentPadding:
                                                              EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                                              isDense: true,
                                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                                              labelText: "ADD",
                                                              prefixIconConstraints: BoxConstraints(
                                                                minWidth: 30,
                                                                minHeight: 25,
                                                              ),
                                                              suffixIconConstraints: BoxConstraints(
                                                                minWidth: 30,
                                                                minHeight: 25,
                                                              ),
                                                              prefixIcon:  GestureDetector(
                                                                onTap:(){
                                                                  setState((){
                                                                    isreadonly = true;
                                                                  });
                                                                  if(products[index]['controller'].text.isNotEmpty&&double.parse(products[index]['controller'].text.toString())>=1){
                                                                    setState((){
                                                                      products[index]['controller'].text = (double.parse(products[index]['controller'].text.toString())-1).toString();
                                                                      products[index]['value']=products[index]['controller'].text;
                                                                      setval_rate();
                                                                    });
                                                                  }
                                                                  if(products[index]['controller'].text.isNotEmpty&&double.parse(products[index]['controller'].text.toString())<1){
                                                                    setState((){
                                                                      products[index]['controller'].text = '0.0';
                                                                      products[index]['value']=products[index]['controller'].text;
                                                                      setval_rate();
                                                                    });
                                                                  }
                                                                },
                                                                child: Container(
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape.rectangle,
                                                                        color:scaffoldbackground,

                                                                        borderRadius: BorderRadius.only(
                                                                            topRight: Radius.circular(0.0),
                                                                            topLeft: Radius.circular(30.0),
                                                                            bottomLeft: Radius.circular(30.0),
                                                                            bottomRight: Radius.circular(0.0))),
                                                                    height: 30,
                                                                    width:10,
                                                                    child:Center(child: Icon(Icons.remove, color:Colors.white))
                                                                ),
                                                              ),
                                                              suffixIcon: GestureDetector(
                                                                onTap:(){
                                                                  if(isnegative_stock_allowed==true){
                                                                    setState((){
                                                                      isreadonly = true;
                                                                    });
                                                                    if(products[index]['controller'].text.isEmpty){
                                                                      setState((){
                                                                        products[index]['controller'].text = '1.0';
                                                                        products[index]['value']=products[index]['controller'].text;
                                                                        setval_rate();
                                                                      });
                                                                    }else{
                                                                      setState((){
                                                                        products[index]['controller'].text = (double.parse(products[index]['controller'].text.toString())+1).toString();
                                                                        products[index]['value']=products[index]['controller'].text;
                                                                        setval_rate();
                                                                      });
                                                                    }
                                                                  }else{
                                                                    if(products[index]['pr_type'].toString()=='Service'||products[index]['cur_bal'].toString()=='N/A'){
                                                                      setState((){
                                                                        isreadonly = true;
                                                                      });
                                                                      if(products[index]['controller'].text.isEmpty){
                                                                        setState((){
                                                                          products[index]['controller'].text = '1.0';
                                                                          products[index]['value']=products[index]['controller'].text;
                                                                          setval_rate();
                                                                        });
                                                                      }else{
                                                                        setState((){
                                                                          products[index]['controller'].text = (double.parse(products[index]['controller'].text.toString())+1).toString();
                                                                          products[index]['value']=products[index]['controller'].text;
                                                                          setval_rate();
                                                                        });
                                                                      }
                                                                    }else{
                                                                      if(products[index]['cur_bal'].toString().contains('-')||double.parse(products[index]['cur_bal'].toString())==0){
                                                                        showPrintedMessage(context, "Error", "Negative stock billing is not allowed", Colors.white,Colors.red, Icons.info, true, "top");
                                                                      }else{
                                                                        if(double.parse(products[index]['cur_bal'].toString())>0){
                                                                          setState((){
                                                                            isreadonly = true;
                                                                          });
                                                                          if(products[index]['controller'].text.isEmpty){
                                                                            setState((){
                                                                              products[index]['controller'].text = '1.0';
                                                                              products[index]['value']=products[index]['controller'].text;
                                                                              setval_rate();
                                                                            });
                                                                          }else{
                                                                            setState((){
                                                                              products[index]['controller'].text = (double.parse(products[index]['controller'].text.toString())+1).toString();
                                                                              products[index]['value']=products[index]['controller'].text;
                                                                              setval_rate();
                                                                            });
                                                                          }
                                                                        }
                                                                        if(double.parse(products[index]['value'].toString())>double.parse(products[index]['cur_bal'].toString())){
                                                                          showPrintedMessage(context, "Error", "Exceeding Stock Limit", Colors.white,Colors.red, Icons.info, true, "top");
                                                                          setState((){
                                                                            isreadonly = true;
                                                                          });
                                                                          setState((){
                                                                            products[index]['controller'].text = products[index]['cur_bal'].toString();
                                                                            products[index]['value']=products[index]['controller'].text;
                                                                            setval_rate();
                                                                          });
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                },
                                                                child: Container(
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape.rectangle,
                                                                        color:scaffoldbackground,

                                                                        borderRadius: BorderRadius.only(
                                                                            topRight: Radius.circular(30.0),
                                                                            topLeft: Radius.circular(0.0),
                                                                            bottomLeft: Radius.circular(0.0),
                                                                            bottomRight: Radius.circular(30.0))),
                                                                    height: 30,
                                                                    width:10,
                                                                    child:Center(child: Icon(Icons.add, color:Colors.white))
                                                                ),
                                                              ),
                                                              labelStyle: TextStyle(fontSize: 13),
                                                              fillColor: Colors.white.withOpacity(0.5),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide(
                                                                  color: Colors.grey.withOpacity(0.3),
                                                                  width: 0.0,
                                                                ),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide(
                                                                  color: Colors.grey.withOpacity(0.3),
                                                                  width: 0.0,
                                                                ),
                                                              ),
                                                              //fillColor: Colors.green
                                                            ),
                                                            controller: products[index]['controller'],
                                                          )
                                                      ),
                                                      //  Icon(Icons.circle, size: 10,color: products[index]['is_active'].toString()=="1"?Colors.green:Colors.red,)
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 8),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Category :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                products[index]['cat_name']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 8),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Pr Type :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                products[index]['pr_type']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Rate :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),

                                                            Row(
                                                              children: [
                                                                Text(" " +
                                                                    '₹',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                      fontSize: 13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w400
                                                                  ),),
                                                                Text(" " +
                                                                    products[index]['pur_rate']
                                                                        .toString(),
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                      fontSize: 13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w400
                                                                  ),),
                                                                Text("/" +
                                                                    products[index]['uom1']
                                                                        .toString(),
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                      fontSize: 13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w400
                                                                  ),),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        TextButton(
                                                            onPressed:(){
                                                              setState((){
                                                                AddAmount(products[index]['iid'].toString(),context, products[index]['name'].toString(), index, products[index]['pur_rate'].toString(), "main list");
                                                              });
                                                            },
                                                            child:Text('Change Rate')
                                                        ),
                                                        // Icon(Icons.circle, size: 10,color: products[index]['is_active'].toString()=="1"?Colors.green:Colors.red,),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Value :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                products[index]['value']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Stock :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                products[index]['cur_bal']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
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
                                        ),
                                      ),
                                      if(index == products.length - 1)
                                        Container(
                                          height: 80,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          color: Colors.white,
                                        ),
                                      if(index != products.length - 1)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50, right: 50),
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
                      ) : Center(
                        child: Text('No data found', style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.black
                        ),),
                      ),
                    ),
                  if(showloader==false&&itemsprod.isNotEmpty&&isbillfoundprod == true)
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height - 237,
                      child: itemsprod.isNotEmpty ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: itemsprod.length,
                            itemBuilder: (BuildContext context, index) {
                              return GestureDetector(
                                onTap: () {
                                  FocusScopeNode currentFocus = FocusScope.of(
                                      context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }


                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      Card(
                                        elevation: 0,
                                        child: Container(
                                          child: Container(
                                            width:MediaQuery.of(context).size.width,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8, top: 8, bottom: 2),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width:MediaQuery.of(context).size.width-162,
                                                        child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Text(itemsprod[index]['name'].toString(), style: GoogleFonts.poppins(
                                                              fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500
                                                          ),),
                                                        ),
                                                      ),
                                                      Container(
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape.rectangle,
                                                              color:Colors.white,
                                                              border: Border.all(color: AppBarColor),
                                                              borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(30.0),
                                                                  topLeft: Radius.circular(30.0),
                                                                  bottomLeft: Radius.circular(30.0),
                                                                  bottomRight: Radius.circular(30.0))),
                                                          width:110,

                                                          child:TextFormField(
                                                            readOnly: itemsprod[index]['pr_type'].toString()=='Service'||itemsprod[index]['cur_bal'].toString()=='N/A'?false:isreadonly,
                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                            inputFormatters: <TextInputFormatter>[
                                                              FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                              MyNumberTextInputFormatter(digit: 4),
                                                            ],
                                                            autofocus: false,
                                                            maxLines: 1,
                                                            minLines: 1,
                                                            onTap:(){
                                                              if(isnegative_stock_allowed==false){
                                                                if(itemsprod[index]['cur_bal'].toString().contains('-')||double.parse(itemsprod[index]['cur_bal'].toString())==0){
                                                                  setState((){
                                                                    isreadonly = true;
                                                                  });
                                                                  showPrintedMessage(context, "Error", "Negative stock billing is not allowed", Colors.white,Colors.red, Icons.info, true, "top");
                                                                }if(double.parse(itemsprod[index]['cur_bal'].toString())>0){
                                                                  setState(() {
                                                                    isreadonly = false;
                                                                  });
                                                                }}else{
                                                                setState((){
                                                                  isreadonly = false;
                                                                });
                                                              }
                                                            },
                                                            onChanged: (v){
                                                              if(isnegative_stock_allowed==true){
                                                                if(v.isNotEmpty) {
                                                                  setState(() {
                                                                    itemsprod[index]['value'] = v.toString();
                                                                    setval_rate();
                                                                  });
                                                                }else{
                                                                  setState(() {
                                                                    itemsprod[index]['value'] = '0.0';
                                                                    setval_rate();
                                                                  });
                                                                }
                                                              }else{
                                                                if(v.isNotEmpty) {
                                                                  if(double.parse(v.toString())>double.parse(itemsprod[index]['cur_bal'].toString())){
                                                                    setState(() {
                                                                      showPrintedMessage(context, "Error", "Exceeding Stock Limit", Colors.white,Colors.red, Icons.info, true, "top");
                                                                      itemsprod[index]['controller'].text = itemsprod[index]['cur_bal'].toString();
                                                                      v = itemsprod[index]['cur_bal'].toString();
                                                                      itemsprod[index]['value'] = v.toString();
                                                                      setval_rate();
                                                                    });
                                                                  }else{
                                                                    setState(() {
                                                                      itemsprod[index]['value'] = v.toString();
                                                                      setval_rate();
                                                                    });
                                                                  }
                                                                }else{
                                                                  setState(() {
                                                                    itemsprod[index]['value'] = '0.0';
                                                                    setval_rate();
                                                                  });
                                                                }
                                                              }
                                                            },
                                                            decoration: new InputDecoration(
                                                              contentPadding:
                                                              EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                                              isDense: true,
                                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                                              labelText: "ADD",
                                                              prefixIconConstraints: BoxConstraints(
                                                                minWidth: 30,
                                                                minHeight: 25,
                                                              ),
                                                              suffixIconConstraints: BoxConstraints(
                                                                minWidth: 30,
                                                                minHeight: 25,
                                                              ),
                                                              prefixIcon:  GestureDetector(
                                                                onTap:(){
                                                                  setState((){
                                                                    isreadonly = true;
                                                                  });
                                                                  if(itemsprod[index]['controller'].text.isNotEmpty&&double.parse(itemsprod[index]['controller'].text.toString())>=1){
                                                                    setState((){
                                                                      itemsprod[index]['controller'].text = (double.parse(itemsprod[index]['controller'].text.toString())-1).toString();
                                                                      itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                      setval_rate();
                                                                    });
                                                                  }
                                                                  if(itemsprod[index]['controller'].text.isNotEmpty&&double.parse(itemsprod[index]['controller'].text.toString())<1){
                                                                    setState((){
                                                                      itemsprod[index]['controller'].text = '0.0';
                                                                      itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                      setval_rate();
                                                                    });
                                                                  }
                                                                },
                                                                child: Container(
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape.rectangle,
                                                                        color:scaffoldbackground,

                                                                        borderRadius: BorderRadius.only(
                                                                            topRight: Radius.circular(0.0),
                                                                            topLeft: Radius.circular(30.0),
                                                                            bottomLeft: Radius.circular(30.0),
                                                                            bottomRight: Radius.circular(0.0))),
                                                                    height: 30,
                                                                    width:10,
                                                                    child:Center(child: Icon(Icons.remove, color:Colors.white))
                                                                ),
                                                              ),
                                                              suffixIcon: GestureDetector(
                                                                onTap:(){
                                                                  if(isnegative_stock_allowed==true){
                                                                    setState((){
                                                                      isreadonly = true;
                                                                    });
                                                                    if(itemsprod[index]['controller'].text.isEmpty){
                                                                      setState((){
                                                                        itemsprod[index]['controller'].text = '1.0';
                                                                        itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                        setval_rate();
                                                                      });
                                                                    }else{
                                                                      setState((){
                                                                        itemsprod[index]['controller'].text = (double.parse(itemsprod[index]['controller'].text.toString())+1).toString();
                                                                        itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                        setval_rate();
                                                                      });
                                                                    }
                                                                  }else{
                                                                    if(itemsprod[index]['pr_type'].toString()=='Service'||itemsprod[index]['cur_bal'].toString()=='N/A'){
                                                                      setState((){
                                                                        isreadonly = true;
                                                                      });
                                                                      if(itemsprod[index]['controller'].text.isEmpty){
                                                                        setState((){
                                                                          itemsprod[index]['controller'].text = '1.0';
                                                                          itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                          setval_rate();
                                                                        });
                                                                      }else{
                                                                        setState((){
                                                                          itemsprod[index]['controller'].text = (double.parse(itemsprod[index]['controller'].text.toString())+1).toString();
                                                                          itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                          setval_rate();
                                                                        });
                                                                      }
                                                                    }else{
                                                                      if(itemsprod[index]['cur_bal'].toString().contains('-')||double.parse(itemsprod[index]['cur_bal'].toString())==0){
                                                                        showPrintedMessage(context, "Error", "Negative stock billing is not allowed", Colors.white,Colors.red, Icons.info, true, "top");
                                                                      }else{
                                                                        if(double.parse(itemsprod[index]['cur_bal'].toString())>0){
                                                                          setState((){
                                                                            isreadonly = true;
                                                                          });
                                                                          if(products[index]['controller'].text.isEmpty){
                                                                            setState((){
                                                                              itemsprod[index]['controller'].text = '1.0';
                                                                              itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                              setval_rate();
                                                                            });
                                                                          }else{
                                                                            setState((){
                                                                              itemsprod[index]['controller'].text = (double.parse(itemsprod[index]['controller'].text.toString())+1).toString();
                                                                              itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                              setval_rate();
                                                                            });
                                                                          }
                                                                        }
                                                                        if(double.parse(itemsprod[index]['value'].toString())>double.parse(itemsprod[index]['cur_bal'].toString())){
                                                                          showPrintedMessage(context, "Error", "Exceeding Stock Limit", Colors.white,Colors.red, Icons.info, true, "top");
                                                                          setState((){
                                                                            isreadonly = true;
                                                                          });
                                                                          setState((){
                                                                            itemsprod[index]['controller'].text = itemsprod[index]['cur_bal'].toString();
                                                                            itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                            setval_rate();
                                                                          });
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                },
                                                                child: Container(
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape.rectangle,
                                                                        color:scaffoldbackground,

                                                                        borderRadius: BorderRadius.only(
                                                                            topRight: Radius.circular(30.0),
                                                                            topLeft: Radius.circular(0.0),
                                                                            bottomLeft: Radius.circular(0.0),
                                                                            bottomRight: Radius.circular(30.0))),
                                                                    height: 30,
                                                                    width:10,
                                                                    child:Center(child: Icon(Icons.add, color:Colors.white))
                                                                ),
                                                              ),
                                                              labelStyle: TextStyle(fontSize: 13),
                                                              fillColor: Colors.white.withOpacity(0.5),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide(
                                                                  color: Colors.grey.withOpacity(0.3),
                                                                  width: 0.0,
                                                                ),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide(
                                                                  color: Colors.grey.withOpacity(0.3),
                                                                  width: 0.0,
                                                                ),
                                                              ),
                                                              //fillColor: Colors.green
                                                            ),
                                                            controller: itemsprod[index]['controller'],
                                                          )
                                                      ),
                                                      //  Icon(Icons.circle, size: 10,color: products[index]['is_active'].toString()=="1"?Colors.green:Colors.red,)
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 8),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Category :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                itemsprod[index]['cat_name']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 8),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Pr Type :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                itemsprod[index]['pr_type']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Rate :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),

                                                            Row(
                                                              children: [
                                                                Text(" " +
                                                                    '₹',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                      fontSize: 13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w400
                                                                  ),),
                                                                Text(" " +
                                                                    itemsprod[index]['pur_rate']
                                                                        .toString(),
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                      fontSize: 13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w400
                                                                  ),),
                                                                Text("/" +
                                                                    itemsprod[index]['uom1']
                                                                        .toString(),
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                      fontSize: 13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w400
                                                                  ),),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        TextButton(
                                                            onPressed:(){
                                                              setState((){
                                                                AddAmount(itemsprod[index]['iid'].toString(),context, itemsprod[index]['name'].toString(), index, itemsprod[index]['pur_rate'].toString(), "search list");
                                                              });
                                                            },
                                                            child:Text('Change Rate')
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Value :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                itemsprod[index]['value']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Stock :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                itemsprod[index]['cur_bal']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
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
                                        ),
                                      ),
                                      if(index == itemsprod.length - 1)
                                        Container(
                                          height: 80,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          color: Colors.white,
                                        ),
                                      if(index != itemsprod.length - 1)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50, right: 50),
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
                      ) : Center(
                        child: Text('No data found', style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.black
                        ),),
                      ),
                    ),
                  if(showloader==false&&itemsprod.isEmpty&&isbillfoundprod == false)
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height - 237,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: Text('No Item found', style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.black
                        ),),
                      ),
                    ),
                  if(showloader==false&&itemsprod.isNotEmpty&&isbillfoundprod == false)
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height - 237,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      color: Colors.white,
                      child: itemsprod.isNotEmpty ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: itemsprod.length,
                            itemBuilder: (BuildContext context, index) {
                              return GestureDetector(
                                onTap: () {
                                  FocusScopeNode currentFocus = FocusScope.of(
                                      context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }


                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      Card(
                                        elevation: 0,
                                        child: Container(
                                          child: Container(
                                            width:MediaQuery.of(context).size.width,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8, top: 8, bottom: 2),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width:MediaQuery.of(context).size.width-162,
                                                        child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Text(itemsprod[index]['name'].toString(), style: GoogleFonts.poppins(
                                                              fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500
                                                          ),),
                                                        ),
                                                      ),
                                                      Container(
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape.rectangle,
                                                              color:Colors.white,
                                                              border: Border.all(color: AppBarColor),
                                                              borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(30.0),
                                                                  topLeft: Radius.circular(30.0),
                                                                  bottomLeft: Radius.circular(30.0),
                                                                  bottomRight: Radius.circular(30.0))),
                                                          width:110,

                                                          child:TextFormField(
                                                            readOnly: itemsprod[index]['pr_type'].toString()=='Service'||itemsprod[index]['cur_bal'].toString()=='N/A'?false:isreadonly,
                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                            inputFormatters: <TextInputFormatter>[
                                                              FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                              MyNumberTextInputFormatter(digit: 4),
                                                            ],
                                                            autofocus: false,
                                                            maxLines: 1,
                                                            minLines: 1,
                                                            onTap:(){
                                                              if(isnegative_stock_allowed==false){
                                                                if(itemsprod[index]['cur_bal'].toString().contains('-')||double.parse(itemsprod[index]['cur_bal'].toString())==0){
                                                                  setState((){
                                                                    isreadonly = true;
                                                                  });
                                                                  showPrintedMessage(context, "Error", "Negative stock billing is not allowed", Colors.white,Colors.red, Icons.info, true, "top");
                                                                }if(double.parse(itemsprod[index]['cur_bal'].toString())>0){
                                                                  setState(() {
                                                                    isreadonly = false;
                                                                  });
                                                                }}else{
                                                                setState((){
                                                                  isreadonly = false;
                                                                });
                                                              }
                                                            },
                                                            onChanged: (v){
                                                              if(isnegative_stock_allowed==true){
                                                                if(v.isNotEmpty) {
                                                                  setState(() {
                                                                    itemsprod[index]['value'] = v.toString();
                                                                    setval_rate();
                                                                  });
                                                                }else{
                                                                  setState(() {
                                                                    itemsprod[index]['value'] = '0.0';
                                                                    setval_rate();
                                                                  });
                                                                }
                                                              }else{
                                                                if(v.isNotEmpty) {
                                                                  if(double.parse(v.toString())>double.parse(itemsprod[index]['cur_bal'].toString())){
                                                                    setState(() {
                                                                      showPrintedMessage(context, "Error", "Exceeding Stock Limit", Colors.white,Colors.red, Icons.info, true, "top");
                                                                      itemsprod[index]['controller'].text = itemsprod[index]['cur_bal'].toString();
                                                                      v = itemsprod[index]['cur_bal'].toString();
                                                                      itemsprod[index]['value'] = v.toString();
                                                                      setval_rate();
                                                                    });
                                                                  }else{
                                                                    setState(() {
                                                                      itemsprod[index]['value'] = v.toString();
                                                                      setval_rate();
                                                                    });
                                                                  }
                                                                }else{
                                                                  setState(() {
                                                                    itemsprod[index]['value'] = '0.0';
                                                                    setval_rate();
                                                                  });
                                                                }
                                                              }
                                                            },
                                                            decoration: new InputDecoration(
                                                              contentPadding:
                                                              EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                                              isDense: true,
                                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                                              labelText: "ADD",
                                                              prefixIconConstraints: BoxConstraints(
                                                                minWidth: 30,
                                                                minHeight: 25,
                                                              ),
                                                              suffixIconConstraints: BoxConstraints(
                                                                minWidth: 30,
                                                                minHeight: 25,
                                                              ),
                                                              prefixIcon:  GestureDetector(
                                                                onTap:(){
                                                                  setState((){
                                                                    isreadonly = true;
                                                                  });
                                                                  if(itemsprod[index]['controller'].text.isNotEmpty&&double.parse(itemsprod[index]['controller'].text.toString())>=1){
                                                                    setState((){
                                                                      itemsprod[index]['controller'].text = (double.parse(itemsprod[index]['controller'].text.toString())-1).toString();
                                                                      itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                      setval_rate();
                                                                    });
                                                                  }
                                                                  if(itemsprod[index]['controller'].text.isNotEmpty&&double.parse(itemsprod[index]['controller'].text.toString())<1){
                                                                    setState((){
                                                                      itemsprod[index]['controller'].text = '0.0';
                                                                      itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                      setval_rate();
                                                                    });
                                                                  }
                                                                },
                                                                child: Container(
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape.rectangle,
                                                                        color:scaffoldbackground,

                                                                        borderRadius: BorderRadius.only(
                                                                            topRight: Radius.circular(0.0),
                                                                            topLeft: Radius.circular(30.0),
                                                                            bottomLeft: Radius.circular(30.0),
                                                                            bottomRight: Radius.circular(0.0))),
                                                                    height: 30,
                                                                    width:10,
                                                                    child:Center(child: Icon(Icons.remove, color:Colors.white))
                                                                ),
                                                              ),
                                                              suffixIcon: GestureDetector(
                                                                onTap:(){
                                                                  if(isnegative_stock_allowed==true){
                                                                    setState((){
                                                                      isreadonly = true;
                                                                    });
                                                                    if(itemsprod[index]['controller'].text.isEmpty){
                                                                      setState((){
                                                                        itemsprod[index]['controller'].text = '1.0';
                                                                        itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                        setval_rate();
                                                                      });
                                                                    }else{
                                                                      setState((){
                                                                        itemsprod[index]['controller'].text = (double.parse(itemsprod[index]['controller'].text.toString())+1).toString();
                                                                        itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                        setval_rate();
                                                                      });
                                                                    }
                                                                  }else{
                                                                    if(itemsprod[index]['pr_type'].toString()=='Service'||itemsprod[index]['cur_bal'].toString()=='N/A'){
                                                                      setState((){
                                                                        isreadonly = true;
                                                                      });
                                                                      if(itemsprod[index]['controller'].text.isEmpty){
                                                                        setState((){
                                                                          itemsprod[index]['controller'].text = '1.0';
                                                                          itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                          setval_rate();
                                                                        });
                                                                      }else{
                                                                        setState((){
                                                                          itemsprod[index]['controller'].text = (double.parse(itemsprod[index]['controller'].text.toString())+1).toString();
                                                                          itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                          setval_rate();
                                                                        });
                                                                      }
                                                                    }else{
                                                                      if(itemsprod[index]['cur_bal'].toString().contains('-')||double.parse(itemsprod[index]['cur_bal'].toString())==0){
                                                                        showPrintedMessage(context, "Error", "Negative stock billing is not allowed", Colors.white,Colors.red, Icons.info, true, "top");
                                                                      }else{
                                                                        if(double.parse(itemsprod[index]['cur_bal'].toString())>0){
                                                                          setState((){
                                                                            isreadonly = true;
                                                                          });
                                                                          if(products[index]['controller'].text.isEmpty){
                                                                            setState((){
                                                                              itemsprod[index]['controller'].text = '1.0';
                                                                              itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                              setval_rate();
                                                                            });
                                                                          }else{
                                                                            setState((){
                                                                              itemsprod[index]['controller'].text = (double.parse(itemsprod[index]['controller'].text.toString())+1).toString();
                                                                              itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                              setval_rate();
                                                                            });
                                                                          }
                                                                        }
                                                                        if(double.parse(itemsprod[index]['value'].toString())>double.parse(itemsprod[index]['cur_bal'].toString())){
                                                                          showPrintedMessage(context, "Error", "Exceeding Stock Limit", Colors.white,Colors.red, Icons.info, true, "top");
                                                                          setState((){
                                                                            isreadonly = true;
                                                                          });
                                                                          setState((){
                                                                            itemsprod[index]['controller'].text = itemsprod[index]['cur_bal'].toString();
                                                                            itemsprod[index]['value']=itemsprod[index]['controller'].text;
                                                                            setval_rate();
                                                                          });
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                },
                                                                child: Container(
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape.rectangle,
                                                                        color:scaffoldbackground,

                                                                        borderRadius: BorderRadius.only(
                                                                            topRight: Radius.circular(30.0),
                                                                            topLeft: Radius.circular(0.0),
                                                                            bottomLeft: Radius.circular(0.0),
                                                                            bottomRight: Radius.circular(30.0))),
                                                                    height: 30,
                                                                    width:10,
                                                                    child:Center(child: Icon(Icons.add, color:Colors.white))
                                                                ),
                                                              ),
                                                              labelStyle: TextStyle(fontSize: 13),
                                                              fillColor: Colors.white.withOpacity(0.5),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide(
                                                                  color: Colors.grey.withOpacity(0.3),
                                                                  width: 0.0,
                                                                ),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide(
                                                                  color: Colors.grey.withOpacity(0.3),
                                                                  width: 0.0,
                                                                ),
                                                              ),
                                                              //fillColor: Colors.green
                                                            ),
                                                            controller: itemsprod[index]['controller'],
                                                          )
                                                      ),
                                                      //  Icon(Icons.circle, size: 10,color: products[index]['is_active'].toString()=="1"?Colors.green:Colors.red,)
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 8),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Category :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                itemsprod[index]['cat_name']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 8),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Pr Type :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                itemsprod[index]['pr_type']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Rate :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),

                                                            Row(
                                                              children: [
                                                                Text(" " +
                                                                    '₹',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                      fontSize: 13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w400
                                                                  ),),
                                                                Text(" " +
                                                                    itemsprod[index]['pur_rate']
                                                                        .toString(),
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                      fontSize: 13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w400
                                                                  ),),
                                                                Text("/" +
                                                                    itemsprod[index]['uom1']
                                                                        .toString(),
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                      fontSize: 13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w400
                                                                  ),),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        TextButton(
                                                            onPressed:(){
                                                              setState((){
                                                                AddAmount(itemsprod[index]['iid'].toString(),context, itemsprod[index]['name'].toString(), index, itemsprod[index]['pur_rate'].toString(), "search list");
                                                              });
                                                            },
                                                            child:Text('Change Rate')
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Value :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                itemsprod[index]['value']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 2,
                                                      right: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Stock :',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
                                                              ),),
                                                            Text(" " +
                                                                itemsprod[index]['cur_bal']
                                                                    .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .w400
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
                                        ),
                                      ),
                                      if(index == itemsprod.length - 1)
                                        Container(
                                          height: 80,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          color: Colors.white,
                                        ),
                                      if(index != itemsprod.length - 1)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50, right: 50),
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
                      ) : Center(
                        child: Text('No data found', style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.black
                        ),),
                      ),
                    ),

                ],
              ):
              ListView(
                  children:[
                    if(showcreateitemloader==false)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                        child: Row(
                          children: [
                            Text('Item Name', style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500
                            ),),
                            Text(' *', style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red
                            ),),
                          ],
                        ),
                      ),
                    if(showcreateitemloader==false)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                        child:  Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5.0),
                                  topLeft: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0),
                                  bottomRight: Radius.circular(5.0))),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: TextFormField(
                              onChanged: (v){

                              },
                              decoration: new InputDecoration(
                                prefixIcon: Icon(Icons.ballot_outlined, color: Colors.grey.withOpacity(0.9),size: 25,),
                                isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                labelText: "Item Name",
                                fillColor: Colors.white.withOpacity(0.5),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1.0,
                                  ),
                                ),
                                //fillColor: Colors.green
                              ),
                              controller: add_item_name_Controller,
                            ),
                          ),
                        ),
                      ),
                    if(showcreateitemloader==false)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                        child: Row(
                          children: [
                            Text('Item Type', style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500
                            ),),
                            Text(' *', style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500,
                                color:Colors.red
                            ),),
                          ],
                        ),
                      ),
                    if(showcreateitemloader==false)
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 40,
                                width: 100,
                                child: RaisedButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(00)),
                                  elevation: 0,
                                  color: Colors.white,
                                  onPressed: (){
                                    setState(() {
                                      isproduct=true;
                                      item_type = 'Stockable';
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 10,
                                        left: 0,
                                        right: 0,
                                        child: Text('Stockable', style:TextStyle(fontSize:15, color:Colors.black)),
                                      ),

                                      if(item_type == 'Stockable')
                                        Positioned(
                                          top: 00,
                                          left: 50,
                                          right: 0,
                                          child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width:5),
                              Container(
                                height: 40,
                                width: 100,
                                child: RaisedButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(00)),
                                  elevation: 0,
                                  color: Colors.white,
                                  onPressed: (){
                                    setState(() {

                                      item_type = 'Service';
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 10,
                                        left: 0,
                                        right: 0,
                                        child: Text('Service', style:TextStyle(fontSize:15, color:Colors.black)),
                                      ),

                                      if(item_type == 'Service')
                                        Positioned(
                                          top: 00,
                                          left: 50,
                                          right: 0,
                                          child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width:5),
                              Container(
                                height: 40,
                                width: 130,
                                child: RaisedButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(00)),
                                  elevation: 0,
                                  color: Colors.white,
                                  onPressed: (){
                                    setState(() {
                                      item_type = 'Non Stockable';
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 10,
                                        left: 0,
                                        right: 0,
                                        child: Text('Non Stockable', style:TextStyle(fontSize:15, color:Colors.black)),
                                      ),

                                      if(item_type == 'Non Stockable')
                                        Positioned(
                                          top: 00,
                                          left: 75,
                                          right: 0,
                                          child: Icon(Icons.check_circle, color:Colors.green, size:15),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if(showcreateitemloader==false)
                      Padding(
                        padding: const EdgeInsets.only(left:50, right: 50),
                        child: Container(
                            height: 70,
                            width:MediaQuery.of(context).size.width,
                            child: Row(
                                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                children:[
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: 3.0, color: selectedrow=='pricing'?Colors.lightBlue.shade900:Colors.white),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: RaisedButton(

                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(00)),
                                      elevation: 0,
                                      color: Colors.white,
                                      onPressed: (){
                                        setState(() {
                                          selectedrow='pricing';
                                          bottomTapped(0);
                                        });
                                      },
                                      child: Text('Pricing', style:TextStyle(fontSize:13, color:Colors.black)),
                                    ),
                                  ),
                                  SizedBox(width:5),
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: 3.0, color: selectedrow=='stock'?Colors.lightBlue.shade900:Colors.white),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: RaisedButton(

                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(00)),
                                      elevation: 0,
                                      color: Colors.white,
                                      onPressed: (){
                                        setState(() {
                                          selectedrow='stock';
                                          bottomTapped(1);
                                        });
                                      },
                                      child: Text('Stock', style:TextStyle(fontSize:13, color:Colors.black)),
                                    ),
                                  ),
                                  SizedBox(width:5),
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: 3.0, color: selectedrow=='other'?Colors.lightBlue.shade900:Colors.white),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: RaisedButton(

                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(00)),
                                      elevation: 0,
                                      color: Colors.white,
                                      onPressed: (){
                                        setState(() {
                                          selectedrow='other';
                                          bottomTapped(2);
                                        });
                                      },
                                      child: Text('Category *', style:TextStyle(fontSize:13, color:Colors.black)),
                                    ),
                                  ),

                                ]
                            )

                        ),
                      ),
                    if(showcreateitemloader==false)
                      Container(
                          height: 300,
                          width:MediaQuery.of(context).size.width,
                          child:PageView.builder(
                              onPageChanged: (v){
                                setState((){
                                  if(v==0){
                                    selectedrow='pricing';
                                  }
                                  if(v==1){
                                    selectedrow='stock';
                                  }
                                  if(v==2){
                                    selectedrow='other';
                                  }
                                });
                              },
                              itemCount:3,
                              scrollDirection: Axis.horizontal,
                              controller: pageController,
                              itemBuilder: (BuildContext context, index){
                                return Column(
                                    children:[
                                      if(index==0)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                          child: Row(
                                            children: [
                                              Text('Sales Price', style: GoogleFonts.poppins(
                                                  fontSize: 15, fontWeight: FontWeight.w500
                                              ),),
                                            ],
                                          ),
                                        ),
                                      if(index==0)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                          child:  Container(
                                            height: 50,
                                            width:MediaQuery.of(context).size.width-10,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(5.0),
                                                    topLeft: Radius.circular(5.0),
                                                    bottomLeft: Radius.circular(5.0),
                                                    bottomRight: Radius.circular(5.0))),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                              child: TextFormField(
                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                  MyNumberTextInputFormatter(digit: 4),
                                                ],
                                                onChanged: (v){

                                                },
                                                decoration: new InputDecoration(

                                                  prefixIconConstraints: BoxConstraints(
                                                    minWidth: 15,
                                                    minHeight: 48,
                                                  ),
                                                  suffixIconConstraints: BoxConstraints(
                                                    minWidth: 70,
                                                    minHeight: 48,
                                                  ),
                                                  prefixIcon: TextButton(onPressed:null,
                                                      child:Text('₹', style:TextStyle(fontSize:30))),
                                                  suffixIcon: Container(
                                                    height: 48,
                                                    width: 160,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey.withOpacity(0.3),
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.only(
                                                            topRight: Radius.circular(5.0),
                                                            topLeft: Radius.circular(0.0),
                                                            bottomLeft: Radius.circular(0.0),
                                                            bottomRight: Radius.circular(5.0))),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left:10),
                                                      child: DropdownButtonHideUnderline(
                                                        child: ButtonTheme(
                                                          child: DropdownButton<String>(
                                                            dropdownColor: Colors.white,
                                                            elevation: 0,
                                                            focusColor:Colors.transparent,
                                                            value: uom1,
                                                            //elevation: 5,
                                                            style: TextStyle(color: AppBarColor),
                                                            iconEnabledColor:AppBarColor,
                                                            items: uoms?.map((item) {
                                                              return new DropdownMenuItem(
                                                                child: new Text(item['name'],style: TextStyle(fontSize: 15, color: AppBarColor),),
                                                                value: item['code'].toString(),
                                                              );
                                                            })?.toList() ??
                                                                [],
                                                            hint:Padding(
                                                              padding: const EdgeInsets.only(left: 5),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    "Unit",
                                                                    style: GoogleFonts.poppins(
                                                                        color: AppBarColor,
                                                                        fontSize: 15,
                                                                        fontWeight: FontWeight.w400),
                                                                  ),
                                                                  Text(
                                                                    " *",
                                                                    style: GoogleFonts.poppins(
                                                                        color: Colors.red,
                                                                        fontSize: 15,
                                                                        fontWeight: FontWeight.w400),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            onChanged: (String? value) {
                                                              FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                                              FocusScopeNode currentFocus = FocusScope.of(context);

                                                              if (!currentFocus.hasPrimaryFocus) {
                                                                currentFocus.unfocus();
                                                              }
                                                              setState(() {
                                                                uom1 = value.toString();
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                  labelText: "",
                                                  fillColor: Colors.white.withOpacity(0.5),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey.withOpacity(0.3),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey.withOpacity(0.3),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  //fillColor: Colors.green
                                                ),
                                                controller: sale_price_Controller,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if(index==0)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                          child: Row(
                                            children: [
                                              Text('Purchase Price', style: GoogleFonts.poppins(
                                                  fontSize: 15, fontWeight: FontWeight.w500
                                              ),),
                                            ],
                                          ),
                                        ),
                                      if(index==0)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
                                          child:  Container(
                                            height: 50,
                                            width:MediaQuery.of(context).size.width-10,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(5.0),
                                                    topLeft: Radius.circular(5.0),
                                                    bottomLeft: Radius.circular(5.0),
                                                    bottomRight: Radius.circular(5.0))),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                              child: TextFormField(
                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                  MyNumberTextInputFormatter(digit: 4),
                                                ],
                                                onChanged: (v){

                                                },
                                                decoration: new InputDecoration(

                                                  prefixIconConstraints: BoxConstraints(
                                                    minWidth: 15,
                                                    minHeight: 48,
                                                  ),
                                                  suffixIconConstraints: BoxConstraints(
                                                    minWidth: 70,
                                                    minHeight: 48,
                                                  ),
                                                  prefixIcon: TextButton(onPressed:null,
                                                      child:Text('₹', style:TextStyle(fontSize:30))),
                                                  suffixIcon: uom1!=null?TextButton(onPressed:null, child:Text('/'+uom1.toString(), style:TextStyle(fontSize:20))):TextButton(onPressed:null, child:Text('')),
                                                  isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                  labelText: "",
                                                  fillColor: Colors.white.withOpacity(0.5),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey.withOpacity(0.3),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey.withOpacity(0.3),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  //fillColor: Colors.green
                                                ),
                                                controller: purchase_price_Controller,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if(index==0)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10, right:10),
                                          child: Row(
                                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width/2.2,
                                                child: Text('HSN', style: GoogleFonts.poppins(
                                                    fontSize: 15, fontWeight: FontWeight.w500
                                                ),),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width/2.2,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 0,),
                                                  child: Row(
                                                    children: [
                                                      Text('GST', style: GoogleFonts.poppins(
                                                          fontSize: 15, fontWeight: FontWeight.w500
                                                      ),),
                                                      Text(' *', style: GoogleFonts.poppins(
                                                          fontSize: 15, fontWeight: FontWeight.w500,
                                                          color:Colors.red
                                                      ),),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if(index==0)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 0, bottom: 2, top: 10, right:20),
                                          child: Row(
                                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width/2.2,
                                                child:Container(
                                                  height: 50,
                                                  width:MediaQuery.of(context).size.width/2.2,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.only(
                                                          topRight: Radius.circular(5.0),
                                                          topLeft: Radius.circular(5.0),
                                                          bottomLeft: Radius.circular(5.0),
                                                          bottomRight: Radius.circular(5.0))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                    child: TextFormField(
                                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                      inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter(RegExp("[0-9]"), allow: true),
                                                      ],
                                                      onChanged: (v){

                                                      },
                                                      decoration: new InputDecoration(
                                                        isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                        labelText: "",
                                                        fillColor: Colors.white.withOpacity(0.5),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey.withOpacity(0.3),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey.withOpacity(0.3),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        //fillColor: Colors.green
                                                      ),
                                                      controller: create_item_hsn_Controller,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width/2.2,
                                                child:Container(
                                                  height: 50,
                                                  width:MediaQuery.of(context).size.width/2.2,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.only(
                                                          topRight: Radius.circular(5.0),
                                                          topLeft: Radius.circular(5.0),
                                                          bottomLeft: Radius.circular(5.0),
                                                          bottomRight: Radius.circular(5.0)),
                                                      border: Border.all(color: Colors.grey.withOpacity(0.3))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                    child: Padding(
                                                      padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                      child: DropdownButtonHideUnderline(
                                                        child: ButtonTheme(
                                                          child: DropdownButton<String>(
                                                            dropdownColor: Colors.white,
                                                            elevation: 0,
                                                            focusColor:Colors.transparent,
                                                            value: newitemgstper,
                                                            //elevation: 5,
                                                            style: TextStyle(color: AppBarColor),
                                                            iconEnabledColor:AppBarColor,
                                                            items: gstperlist1?.map((item) {
                                                              return new DropdownMenuItem(
                                                                child: new Text(item['gst']+" "+ "%",style: TextStyle(fontSize: 18, color: AppBarColor),),
                                                                value: item['gst'].toString(),
                                                              );
                                                            })?.toList() ??
                                                                [],

                                                            hint:Padding(
                                                              padding: const EdgeInsets.only(left: 5),
                                                              child: Text(
                                                                "GST %",
                                                                style: GoogleFonts.poppins(
                                                                    color: AppBarColor,
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.w400),
                                                              ),
                                                            ),
                                                            onChanged: (String? value){
                                                              FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                                              FocusScopeNode currentFocus = FocusScope.of(context);

                                                              if (!currentFocus.hasPrimaryFocus) {
                                                                currentFocus.unfocus();
                                                              }
                                                              setState(() {
                                                                newitemgstper = value.toString();
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if(index==1)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10, right:10),
                                          child: Row(
                                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width/2.2,
                                                child: Text('Opening Stock', style: GoogleFonts.poppins(
                                                    fontSize: 15, fontWeight: FontWeight.w500
                                                ),),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width/2.2,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 0,),
                                                  child: Text('Opening Amount', style: GoogleFonts.poppins(
                                                      fontSize: 15, fontWeight: FontWeight.w500
                                                  ),),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if(index==1)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 0, bottom: 2, top: 10, right:20),
                                          child: Row(
                                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width/2.2,
                                                child:Container(
                                                  height: 50,
                                                  width:MediaQuery.of(context).size.width/2.2,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.only(
                                                          topRight: Radius.circular(5.0),
                                                          topLeft: Radius.circular(5.0),
                                                          bottomLeft: Radius.circular(5.0),
                                                          bottomRight: Radius.circular(5.0))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                    child: TextFormField(
                                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                      inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                        MyNumberTextInputFormatter(digit: 2),
                                                      ],
                                                      onChanged: (v){

                                                      },
                                                      decoration: new InputDecoration(
                                                        isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                        labelText: "",
                                                        fillColor: Colors.white.withOpacity(0.5),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey.withOpacity(0.3),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey.withOpacity(0.3),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        //fillColor: Colors.green
                                                      ),
                                                      controller: create_item_open_stock_Controller,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width/2.2,
                                                child:Container(
                                                  height: 50,
                                                  width:MediaQuery.of(context).size.width/2.2,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.only(
                                                          topRight: Radius.circular(5.0),
                                                          topLeft: Radius.circular(5.0),
                                                          bottomLeft: Radius.circular(5.0),
                                                          bottomRight: Radius.circular(5.0))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                    child: TextFormField(
                                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                      inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                                                        MyNumberTextInputFormatter(digit: 2),
                                                      ],
                                                      onChanged: (v){

                                                      },
                                                      decoration: new InputDecoration(
                                                        isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                        labelText: "",
                                                        fillColor: Colors.white.withOpacity(0.5),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey.withOpacity(0.3),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey.withOpacity(0.3),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        //fillColor: Colors.green
                                                      ),
                                                      controller: create_item_open_amount_Controller,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if(index==1)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                          child: Row(
                                            children: [
                                              Text('Item Code', style: GoogleFonts.poppins(
                                                  fontSize: 15, fontWeight: FontWeight.w500
                                              ),),
                                            ],
                                          ),
                                        ),
                                      if(index==1)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 0, bottom: 2, top: 10, right:0),
                                          child: Row(
                                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                child:Container(
                                                  height: 50,
                                                  width:MediaQuery.of(context).size.width-10,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.only(
                                                          topRight: Radius.circular(5.0),
                                                          topLeft: Radius.circular(5.0),
                                                          bottomLeft: Radius.circular(5.0),
                                                          bottomRight: Radius.circular(5.0))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                                                    child: TextFormField(

                                                      onChanged: (v){

                                                      },
                                                      decoration: new InputDecoration(
                                                        isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                        labelText: "",
                                                        fillColor: Colors.white.withOpacity(0.5),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey.withOpacity(0.3),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey.withOpacity(0.3),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        //fillColor: Colors.green
                                                      ),
                                                      controller: create_item_code_Controller,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if(index==2)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                          child: Row(
                                            children: [
                                              Text('Category', style: GoogleFonts.poppins(
                                                  fontSize: 15, fontWeight: FontWeight.w500
                                              ),),
                                              Text('*', style: GoogleFonts.poppins(
                                                fontSize: 15, fontWeight: FontWeight.w500,
                                                color: Colors.red,
                                              ),),
                                            ],
                                          ),
                                        ),
                                      if(index==2)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10, right:20),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            child:Container(
                                              height: 50,
                                              width:MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(5.0),
                                                      topLeft: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0)),
                                                  border: Border.all(color: Colors.grey.withOpacity(0.3))),
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(00, 0, 00, 0),
                                                  child: DropdownButtonHideUnderline(
                                                    child: ButtonTheme(
                                                      child: DropdownButton<String>(
                                                        dropdownColor: Colors.white,
                                                        elevation: 0,
                                                        focusColor:Colors.transparent,
                                                        value: catname,
                                                        //elevation: 5,
                                                        style: TextStyle(color: AppBarColor),
                                                        iconEnabledColor:AppBarColor,
                                                        items: Catlist?.map((item) {
                                                          return new DropdownMenuItem(
                                                            child: new Text(item['name'],style: TextStyle(fontSize: 18, color: AppBarColor),),
                                                            value: item['cat_id'].toString(),
                                                          );
                                                        })?.toList() ??
                                                            [],
                                                        hint:Padding(
                                                          padding: const EdgeInsets.only(left: 5),
                                                          child: Text(
                                                            "Select Category",
                                                            style: GoogleFonts.poppins(
                                                                color: AppBarColor,
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.w400),
                                                          ),
                                                        ),
                                                        onChanged: (String? value){
                                                          FocusScope.of(context).requestFocus(new FocusNode()); //remove focus

                                                          FocusScopeNode currentFocus = FocusScope.of(context);

                                                          if (!currentFocus.hasPrimaryFocus) {
                                                            currentFocus.unfocus();
                                                          }
                                                          setState(() {
                                                            catname = value.toString();
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if(index==2)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                          child: Row(
                                            children: [
                                              Text('Add Remark', style: GoogleFonts.poppins(
                                                  fontSize: 15, fontWeight: FontWeight.w500
                                              ),),
                                            ],
                                          ),
                                        ),
                                      if(index==2)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10, right:20),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            child:Container(
                                              width: MediaQuery.of(context).size.width,
                                              child:Container(
                                                height: 80,
                                                width:MediaQuery.of(context).size.width,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(5.0),
                                                        topLeft: Radius.circular(5.0),
                                                        bottomLeft: Radius.circular(5.0),
                                                        bottomRight: Radius.circular(5.0))),
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  child: TextFormField(

                                                    onChanged: (v){

                                                    },
                                                    decoration: new InputDecoration(
                                                      isDense: true,floatingLabelBehavior: FloatingLabelBehavior.never,
                                                      labelText: "",
                                                      fillColor: Colors.white.withOpacity(0.5),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: BorderSide(
                                                          color: Colors.grey.withOpacity(0.3),
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: BorderSide(
                                                          color: Colors.grey.withOpacity(0.3),
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                      //fillColor: Colors.green
                                                    ),
                                                    controller: remarks_Controller,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ]
                                );
                              })
                      ),
                    if(showcreateitemloader==true)
                      Container(
                        child:Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 0.7,

                          ),
                        ),
                      ),

                  ]
              ),
            ),
            bottomNavigationBar:show_create_item_screen==false?Container(
                width:MediaQuery.of(context).size.width,
                height:70,
                color:Colors.lightBlueAccent.withOpacity(0.3),
                child:Row(
                    mainAxisAlignment:MainAxisAlignment.end,
                    children:[
                      Container(
                          width:MediaQuery.of(context).size.width-100,
                          height:70,
                          child:Row(
                            children:[
                              SizedBox(width:10),
                              Icon(Icons.arrow_circle_up, size:30),
                              SizedBox(width:10),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:MainAxisAlignment.center,
                                  children:[
                                    Row(
                                      children: [
                                        Text(totalitems, style:TextStyle(fontSize:20, color:AppBarColor, fontWeight:FontWeight.bold)),
                                        SizedBox(width:5),
                                        if(double.parse(totalitems.toString())<=0.0)
                                          Text('Item',style:TextStyle(fontSize:20, color:AppBarColor, fontWeight:FontWeight.bold)),
                                        if(double.parse(totalitems.toString())>0.0)
                                          Text('Items',style:TextStyle(fontSize:20, color:AppBarColor, fontWeight:FontWeight.bold)),
                                      ],
                                    ),
                                    SizedBox(height:5),
                                    Row(
                                      children: [
                                        Text('₹',style:TextStyle(fontSize:20, color:AppBarColor, fontWeight:FontWeight.bold)),
                                        SizedBox(width:5),
                                        Text(totalvalue,style:TextStyle(fontSize:20, color:AppBarColor, fontWeight:FontWeight.bold)),
                                      ],
                                    )
                                  ]
                              ),
                            ],
                          )
                      ),
                      Container(
                          width:100,
                          height:70,
                          child:RaisedButton(
                              elevation:0,
                              color: AppBarColor,
                              onPressed:double.parse(totalitems.toString())<=0.0?null:(){
                                saveselectedlist();
                              },
                              child:Text('Next', style: TextStyle(
                                  fontSize:15, color:double.parse(totalitems.toString())<=0.0?Colors.black:Colors.white
                              ),)
                          )
                      )
                    ]
                )
            ):Container(
                width:MediaQuery.of(context).size.width,
                height:70,
                color:Colors.white,
                child:Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: showcreateitemloader==false?Container(

                      color:Colors.indigo,
                      child: RaisedButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onPressed:(){
                            if(add_item_name_Controller.text.isNotEmpty&&catname != null&&uom1 != null&&newitemgstper!=null){
                              addItem();
                            }else{
                              showPrintedMessage(context, "Error", "Please Fill All Required Fields", Colors.white,Colors.red, Icons.info, true, "top");
                            }
                          },
                          elevation:0,
                          color:Colors.transparent,
                          child: Text('Save', style:TextStyle(fontSize:15, color:Colors.white))
                      )
                  ):Container(),
                )
            )
        )
    ):
    Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child:Center(
              child:CircularProgressIndicator(
                strokeWidth: 0.7,

              ),
            )
        )
    );
  }
}


class MyNumberTextInputFormatter extends TextInputFormatter {
  static const defaultDouble = 0.001;

  /// Allowed decimal digits, -1 represents no limit
  int digit;
  MyNumberTextInputFormatter({this.digit = -1});
  static double strToFloat(String str, [double defaultValue = defaultDouble]) {
    try {
      return double.parse(str);
    } catch (e) {
      return defaultValue;
    }
  }

  /// Get the current count number
  static int getValueDigit(String value) {
    if (value.contains(".")) {
      return value.split(".")[1].length;
    } else {
      return -1;
    }
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    int selectionIndex = newValue.selection.end;
    if (value == ".") {
      value = "0.";
      selectionIndex++;
    } else if (value == "-") {
      value = "-";
      selectionIndex++;
    } else if (value != "" && value != defaultDouble.toString() && strToFloat(value, defaultDouble) == defaultDouble || getValueDigit(value) > digit) {
      value = oldValue.text;
      selectionIndex = oldValue.selection.end;
    }
    return new TextEditingValue(
      text: value,
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}


