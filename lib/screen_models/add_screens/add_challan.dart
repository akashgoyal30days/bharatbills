import 'package:bbills/api_models/api_common.dart';
import 'package:bbills/app_constants/ui_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../shared preference singleton.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bbills_functional_const.dart';
import '../../main.dart';
import '../../toast_messeger.dart';
import 'package:dio/dio.dart';
import 'package:bbills/app_constants/api_constants.dart';

import '../delivery_challan.dart';

class AddDelivChallan extends StatefulWidget {
  @override
  _AddDelivChallanState createState() => _AddDelivChallanState();
}

class _AddDelivChallanState extends State<AddDelivChallan> {

  //-------for user type-----//
  bool isregistered =  true;

  //-------gst none or gst------//
  String gst_type = 'gst-non';

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

  String selected_cloud_contact_id = '';
  String selected_cloud_provide_discount = '0';
  bool showbill_loader = false;
  String? selected_ware1;
  String? selected_ware2;
  String selected_ware1id = '';
  String selected_ware2id = '';
  List<String> warelist1 = [];
  List<String> warelist2 = [];
  List<String> warelistid1 = [];
  List<String> warelistid2 = [];
  void getWarehouse () async{
    setState(() {
      warelist1.clear();
      warelist2.clear();
      warelistid1.clear();
      warelistid2.clear();
      selected_ware1 = null;
      selected_ware2 = null;
    });
    try{
      var rsp = await apiurl("/member/process", "warehouse.php", {
        "type": "view_all",
      });
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState(() {
            for(var i = 0; i<rsp['data'].length; i++){
              warelist1.add(rsp['data'][i]['name'].toString());
              warelist2.add(rsp['data'][i]['name'].toString());
              warelistid1.add(rsp['data'][i]['wid'].toString());
              warelistid2.add(rsp['data'][i]['wid'].toString());
            }
            if(warelist1.isNotEmpty){
              selected_ware1 = warelist1[0].toString();
              selected_ware1id = warelistid1[0].toString();
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
        "challan_to": selected_cloud_contact_id,
        "state": "",
        "phone":"",
        "address":"",
        "gst":"",
        "stores":selected_ware2id,
        "series": seriesid,
        if(seriesid=="manual")
          "challan_no": billno,
        "challan_date": formateddate,
        "product": totalselected_id,
        "uom1": totalselected_val,
        "value": total_elementwise_exclu_rate,
        "description": description,
        "gst_value": totalselected_tax,
        "remarks": total_remarks_Controller.text.toString(),
        "nature_required": "",
        "exp_duration": duration_Controller.text.toString(),
        "vehicle":vno_Controller.text.toString(),
        "transporter":total_transporter_Controller.text.toString(),
        "gr":gr_Controller.text.toString(),
        "form_no":contact_Controller.text.toString(),
        "eway": eway_Controller.text.toString(),
      });

      var rsp = await gbill("/member/process", "delivery_challan.php", formData);
      //debugPrint(rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showbill_loader=false;
        });
        if(rsp['status'].toString()=="true"){
          showPrintedMessage(context, "Success", "Challan Generated Successfully", Colors.white,Colors.green, Icons.info, true, "top");
          Navigator.of(context)
              .popUntil((route) =>
          route.isFirst);
          Navigator
              .pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType
                      .fade,
                  child: DeliveryChalanScreen()));
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
    }catch(error){
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
      var rsp = await apiurl("/member/process", "customer.php", {
        "type":"add",
        if(state!=null)
          "state": state.toString()
        else
          "state": "",
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
        'name': add_item_name_Controller.text.toString(),
        "item_desc": remarks_Controller.text.toString(),
        if(uom1!=null)
          "uom1": uom1.toString()
        else
          "uom1":"",
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
            products.clear();
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
            discount_percent_Controller.text = '0.0';

          }
          );

        }else if(rsp['status'].toString()=="false"){  setState(() {
          showcreateitemloader=false;
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
  dynamic producuts_rate_Controller = TextEditingController();
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
      var rsp = await apiurl("/member/process", "customer.php", {
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
  dynamic total_transporter_Controller = TextEditingController();
  dynamic total_transporterdate_Controller = TextEditingController();
  dynamic contact_Controller = TextEditingController();
  dynamic gr_Controller = TextEditingController();
  dynamic vno_Controller = TextEditingController();
  dynamic eway_Controller = TextEditingController();
  dynamic duration_Controller = TextEditingController();
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
    getbillnum();
    getseries();
    getWarehouse();
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
  void getbillnum () async{
    try{
      var rsp = await apiurl("/member/process", "bill_nums.php", {
        "type": "challan",
      });
      //debugPrint('myseries num- '+rsp.toString());
      if(rsp.containsKey('status')){
        setState(() {
          showloader=false;
        });
        if(rsp['status'].toString()=="true"){
          setState((){
            billno = rsp['no'].toString();
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

  List series = [];
  String? seriesid;
  void getseries () async{
    setState(() {
      series.clear();
      seriesid = "auto";
      series.add({"id": "auto", "sname": "Auto Series", "name": "aseries", "last_count": "0", "status": "0"});
      series.add({"id": "manual", "sname": "Manual", "name": "manual", "last_count": "0", "status": "0"});
    });
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
                  selectednumber.add(contact.phones.first.number.toString());
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
          rateval.add(double.parse(products[i]['rate'].toString())*double.parse(products[i]['value'].toString()));
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
          total_base_rate.add(products[i]['rate'].toString());
          intrim_prod_base_rate.add(products[i]['rate'].toString());
          prod_rate_with_discount.add(products[i]['rate'].toString());
          // intrim_prod_base_rate.add((double.parse(products[i]['rate'].toString())*double.parse(products[i]['value'].toString())).toStringAsFixed(2));
          //   prod_rate_with_discount.add((double.parse(products[i]['rate'].toString())*double.parse(products[i]['value'].toString())).toStringAsFixed(2));
          if(gst_type!='gst-non') {
            totalselected_tax.add(products[i]['gst'].toString());
          }else{
            totalselected_tax.add('0.0');
          }
          if(gst_type!='inclu') {
            totalselected_rate.add(products[i]['rate'].toString());
          }else{
            totalselected_rate.add((double.parse(products[i]['rate'].toString())/(1+(double.parse(products[i]['gst'].toString())/100))).toStringAsFixed(2));
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
      partyname+=735;
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
            products[index]['rate'] = producuts_rate_Controller.text.toString();
            products[index]['controller'].text = '0.0';
            products[index]['value']='0.0';

          });
        }else{
          setState(() {
            itemsprod[index]['rate'] = producuts_rate_Controller.text.toString();
            itemsprod[index]['controller'].text = '0.0';
            itemsprod[index]['value']='0.0';
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
                rsp['data'][i]['rate'] = '0';
                rsp['data'][i].addAll({'value':'0.0', 'controller':TextEditingController()});
              });
            }
            //debugPrint(rsp['data'].toString());
            for(var i=0; i<rsp['data'].length; i++) {
              if (rsp['data'][i]['pr_type'].toString() == "Stockable") {
                if (rsp['data'][i]['is_active'].toString() == "1") {
                  products.add(rsp['data'][i]);
                }
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
                  child: DeliveryChalanScreen()));
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
              title:Text('Add Delivery Challan', style: GoogleFonts.poppins(fontSize: 16),),
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
                      if(seriesid.toString()=="manual"){
                        if(billno!=''){
                          if(selected_cloud_contact_id.toString()!=''&&selected_ware2id!='') {
                            generate_Bill();
                          }else{
                            showPrintedMessage(context, "Alert", "Please fill all requred fields", Colors.white,Colors.redAccent, Icons.info, true, "top");
                          }
                        }else{
                          showPrintedMessage(context, "Error", "Please enter bill number", Colors.white, Colors.redAccent, Icons.info, true, "top");
                        }
                      }else{
                        if(selected_cloud_contact_id.toString()!=''&&selected_ware2id!='') {
                          generate_Bill();
                        }else{
                          showPrintedMessage(context, "Alert", "Please fill all requred fields", Colors.white,Colors.redAccent, Icons.info, true, "top");
                        }
                      }

                    },
                    child:Text('Generate Challan', style:TextStyle(
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
                            duration: Duration(seconds: 1),
                            color: Colors.white,
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
                                                      Text('Challan No.  ', style: GoogleFonts.poppins(fontSize: 15, color: Colors.blueAccent),),
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
                                                                                    setState((){
                                                                                      seriesid = "auto";
                                                                                      getbillnum();
                                                                                    });
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
                                                                  if(seriesid=="manual")
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                      child: Row(
                                                                        children: [
                                                                          Text('Invoice Number *', style: GoogleFonts.poppins(
                                                                              fontSize: 15, fontWeight: FontWeight.w500
                                                                          ),),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  if(seriesid=="manual")
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
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                                    child: Row(
                                                                      children: [
                                                                        Text('Series', style: GoogleFonts.poppins(
                                                                            fontSize: 15, fontWeight: FontWeight.w500
                                                                        ),),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                                                                    child:  Container(
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
                                                                                  value: seriesid,
                                                                                  //elevation: 5,
                                                                                  style: TextStyle(color: AppBarColor),
                                                                                  iconEnabledColor:AppBarColor,
                                                                                  items: series.map((item) {
                                                                                    return new DropdownMenuItem(
                                                                                      child: new Text(item['sname'].toString(),style: TextStyle(fontSize: 18, color: AppBarColor),),
                                                                                      value: item['id'].toString(),
                                                                                    );
                                                                                  }).toList() ??
                                                                                      [],

                                                                                  hint:Padding(
                                                                                    padding: const EdgeInsets.only(left: 5),
                                                                                    child: Text(
                                                                                      "Auto Series",
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
                                                                                      seriesid = value.toString();
                                                                                      if(seriesid!='manual'){
                                                                                        getbillnum();
                                                                                      }else{
                                                                                        billno = '';
                                                                                        start_serial_Controller.clear();
                                                                                      }
                                                                                      _invoicebottosheetincrement();                                                                        });
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
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
                                                                            if(seriesid.toString()=="manual"){
                                                                              if(start_serial_Controller.text.isNotEmpty){
                                                                                Navigator.pop(context);
                                                                                billno = start_serial_Controller.text.toString();
                                                                              }else{
                                                                                showPrintedMessage(context, "Error", "Please enter bill number", Colors.white, Colors.redAccent, Icons.info, true, "top");
                                                                              }
                                                                            }else{
                                                                              Navigator.pop(context);
                                                                            }
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2, bottom: 8),
                                    child: Container(
                                      height: 50,
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
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 2, right: 10),
                                            child: Container(
                                              height: 40,
                                              width:MediaQuery.of(context).size.width-12,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(color: Colors.transparent,)
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    hint : Text('Select Store *'),
                                                    value: selected_ware2,
                                                    isDense: true,
                                                    items:warelist2.map((String value) {
                                                      return DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (s){
                                                      int index = warelist2.indexOf(s.toString());
                                                      setState(() {
                                                        selected_ware2 = s.toString();
                                                        selected_ware2id = warelistid2[index].toString();
                                                        //debugPrint(selected_ware2id.toString());
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
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
                                                                    if(totalselected_id.isEmpty) {
                                                                      partyname = 265;
                                                                    }else{
                                                                      partyname = 990;
                                                                    }
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
                                                                                      // if(selectednumber.isNotEmpty)
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
                                  padding: const EdgeInsets.only(left: 10, bottom: 2, top: 8, right: 10),
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


                                    ],
                                  ),
                                ),
                                if(isregistered==true)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, bottom: 2, top: 8, right: 10),
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
                                if(index==totalselected_id.length-1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50, right: 50),
                                    child: Divider(
                                      color: AppBarColor,
                                      thickness: 0.2,
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
                                            labelText: "Transporter",
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
                                          controller: total_transporter_Controller,
                                        ),
                                      ),
                                    ),
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
                                            labelText: "PO / Work Number",
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
                                          controller: contact_Controller,
                                        ),
                                      ),
                                    ),
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
                                            labelText: "GR Number",
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
                                          controller: gr_Controller,
                                        ),
                                      ),
                                    ),
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
                                            labelText: "Vehicle Number",
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
                                          controller: vno_Controller,
                                        ),
                                      ),
                                    ),
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
                                            labelText: "E-Way Bill",
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
                                          controller: eway_Controller,
                                        ),
                                      ),
                                    ),
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
                                            labelText: "Expected Duration Of Process",
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
                                          controller: duration_Controller,
                                        ),
                                      ),
                                    ),
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

                )
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
                                        Text('Challan No.  ', style: GoogleFonts.poppins(fontSize: 15, color: Colors.blueAccent),),
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
                                                                      setState((){
                                                                        seriesid = "auto";
                                                                        getbillnum();
                                                                      });
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
                                                    if(seriesid=="manual")
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                        child: Row(
                                                          children: [
                                                            Text('Invoice Number *', style: GoogleFonts.poppins(
                                                                fontSize: 15, fontWeight: FontWeight.w500
                                                            ),),
                                                          ],
                                                        ),
                                                      ),
                                                    if(seriesid=="manual")
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
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10),
                                                      child: Row(
                                                        children: [
                                                          Text('Series', style: GoogleFonts.poppins(
                                                              fontSize: 15, fontWeight: FontWeight.w500
                                                          ),),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
                                                      child:  Container(
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
                                                                    value: seriesid,
                                                                    //elevation: 5,
                                                                    style: TextStyle(color: AppBarColor),
                                                                    iconEnabledColor:AppBarColor,
                                                                    items: series.map((item) {
                                                                      return new DropdownMenuItem(
                                                                        child: new Text(item['sname'].toString(),style: TextStyle(fontSize: 18, color: AppBarColor),),
                                                                        value: item['id'].toString(),
                                                                      );
                                                                    }).toList() ??
                                                                        [],

                                                                    hint:Padding(
                                                                      padding: const EdgeInsets.only(left: 5),
                                                                      child: Text(
                                                                        "Auto Series",
                                                                        style: GoogleFonts.poppins(
                                                                            color: AppBarColor,
                                                                            fontSize: 15,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ),
                                                                    onChanged: (String? value){
                                                                      setState(() {
                                                                        seriesid = value.toString();
                                                                        if(seriesid!='manual'){
                                                                          getbillnum();
                                                                        }else{
                                                                          billno = '';
                                                                          start_serial_Controller.clear();
                                                                        }
                                                                        _invoicebottosheetincrement();                                                                        });
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
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
                                                              if(seriesid.toString()=="manual"){
                                                                if(start_serial_Controller.text.isNotEmpty){
                                                                  Navigator.pop(context);
                                                                  billno = start_serial_Controller.text.toString();
                                                                }else{
                                                                  showPrintedMessage(context, "Error", "Please enter bill number", Colors.white, Colors.redAccent, Icons.info, true, "top");
                                                                }
                                                              }else{
                                                                Navigator.pop(context);
                                                              }
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
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 8),
                      child: Container(
                        height: 50,
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
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 10),
                              child: Container(
                                height: 40,
                                width:MediaQuery.of(context).size.width-12,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.transparent,)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      hint : Text('Select Store *'),
                                      value: selected_ware2,
                                      isDense: true,
                                      items:warelist2.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (s){
                                        int index = warelist2.indexOf(s.toString());
                                        setState(() {
                                          selected_ware2 = s.toString();
                                          selected_ware2id = warelistid2[index].toString();
                                          //debugPrint(selected_ware2id.toString());
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                                                        if(totalselected_id.isEmpty) {
                                                          partyname = 265;
                                                        }else{
                                                          partyname = 990;
                                                        }
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
                                                                          // if(selectednumber.isNotEmpty)
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
                                        }).toList() ??
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
                      products.clear();
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
                      discount_percent_Controller.text = '0.0';


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
                  /* Padding(
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
                  ),*/
                  if(showloader == true)
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height - 177,
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
                          .height - 177,
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
                                                                    products[index]['rate']
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
                                                                AddAmount(products[index]['iid'].toString(),context, products[index]['name'].toString(), index, products[index]['rate'].toString(), "main list");
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
                          .height - 177,
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
                                                                    itemsprod[index]['rate']
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
                                                                AddAmount(itemsprod[index]['iid'].toString(),context, itemsprod[index]['name'].toString(), index, itemsprod[index]['rate'].toString(), "search list");
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
                          .height - 177,
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
                          .height - 177,
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
                                                                      itemsprod[index]['rate']
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
                                                                  AddAmount(itemsprod[index]['iid'].toString(),context, itemsprod[index]['name'].toString(), index, itemsprod[index]['rate'].toString(), "search list");
                                                                });
                                                              },
                                                              child:Text('Change Rate')
                                                          )
                                                        ]
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
                                      child: Text('Pricing', style:TextStyle(fontSize:15, color:Colors.black)),
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
                                      child: Text('Stock', style:TextStyle(fontSize:15, color:Colors.black)),
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
                                      child: Text('Other', style:TextStyle(fontSize:15, color:Colors.black)),
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
                                                            items: uoms.map((item) {
                                                              return new DropdownMenuItem(
                                                                child: new Text(item['name'],style: TextStyle(fontSize: 15, color: AppBarColor),),
                                                                value: item['code'].toString(),
                                                              );
                                                            }).toList() ??
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
                                                            items: gstperlist1.map((item) {
                                                              return new DropdownMenuItem(
                                                                child: new Text(item['gst']+" "+ "%",style: TextStyle(fontSize: 18, color: AppBarColor),),
                                                                value: item['gst'].toString(),
                                                              );
                                                            }).toList() ??
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
                                                        items: Catlist.map((item) {
                                                          return new DropdownMenuItem(
                                                            child: new Text(item['name'],style: TextStyle(fontSize: 18, color: AppBarColor),),
                                                            value: item['cat_id'].toString(),
                                                          );
                                                        }).toList() ??
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



