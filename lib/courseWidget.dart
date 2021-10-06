import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'assiduite.dart';

class CourseWidget extends StatefulWidget {
  Map<String, dynamic> _data;
  CourseWidget(data){
    this._data = data;
  }


  @override
  _CourseWidgetState createState() => _CourseWidgetState(_data);
}

class _CourseWidgetState extends State<CourseWidget> {
  Color _color = Colors.black;
  String _feedback = "";
  double _size = 94.0;
  Color _colorFeedback = Colors.green;

  Map<String, dynamic> _data;
  _CourseWidgetState(data){
    this._data = data;
  }

  String format_time(){
    String time = "";
    var start = DateTime.tryParse(_data["dtstart"].dt);
    time += (start.hour.toInt()+2).toString()+"h ";
    var minute = start.minute.toInt();
    if (minute == 0){
      time += "00";
    } else {
      time += minute.toString();
    }
    time += " - ";
    var end = DateTime.tryParse(_data["dtend"].dt);
    time += (end.hour.toInt()+2).toString()+"h ";
    minute = end.minute.toInt();
    if (minute == 0){
      time +="00";
    } else {
      time += minute.toString();
    }
    return time;
  }

  bool isBefore(DateTime course){
    var now = DateTime.now();
    var minutesNow = now.hour.toInt()*60+now.minute.toInt();
    var minutesCourse = (course.hour.toInt()+2)*60+course.minute.toInt()-15;
    return minutesNow < minutesCourse;
  }

  bool isAfter(DateTime course){
    var now = DateTime.now();
    var minutesNow = now.hour.toInt()*60+now.minute.toInt();
    var minutesCourse = (course.hour.toInt()+2)*60+course.minute.toInt()+15;
    return minutesNow > minutesCourse;
  }

  void _changeFeedBack(String message, Color color){
    setState(() {
      _feedback = message;
      _size = 100.0;
      _colorFeedback = color;
    });
    Timer(Duration(seconds: 5), () => {
      setState(() {
      _feedback = "";
      _size = 94.0;
      _colorFeedback = Colors.green;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    color : _color,
                    width: 0.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onPressed: () async {
                /*
                            NotificationApi.showNotification(
                              title: e["summary"].toString(),
                              body: "Tou can point",
                              payload: "notification.abs");

                            AwesomeNotifications().createNotification(
                                content: NotificationContent(
                                    id: 10,
                                    channelKey: 'basic_channel',
                                    title: 'Simple Notification',
                                    body: 'Simple body'
                                )
                            );
                           */
                if (isBefore(DateTime.tryParse(_data["dtstart"].dt))){
                  _changeFeedBack("Vous ne pouvez pas encore pointer pour ce cours", Colors.red);
                  return;
                }

                if (isAfter(DateTime.tryParse(_data["dtend"].dt))){
                  _changeFeedBack("Vous ne pouvez plus pointer pour ce cours", Colors.red);
                  return;
                }
                var assiduite = Assiduite();
                if( await assiduite.parse_courses_to_point() ){
                  _changeFeedBack("Il n'y a rien à pointer", Colors.red);
                  return;
                }

                var result = await assiduite.point_course(_data['summary']);
                if (result.contains("enregistré")) {
                  _changeFeedBack(result, Colors.green);
                } else {
                  _changeFeedBack(result, Colors.red);
                }
              },

              child: SizedBox(
                height: _size,
                child: SafeArea(
                  child : SingleChildScrollView(
                    child : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child : Text(
                              _data["summary"].toString(),
                              style : TextStyle(
                                color : Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child : Text(
                              _data['location'],
                              style: TextStyle(color : Colors.black, fontSize: 17)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child : Text(
                              format_time(),
                              style: TextStyle(color : Colors.black, fontSize: 17)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child : Text(
                              _feedback,
                              style: TextStyle(color : _colorFeedback, fontSize: 17)),
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
    );
  }

}
