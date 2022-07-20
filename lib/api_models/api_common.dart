import 'dart:developer';

import 'package:bbills/app_constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared preference singleton.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future apiurl(String package, String url, Map fromfile) async {
  String token = "";
  SharedPreferences userdetails = SharedPreferenceSingleton.sharedPreferences;
  if (userdetails.getString("utoken") != null) {
    token = userdetails.getString("utoken").toString();
  }
  Map body = {
    "_req_from": reqfrom,
    "api_key": apikey,
    if (url != "login.php" && url != "recovery.php" && url != "logout.php")
      "_req_token": token
  };
  body.addAll(fromfile);
  //debugPrint(body.toString());
  var response = await http.post(
    Uri.https("$baseurl", "$suburl" + "$package/$url"),
    body: body,
    /*headers: <String, String>{
        'Accept': 'application/json',
      }*/
  );

  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  // var convertedDatatoJson = response.body.replaceAll(r"\\n", "");
  return convertedDatatoJson;
}

Future regurl(String package, String url, Map fromfile) async {
  Map body = {
    "_req_from": reqfrom,
    "api_key": apikey,
  };
  body.addAll(fromfile);
  //debugPrint(body.toString());
  var response = await http.post(
    Uri.https("bharatbills.in", "$package/$url"),
    body: body,
    /*headers: <String, String>{
        'Accept': 'application/json',
      }*/
  );

  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  // var convertedDatatoJson = response.body.replaceAll(r"\\n", "");
  return convertedDatatoJson;
}

//for generating bills
Future gbill(String package, String url, FormData fromfile) async {
  final dio = Dio();

  dio.options.headers = {
    'Accept': 'application/json',
    'Content-Type': 'multipart/form-data',
  };
  //debugPrint(fromfile.fields.toString());
  Response response = await dio.post(
    
    "https://" + baseurl + "/" + suburl + package + '/' + url,
    data: fromfile,
    onSendProgress: (received, total) {
      if (total != -1) {


      }
    },
  );
  var convertedDatatoJson = json.decode(response.data);
  return convertedDatatoJson;
}
