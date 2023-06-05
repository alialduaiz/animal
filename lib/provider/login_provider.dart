import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LogInProvider with ChangeNotifier {
   TextEditingController phone  = TextEditingController();
   TextEditingController password  = TextEditingController();
   final List<Map<String, dynamic>> userTypes = [
      {'type': 'User', 'icon': FontAwesomeIcons.user, 'title': 'User Login', 'subtitle': 'Sign in as a user'},
      {'type': 'Admin', 'icon': FontAwesomeIcons.userShield, 'title': 'Admin Login', 'subtitle': 'Sign in as an admin'},
      {'type': 'Police', 'icon': FontAwesomeIcons.userSecret, 'title': 'Security Login', 'subtitle': 'Sign in as security'},

   ];
   IconData selectedIcon = FontAwesomeIcons.user;
}