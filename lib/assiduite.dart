import 'dart:convert';
import 'dart:io';


import 'package:vpn/userSimplePreferences.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'Dart:async' show Future;

class Assiduite{
  String _url;
  String _urlPage;
  String _user;
  String _passwd;
  String contend = "";
  List<Map<String,String>> _courses_to_point = [];

  Future<void> _getData() async {
    _url = await UserSimplePreferences.getUrl();
    _user = await UserSimplePreferences.getUsername();
    _passwd = await UserSimplePreferences.getPasswd();
  }

  String basicAuthorizationHeader(String username, String password) {
    return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  }

  Future<bool> parse_courses_to_point() async {
    await _getData();
    try {
      final res = await http.get(
          Uri.parse("https://extranet.ensimag.fr/assiduite"),
          headers:{
            HttpHeaders.authorizationHeader: basicAuthorizationHeader(_user, _passwd),
          }
      );

      var document = parse(res.body);
      var rows = document.getElementsByClassName("click");
      _courses_to_point =  [];

      rows.forEach((row) async {
        final infos = row.getElementsByTagName("td");
        var data = {"name": infos[5].text,"date": infos[2].text, "start":infos[3].text, "end":infos[4].text, "id": row.attributes['ide'].toString()};

        _courses_to_point.add(data);
      });
    } catch (errors){
      print(errors);
    }
    return _courses_to_point.isEmpty;
  }

  Future<String> point_course(String courseName) async{
    await _getData();
    var success = false;
    var found = false;
    var tab = [];
    for (int indice = 0 ; indice < _courses_to_point.length; indice++) {
      tab.add(_courses_to_point[indice]["name"]);
      if (courseName == _courses_to_point[indice]["name"]) {
        found = true;
        final queryParameters = {
          'idE': _courses_to_point[indice]["id"],
          'uid': _user,
        };

        final uri = Uri.http(
            'extranet.ensimag.fr', '/assiduite/pointage/groupe',
            queryParameters);

        final headers = {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: basicAuthorizationHeader(
              _user, _passwd),
        };

        try {
          // point to courses
          var response = await http.get(uri, headers: headers);
          success = response.body.contains(
              _courses_to_point[indice]["id"].toString()) &&
              response.body.contains(_user);
        } catch (error) {
          return "Error : "+error;
        }
      }
    }
    if (!found){
      return "Error : unknown "+courseName+"\n"+tab.toString();
    }
    return success ? "Le pointage a bien été enregistré" : "Le pointage n'a pas fonctionné";
  }

}

