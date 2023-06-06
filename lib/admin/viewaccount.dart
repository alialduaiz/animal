import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled6/admin/update_admin.dart';
import '../User/update_user.dart';
import '../globals.dart';
import '../imports_all.dart';
import '../provider/ChatsProvider.dart';
import '../provider/users_provider.dart';


class ManageAccount extends StatefulWidget {
  final String userId;

  const ManageAccount({required this.userId});
  @override
  _ManageAccount createState() => _ManageAccount();
}
class _ManageAccount extends State<ManageAccount> {
  String _AccountStatus = '';
  final List<String> AcountStatusOptions = [
    'Active',
    'Inactive',
  ];
  Map<String, dynamic>? _userDetails;

  @override
  void initState() {
    super.initState();
    _getUser();

  }Widget buildAcountStatus() {
    return Container(
      width: MediaQuery.of(context).size.width*0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.0),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              FlutterI18n.translate(context,'account_status'),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Column(
            children: AcountStatusOptions.map((status) {
              final isSelected = _AccountStatus == status;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _AccountStatus = status;
                  });
                  updateAccountStatus(widget.userId, status);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.black,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                    color: isSelected ? Colors.blue : Colors.transparent,
                    borderRadius: status =='Dealt With'? BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ):BorderRadius.only(
                      bottomRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  height: 50,
                  child: Text(
                    FlutterI18n.translate(context,status),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> updateAccountStatus(String userId, String newAccountStatus) async {
    final apiUrl = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/update_user_status';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({'User_ID': userId, 'Status': newAccountStatus}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Account status updated successfully');
    } else {
      print('Failed to update account status. Error: ${response.body}');
    }
  }

  Future<void> _getUser() async {


    // Print the user ID for debugging
    print('User ID: $widget.userId');


    final response = await http.get(Uri.parse('$GServer/users'));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final _fetchedUsers = jsonDecode(decodedBody) as List<dynamic>;
      final _filteredUser = _fetchedUsers
          .cast<Map<String, dynamic>>()
          .firstWhere((user) => user['ID'] == widget.userId, orElse: () => {});

      // Print the user details for debugging
      print('User details: $_filteredUser');

      setState(() {
        _userDetails = _filteredUser;
        _AccountStatus =_filteredUser['Account_Status'];
      });
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
   // sleep(Duration(seconds: 5));
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
                    title:  '${FlutterI18n.translate(context,'edit_account')}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Edit_User() // Handle Edit Account
                        ),

                      );
                    },
                    textColor: Colors.blue,
                  ),
                  OptionMenuItem(
                    title:  '${FlutterI18n.translate(context,'Message the user')}',
                    onTap: () {
                      // Navigator.push(
                      //   context,
                        // MaterialPageRoute(
                        //     builder: (context) =>
                        //         Edit_User() // Handle Edit Account
                        // ),

                      // );
                    },
                    textColor: Colors.blue,
                  ),
                  OptionMenuItem(
                    title:  '${FlutterI18n.translate(context,'Delete Account')}',
                    onTap: () {

                      Provider.of<ReportsProvider>(context, listen: false).deleteUser(context,_userDetails!['ID'] ) ;// Handle Edit Account



                    },
                    textColor: Colors.blue,
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
                          _userDetails!=null && _userDetails!['Type']!= null ?(_userDetails!['Type']=='EVSecurity'?FontAwesomeIcons.userSecret:
                        _userDetails!['Type']=='Admin'?FontAwesomeIcons.userShield:Icons.person):Icons.person

                      ,


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

              RowItem(label: FlutterI18n.translate(context,'ID'), value: _userDetails != null ? _userDetails!['ID'].hashCode.toString() ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              RowItem(label: FlutterI18n.translate(context,'phone'), value: _userDetails != null ? _userDetails!['Phone'] ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              RowItem(label: FlutterI18n.translate(context,'email'), value: _userDetails != null ? _userDetails!['Email'] ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              RowItem(label: FlutterI18n.translate(context,'national_id'), value: _userDetails != null ? _userDetails!['National_ID'] ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              RowItem(label: FlutterI18n.translate(context,'age'), value: _userDetails != null ? _userDetails!['Age']?.toString() ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              RowItem(label: FlutterI18n.translate(context,'account_status'), value: _userDetails != null ? _userDetails!['Account_Status'] ?? '${FlutterI18n.translate(context,'loading' )}' : '${FlutterI18n.translate(context,'loading' )}'),
              buildAcountStatus(),

            ],
          ),
        ),

      ),
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
