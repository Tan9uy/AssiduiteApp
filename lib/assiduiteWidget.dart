import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:vpn/userSimplePreferences.dart';
import 'vpn.dart';
import 'package:html/parser.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:http/http.dart' as http;
import 'Dart:async' show Future;

class AssiduiteWidget extends StatefulWidget {
  @override
  _AssiduiteWidgetState createState() => _AssiduiteWidgetState();
}

class _AssiduiteWidgetState extends State<AssiduiteWidget> {
  String _url;
  String _urlPage;
  String _user;
  String _passwd;
  String contend = "";
  String  _result1 ;
  List<Map<String,String>> _courses_to_point = [];


  @override
  void initState() {
    super.initState();
    _url = UserSimplePreferences.getUrl();
    _urlPage = UserSimplePreferences.getUrlPointage();
    _user = UserSimplePreferences.getUsername();
    _passwd = UserSimplePreferences.getPasswd();
  }

  String basicAuthorizationHeader(String username, String password) {
    return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final res = await http.get(
                          Uri.parse(_urlPage),
                          headers:{
                            HttpHeaders.authorizationHeader: basicAuthorizationHeader(_user, _passwd),
                          }
                      );
                      setState(() {
                        _result1 = "Try accessing the page /assiduite";
                      });

                      var document = parse(res.body);
                      var rows = document.getElementsByClassName("click");
                      if (res.statusCode != 200){
                        setState(() {
                          _result1 = "Something went wrong "+res.statusCode.toString();
                        });
                      }
                      _courses_to_point =  [];

                      if (rows.length == 0){
                        _result1 = "Nothing can be pointed !";
                      }

                      rows.forEach((row) async {
                        final infos = row.getElementsByTagName("td");
                        var data = {"name": infos[5].text,"date": infos[2].text, "start":infos[3].text, "end":infos[4].text, "id": row.attributes['ide'].toString()};

                        setState(() {
                          _courses_to_point.add(data);
                        });
                      });


                    } catch (errors){
                      print(errors);
                    }

                  },
                  style: ElevatedButton.styleFrom(shadowColor: Colors.black,primary : Colors.green),
                  child: const Text('Get pointage page'),
                ),
                Container(
                  height: (MediaQuery.of(context).size.height-300),
                  width: (MediaQuery.of(context).size.width),
                  child : ListView(
                    children: _courses_to_point.map((e) =>
                      Row(
                        children : [
                        Expanded(
                          child : Padding(
                            padding : const EdgeInsets.all(8.0),
                            child : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 13.0,
                                shadowColor: Colors.black,
                                primary : Colors.white,
                                shape: RoundedRectangleBorder(
                                  side : BorderSide(
                                    color : Colors.green,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () async {

                                setState(() {
                                  _result1 = "Try pointing "+e["name"];
                                });

                                final queryParameters = {
                                  'idE': e["id"],
                                  'uid': _user,
                                };

                                final uri = Uri.http('https://extranet.ensimag.fr', '/assiduite/pointage/groupe', queryParameters);

                                final headers = {
                                  HttpHeaders.contentTypeHeader: 'application/json',
                                  HttpHeaders.authorizationHeader: basicAuthorizationHeader(_user, _passwd),
                                };

                                final response = await http.get(uri, headers: headers);

                                setState(() {
                                  _result1 = response.statusCode.toString();
                                });
                              },

                              child: SizedBox(
                                height: 70.0,
                                child: SafeArea(
                                  child : SingleChildScrollView(
                                    child : Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child : Text(
                                              e["name"].toString(),
                                              style : TextStyle(
                                                color : Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child : Text(e['start']+"  "+e['End'], style: TextStyle(color : Colors.black, fontSize: 17)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ],
                      ),
                    ).toList(),
                  ),
                ),
                Text(_result1 ?? "Nothing can be pointed"),
              ],
            ),
    );
  }
}
