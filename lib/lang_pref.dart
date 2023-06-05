import 'package:shared_preferences/shared_preferences.dart';

class LangPref {
  static const _selectedLanguageKey = 'selectedLanguage';

  Future<void> setSelectedLanguage(String languageCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLanguageKey, languageCode);
  }

  Future<String> getSelectedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedLanguageKey) ?? 'en';
  }
}
