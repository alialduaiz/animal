import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:untitled6/User/show_report.dart';
import 'package:untitled6/User/show_report_All.dart';
import 'dart:ui' as UI;
import '../globals.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _MenuSearchState extends State<MenuSearch> {
  List<Map<String, dynamic>> _searchItems = [];
  List<Map<String, dynamic>> _searchItemsFiltered = [];

  Future<void> _getReports() async {
   // final response = await http.get(Uri.parse('$urll/report'));
    final response = await http.get(Uri.parse('http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/report'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final _searchI = json.decode(decodedBody) as List<dynamic>;
      print(_searchI);
      setState(() {
        _searchItems = _searchI.cast<Map<String, dynamic>>().toList();
        _searchItemsFiltered = List<Map<String, dynamic>>.from(_searchItems);
      });
    } else {
      throw Exception('Failed to fetch');
    }
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
      if (text.isEmpty) {
        // If the search query is empty, show all items.
        _searchItemsFiltered = List<Map<String, dynamic>>.from(_searchItems);
      } else {
        // Filter the items based on the search query.
        _searchItemsFiltered = _searchItems.where((item) {
          // Modify the conditions below based on your search requirements.
          return item['Title'].toLowerCase().contains(text.toLowerCase()) ||
              item['ID'].toString().contains(text);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
      Scaffold(
      appBar: AppBar(
      title: Text(
        FlutterI18n.translate(context,'all_reports'),
      ),
      centerTitle: true,
      backgroundColor: Color(0xFF087474),
      ),
      body: Column(
      children: [
      Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
      decoration: InputDecoration(
      hintText: FlutterI18n.translate(context,'search'),
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

                    builder: (context) => ViewReportAll(reportid: report['ID']),
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
                    FlutterI18n.translate(context,'View'),
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
