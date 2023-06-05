import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:untitled6/User/Myreports.dart';
import 'package:untitled6/User/showlocations.dart';

import '../language.dart';
import 'All_Reports.dart';

class UserInterfaceReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(

        backgroundColor: Color(0xFF087474),
        title: Text(
          FlutterI18n.translate(context, 'View Reports'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height:MediaQuery.of(context).size.height*0.1 ,),

            _buildButton(context, FlutterI18n.translate(context, 'My Reports'), Icons.assignment, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyReports()));
            }),
            SizedBox(height:MediaQuery.of(context).size.height*0.1 ,),
            _buildButton(context, FlutterI18n.translate(context, 'All Reports'), Icons.library_books, () {
              // Do something when "All Reports" button is pressed
              Navigator.push(context, MaterialPageRoute(builder: (context) => AllReports()));
            }),
            SizedBox(height:MediaQuery.of(context).size.height*0.1 ,),
            _buildButton(context, FlutterI18n.translate(context,'Predators Map'), Icons.map, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ShowLocations()));
            }),
            SizedBox(height:MediaQuery.of(context).size.height*0.1 ,),
          ],
        ),
      ),
 bottomNavigationBar: LanguageSelectionBottomBar(),
    ),

    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon, VoidCallback onPressed) {
    return Center(
        child:Container(
          height: (MediaQuery.of(context).size.height*0.1) ,
          width: MediaQuery.of(context).size.width/2,

          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: ElevatedButton.icon(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF087474),
            ),

            icon: Icon(
              icon,
              color: Colors.white,
            ),
            label: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          )
    );
  }
}

