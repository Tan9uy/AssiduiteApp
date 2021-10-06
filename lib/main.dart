import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vpn/schoolWidget.dart';
import 'package:vpn/settingsWidget.dart';
import 'package:vpn/stockageWidget.dart';
import 'package:vpn/userSimplePreferences.dart';
import 'package:vpn/vpn.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Dart:async' show Future;

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

    /*
    NotificationApi.init();

    AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
        'resource://drawable/res_app_icon',
        [
          NotificationChannel(
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: Color(0xFF9D50DD),
              ledColor: Colors.white
          )
        ]
    );

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experien
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    AwesomeNotifications().actionStream.listen(
            (receivedNotification){

          Navigator.of(context).pushNamed(
              '/NotificationPage',
              arguments: { 'id': receivedNotification.id } // your page params. I recommend to you to pass all *receivedNotification* object
          );

        }
    );
     */
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
          onPressed: () async {
            while (!await Permission.storage.isGranted){
              await Permission.storage.request();
              showDialog(
                context: context,
                builder: (BuildContext context) => StockageDialogWidget(),
              );
            }
           _user = await UserSimplePreferences.getUsername();
           _passwd = await UserSimplePreferences.getPasswd();

            try {
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
