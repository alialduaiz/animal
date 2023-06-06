
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../globals.dart';
import '../language.dart';

Country _selectedCountry = CountryPickerUtils.getCountryByIsoCode('US');
String? _selectedGender = 'Male';
class AddAccountPage extends StatefulWidget {
  const AddAccountPage({Key? key}) : super(key: key);

  @override
  _AddAccountPageState createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordMatch = true;
  TextEditingController _fullNameController  = TextEditingController();
  TextEditingController _emailController  = TextEditingController();
  TextEditingController _passwordController  = TextEditingController();
  TextEditingController _confirmPasswordController  = TextEditingController();
  TextEditingController _nationalIDController  = TextEditingController();
  TextEditingController _phoneController  = TextEditingController();
  TextEditingController _genderController  = TextEditingController();
  TextEditingController _nationalityController  = TextEditingController();

  String _AccStatusController = '';
  String _TypeController = '';


  FocusNode _fullNameNode = FocusNode();
  FocusNode _emailNode = FocusNode();
  FocusNode _passwordNode = FocusNode();
  FocusNode _ConfirmPasswordNode = FocusNode();
  FocusNode _NationalIDNode = FocusNode();
  FocusNode _genderNode = FocusNode();
  FocusNode _nationanlityNode = FocusNode();
  DateTime? _selectedDate;
  final List<String> TypeOptions = [
    'Admin',
    'User',
    'EVSecurity',
  ];
  final List<String> AccStatusOptions = [
    'Active',
    'Inactive',
  ];
  Widget buildType() {
    return  Container(
      width: MediaQuery.of(context).size.width*0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(height: 8.0),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              FlutterI18n.translate(context, 'Type_ِAccount'),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Column(
            children: TypeOptions.map((status) {
              final isSelected = _TypeController == status;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _TypeController = status;
                  });

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
                    borderRadius: status =='Admin'? BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ):status =='EVSecurity'?BorderRadius.only(
                      bottomRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ):BorderRadius.only(

                    ),
                  ),
                  height: 50,
                  child: Text(
                    FlutterI18n.translate(context, status),
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
  Widget buildAccStatus() {
    return Container(
      width: MediaQuery.of(context).size.width*0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.0),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              FlutterI18n.translate(context,'Account Status'),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Column(
            children: AccStatusOptions.map((status) {
              final isSelected = _AccStatusController == status;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _AccStatusController = status;
                  });

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
                    borderRadius: status =='Active'? BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ):BorderRadius.only(
                      bottomRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  height: 50,
                  child: Text(
                    FlutterI18n.translate(context, status),
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
  Future<bool> AddAccountUser() async {

    try {

      final response = await http.post(
          Uri.parse('$GServer/register'),
          body: {
            "Name": _fullNameController.text,
            "Email": _emailController.text,
            "Password": _passwordController.text,
            "National_ID": _nationalIDController.text,
            "Phone": _phoneController.text,
            "Account_Type": _TypeController,
            "Age": _calculateAge(_selectedDate).toString(),
            "Nationality": _selectedCountry.name.toString(), // Updated
            "Gender": _selectedGender.toString(), // Updated
            "Account_Status":_AccStatusController
          });

      print('response is :');
      print(response);
      if (response.statusCode == 201) {

        print('User registered successfully');

        // Navigate to another screen or show a success message
        return true;
      } else {
        print('Failed to register user');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(FlutterI18n.translate(context, 'Notification')),
                content: Text( FlutterI18n.translate(context, "These data are wrong email or National ID or phone number heave been already registered")

                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(FlutterI18n.translate(context, 'Close')),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }

        );
        // Show an error message
        return false;
      }
    } catch (e) {
      print('Error: $e');

      // Handle the exception
      return false;
    }
  }


  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return 0;
    }

    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (birthDate.month > currentDate.month || (birthDate.month == currentDate.month && birthDate.day > currentDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF087474),
        title: Text(
    FlutterI18n.translate(context, 'Add Account'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FlutterI18n.translate(context, 'Create Account') ,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28.0,
                              ),

                            ),
                            const SizedBox(height: 20.0),


                            TextFormField(
                              focusNode: _fullNameNode,

                              controller: _fullNameController,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                hintText: FlutterI18n.translate(context, 'Full Name'),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                prefixIcon: Icon(Icons.abc),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return FlutterI18n.translate(context, 'Please enter your full name');
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                hintText: FlutterI18n.translate(context, 'Email Address'),
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return FlutterI18n.translate(context, 'Please enter your email address');
                                } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return FlutterI18n.translate(context, 'Please enter a valid email address');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: FlutterI18n.translate(context, 'Password'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return FlutterI18n.translate(context,'Please enter your password');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                hintText: FlutterI18n.translate(context, 'Confirm Password'),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _passwordMatch = value == _passwordController.text;
                                });
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return FlutterI18n.translate(context,'Please confirm your password');
                                } else if (!_passwordMatch) {
                                  return FlutterI18n.translate(context,'Passwords do not match');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _nationalIDController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                hintText: FlutterI18n.translate(context, 'National ID'),

                                prefixIcon: Icon(Icons.person_pin_outlined),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex:5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              border: Border.all( width: 1 , color:  Color(0xFF087474))
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: CountryPickerDropdown(
                                              initialValue: _selectedCountry.isoCode,
                                              itemBuilder: _buildDropdownItem,
                                              onValuePicked: (Country country) {
                                                setState(() {
                                                  _selectedCountry = country;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex:5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              border: Border.all( width: 1 , color:  Color(0xFF087474))
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: DropdownButton<String>(
                                              underline: SizedBox(),
                                              value: _selectedGender,
                                              onChanged: (String ? newValue) {
                                                setState(() {
                                                  _selectedGender = newValue;
                                                });
                                              },
                                              items: <String>['Male', 'Female']
                                                  .map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(FlutterI18n.translate(context,value)),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return FlutterI18n.translate(context, 'Please enter your phone number');
                                } else if (!value.startsWith("05")) {
                                  return FlutterI18n.translate(context, 'Phone number should start with 05');
                                } else if (value.length != 10) {
                                  return FlutterI18n.translate(context, 'Phone number should be 10 digits');
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                hintText: FlutterI18n.translate(context, 'add your phone number(0530458777)'),
                                prefixIcon: Icon(Icons.phone),
                              ),
                            ),
                            buildAccStatus(),
                            buildType(),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: _selectedDate == null
                                    ? ''
                                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',

                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                hintText: FlutterI18n.translate(context, 'Birthdate'),
                                prefixIcon: Icon(Icons.calendar_today),
                                suffixIcon: Icon(Icons.arrow_drop_down),
                              ),
                              onTap: () => _selectDate(context),
                              validator: (value) {
                                if (_selectedDate == null) {
                                  return FlutterI18n.translate(context, 'Please select your birthdate');
                                } else if (_calculateAge(_selectedDate) < 14) {
                                  return FlutterI18n.translate(context, 'You should be older than 14 to sign up');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30.0),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate() && _selectedDate != null) {
                                  if (_calculateAge(_selectedDate) < 14) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(FlutterI18n.translate(context, 'Error')),
                                          content: Text(FlutterI18n.translate(context, 'You should be older than 14 to sign up')),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text(FlutterI18n.translate(context, 'Close')),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {

                                    bool flag= await AddAccountUser();
                                    if(flag){
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(FlutterI18n.translate(context, 'Notification')),
                                              content: Text(FlutterI18n.translate(context, 'Successful Sign up')),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(FlutterI18n.translate(context, 'Close')),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          }

                                      );
                                    }
                                    else{
                                      AlertDialog(
                                        title: Text(FlutterI18n.translate(context, 'Error')),
                                        content: Text(FlutterI18n.translate(context, 'AddAccount failed plesue make sure of your info or try again later')),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(FlutterI18n.translate(context, 'Close')),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(FlutterI18n.translate(context, 'Error')),
                                        content: Text(FlutterI18n.translate(context, 'Please complete all fields correctly.')),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(FlutterI18n.translate(context, 'Close')),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Text(
                                FlutterI18n.translate(context, 'Add Account'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF087474),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50.0,
                                  vertical: 20.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ),
                  )
              );
            },
          )
      ),
    bottomNavigationBar: LanguageSelectionBottomBar(),
    );
  }
}
Widget _buildDropdownItem(Country country) {
  return Row(
    children: [
      CountryPickerUtils.getDefaultFlagImage(country),
      SizedBox(width: 8.0),
      Text("${country.isoCode}",),
    ],
  );
}