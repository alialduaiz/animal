
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'User/Login.dart';

void logoutAndNavigateToLoginPage(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Logout Confirmation'),
        content: Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () {
              // Clear local preferences
              SharedPreferences.getInstance().then((prefs) {
                prefs.clear();

                // Navigate to LoginPage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
                      (route) => false,
                );
              });
            },
          ),
        ],
      );
    },
  );
}
