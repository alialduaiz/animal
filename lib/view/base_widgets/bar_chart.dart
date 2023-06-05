import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:convert';
import 'package:http/http.dart' as http;
int kdealtWithCount = 0 ;
int knotDealtWithCount = 0 ;

Future<Map<String, int>> fetchReportStatusCount() async {
  final response = await http.get(Uri.parse('http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/report'));

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
    kdealtWithCount= dealtWithCount;
    knotDealtWithCount= notDealtWithCount;



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
        colorFn: (ItemCount count, _) =>
        count.item == 'Dealt With'
            ? charts.ColorUtil.fromDartColor(Colors.green)
            : charts.ColorUtil.fromDartColor(Colors.red),
        labelAccessorFn: (ItemCount count, _) => '${count.count}',
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    fetchReportStatusCount();
    return  _seriesData== null
    ? Center(
    child: CircularProgressIndicator(),
    ):Container(
      height: MediaQuery.of(context).size.height*0.5,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Report Statistics',
              style: Theme.of(context).textTheme.headline6,
            ),
            Expanded(
              child: charts.BarChart(
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
  }
}

class ItemCount {
  final String item;
  final int count;

  ItemCount(this.item, this.count);
}
