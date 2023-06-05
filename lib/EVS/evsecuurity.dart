import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:untitled6/ChatsScreen.dart';
import 'package:untitled6/EVS/Manage_Account_EV.dart';

import '../language.dart';
import '../logout.dart';
import 'All_Reports_ev.dart';

class ESHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        logoutAndNavigateToLoginPage(context);
        return false; // prevent the page from being popped automatically
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF087474),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.power_settings_new,
                color: Colors.grey.shade300,
                size: 35.0,
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconWithText(
                          Icons.local_police_rounded,
                          FlutterI18n.translate(context, 'name'),
                          FlutterI18n.translate(context, 'manageAccount'),
                          screenWidth,
                          screenHeight,
                              () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ManageAccountAdmin()));
                          },
                        ),
                        SizedBox(height: 20),
                        _buildIconWithText(
                          Icons.description_outlined,
                          FlutterI18n.translate(context, 'reports'),
                          FlutterI18n.translate(context, 'viewAll'),
                          screenWidth,
                          screenHeight,
                              () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllReports()));
                          },
                        ),
                        SizedBox(height: 20),
                        _buildIconWithText(
                          Icons.mail,
                          FlutterI18n.translate(context, 'message'),
                          FlutterI18n.translate(context, 'viewMessages'),
                          screenWidth,
                          screenHeight,
                              () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatsScreen()));
                            print('View Messages tapped');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: LanguageSelectionBottomBar(),
      ),
    );
  }

}

Widget _buildIconWithText(
    IconData iconData,
    String name,
    String text,
    double screenWidth,
    double screenHeight,
    VoidCallback onTap,
    ) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: screenWidth * 0.25,
      height: screenWidth * 0.49,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 80,
            color: Color(0xFF087474),
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: onTap,
            child: Text(
              text,
              maxLines: null,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
