import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../imports_all.dart';
import '/SignUPpage.dart';
import '/User/UserHome.dart';
import '/EVS/evsecuurity.dart';
import 'package:untitled6/view/admin_dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../globals.dart';
import '../language.dart';

class LogoutPage extends StatefulWidget {
  @override
  _LogoutPageState createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  void initState() {
    super.initState();
    logout();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).popUntil((route) => route is LoginPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

final List<Map<String, dynamic>> _userTypes = [
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

class _LoginPageState extends State<LoginPage> {
  // Define variables to keep track of the selected user type and selected icon
  int _selectedUserType = 0;
  IconData _selectedIcon = FontAwesomeIcons.user;
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  late SharedPreferences _prefs;

  // Define a list of user types and icons
  final List<Map<String, dynamic>> _userTypes = [
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

  bool _isLoading = false;

  Future<Map<String, dynamic>> loginUser(
      String phone, String password, String accountType) async {
    final response = await http.post(
      Uri.parse('$GServer/login/'),
      body: {
        'phone': phone,
        'password': password,
        'account_type': accountType,
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      // Assuming that the response data has a field 'id' which contains the user id.
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String userId = responseData['ID'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      return {
        'success': true,
        'message': 'Error',
        'userId': userId, // Add the userId to the response object
        'Type': accountType,
      };
    } else {
      // Parse the response to get the error message.
      // This depends on how your API sends error messages.
      // Here I am assuming that it sends a field 'error' containing the error message.
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String errorMessage = responseData['error'];
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    _userTypes[0]['title'] = FlutterI18n.translate(context, 'userLogin');
    _userTypes[1]['title'] = FlutterI18n.translate(context, 'adminLogin');
    _userTypes[2]['title'] = FlutterI18n.translate(context, 'securityLogin');

    return  ScaffoldMessenger(
          child: Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.05,
          backgroundColor: Color(0xFF087474),
          title: Text(
            _userTypes[_selectedUserType]['title'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body:  SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF087474),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image(
                            image: AssetImage('assets/img/animals.jpg'),
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.width * 0.4,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      // Display the user type selection boxes
                      Container(
                        child: Wrap(
                          spacing: MediaQuery.of(context).size.width * 0.05,
                          children: _userTypes.map((userType) {
                            final index = _userTypes.indexOf(userType);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _phoneController.clear();
                                  _passwordController.clear();
                                  _selectedUserType = index;
                                  _selectedIcon = userType['icon'];
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  color: _selectedUserType == index
                                      ? Color(0xFF087474)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: FaIcon(
                                    userType['icon'],
                                    size: MediaQuery.of(context).size.width * .12,
                                    color: _selectedUserType == index
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      // Display the sign-in form
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: _phoneController,
                              // You can customize the decoration for the phone input field
                              decoration: InputDecoration(
                                hintText:
                                    FlutterI18n.translate(context, 'phoneNumber'),
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            TextFormField(
                              obscureText: true,
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText:
                                    FlutterI18n.translate(context, 'password'),
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            // Add a sign-in button
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      try {
                                        var connectivityResult =
                                            await (Connectivity()
                                                .checkConnectivity());

                                        if (connectivityResult ==
                                            ConnectivityResult.none) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(FlutterI18n.translate(
                                                  context,
                                                  'No Internet Connection')),
                                            ),
                                          );
                                          return;
                                        }

                                        String phone = _phoneController.text;
                                        String password =
                                            _passwordController.text;
                                        String accountType =
                                            _userTypes[_selectedUserType]['type'];

                                        Map<String, dynamic> result =
                                            await loginUser(
                                                phone, password, accountType);

                                        if (result['success'] &&
                                            (_userTypes[_selectedUserType]
                                                    ['type']) ==
                                                (result['Type'])) {
                                          // Login succeeded, navigate to the appropriate screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => _userTypes[
                                                                  _selectedUserType]
                                                              ['type'] ==
                                                          'User' &&
                                                      result['Type'] == 'User'
                                                  ? MyHome()
                                                  : _userTypes[_selectedUserType]
                                                                  ['type'] ==
                                                              'Admin' &&
                                                          result['Type'] ==
                                                              'Admin'
                                                      ? AdminDashboard()
                                                      : ESHome(),
                                            ),
                                          );
                                        } else {
                                          // Login failed, display an error message
                                          print(
                                              'result[Type]=======${result['Type']}');
                                          print(
                                              '(_userTypes[_selectedUserType].toString()${(_userTypes[_selectedUserType]['type']).toString()}');

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(FlutterI18n.translate(
                                                  context, result['message'])),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        print('Error: $e');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(FlutterI18n.translate(
                                                context,
                                                'Error occured while logging in')),
                                          ),
                                        );
                                      }

                                      setState(() {
                                        _isLoading = false;
                                      });
                                    },
                              child: Text(
                                FlutterI18n.translate(context, 'login'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF604A4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            // Add a sign-up link
                            Visibility(
                              visible:
                                  _userTypes[_selectedUserType]['type'] == 'User',
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignupPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  '${FlutterI18n.translate(context, 'dontHaveAccount')} ',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: LanguageSelectionBottomBar(),
      ),
    );
  }
}
