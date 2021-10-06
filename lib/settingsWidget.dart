import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vpn/stockageWidget.dart';
import 'package:vpn/userSimplePreferences.dart';
import 'vpn.dart';
import 'Dart:async' show Future, Timer;

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _user;
  String _passwd;
  String _url;

  final TextEditingController _controllerUser = TextEditingController();
  final TextEditingController _controllerPasswd = TextEditingController();
  final TextEditingController _controllerUrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(_user);
    return SizedBox(
        height: (MediaQuery.of(context).size.height-213),
        child: SafeArea(
          child : SingleChildScrollView(
            child : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: _controllerUser,
                      decoration: const InputDecoration(
                        hintText: 'Enter your user name',
                      ),
                      onChanged: (String user) {
                        _user = user;
                      },
                    ),
                    Container(height: 10),
                    TextField(
                      controller: _controllerPasswd,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                      ),
                      obscureText: true,
                      onChanged: (String passwd) {
                        _passwd = passwd;
                      },
                    ),
                    Container(height: 10),
                    TextField(
                      controller: _controllerUrl,
                      decoration: const InputDecoration(
                        hintText: 'URL edt',
                      ),
                      onChanged: (String url) {
                        _url = url;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(shadowColor: Colors.black,primary : Colors.green),
                        onPressed: () async {
                          while (!await Permission.storage.isGranted){
                            await Permission.storage.request();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => StockageDialogWidget(),
                            );
                          }
                          if (await Permission.storage.isGranted) {
                            await UserSimplePreferences.setUsername(_user);
                            await UserSimplePreferences.setUserPasswd(_passwd);
                            await UserSimplePreferences.setUrl(_url);
                          }
                        },
                        child: const Text('Save',style: TextStyle(color : Colors.white, fontSize: 17)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          )
        )
    );
  }

  @override
  void dispose() {
    _controllerUser.dispose();
    _controllerPasswd.dispose();
    _controllerUrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controllerUser.text = '';
    _controllerPasswd.text = '';
    _controllerUrl.text = '';
    data();
    super.initState();
  }
  void data() async {
    if (await Permission.storage.isGranted || await Permission.storage
        .request()
        .isGranted) {
      _user = await UserSimplePreferences.getUsername();
      _passwd = await UserSimplePreferences.getPasswd();
      _url = await UserSimplePreferences.getUrl();
      _controllerUser.text = _user;
      _controllerPasswd.text = _passwd;
      _controllerUrl.text = _url;
      setState(() {
        _user = _user;
        _passwd = _passwd;
        _url = _url;
      });
    }
  }
}
