import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' as intl;
import '../globals.dart';
import '../imports_all.dart';
import '../language.dart';
class ViewReport extends StatefulWidget {
  final String reportid;

  const ViewReport({required this.reportid});

  @override
  State<ViewReport> createState() => _ViewReportState();
}

class _ViewReportState extends State<ViewReport> {
  Map<String, dynamic>? _reportdetails;

String _verificationStatus = '';
String _reportStatus = '';
  late String addedDateString = _reportdetails?['Added_Date'].toString() ?? 'loading';

// If the 'Added_Date' isn't loaded yet, don't try to parse it
  late String formattedDate = addedDateString == 'loading'
      ? 'loading'
      : intl.DateFormat.yMMMd().format(DateTime.parse(addedDateString));
  final List<String> verificationStatusOptions = [
    'Not Confirmed',
    'Confirmed',
    'Rejected',
  ];

  final List<String> reportStatusOptions = [
    'Dealt With',
    'Not Dealt With',
  ];
  Widget buildVerificationStatus() {
    return  Container(
      width: MediaQuery.of(context).size.width*0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(height: 8.0),
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
            children: verificationStatusOptions.map((status) {
              final isSelected = _verificationStatus == status;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _verificationStatus = status;
                  });
                  updateVerificationStatus(widget.reportid, status);
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
                    borderRadius: status =='Not Confirmed'? BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ):status =='Rejected'?BorderRadius.only(
                      bottomRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ):BorderRadius.only(

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

  Widget buildReportStatus() {
    return Container(
      width: MediaQuery.of(context).size.width*0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.0),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              FlutterI18n.translate(context, 'Report Status'),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Column(
            children: reportStatusOptions.map((status) {
              final isSelected = _reportStatus == status;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _reportStatus = status;
                  });
                  updateReportStatus(widget.reportid, status);
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

  Future<void> updateReportStatus(String reportId, String newReportStatus) async {
    final apiUrl = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/api/report/$reportId/status/';

    final response = await http.put(
      Uri.parse(apiUrl),
      body: jsonEncode({'report_status': newReportStatus}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Report status updated successfully');
    } else {
      print('Failed to update report status. Error: ${response.body}');
    }
  }

  Future<void> updateVerificationStatus(String reportId, String newVerificationStatus) async {
    final apiUrl = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/api/report/$reportId/verification/';

    final response = await http.put(
      Uri.parse(apiUrl),
      body: jsonEncode({'verification_status': newVerificationStatus}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Verification status updated successfully');
    } else {
      print('Failed to update verification status. Error: ${response.body}');
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

      String apiUrl = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/cancel_report/$reportId';

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

  Future<void> _getReports() async {
    final response = await http.get(Uri.parse(
        'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/report'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final _fetchedReports = jsonDecode(decodedBody) as List<dynamic>;
      final _filteredReport = _fetchedReports
          .cast<Map<String, dynamic>>()
          .firstWhere((report) => report['ID'] == widget.reportid, orElse: () => {});

// Print the user details for debugging
      print('Report details: $_filteredReport');

      setState(() {
        _reportdetails = _filteredReport.isNotEmpty ? _filteredReport : null;
        _verificationStatus = _reportdetails!['Verification_Status'];
        _reportStatus = _reportdetails!['Report_Status'];
      });
    } else {
      throw Exception('Failed to fetch Reports');
    }
  }

  @override
  void initState() {
    super.initState();
    _getReports();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF087474),
          title: Text('View report'),
          centerTitle: true,
          actions: [
             IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                List<OptionMenuItem> menuItems = [
                  OptionMenuItem(
                    title: 'Message the Reporter',
                    onTap: () {
                      cancelReport(context, _reportdetails!['ID']);

                    },
                    textColor: Colors.blue,
                  ),
                  OptionMenuItem(
                    title: 'Cancel Report',
                    onTap: () {
                       cancelReport(context, _reportdetails!['ID']);

                    },
                    textColor: Colors.blue,
                  ),

                  if ( _reportdetails != null &&(_reportdetails!['Type'] == 'Non-Predator' ) ) OptionMenuItem(
                    title: 'Adopt',
                    onTap: () {
                      cancelReport(context, _reportdetails!['ID']);

                    },
                    textColor: Colors.blue,
                  ),

                  OptionMenuItem(
                    title: 'Cancel',
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
        body: _reportdetails == null
            ? Center(
          child: CircularProgressIndicator(),
        ):SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
                child: Row(
                  children: [
                    ReportImage(urlimage: '$GServer${_reportdetails!=null ? _reportdetails!['image'] ?? CircularProgressIndicator() : CircularProgressIndicator()}'),
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Title:',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _reportdetails!=null ? _reportdetails!['Title'] ?? 'loading' : 'loading',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ColumnItem(
                textDirection: Directionality.of(context),
                label: FlutterI18n.translate(context, 'ID')!,
                value: _reportdetails?['ID']?.toString().hashCode.toString() ?? '${FlutterI18n.translate(context,'loading' )}',
              ),
              ColumnItem(
                textDirection: Directionality.of(context),
                label: FlutterI18n.translate(context, 'Note')!,
                value: '${_reportdetails!['Note']}',
              ),

              ColumnItem(
                textDirection: Directionality.of(context),
                label: FlutterI18n.translate(context, 'Type')!,
                value:'${FlutterI18n.translate(context, _reportdetails?['Type'] ?? 'loading' )}',
              ),

              Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(width: 1, color: Colors.black),
              ),
              child: InkWell(
                  onTap: () {

                    if (_reportdetails != null) {
                      double latitude = _reportdetails!['alt'] != null ? double.parse(_reportdetails!['alt']!.toString()) : 0.0;
                      double longitude = _reportdetails!['lag'] != null ? double.parse(_reportdetails!['lag']!.toString()) : 0.0;
                      String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                      if (Platform.isIOS) {
                        // For iOS, use the Maps app
                        canLaunch(googleMapsUrl).then((value) {
                          if (value) {
                            launch(googleMapsUrl);
                          } else {
                            print('Could not launch Google Maps');
                          }
                        });
                      } else {
                        // For Android, use the Google Maps app or open in a browser
                        launch(googleMapsUrl);
                      }
                    }
                  },
                  child: _reportdetails != null
                      ? Expanded(
                    child: ShowLocations(
                      latitude: _reportdetails!['alt'] != null ? double.parse(_reportdetails!['alt']!.toString()) : 0.0,
                      longitude: _reportdetails!['lag'] != null ? double.parse(_reportdetails!['lag']!.toString()) : 0.0,
                      containerHeight: MediaQuery.of(context).size.height * 0.4,
                      containerWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                  )
                      : CircularProgressIndicator(),
                ),
            ),



             buildVerificationStatus(),
             buildReportStatus(),
              // ...
              ColumnItem(
                textDirection: Directionality.of(context),
                label: FlutterI18n.translate(context, 'Added_Date'),
                value: FlutterI18n.translate(context,formattedDate?? 'loading' ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: LanguageSelectionBottomBar(),
      ),
    );
  }
}

class ReportImage extends StatelessWidget {
  final String urlimage;
  ReportImage({required this.urlimage});

  @override
  Widget build(BuildContext context) {
    return urlimage != 'null'
        ? Container(
      height: 70,
      width: 70,
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
          imageUrl: urlimage,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(
            Icons.image,
            size: 70, // Set the desired size
          ),
        ),
      ),
    )
        : Icon(
      Icons.image,
      size: 70, // Set the desired size
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
      child: Center(
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
                    color: Colors.black26,
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
                  style: TextStyle(fontSize: 16.0
                  ,color: Color(0xFF0ED5A0),
                  ),

                ),
              ),
            ),
          ],
        ),
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
      children:

      [
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
                'Option Menu',
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

class ShowLocations extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final double containerHeight;
  final double containerWidth;

  ShowLocations({
    required this.latitude,
    required this.longitude,
    required this.containerHeight,
    required this.containerWidth,
  });

  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  Future<void> _centerView() async {
    final GoogleMapController controller = await _controller.future;
    if (latitude != null && longitude != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude!, longitude!),
            zoom: 16,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerHeight,
      width: containerWidth,
      child: GoogleMap(
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _centerView();
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude ?? 0.0, longitude ?? 0.0),
          zoom: 16,
        ),
        markers: latitude != null && longitude != null
            ? Set<Marker>.of([
          Marker(
            markerId: MarkerId('locationMarker'),
            position: LatLng(latitude!, longitude!),
          ),
        ])
            : Set<Marker>(),
      ),
    );
  }
}
