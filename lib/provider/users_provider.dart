import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
Future<void> deleteUser(BuildContext context, String userID) async {
  final url = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/delete_user';

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {'User_ID': userID},
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
}
Future<void> updateReport(String reportId, String title, double alt, double lag, String note, String type, String verificationStatus, String reportStatus) async {
  var url = Uri.parse('https://your-api-url/reports/$reportId/');  // replace with your actual API URL

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
      'Verification_Status': verificationStatus,
      'Report_Status': reportStatus,
    }),
  );

  if (response.statusCode == 200) {
    print('Report updated successfully.');
  } else {
    throw Exception('Failed to update report.');
  }
}
Future<void> deleteReport(String reportId) async {
  var url = Uri.parse('https://your-api-url/reports/$reportId/');  // replace with your actual API URL

  var response = await http.delete(url);

  if (response.statusCode == 200) {
    print('Report deleted successfully.');
  } else {
    throw Exception('Failed to delete report.');
  }
}
