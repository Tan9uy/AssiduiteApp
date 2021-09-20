import 'package:shared_preferences/shared_preferences.dart';

class UserSimplePreferences {
  static SharedPreferences _preferences;
  static const String _userKey = 'user';
  static const String _passwdKey = 'passwd';
  static const String _urlKey = 'url';
  static const String _urlPointageKey = 'urlPointage';
  static const String _dataEdtKey = 'data';


  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setUsername(String user) async => _preferences.setString(_userKey, user);
  static Future setUserPasswd(String passwd) async => _preferences.setString(_passwdKey, passwd);
  static Future setUrl(String url) async => _preferences.setString(_urlKey, url);
  static Future setUrlPointage(String url) async => _preferences.setString(_urlPointageKey, url);
  static Future setDataEdt(String data) async => _preferences.setString(_dataEdtKey, data);


  static String getUsername() => _preferences.getString(_userKey);
  static String getPasswd() => _preferences.getString(_passwdKey);
  static String getUrl() => _preferences.getString(_urlKey);
  static String getUrlPointage() => _preferences.getString(_urlPointageKey);
  static String getDataEdt() => _preferences.getString(_dataEdtKey);

}