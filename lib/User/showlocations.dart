import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:async';

enum FilterOption {
  all,
  predator,
  nonPredator,
}

class ShowLocations extends StatefulWidget {
  @override
  _ShowLocationsState createState() => _ShowLocationsState();
}

class _ShowLocationsState extends State<ShowLocations> {
  List<Map<String, dynamic>> _locations = [];
  double? _latitude;
  double? _longitude;
  bool _loading = true;
  FilterOption _selectedFilter = FilterOption.all;

  Future<void> _getLocations() async {
    final response = await http.get(Uri.parse('http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/report'));
    if (response.statusCode == 200) {
      final locations = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        _locations = locations.cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to fetch locations');
    }
  }

  Completer<GoogleMapController> _controller = Completer();

  Future<void> _getCurrentLocation() async {
    try {
      LocationData locationData = await Location().getLocation();
      setState(() {
        _latitude = locationData.latitude;
        _longitude = locationData.longitude;
        _loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _centerView() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_latitude ?? 0, _longitude ?? 0),
          zoom: 16,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getLocations();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${FlutterI18n.translate(context,'Predators Locations')}'),
        actions: [
          PopupMenuButton<FilterOption>(
            onSelected: (FilterOption result) {
              setState(() {
                _selectedFilter = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterOption>>[
              PopupMenuItem<FilterOption>(
                value: FilterOption.all,
                child: Text('All'),
              ),
              PopupMenuItem<FilterOption>(
                value: FilterOption.predator,
                child: Text('${FlutterI18n.translate(context,'Predators')}'),
              ),
              PopupMenuItem<FilterOption>(
                value: FilterOption.nonPredator,
                child: Text('${FlutterI18n.translate(context,'Non-Predators')}'),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(_latitude ?? 0, _longitude ?? 0),
          zoom: 5,
        ),
        markers: _locations
            .where((location) {
          if (_selectedFilter == FilterOption.all) {
            return true;
          } else if (_selectedFilter == FilterOption.predator) {
            return location['Type'] == 'Predator';
          } else if (_selectedFilter == FilterOption.nonPredator) {
            return location['Type'] == 'Non-Predator';
          }
          return false;
        })
            .map((location) => Marker(
          markerId: MarkerId(location['ID'].toString()),
          position: LatLng(
            location['alt'],
            location['lag'],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            location['Type'] == 'Non-Predator'
                ? BitmapDescriptor.hueBlue
                : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: location['Title'],
            snippet: location['Note'],
          ),
        ))
            .toSet(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _centerView(),
        child: Icon(Icons.center_focus_strong),
      ),
    );
  }
}
