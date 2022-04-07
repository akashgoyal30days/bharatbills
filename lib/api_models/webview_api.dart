import 'package:bbills/app_constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared preference singleton.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future webapiurl(String package, String url, Map fromfile) async {
  String token = "";
  SharedPreferences userdetails = SharedPreferenceSingleton.sharedPreferences;
  if (userdetails.getString("utoken") != null) {
    token = userdetails.getString("utoken").toString();
  }
  Map body = {
    "_req_from": reqfrom,
    "api_key": apikey,
    if (url != "login.php") "_req_token": token
  };
  body.addAll(fromfile);
  //debugPrint(body.toString());
  //debugPrint('$package/$url');
  var response = await http.post(
    Uri.https("$baseurl", "$suburl" + "$package/$url"),
    body: body,
    /*headers: <String, String>{
        'Accept': 'application/json',
      }*/
  );

  var convertedDatatoJson = response.body.replaceAll(r"\\n", "");
  return convertedDatatoJson;
}
