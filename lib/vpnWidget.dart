import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpn/userSimplePreferences.dart';
import 'vpn.dart';
import 'Dart:async' show Future;

class VpnWidget extends StatefulWidget {
  @override
  _VpnWidgetState createState() => _VpnWidgetState();
}

class _VpnWidgetState extends State<VpnWidget> {
  String _current_status;
  String _str_user = "Connect";
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

  Stream<String> _status;
  statusVpn(){
    _status_listen = true;
    _status.listen( (String data) {
      setState(() {
        _current_status = data;
        if (data == "CONNECTED") {
          _color_status = Colors.lightGreen;
          _str_user = "Connected";
        } else if ( data == "DISCONNECTED") {
          _color_status = Colors.red;
          _str_user = "Connect";
        } else {
          _color_status = Colors.orange;
          _str_user = "Connecting";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
      _status = Vpn('assets/Ensimag-VPN-ETU-udp.ovpn',_user,_passwd).status;
      if (!_status_listen)
        statusVpn();
      },
    );
  }
}
