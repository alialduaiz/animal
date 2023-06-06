import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:untitled6/admin/viewaccount.dart';

import '../globals.dart';
import '../language.dart';

class MyUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UsersList();
  }
}

class UsersList extends StatefulWidget {
  const UsersList({Key? key}) : super(key: key);

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  String _selectedAccountType = 'All';
  String _selectedAccountStatus = 'All';
  Map<String, dynamic>? _userdetails;
  final List<Map<String, dynamic>> userTypes = [
    {
      'type': 'User',
      'icon': FontAwesomeIcons.user,
      'title': 'User Login',
      'subtitle': 'Sign in as a user'
    },
    {
      'type': 'Admin',
      'icon': FontAwesomeIcons.userShield,
      'title': 'Admin Login',
      'subtitle': 'Sign in as an admin'
    },
    {
      'type': 'EVSecurity',
      'icon': FontAwesomeIcons.userSecret,
      'title': 'Security Login',
      'subtitle': 'Sign in as security'
    },
  ];

  Future<void> _getUsers() async {
    final response = await http.get(Uri.parse('$GServer/users'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);

      final _fetchedUsers = jsonDecode(decodedBody) as List<dynamic>;

      setState(() {
        _users = _fetchedUsers.cast<Map<String, dynamic>>().toList();
        _applyFilters();
      });
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final isTypeMatch = _selectedAccountType == 'All' ||
            user['Account_Type'] == _selectedAccountType;
        final isStatusMatch = _selectedAccountStatus == 'All' ||
            user['Account_Status'] == _selectedAccountStatus;
        return isTypeMatch && isStatusMatch;
      }).toList();
    });
  }

  @override
  void initState() {
    _getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF087474),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: SizedBox(),
            ),
            Container(
              child: Text(
                FlutterI18n.translate(context, 'Users List'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              alignment: Alignment.center,
            ),
            Container(
              child: InkWell(
                  onTap: () {
                    print("hello ali ");
                  },
                  child: Icon(Icons.add)),
              alignment: Alignment.topRight,
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedAccountType,
                  items: ['All', 'User', 'Admin', 'EVSecurity']
                      .map((type) => DropdownMenuItem<String>(
                            child: Text(FlutterI18n.translate(context, type)),
                            value: type,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountType = value!;
                    });
                    _applyFilters();
                  },
                ),
                DropdownButton<String>(
                  value: _selectedAccountStatus,
                  items: ['All', 'Active', 'Inactive']
                      .map((status) => DropdownMenuItem<String>(
                            child: Text(FlutterI18n.translate(context, status)),
                            value: status,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountStatus = value!;
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _onSearchTextChanged(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                final userType = userTypes
                    .firstWhere((type) => type['type'] == user['Account_Type']);
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF087474),
                    child: Icon(userType['icon'], color: Colors.white),
                  ),
                  title: Text(
                    user['Name'],
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${user['ID'].hashCode.toString()}"),
                      Text("Account Type: ${user['Account_Type']}"),
                      Text("Account Status: ${user['Account_Status']}"),
                    ],
                  ),

                  onTap: () {

                    // TODO: Implement onTap
                  },
                  trailing: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManageAccount(userId: user['ID'].toString())
                          )
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          color: Color(0xFF1B54D9),
                        ),
                        Text(
                          FlutterI18n.translate(context, 'view'),
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
  bottomNavigationBar: LanguageSelectionBottomBar(),
    );
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      if (text.isEmpty) {
// If the search query is empty, show all items.
        _applyFilters();
      } else {
// Filter the items based on the search query.
        _filteredUsers = _users.where((user) {
// Modify the conditions below based on your search requirements.
          return user['Name'].toLowerCase().contains(text.toLowerCase()) ||
              user['ID'].toString().contains(text);
        }).toList();
      }
    });
  }
}
