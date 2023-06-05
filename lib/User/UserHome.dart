import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled6/User/View_reports.dart';
import 'package:untitled6/User/Add_report.dart';
import '../ChatsScreen.dart';
import '../language.dart';
import '../logout.dart';
import 'Manage_Account_User.dart';

String ID='';
class MyHome extends StatelessWidget {

  Future<void> getUserIdFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    ID=userId!=null?userId:'55';
    // Do something with the userId
    print(userId);
  }
    @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        logoutAndNavigateToLoginPage(context);
        return false; // prevent the page from being popped automatically
      },
      child: MaterialApp(
        title: 'User Homepage',
        theme: ThemeData(
          primaryColor: Color(0xFF087474),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(

              backgroundColor: Color(0xFF087474),
            title:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Container(child: SizedBox(),),
                Container(
                  child: Text(
                    '${FlutterI18n.translate(context,'Home')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,

                  ),

                ),
                  alignment: Alignment.center,
                ),
                Container( child: InkWell(
                    onTap: (){
                      logoutAndNavigateToLoginPage(context);

                    },
                    child: Icon(Icons.power_settings_new)),
                alignment: Alignment.topRight,)
              ],


            ),




          ),
          body: SafeArea(

            child:
            SingleChildScrollView(

              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height*0.28,
                      width: MediaQuery.of(context).size.width,

                      decoration:BoxDecoration(
                        color: Colors.white,
                          border: Border.all( width: 1 , color: Colors.blueGrey,strokeAlign: BorderSide.strokeAlignOutside)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.person,
                            color: Color(0xFF087474),
                            size: MediaQuery.of(context).size.height*0.28/2,
                          ),

                          Container(
                            height: MediaQuery.of(context).size.height*0.28/4,
                            child: Text(
                              FlutterI18n.translate(context, 'Account'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF087474),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ManageAccountUser()));
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height*0.28/4,
                              child: Text(
                                '${FlutterI18n.translate(context, 'manage account')}',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFF087474),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ),


                    Container(

                      height: MediaQuery.of(context).size.height*0.28,
                      width: MediaQuery.of(context).size.width,
                      decoration:BoxDecoration(
                          color: Colors.white,
                          border: Border.all( width: 1 , color: Colors.blueGrey,strokeAlign: BorderSide.strokeAlignOutside)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: Color(0xFF087474),
                            size: MediaQuery.of(context).size.height*0.28/2,
                          ),

                          Text(
                            '${FlutterI18n.translate(context,'reports')}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF087474),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddRprt()));
                                },
                                child: Container(
                                  height: MediaQuery.of(context).size.height*0.28/4,
                                  child:  Text('${FlutterI18n.translate(context,'add report')}',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Color(0xFF087474),
                                    ),
                                  ),
                                ),
                              ),
                              Text('    '),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserInterfaceReports()));
                                },
                                child: Container(
                                  height: MediaQuery.of(context).size.height*0.28/4,
                                  child: Text(
                                    '${FlutterI18n.translate(context,'view reports')}',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Color(0xFF087474),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: MediaQuery.of(context).size.height*0.28,
                      width: MediaQuery.of(context).size.width,
                      decoration:BoxDecoration(
                          color: Colors.white,
                          border: Border.all( width: 1 , color: Colors.blueGrey,strokeAlign: BorderSide.strokeAlignOutside)
                      ),
                       child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message,
                            color: Color(0xFF087474),
                            size: MediaQuery.of(context).size.height*0.28/2,
                          ),
                          Text(
                            '${FlutterI18n.translate(context,'Messages')}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF087474),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>ChatsScreen()));
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height*0.28/4,
                              child: Text(
                                '${FlutterI18n.translate(context,'view message')}',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFF087474),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: LanguageSelectionBottomBar(),
        ),
      ),
    );
  }
}
