import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';




String color_value='0xFF01A45D';

class IconWithText extends StatelessWidget {
  final IconData icon;
  final String text;

  IconWithText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon),
        SizedBox(height: 4.0),
        Text(text),
      ],
    );
  }
}
Future<bool> checkInternetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}
class RowItem extends StatelessWidget {
  final String label;
  final String value;

  RowItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
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
                ),
              ),
            ),
          ),
          SizedBox(width: 40.0),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                value,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class ColumnItem extends StatelessWidget {
  final String label;
  final String? value;
  final EdgeInsets padding;
  final MainAxisAlignment columnMainAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;
  final TextDirection textDirection;
  final double ValueFontSize;
  final double LabelFontSize;

  ColumnItem({
    required this.label,
    required this.value,
    this.padding = const EdgeInsets.all(16.0),
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.start,
    this.textDirection = TextDirection.ltr,
    this.ValueFontSize= 25.0,
    this.LabelFontSize= 30.0,

  });

  @override
  Widget build(BuildContext context) {
    bool isRtl = textDirection == TextDirection.rtl;
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: columnMainAxisAlignment,
        crossAxisAlignment: columnCrossAxisAlignment,
        children: [
          Align(
            alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: LabelFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Align(
            alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              value??'kiii',
              style: TextStyle(fontSize: ValueFontSize,color: Color(0xFF01A45D),fontWeight: FontWeight.bold,),


            ),
          ),
        ],
      ),
    );
  }
}
String convertUUIDToNumber(String uuid) {
  // Hash the UUID using MD5
  var bytes = utf8.encode(uuid);
  var md54 = md5.convert(bytes);

  // Convert the MD5 hash to a BigInt
  BigInt bigInt = BigInt.parse(md54.toString(), radix: 16);

  // Take the modulo with 10^10 to get a 10-digit number
  BigInt mod = bigInt % BigInt.from(10000000000);

  return mod.toString();
}