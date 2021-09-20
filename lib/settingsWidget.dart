import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vpn/userSimplePreferences.dart';
import 'vpn.dart';
import 'Dart:async' show Future;

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _user;
  String _passwd;
  String _url;
  String _urlPage;

  @override
  void initState() {
    super.initState();
    _user = UserSimplePreferences.getUsername() ?? '';
    _passwd = UserSimplePreferences.getPasswd() ?? '';
    _url = UserSimplePreferences.getUrl() ?? '';
    _urlPage = UserSimplePreferences.getUrlPointage() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: _user,
                decoration: const InputDecoration(
                  hintText: 'Enter your user name',
                ),
                onChanged: (name) => setState(() => _user = name),
            ),
            Container(height: 10),
            TextFormField(
              initialValue: _passwd,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
              obscureText: true,
              onChanged: (name) => setState(() => _passwd = name),
              validator: (String value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                _passwd = value;
                return null;
              },
            ),
            Container(height: 10),
            TextFormField(
              initialValue: _url,
              decoration: const InputDecoration(
                hintText: 'URL ical',
              ),
              onChanged: (name) => setState(() => _url = name),
            ),
            TextFormField(
              initialValue: _urlPage,
              decoration: const InputDecoration(
                hintText: 'URL assiduite',
              ),
              onChanged: (name) => setState(() => _urlPage = name),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await UserSimplePreferences.setUsername(_user);
                  await UserSimplePreferences.setUserPasswd(_passwd);
                  await UserSimplePreferences.setUrl(_url);
                  await UserSimplePreferences.setUrlPointage(_urlPage);
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_formKey.currentState.validate()) {
                    print("Valide");
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
