import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class UserSimplePreferences {
  static EncryptedSharedPreferences  _preferences;
  static const String _userKey = 'user';
  static const String _passwdKey = 'passwd';
  static const String _urlKey = 'url';
  static const String _urlPointageKey = 'urlPointage';
  static const String _dataEdtKey = 'data';


  static Future init() async =>
      _preferences = await EncryptedSharedPreferences();

  static Future setUsername(String user) async => _preferences.setString(_userKey, user);
  static Future setUserPasswd(String passwd) async => _preferences.setString(_passwdKey, passwd);
  static Future setUrl(String url) async => _preferences.setString(_urlKey, url);
  static Future setUrlPointage(String url) async => _preferences.setString(_urlPointageKey, url);
  static Future setDataEdt(String data) async => _preferences.setString(_dataEdtKey, data);


  static Future<String> getUsername() async =>  _preferences.getString(_userKey);
  static Future<String> getPasswd() async => _preferences.getString(_passwdKey);
  static Future<String> getUrl() async => _preferences.getString(_urlKey);
  static Future<String> getUrlPointage() async => _preferences.getString(_urlPointageKey);
  static Future<String> getDataEdt() async => _preferences.getString(_dataEdtKey);

}