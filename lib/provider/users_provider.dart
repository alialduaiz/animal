import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';



class ReportsProvider extends ChangeNotifier {
  Future<void> resendReport(BuildContext context, String reportId) async {
    bool confirmCancel = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(FlutterI18n.translate(context, 'Cancel Report')),
          content: Text(FlutterI18n.translate(context, 'Are you sure you want to resend this report?')),
          actions: <Widget>[
            TextButton(
              child: Text(FlutterI18n.translate(context, 'No')),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(FlutterI18n.translate(context, 'Yes')),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmCancel) {
      String apiUrl = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/resend_report/$reportId';

      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          // Report canceled successfully
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(FlutterI18n.translate(context, 'Success')),
                content: Text(FlutterI18n.translate(context, 'Report resent successfully.')),
                actions: <Widget>[
                  TextButton(
                    child: Text(FlutterI18n.translate(context, 'OK')),
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
                title: Text(FlutterI18n.translate(context, 'Error')),
                content: Text(FlutterI18n.translate(context, 'Failed to cancel the report. Please try again later.')),
                actions: <Widget>[
                  TextButton(
                    child: Text(FlutterI18n.translate(context, 'OK')),
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
              title: Text(FlutterI18n.translate(context, 'Error')),
              content: Text(FlutterI18n.translate(context, 'An error occurred while canceling the report. Please try again later.')),
              actions: <Widget>[
                TextButton(
                  child: Text(FlutterI18n.translate(context, 'OK')),
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

  Future<void> cancelReport(BuildContext context, String reportId) async {
    bool confirmCancel = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(FlutterI18n.translate(context, 'Cancel Report')),
          content: Text(FlutterI18n.translate(context, 'Are you sure you want to cancel this report?')),
          actions: <Widget>[
            TextButton(
              child: Text(FlutterI18n.translate(context, 'No')),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(FlutterI18n.translate(context, 'Yes')),
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
                title: Text(FlutterI18n.translate(context, 'Success')),
                content: Text(FlutterI18n.translate(context, 'Report canceled successfully.')),
                actions: <Widget>[
                  TextButton(
                    child: Text(FlutterI18n.translate(context, 'OK')),
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
                title: Text(FlutterI18n.translate(context, 'Error')),
                content: Text(FlutterI18n.translate(context, 'Failed to cancel the report. Please try again later.')),
                actions: <Widget>[
                  TextButton(
                    child: Text(FlutterI18n.translate(context, 'OK')),
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
              title: Text(FlutterI18n.translate(context, 'Error')),
              content: Text(FlutterI18n.translate(context, 'An error occurred while canceling the report. Please try again later.')),
              actions: <Widget>[
                TextButton(
                  child: Text(FlutterI18n.translate(context, 'OK')),
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
  List<Map<String, dynamic>> searchItems = [];
  List<Map<String, dynamic>> searchItemsFiltered = [];

  String selectedReportStatus = 'Report Status';
  String selectedVerificationStatus = 'Verification Status';
  String selectedIsCancellation = 'All';
  String selectedType = 'Type';
  void onSearchTextChanged(String text) {

    // Filter the items based on the search query and dropdown filters.
    searchItemsFiltered = searchItems.where((item) {
      // Modify the conditions below based on your search requirements.
      bool matchesSearchText =
          item['Title'].toLowerCase().contains(text.toLowerCase()) ||
              item['ID'].toString().contains(text);
      bool matchesReportStatus = selectedReportStatus == 'Report Status' ||
          item['ReportStatus'].toString() == selectedReportStatus;
      bool matchesVerificationStatus =
          selectedVerificationStatus == 'Verification Status' ||
              item['VerificationStatus'].toString() ==
                  selectedVerificationStatus;
      bool matchesIsCancellation = selectedIsCancellation == 'All' ||
          item['IsCancellation'].toString().toLowerCase() ==
              selectedIsCancellation.toLowerCase();
      bool matchesType =
          selectedType == 'Type' || item['Type'].toString() == selectedType;

      return matchesSearchText &&
          matchesReportStatus &&
          matchesVerificationStatus &&
          matchesIsCancellation &&
          matchesType;
    }).toList();
    notifyListeners();

  }
  Future<void> deleteUser(BuildContext context, String userID) async {
    final url = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/deleteuser';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'UserID': userID},
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Account deleted successfully'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Account not found'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to delete account'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
    notifyListeners();
  }

  Future<void> updateReport(String reportId, String title, double alt,
      double lag, String note, String type, String verificationStatus,
      String reportStatus) async {
    var url = Uri.parse(
        'https://your-api-url/reports/$reportId/'); // replace with your actual API URL

    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Title': title,
        'alt': alt.toString(),
        'lag': lag.toString(),
        'Note': note,
        'Type': type,
        'VerificationStatus': verificationStatus,
        'ReportStatus': reportStatus,
      }),
    );

    if (response.statusCode == 200) {
      print('Report updated successfully.');
    } else {
      throw Exception('Failed to update report.');
    }
  }

  Future<void> deleteReport(String reportId) async {
    var url = Uri.parse(
        'https://your-api-url/reports/$reportId/'); // replace with your actual API URL

    var response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Report deleted successfully.');
    } else {
      throw Exception('Failed to delete report.');
    }
  }
  Future<void> getReports() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final response = await http.get(Uri.parse(
        'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/report'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final searchI = json.decode(decodedBody) as List<dynamic>;
      print(searchI);

        searchItems = searchI
            .cast<Map<String, dynamic>>()
            .where((report) => (report['IsDeleted'].toString() == 'false' &&
            report['UserID'] == userId))
            .toList();




    } else {
      throw Exception('Failed to fetch');
    }
    notifyListeners();
  }

  void refreshData() {

      searchItems.clear();
      searchItemsFiltered.clear();
      selectedReportStatus = 'Report Status';
      selectedVerificationStatus = 'Verification Status';
      selectedIsCancellation = 'All';
      selectedType = 'Type';


    getReports();
      notifyListeners();

  }
}