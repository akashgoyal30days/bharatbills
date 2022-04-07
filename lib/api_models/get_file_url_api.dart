import 'package:bbills/app_constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared preference singleton.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future fileurlapi(String package, String url, Map fromfile) async {
  String token = "";
  SharedPreferences userdetails = SharedPreferenceSingleton.sharedPreferences;
  if (userdetails.getString("utoken") != null) {
    token = userdetails.getString("utoken").toString();
  }
  var response = await http.post(
    Uri.https("villaments.win", "$package/$url"),
    body: fromfile,
  );

  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  //var convertedDatatoJson = response.body.replaceAll(r"\\n", "");
  return convertedDatatoJson;
}
