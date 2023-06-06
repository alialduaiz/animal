import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled6/User/show_report.dart';
import 'package:untitled6/User/updrprt.dart';
import 'package:untitled6/globals.dart';

import '../EVS/show_report_ev.dart';
import '../language.dart';
import '../provider/reports_provider.dart' as prov;
import '../provider/users_provider.dart';

class MyReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MenuSearch();
  }
}

class MenuSearch extends StatefulWidget {
  const MenuSearch({Key? key}) : super(key: key);

  @override
  _MenuSearchState createState() => _MenuSearchState();
}

class _MenuSearchState extends State<MenuSearch> {
  bool flagfilters = false;
  List<Map<String, dynamic>> _searchItems = [];
  List<Map<String, dynamic>> _searchItemsFiltered = [];
  String _selectedReportStatus = 'Report Status';
  String _selectedVerificationStatus = 'Verification Status';
  String _selectedIsCancellation = 'All';
  String _selectedType = 'Type';

  Future<void> _getReports() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final response = await http.get(Uri.parse(
        'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/report'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final _searchI = json.decode(decodedBody) as List<dynamic>;
      print(_searchI);
      setState(() {
        _searchItems = _searchI
            .cast<Map<String, dynamic>>()
            .where((report) => (report['IsDeleted'].toString() == 'false' &&
            report['User_ID'] == userId))
            .toList();


      });
    } else {
      throw Exception('Failed to fetch');
    }
  }

  void _refreshData() {
    setState(() {
      _searchItems.clear();
      _searchItemsFiltered.clear();
      _selectedReportStatus = 'Report Status';
      _selectedVerificationStatus = 'Verification Status';
      _selectedIsCancellation = 'All';
      _selectedType = 'Type';
    });

    _getReports();
  }

  @override
  void initState() {
    _getReports().then((_) {
      _onSearchTextChanged('');
    });
    super.initState();
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      // Filter the items based on the search query and dropdown filters.
      _searchItemsFiltered = _searchItems.where((item) {
        // Modify the conditions below based on your search requirements.
        bool matchesSearchText =
            item['Title'].toLowerCase().contains(text.toLowerCase()) ||
                item['ID'].toString().contains(text);
        bool matchesReportStatus = _selectedReportStatus == 'Report Status' ||
            item['Report_Status'].toString() == _selectedReportStatus;
        bool matchesVerificationStatus =
            _selectedVerificationStatus == 'Verification Status' ||
                item['Verification_Status'].toString() ==
                    _selectedVerificationStatus;
        bool matchesIsCancellation = _selectedIsCancellation == 'All' ||
            item['IsCancellation'].toString().toLowerCase() ==
                _selectedIsCancellation.toLowerCase();
        bool matchesType =
            _selectedType == 'Type' || item['Type'].toString() == _selectedType;

        return matchesSearchText &&
            matchesReportStatus &&
            matchesVerificationStatus &&
            matchesIsCancellation &&
            matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    _onSearchTextChanged('');
    return Consumer<ReportsProvider>(
      builder: (context, value, child) =>

     Scaffold(
        appBar: AppBar(
          title: Text(
            FlutterI18n.translate(context, 'My reports'),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF087474),
        ),
        body: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (!flagfilters) {
                      flagfilters = true;
                    } else {
                      flagfilters = false;
                    }
                    _refreshData();
                  },
                  icon: Icon(!flagfilters
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_down_sharp),
                ),
              ],
            ),
            Visibility(
              visible: flagfilters,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    // First group of filters
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Filter Dropdown for Report_Status
                        DropdownButton<String>(
                          value: _selectedReportStatus,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedReportStatus = newValue!;
                              _onSearchTextChanged('');
                            });
                          },
                          items: <String>[
                            'Report Status',
                            'Dealt With',
                            'Not Dealt With'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(FlutterI18n.translate(context, value)),
                            );
                          }).toList(),
                        ),

                        // Filter Dropdown for Verification_Status
                        DropdownButton<String>(
                          value: _selectedVerificationStatus,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedVerificationStatus = newValue!;
                              _onSearchTextChanged('');
                            });
                          },
                          items: <String>[
                            'Verification Status',
                            'Not Confirmed',
                            'Confirmed',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(FlutterI18n.translate(context, value)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    // Second group of filters
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Filter Dropdown for IsCancellation
                        DropdownButton<String>(
                          value: _selectedIsCancellation,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedIsCancellation = newValue!;
                              _onSearchTextChanged('');
                            });
                          },
                          items: <String>['All', 'Cancelled']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value == 'All' ? value : 'True',
                              child: Text(FlutterI18n.translate(context, value)),
                            );
                          }).toList(),
                        ),

                        // Filter Dropdown for Type
                        DropdownButton<String>(
                          value: _selectedType,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedType = newValue!;
                              _onSearchTextChanged('');
                            });
                          },
                          items: <String>['Type', 'Non-Predator', 'Predator']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(FlutterI18n.translate(context, value)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: FlutterI18n.translate(context, 'Search'),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  _onSearchTextChanged(value);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                key: UniqueKey(),
                itemCount: _searchItemsFiltered.length,
                itemBuilder: (context, index) {
                  final report = _searchItemsFiltered[index];
                  late String addedDateString =
                      report?['Added_Date'].toString() ?? 'loading';

// If the 'Added_Date' isn't loaded yet, don't try to parse it
                  late String formattedDate = addedDateString == 'loading'
                      ? 'loading'
                      : intl.DateFormat.yMMMd()
                      .format(DateTime.parse(addedDateString));

                  return ListTile(
                    leading: ClipOval(
                      child: CircleAvatar(
                        radius: 40.0,
                        child: ClipOval(
                          child: Image(
                            image: report['IsCancellation']
                                ? AssetImage('assets/cancelled.png')
                                : report['Verification_Status'] == "Not Confirmed"
                                ? AssetImage('assets/notconfired.png')
                                : report['Verification_Status'] == "Confirmed"
                                ? AssetImage('assets/confired.png')
                                : AssetImage('assets/cancelled.png'),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            fit: BoxFit.contain,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    title: Text(
                      report['Title'],
                      style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${FlutterI18n.translate(context, 'ID')}: ${report['ID'].hashCode.toString()}"),
                        Text(
                            "${FlutterI18n.translate(context, 'Created on')}: $formattedDate"),
                      ],
                    ),
                    onTap: () {
                      print(
                          'IsCancellation:${report['IsCancellation'].toString()}');
                      // TODO: Implement onTap
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            print('id is ${report['ID']}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewReport(reportid: report['ID']),
                              ),
                            );
                            // TODO: Implement onTap
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.remove_red_eye,
                                color: Color(0xFF1B54D9),
                              ),
                              Text(
                                FlutterI18n.translate(context, 'View'),
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),

                        !report['IsCancellation']
                            ?report['Verification_Status'] == "Confirmed"?SizedBox(): InkWell(
                          onTap: () {
                            prov.cancelReport(context, report['ID']);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel,
                                color: Color(0xFFFB2D2D),
                              ),
                              Text(
                                FlutterI18n.translate(context, 'Cancel'),
                                style: TextStyle(
                                  color: Color(0xFFFB2D2D),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        )
                            : InkWell(
                          onTap: () {
                            prov.resendReport(context, report['ID']);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh,
                                color: Colors.yellow,
                              ),
                              Text(
                                FlutterI18n.translate(context, 'Resend'),
                                style: TextStyle(
                                  color: Colors.yellow,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UpdateReport(reportId: report['ID']),
                              ),
                            );
                            // TODO: Implement onTap
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Color(0xFF27CE9C),
                              ),
                              Text(
                                FlutterI18n.translate(context, 'Edit'),
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFF27CE9C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: LanguageSelectionBottomBar(),
      ),
    );
  }
}
