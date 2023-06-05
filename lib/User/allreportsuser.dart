import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../language.dart';





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
  List<Map<String, dynamic>> _searchItems = [];
  List<Map<String, dynamic>> _searchItemsFiltered = [];


  Future<void> _getReports() async {
    final response = await http.get(Uri.parse('http://192.168.43.134:8000/report'));
    if (response.statusCode == 200) {
      final _searchI = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        _searchItems = _searchI.cast<Map<String, dynamic>>().toList();
        _searchItemsFiltered = List<Map<String, dynamic>>.from(_searchItems);
      });
    } else {
      throw Exception('Failed to fetch ');
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My reports',
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
                hintText: 'Search',
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
                  leading: ClipOval(

                    child: CircleAvatar(
                      radius: 40.0,
                      child: ClipOval(
                        child: Image(
                          image: report['Verification_Status'] == "Not Confirmed" ?  AssetImage('assets/notconfired.png'):
                          report['Verification_Status'] == "Confirmed" ?AssetImage('assets/confired.png'):  report['IsCancellation']?AssetImage('assets/cancelled.png') :AssetImage('assets/cancelled.png'),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: MediaQuery
                              .of(context)
                              .size
                              .width,
                          fit: BoxFit.contain,
                        ),
                      ),
                      backgroundColor: Colors.transparent,

                    ),
                  ),
                  title: Text(
                    report['Title'],
                    style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${report['ID']}"),
                      Text("Created on: ${report['Added_Date']}"),
                    ],
                  ),
                  onTap: () {
                    // TODO: Implement onTap
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          // TODO: Implement onTap
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_red_eye, color: Color(0xFF1B54D9),),
                            Text(
                              "View",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20,),
                      InkWell(
                        onTap: () {
                          // TODO: Implement onTap
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel, color: Color(0xFFFB2D2D),),
                            Text(
                              "Edit",
                              style: TextStyle(
                                color: Color(0xFFFB2D2D),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20,),
                      InkWell(
                        onTap: () {
                          // TODO: Implement onTap
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Icon(Icons.edit, color: Color(0xFF27CE9C),),
                            Text(
                              "Cancel",
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
    );
  }
}