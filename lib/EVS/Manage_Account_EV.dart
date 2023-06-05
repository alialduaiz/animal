import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled6/admin/update_admin.dart';

import '../User/update_user.dart';
import '../globals.dart';
import '../language.dart';


class ManageAccountAdmin extends StatefulWidget {

  @override
  _ManageAccountAdmin createState() => _ManageAccountAdmin();
}
class _ManageAccountAdmin extends State<ManageAccountAdmin> {
  Map<String, dynamic>? _userDetails;

  @override
  void initState() {
    super.initState();
    _getUser();

  }

  ////
  Future<void> _getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    // Print the user ID for debugging
    print('User ID: $userId');

    final response = await http.get(Uri.parse('$GServer/users'));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final _fetchedUsers = jsonDecode(decodedBody) as List<dynamic>;
      final _filteredUser = _fetchedUsers
          .cast<Map<String, dynamic>>()
          .firstWhere((user) => user['ID'] == userId, orElse: () => {});

      // Print the user details for debugging
      print('User details: $_filteredUser');

      setState(() {
        _userDetails = _filteredUser;
      });
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    sleep(Duration(seconds: 5));
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF087474),
          title: Text(
              '${FlutterI18n.translate(context,'manage account')}'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                List<OptionMenuItem> menuItems = [
                  OptionMenuItem(
                    title:  '${FlutterI18n.translate(context,'Edit_Account')}',
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                            builder: (context) =>
                                Edit_User() // Handle Edit Account
                        ),

                      );
                    },
                    textColor: Colors.redAccent,
                  ),
                  OptionMenuItem(
                    title:  '${FlutterI18n.translate(context,'delete')}',
                    onTap: () {
                      // Handle Delete Account
                    },
                    textColor: Colors.red,
                  ),
                  OptionMenuItem(
                    title:  '${FlutterI18n.translate(context,'Cancel')}',
                    onTap: () {
                      Navigator.pop(context); // Handle Cancel
                    },
                  ),
                ];

                showOptionMenuSheet(context, menuItems);



              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 63.0,
                      backgroundColor: Colors.teal,
                      child: CircleAvatar(
                        radius: 60.0,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.mail,
                          size: 60,
                          color: Color(0xFF087474),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child:
                      Row(
                        children: [
                          Text(
                            FlutterI18n.translate(context,'name'),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),



                          Text(
                            _userDetails != null ? _userDetails!['Name'] ??  '${FlutterI18n.translate(context,'loading' )}': '${FlutterI18n.translate(context,'loading' )}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              RowItem(label: FlutterI18n.translate(context,'ID'), value: _userDetails != null ? _userDetails!['ID'] ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              RowItem(label: FlutterI18n.translate(context,'phone'), value: _userDetails != null ? _userDetails!['Phone'] ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              RowItem(label: FlutterI18n.translate(context,'email'), value: _userDetails != null ? _userDetails!['Email'] ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              RowItem(label: FlutterI18n.translate(context,'national_id'), value: _userDetails != null ? _userDetails!['National_ID'] ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              RowItem(label: FlutterI18n.translate(context,'age'), value: _userDetails != null ? _userDetails!['Age']?.toString() ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              RowItem(label: FlutterI18n.translate(context,'account_status'), value:  FlutterI18n.translate(context,(_userDetails != null ?(_userDetails!['Account_Status']) ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'))),


            ],
          ),
        ),
        bottomNavigationBar: LanguageSelectionBottomBar(),
      ),

    );
  }
}

class RowItem extends StatelessWidget {
  final String label;
  final String value;

  RowItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 40.0),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconWithText extends StatelessWidget {
  final IconData icon;
  final String text;

  IconWithText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon),
        SizedBox(height: 4.0),
        Text(text),
      ],
    );
  }
}
void showOptionMenuSheet(BuildContext context, List<OptionMenuItem> menuItems) {
  double itemHeight = 50.0;
  double titleHeight = 50.0;
  double totalHeight = (menuItems.length + 1) * itemHeight + titleHeight;

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext context) {
      return Container(
        height: totalHeight,
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                FlutterI18n.translate(context,'option_menu'),
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (BuildContext context, int index) {
                  OptionMenuItem menuItem = menuItems[index];
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      menuItem.onTap();
                    },
                    title: Text(
                      menuItem.title,
                      style: TextStyle(
                        color: menuItem.textColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );

    },
  );
}

class OptionMenuItem {
  final String title;
  final Function onTap;
  final Color textColor;

  OptionMenuItem({required this.title, required this.onTap, this.textColor = Colors.black});
}
