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

class SchoolWidget extends StatefulWidget {
  @override
  _SchoolWidgetState createState() => _SchoolWidgetState();
}

class _SchoolWidgetState extends State<SchoolWidget> {
  String _url;
  String contend = "";
  ICalendar _iCalendar;
  bool _isInit = false;
  List<Map<String, dynamic>> _courses;


  @override
  void initState() {
    super.initState();
    _url = UserSimplePreferences.getUrl();
    _courses = [];
  }

  List<Map<String, dynamic>> getEdtForToday(String edt) {
    if (edt == "") {
      _iCalendar = ICalendar.fromString(UserSimplePreferences.getDataEdt());
    } else {
      _iCalendar = ICalendar.fromString(edt);
      UserSimplePreferences.setDataEdt(edt);
    }
    _courses.removeRange(0, _courses.length);
    _iCalendar.data.forEach((course) {
      if (DateTime.tryParse(course["dtstart"].dt).toUtc().day == DateTime.now().day){
        _courses.add(course);
      }
    });
    _courses.sort( (a,b) => DateTime.tryParse(a["dtstart"].dt).toUtc().hour.compareTo(DateTime.tryParse(b["dtstart"].dt).toUtc().hour));
    return _courses;
  }

  Future<http.Response> fetchEdt()  async {
    return http.get(Uri.parse(_url));
  }

  Widget _getcourses(){
    setState(() {
      _courses = getEdtForToday("");
    });
    return Text("hello");
  }

  Widget _generateTextContent() {
    const style = TextStyle(color: Colors.black);
    return Container(
      height: (MediaQuery.of(context).size.height-213),
      width: (MediaQuery.of(context).size.width),
        child : ListView(
          children: _courses
                .map((e) => Row(
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
                            var date = e['dtstamp'];
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
                                                        e["summary"].toString(),
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
                                            child : Text(e['location']+" "+DateTime.tryParse(e["dtstart"].dt).toUtc().hour.toString(), style: TextStyle(color : Colors.black, fontSize: 17)),
                                          ),
                                        ],
                                      ),
                                  ),
                              ),
                          ),
                        ),
                      ),
                    ),
                  ],)
                ).toList(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    var _width = MediaQuery.of(context).size.width;
    var jours = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
    var mois = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Decembre'];
    return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Center(
                    child: Row(
                      children : [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child : Text(jours[date.weekday.toInt()-1]+" "+date.day.toString()+" "+mois[date.month.toInt()-1]),
                        ),
                        SizedBox(
                          width: _width/4,
                        ),

                        ElevatedButton(
                          onPressed: () async {
                            try {
                              Future<http.Response> response = fetchEdt();
                              response.then((value) =>
                              {
                                if (value.statusCode == 200){
                                  setState(() {
                                    contend = value.body;
                                    _courses = getEdtForToday(contend);
                                  })
                                }
                              });
                            } catch (error){
                              throw ErrorDescription("something when wrong went fetching edt");
                            }
                          },
                          style: ElevatedButton.styleFrom(shadowColor: Colors.black,primary : Colors.green),
                          child: const Text('Update calendar'),
                        ),
                      ],
                  ),
                ),
                if (_courses.length != 0)
                  _generateTextContent(),
                if (_courses.length == 0 && _isInit)
                    _getcourses(),
              ],
            ),
    );
  }
}
