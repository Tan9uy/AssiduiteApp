import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_openvpn/flutter_openvpn.dart';

class Vpn {
  final _controller = StreamController<String>();
  String _ovpnFile;
  String _password;
  String _user;

  Vpn(ovpnFIle,user,password){
    this._ovpnFile = ovpnFIle;
    this._user = user;
    this._password = password;
    vpn();
  }

  vpn() async {
    print("vpn function");
    String vpnData = await rootBundle.loadString(this._ovpnFile);
    await FlutterOpenvpn.init();
    await FlutterOpenvpn.lunchVpn(
      vpnData,
          (isProfileLoaded) {
        print('isProfileLoaded : $isProfileLoaded');
      },
          (vpnActivated) {
        print('vpnActivated : $vpnActivated');
        _controller.add(vpnActivated);
      },
      user: this._user,
      pass: this._password,
      onConnectionStatusChanged:
          (duration, lastPacketRecieve, byteIn, byteOut) => print(byteIn),
      expireAt: DateTime.now().add(
        Duration(
          seconds: 60,
        ),
      ),
    );
  }

  Stream<String> get status {
    return _controller.stream;
  }

}