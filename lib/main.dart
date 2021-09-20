import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';
import 'package:vpn/assiduiteWidget.dart';
import 'package:vpn/schoolWidget.dart';
import 'package:vpn/settingsWidget.dart';
import 'package:vpn/userSimplePreferences.dart';
import 'package:vpn/vpn.dart';

import 'Dart:async' show Future;
import 'package:vpn/vpnWidget.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSimplePreferences.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    print("tap");
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pointage App',
      home: MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget{
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget>{
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white);

  String _current_status;
  Stream<String> _status;

  bool _status_listen = false;
  MaterialColor _color_status = Colors.red;

  String _user;
  String _passwd;

  @override
  void initState() {
    super.initState();
    _user = UserSimplePreferences.getUsername() ?? '';
    _passwd = UserSimplePreferences.getPasswd() ?? '';
  }

  statusVpn(){
    _status_listen = true;
    _status.listen( (String data) {
      setState(() {
        _current_status = data;
        if (data == "CONNECTED") {
          _color_status = Colors.lightGreen;
        } else if ( data == "DISCONNECTED") {
          _color_status = Colors.red;
        } else {
          _color_status = Colors.orange;
        }
        print("change state and color");
      });
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    AssiduiteWidget(),
    SchoolWidget(),
    SettingsWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pointage ENSIMAG'),
          centerTitle: true,
          backgroundColor : Colors.green,
        ),
        body: Column(
          children: [
            _widgetOptions.elementAt(_selectedIndex),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            try {
              print("=====================================================================>"+_user+" "+_passwd);
              _status =
                  Vpn('assets/Ensimag-VPN-ETU-udp.ovpn', _user, _passwd).status;
              print(!_status_listen);
              statusVpn();
            } catch (error){
              print(error);
            }
          },
          child: Icon(Icons.vpn_key),
          backgroundColor: _color_status,
          elevation: 6.0,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.green,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Assiduite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'School',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
        )
    );
  }
}
