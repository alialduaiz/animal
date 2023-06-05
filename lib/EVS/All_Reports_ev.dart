import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:untitled6/EVS/show_report_ev.dart';
import 'dart:ui' as UI;
import '../globals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/scheduler.dart';

import '../language.dart';

const String urll = GServer;

class AllReports extends StatelessWidget {
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

class _MenuSearchState extends State<MenuSearch> with RouteAware {
bool flagfilters = false;
  List<Map<String, dynamic>> _searchItems = [];
  List<Map<String, dynamic>> _searchItemsFiltered = [];


  String _selectedReportStatus = 'Report Status';
  String _selectedVerificationStatus = 'Verification Status';
  String _selectedIsCancellation = 'All';
  String _selectedType = 'Type';
  Future<void> _getReports() async {
   // final response = await http.get(Uri.parse('$urll/report'));
    final response = await http.get(Uri.parse('http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/report'));
    //final response = await http.get(Uri.parse('http://192.168.43.134:8000/report'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final _searchI = json.decode(decodedBody) as List<dynamic>;
      print(_searchI);
      setState(() {
        _searchItems = _searchI.cast<Map<String, dynamic>>().where((report) => report['IsDeleted'] == false).toList();
        _searchItemsFiltered = List<Map<String, dynamic>>.from(_searchItems);
      });
    } else {
      throw Exception('Failed to fetch');
    }
  }

  Future<void> deleteRejectedReports() async {
    for (var report in _searchItemsFiltered) {
      if (report['Verification_Status'] == 'Rejected') {
        print('found rejetedone');
        final response = await http.get(
            Uri.parse('http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/delete_report/${report['ID']}'));
        if (response.statusCode != 200) {
          print('response is');
          print(response);
          // Handle the error here

      }
        else {
          print('report delete  is');
          print(report['IsDeleted']);
          print(report['Title']);
          print("\n\n");

        }
      }
    }
    Future<void> cancelReport(BuildContext context, String reportId) async {
      bool confirmCancel = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cancel Report'),
            content: Text('Are you sure you want to cancel this report?'),
            actions: <Widget>[
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirmCancel) {

        String apiUrl = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/delete_report/$reportId';

        try {
          final response = await http.get(Uri.parse(apiUrl));
          if (response.statusCode == 200) {
            // Report canceled successfully
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Success'),
                  content: Text('Report canceled successfully.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();

                      },
                    ),
                  ],
                );
              },
            );
          } else {
            // Failed to cancel report
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text('Failed to cancel the report. Please try again later.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
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
          // Request failed
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('An error occurred while canceling the report. Please try again later.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }

    // Refresh the reports after deletion
    await _getReports();
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(FlutterI18n.translate(context, 'Delete all Rejected Reports?'), style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await deleteRejectedReports();
                  Navigator.pop(context);
                },
                child: Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _getReports().then((_) {
        _onSearchTextChanged('');
      });
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies called');
    Future.delayed(Duration.zero, () {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    });
  }

  @override
  void didPopNext() {
    super.didPopNext();
    print('didPopNext called');
    _getReports().then((_) {
      _onSearchTextChanged('');
    });
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
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }



  void _onSearchTextChanged(String text) {
    setState(() {

        // Filter the items based on the search query and dropdown filters.
        _searchItemsFiltered = _searchItems.where((item) {
          // Modify the conditions below based on your search requirements.
          bool matchesSearchText = item['Title'].toLowerCase().contains(text.toLowerCase()) || item['ID'].toString().contains(text);
          bool matchesReportStatus = _selectedReportStatus == 'Report Status' || item['Report_Status'].toString() == _selectedReportStatus;
          bool matchesVerificationStatus = _selectedVerificationStatus == 'Verification Status' || item['Verification_Status'].toString() == _selectedVerificationStatus;
          bool matchesIsCancellation = _selectedIsCancellation == 'All' || item['IsCancellation'].toString().toLowerCase() == _selectedIsCancellation.toLowerCase();
          bool matchesType = _selectedType == 'Type' || item['Type'].toString() == _selectedType;

          return matchesSearchText && matchesReportStatus && matchesVerificationStatus && matchesIsCancellation && matchesType;
        }).toList();

    });
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child: Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context,'All Reports')),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _refreshData();

              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {

                  List<OptionMenuItem> menuItems = [

                    OptionMenuItem(
                      title: FlutterI18n.translate(context, 'Delete all Rejected Reports?'),
                      onTap: () {
                        _showDeleteConfirmationDialog(context);
                        // Handle Delete Account
                      },
                      textColor: Colors.red,
                    ),
                    OptionMenuItem(
                      title: FlutterI18n.translate(context, 'Cancel'),
                      onTap: () {
                        Navigator.pop(context); // Handle Cancel
                      },
                      textColor: Colors.blueGrey,
                    ),
                  ];

                  showOptionMenuSheet(context, menuItems);
                },

            ),
          ],
          centerTitle: true,
          backgroundColor: Color(0xFF087474),


        ),
        body: Column(
          children: [
            Row(
              children: [
                IconButton(

                 onPressed: () {
                   if(!flagfilters) {flagfilters=true;}
                   else {flagfilters=false;}
                   _refreshData();

                },
                  icon: Icon(!flagfilters?
                      Icons.keyboard_arrow_right
                      :Icons.keyboard_arrow_down_sharp
                  ),

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
                          items: <String>['Report Status', 'Dealt With', 'Not Dealt With']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(FlutterI18n.translate(context,value)),
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
                          items: <String>['Verification Status', 'Not Confirmed', 'Confirmed', 'Rejected']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(FlutterI18n.translate(context,value)),
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
                              value: value == 'All' ? value :'True',
                              child: Text(FlutterI18n.translate(context,value)),
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
                              child: Text(FlutterI18n.translate(context,value)),
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
      itemCount: _searchItemsFiltered.length,
      itemBuilder: (context, index) {
      final report = _searchItemsFiltered[index];
      return ListTile(
        leading: report['image'] != null && report['image'].isNotEmpty
            ? Container(
          height: MediaQuery.of(context).size.width*0.2,
          width: MediaQuery.of(context).size.width*0.2,
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
            child: CachedNetworkImage(
              imageUrl: '$urll${report['image']}',
                height: MediaQuery.of(context).size.width*0.15,
              width: MediaQuery.of(context).size.width*0.15,
              fit: BoxFit.cover,
              placeholder: (context, urll) =>
                  CircularProgressIndicator(),
              errorWidget: (context, urll, error) => Icon(
                Icons.image,
                size:MediaQuery.of(context).size.width*0.3, // Set the desired size
              ),
            ),
          ),
        )
            : Icon(
          Icons.image,
          size: 70, // Set the desired size
        ),
        title: Text(
            '${report['Title']}',
          style: GoogleFonts.amiri(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),

      ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${FlutterI18n.translate(context,'Created on')}: ${report['Added_Date']}"),
          ],
        ),
        onTap: () {

        },

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(

                    builder: (context) => ViewReport(reportid: report['ID']),
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
                    FlutterI18n.translate(context,'view'),
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
                FlutterI18n.translate(context, 'Option Menu')!,
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