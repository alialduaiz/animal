import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

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
