import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';
import '../language.dart';

Country _selectedCountry = CountryPickerUtils.getCountryByIsoCode('US');
String? _selectedGender = 'Male';

class Edit_User extends StatefulWidget {
    const Edit_User({Key? key}) : super(key: key);

    @override
    _Edit_UserState createState() => _Edit_UserState();
}

class _Edit_UserState extends State<Edit_User> {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    Map<String, dynamic>? filteredUser;
    bool _passwordMatch = true;
    TextEditingController _fullNameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();
    TextEditingController _nationalIDController = TextEditingController();
    TextEditingController _phoneController = TextEditingController();
    TextEditingController _genderController = TextEditingController();
    TextEditingController _nationalityController = TextEditingController();

    FocusNode _fullNameNode = FocusNode();
    FocusNode _emailNode = FocusNode();
    FocusNode _passwordNode = FocusNode();
    FocusNode _ConfirmPasswordNode = FocusNode();
    FocusNode _NationalIDNode = FocusNode();
    FocusNode _genderNode = FocusNode();
    FocusNode _nationanlityNode = FocusNode();
    DateTime? _selectedDate;

    Future<bool> updateUser() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? userId = prefs.getString('userId');
        print('_confirmPasswordController.text:${_confirmPasswordController.text} and \n _passwordController.text=${_passwordController.text}');
        print(_confirmPasswordController.text== _passwordController.text);
        print  (' _passwordController${_passwordController.text.isNotEmpty.toString()}');
        try {
            final response = await http.post(
                Uri.parse('$GServer/update_user'),
                body: {
                    "User_ID": userId!, // Pass the user ID obtained from SharedPreferences
                    "Name": _fullNameController.text,
                    "Email": _emailController.text,
                    "Phone": _phoneController.text,
                    "National_ID": _nationalIDController.text,

                    "Age": _calculateAge(_selectedDate).toString(),
                 "Password": _passwordController,
                },


            );

            if (response.statusCode == 200) {
                print('Account updated successfully');
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text(FlutterI18n.translate(context,'Notification')),
                            content: Text(FlutterI18n.translate(context,"Account updated successfully")),
                            actions: <Widget>[
                                TextButton(
                                    child: Text(FlutterI18n.translate(context,"Close")),
                                    onPressed: () {
                                        Navigator.of(context).pop();
                                    },
                                ),
                            ],
                        );
                    },
                );
                return true;
            } else {
                print('Failed to update account');
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text(FlutterI18n.translate(context,'Notification')),
                            content: Text(FlutterI18n.translate(context,"Failed to update account")),
                            actions: <Widget>[
                                TextButton(
                                    child: Text(FlutterI18n.translate(context,"Close")),
                                    onPressed: () {
                                        Navigator.of(context).pop();
                                    },
                                ),
                            ],
                        );
                    },
                );
                return false;
            }
        } catch (e, stacktrace) {
            print('Error: $e');
            print('Stacktrace: $stacktrace');

            // Handle the exception
            showDialog(
                context: context,
                builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text(FlutterI18n.translate(context,'Notification')),
                        content: Text(FlutterI18n.translate(context,"An error occurred while updating the account")),
                        actions: <Widget>[
                            TextButton(
                                child: Text(FlutterI18n.translate(context,"Close")),
                                onPressed: () {
                                    Navigator.of(context).pop();
                                },
                            ),
                        ],
                    );
                },
            );
            return false;
        }
    }


    int _calculateAge(DateTime? birthDate) {
        if (birthDate == null) {
            return 0;
        }

        final currentDate = DateTime.now();
        int age = currentDate.year - birthDate.year;
        if (birthDate.month > currentDate.month ||
            (birthDate.month == currentDate.month && birthDate.day > currentDate.day)) {
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

    Future<bool?> showConfirmationDialog(BuildContext context) async {
        return showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text(FlutterI18n.translate(context, "Confirmation")),
                    content: Text(FlutterI18n.translate(context, "Are you sure you want to save the changes?")),
                    actions: <Widget>[
                        TextButton(
                            child: Text(FlutterI18n.translate(context, "Yes")),
                            onPressed: () {
                                Navigator.of(context).pop(true); // Return true to indicate confirmation
                            },
                        ),
                        TextButton(
                            child: Text(FlutterI18n.translate(context, "No")),
                            onPressed: () {
                                Navigator.of(context).pop(false); // Return false to indicate cancellation
                            },
                        ),
                    ],
                );
            },
        );
    }

    @override
    void initState() {
        super.initState();
        getUserInfo();
    }

    void getUserInfo() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? userId = prefs.getString('userId');

        try {
            final response = await http.get(Uri.parse('$GServer/users'));

            if (response.statusCode == 200) {
                final decodedBody = utf8.decode(response.bodyBytes);
                final fetchedUsers = jsonDecode(decodedBody) as List<dynamic>;
                 filteredUser = fetchedUsers.cast<Map<String, dynamic>>().firstWhere(
                        (user) => user['ID'] == userId,
                    orElse: () => {},
                );

                setState(() {
                    _fullNameController.text = filteredUser!['Name'];
                    _emailController.text = filteredUser!['Email'];
                    _phoneController.text = filteredUser!['Phone'];
                    _nationalIDController.text = filteredUser!['National_ID'];


                    int age = filteredUser!['Age'] as int;
                    final currentDate = DateTime.now();
                    final birthDate = DateTime(currentDate.year - age, currentDate.month, currentDate.day);
                    _selectedDate=birthDate;

                });
            } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text(FlutterI18n.translate(context, "Notification")),
                            content: Text(FlutterI18n.translate(context, "Failed to retrieve user information")),
                            actions: <Widget>[
                                TextButton(
                                    child: Text(FlutterI18n.translate(context, "Close")),
                                    onPressed: () {
                                        Navigator.of(context).pop();
                                    },
                                ),
                            ],
                        );
                    },
                );

            }
        } catch (e) {
            print('Error: $e');
            showDialog(
                context: context,
                builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text(FlutterI18n.translate(context, "Notification")),
                        content: Text(FlutterI18n.translate(context, "An error occurred while fetching user information")),
                        actions: <Widget>[
                            TextButton(
                                child: Text(FlutterI18n.translate(context, "Close")),
                                onPressed: () {
                                    Navigator.of(context).pop();
                                },
                            ),                        ],
                    );
                },
            );
        }
    }


    void _saveChanges() async {
        final confirmed = await showConfirmationDialog(context);

        if (confirmed != null && confirmed) {
            final success = await updateUser();

            if (success) {
                // Handle success, such as navigating to another screen or showing a success message
            } else {
                // Handle failure, such as showing an error message
            }
        } else {
            // Handle cancellation
        }
    }


        // Add the save button in your form


@override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                backgroundColor: Color(0xFF087474),
                title: Text(
                    FlutterI18n.translate(context,'edit_account'),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                    ),
                ),
                centerTitle: true,
            ),
            body:  filteredUser == null
                ? Center(
                child: CircularProgressIndicator(),
            ):SafeArea(
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
                                                    FlutterI18n.translate(context,'edit_account'),
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
                                                        hintText: FlutterI18n.translate(context,'Full Name'),

                                                        border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                        prefixIcon: Icon(Icons.abc),
                                                    ),
                                                    validator: (value) {
                                                        if (value!.isEmpty) {
                                                            return FlutterI18n.translate(context,'Please enter your full name');
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
                                                        hintText: FlutterI18n.translate(context,'Email Address'),
                                                        prefixIcon: Icon(Icons.email),
                                                    ),
                                                    validator: (value) {
                                                        if (value!.isEmpty) {
                                                            return FlutterI18n.translate(context,'Please enter your email address');
                                                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                                            return FlutterI18n.translate(context,'Please enter a valid email address');
                                                        }
                                                        return null;
                                                    },
                                                ),
                                                const SizedBox(height: 20.0),
                                                TextFormField(
                                                    controller: _passwordController,
                                                    obscureText: true,
                                                    decoration: InputDecoration(
                                                        hintText: FlutterI18n.translate(context,'Password'),
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
                                                        hintText: FlutterI18n.translate(context,'Confirm Password'),
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
                                                        hintText: FlutterI18n.translate(context,'National ID'),

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
                                                                                            child: Text(value),
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
                                                            return 'Please enter your phone number';
                                                        } else if (!value.startsWith("05")) {
                                                            return 'Phone number should start with 05';
                                                        } else if (value.length != 10) {
                                                            return 'Phone number should be 10 digits';
                                                        }
                                                        return null;
                                                    },
                                                    decoration: InputDecoration(
                                                        border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                        hintText: 'add your phone number(0530458777)',
                                                        prefixIcon: Icon(Icons.phone),
                                                    ),
                                                ),

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
                                                        hintText: 'Birthdate',
                                                        prefixIcon: Icon(Icons.calendar_today),
                                                        suffixIcon: Icon(Icons.arrow_drop_down),
                                                    ),
                                                    onTap: () => _selectDate(context),
                                                    validator: (value) {
                                                        if (_selectedDate == null) {
                                                            return 'Please select your birthdate';
                                                        } else if (_calculateAge(_selectedDate) < 14) {
                                                            return 'You should be older than 14 to sign up';
                                                        }
                                                        return null;
                                                    },
                                                ),
                                                const SizedBox(height: 30.0),
                                        ElevatedButton(
                                            onPressed: _saveChanges,
                                            child: Text('Save'),
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