import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:untitled6/admin/Manage_Account_Admin.dart';
import 'package:untitled6/admin/add_Account.dart';
import 'package:untitled6/admin/manage_accounts.dart';
import '../ChatsScreen.dart';
import '../EVS/All_Reports_ev.dart';
import '../logout.dart';

int kdealtWithCount = 0;
int knotDealtWithCount = 0;

Future<Map<String, int>> fetchReportStatusCount() async {
  final response = await http.get(
      Uri.parse('http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/report'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    int dealtWithCount = 0;
    int notDealtWithCount = 0;

    for (var item in data) {
      if (item['Report_Status'] == 'Dealt With') {
        dealtWithCount++;
      } else if (item['Report_Status'] == 'Not Dealt With') {
        notDealtWithCount++;
      }
    }
    kdealtWithCount = dealtWithCount;
    knotDealtWithCount = notDealtWithCount;

    return {
      'dealt_with_count': dealtWithCount,
      'not_dealt_with_count': notDealtWithCount,
    };
  } else {
    throw Exception('Failed to load report statuses');
  }
}
class ChartApp extends StatefulWidget {
  @override
  _ChartAppState createState() => _ChartAppState();
}

class _ChartAppState extends State<ChartApp> {
  late List<charts.Series<ItemCount, String>> _seriesData;

  @override
  void initState() {
    super.initState();
    _seriesData = <charts.Series<ItemCount, String>>[];
    fetchReportStatusCount();
    _generateData();
  }

  void _generateData() {
    final data = [
      ItemCount('Dealt With', kdealtWithCount),
      ItemCount('Not Dealt With', knotDealtWithCount),
    ];

    _seriesData.add(
      charts.Series(
        id: 'report statistics',
        data: data,
        domainFn: (ItemCount count, _) => count.item,
        measureFn: (ItemCount count, _) => count.count,
        colorFn: (ItemCount count, _) {
          if (count.item == 'Dealt With') {
            return charts.ColorUtil.fromDartColor(Colors.green);
          } else if (count.item == 'Not Dealt With') {
            return charts.ColorUtil.fromDartColor(Colors.red);
          }
          return charts.ColorUtil.fromDartColor(Colors.transparent);
        },
        labelAccessorFn: (ItemCount count, _) => '${count.count}',
      ),
    );

    setState(() {}); // Trigger a rebuild of the widget
  }

  @override
  Widget build(BuildContext context) {
    fetchReportStatusCount(); // Assuming this method fetches the data asynchronously

    return FutureBuilder<void>(
      future: Future.wait([fetchReportStatusCount()]),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          // Handle error case
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Text('Error fetching data.'),
            ),
          );
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  FlutterI18n.translate(context, 'Report Statistics'),
                  style: Theme.of(context).textTheme.headline6,
                ),
                Expanded(
                  child: _seriesData == null
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : charts.BarChart(
                    _seriesData,
                    animate: true,
                    barGroupingType: charts.BarGroupingType.grouped,
                    barRendererDecorator: charts.BarLabelDecorator<String>(),
                    domainAxis: charts.OrdinalAxisSpec(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ItemCount {
  final String item;
  final int count;

  ItemCount(this.item, this.count);
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}


class _AdminDashboardState extends State<AdminDashboard> {
  Future<Map<String, int>>? _fetchReportStatusCountFuture;

  @override
  void initState() {
    super.initState();
    _fetchReportStatusCountFuture = fetchReportStatusCount();
    fetchReportStatusCount(); // Fetch the data
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        logoutAndNavigateToLoginPage(context);
        return false; // prevent the page from being popped automatically
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: SizedBox(),
            backgroundColor: Color(0xFF087474),
            title: Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                Center(
                  child:Text(
                    FlutterI18n.translate(context, "dashboard"),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                InkWell(
                  onTap: () {
                    logoutAndNavigateToLoginPage(context);
                  },
                  child: Icon(Icons.power_settings_new),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    // Add more widgets here...
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            border: Border.all( width: 1 , color:  Color(0xFF087474))
                        )
                        ,
                        child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [

                            Icon(FontAwesomeIcons.userShield, size:  (MediaQuery.of(context).size.height*0.2) /3 ,color:  Color(0xFF087474),),
                            Text(FlutterI18n.translate(context, "admin")),
                            InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ManageAccountAdmin()));


                                },
                                child:  Text(FlutterI18n.translate(context, "manage_account") ,style:  TextStyle(decoration: TextDecoration.underline),))
                          ],
                        ),
                      ),
                    )  ,
                    SizedBox(width: 5,),
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            border: Border.all( width: 1 , color:  Color(0xFF087474))
                        )
                        ,
                        child:
                        Column (
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.insert_drive_file , size: (MediaQuery.of(context).size.height*0.2) /3,color: Color(0xFF087474)),
                            Text(FlutterI18n.translate(context,'reports')),
                            InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AllReports()));

                                },
                                child: Text(FlutterI18n.translate(context, "view_all") ,textAlign: TextAlign.center,style: TextStyle(decoration: TextDecoration.underline),))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            border: Border.all( width: 1 , color:  Color(0xFF087474))
                        )
                        ,
                        child:
                        Column (
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.message_outlined , color:  Color(0xFF087474),size: (MediaQuery.of(context).size.height*0.2) /3,),
                            Text(FlutterI18n.translate(context, "messages")),
                            InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatsScreen()));

                                },
                                child: Text(FlutterI18n.translate(context, "view_messages") ,textAlign: TextAlign.center,style: TextStyle(decoration: TextDecoration.underline),))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 5,),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                      ),
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                        border: Border.all(width: 1, color: Color(0xFF087474)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.group,
                            size: (MediaQuery.of(context).size.height * 0.3) / 2,
                            color: Colors.green[700],
                          ),
                          Text(
                              FlutterI18n.translate(context, "accounts"),

                            style: TextStyle(fontSize: 20),
                          ),
                          InkWell(
                            onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyUsers()));
                            },
                            child: Text(
                              FlutterI18n.translate(context, "manage_accounts"),

                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddAccountPage()));
                            },
                            child: Text(
                              FlutterI18n.translate(context, "add_new_account"),

                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ChartApp(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


