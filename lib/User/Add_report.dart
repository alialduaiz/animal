import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_i18n/flutter_i18n.dart';

import '../language.dart';

class AddRprt extends StatefulWidget {
  @override
  _AddRprtState createState() => _AddRprtState();
}
class _AddRprtState extends State<AddRprt> {
  TextEditingController _noteController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  String _typeController = 'Predator';
  GoogleMapController? _mapController;
  LatLng? _markerLatLng;
  File? _imageFile;
  final picker = ImagePicker();
  LocationData _currentLocation =
  LocationData.fromMap({"latitude": 0.0, "longitude": 0.0});

  Location _location = Location();
  List<String> aType = [
    'Predator',
    'Non-Predator',
  ];
  late int selectedType = 0;
  // Get the current location of the device
  Future<void> _getCurrentLocation() async {
    try {
      LocationData currentLocation = await _location.getLocation();
      setState(() {
        _currentLocation = currentLocation;
        _markerLatLng =
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
      });
      _mapController!
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        zoom: 14.0,
      )));
    } catch (e) {
      print('Could not get location: $e');
    }
  }

  // Add a marker to the map when the user taps on a location
  void _onMapTap(LatLng latLng) {
    setState(() {
      _markerLatLng = latLng;
    });
  }

  // Pick an image from the camera or gallery
  void _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  late Future _init;

  @override
  void initState() {
    super.initState();
    _init = _getCurrentLocation();
  }

  Future<void> addReport() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    print("hihi");
    print("user id: $userId");
    print("imager:$_imageFile");
    if (userId != null && _imageFile != null) {
      String apiUrl = "http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/add_report/"; // Update the API URL here
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['User_ID'] = userId;
      request.fields['Title'] = _titleController.text;
      request.fields['alt'] = _markerLatLng!.latitude.toString();
      request.fields['lag'] = _markerLatLng!.longitude.toString();
      request.fields['Note'] = _noteController.text;
      request.fields['Type'] = _typeController;

      request.files
          .add(await http.MultipartFile.fromPath('Image', _imageFile!.path));
      print("hihi");

      try {
        var response = await request.send();
        if (response.statusCode == 201) {
          Fluttertoast.showToast(
              msg: FlutterI18n.translate(context, 'Report added successfully.'),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(
              msg: FlutterI18n.translate(
                  context, 'Failed to add report. Please try again.'),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          throw Exception('Failed to add report.');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF087474),
          title: Text(
            FlutterI18n.translate(context, 'Add Report'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
            future: _init,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Return a loading indicator while waiting
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Return an error message if something went wrong
                return Text('Error: ${snapshot.error}');
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.0),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                          child: GoogleMap(
                            mapType: MapType.normal,
                            zoomControlsEnabled: true,
                            zoomGesturesEnabled: true,
                            rotateGesturesEnabled: true,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                            onTap: _onMapTap,
                            initialCameraPosition: CameraPosition(
                              target: _currentLocation != null
                                  ? LatLng(_currentLocation!.latitude!,
                                  _currentLocation!.longitude!)
                                  : LatLng(0,
                                  0), // default value when _currentLocation is null
                              zoom: 14.0,
                            ),
                            markers: _markerLatLng == null
                                ? Set<Marker>()
                                : Set<Marker>.from([
                              Marker(
                                markerId: MarkerId('marker'),
                                position: _markerLatLng!,
                              ),
                            ]),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _getCurrentLocation(),
                          child: Text(FlutterI18n.translate(context, 'My Location')),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: FlutterI18n.translate(context, 'title'),
                          ),
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        // Other form widgets go here
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                color: Color(0xFF087474),
                                border:
                                Border.all(width: 1, color: Colors.black),
                              ),
                              child: Stack(
                                children: [
                                  // Add the image preview if an image has been picked
                                  if (_imageFile != null)
                                    Center(
                                      child: Positioned(
                                        bottom:
                                        MediaQuery.of(context).size.height *
                                            0.5 *
                                            0.25,
                                        top:
                                        MediaQuery.of(context).size.height *
                                            0.5 *
                                            0.05,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.5 *
                                              0.5,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.5 *
                                              0.5,
                                          child: ClipOval(
                                            child: Image.file(
                                              _imageFile!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                  // Show the image icon if no image has been picked
                                    Positioned.fill(
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size:
                                        MediaQuery.of(context).size.height *
                                            0.5 *
                                            0.65,
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: Container(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.9,
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.5 *
                                            0.2,
                                        alignment: Alignment.bottomCenter,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  _pickImage(ImageSource.camera),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    0.9 /
                                                    2,
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.5 *
                                                    0.2,
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.black,
                                                      strokeAlign: BorderSide
                                                          .strokeAlignOutside),
                                                ),
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .camera_alt_rounded,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        FlutterI18n.translate(
                                                            context,
                                                            'Take a photo'),
                                                        style: TextStyle(
                                                            color:
                                                            Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () =>
                                                  _pickImage(ImageSource.gallery),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    0.9 /
                                                    2,
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.5 /
                                                    5,
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.black,
                                                      strokeAlign: BorderSide
                                                          .strokeAlignOutside),
                                                ),
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.image_sharp,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        FlutterI18n.translate(
                                                            context,
                                                            'Pick from gallery'),
                                                        style: TextStyle(
                                                            color:
                                                            Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.0),
                        Row(
                          children: [
                            SizedBox(
                              height: 150.0,
                              width: MediaQuery.of(context).size.width * .5,
                              child: TextField(
                                controller: _noteController,
                                maxLines: null,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: FlutterI18n.translate(context, 'Note'),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .1,
                            )
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                FlutterI18n.translate(context, 'Type'),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: aType.map((option) {
                                final index = aType.indexOf(option);
                                final isSelected = selectedType == index;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedType = index;
                                      _typeController = option;
                                    });
                                    print('Selected type: ${_typeController}');
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.6 /
                                        2,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.black,
                                          strokeAlign:
                                          BorderSide.strokeAlignOutside),
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                      borderRadius: !(option == 'Predator')
                                          ? BorderRadius.only(
                                          topLeft: Radius.zero,
                                          topRight: Radius.circular(8),
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.circular(8))
                                          : BorderRadius.only(
                                          topRight: Radius.zero,
                                          topLeft: Radius.circular(8),
                                          bottomRight: Radius.zero,
                                          bottomLeft: Radius.circular(8)),
                                    ),
                                    height: 50,
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Container(
                          child: ElevatedButton(
                            onPressed: () async {
                              addReport();
                              Navigator.of(context).pop();
                              print('sadasfasfasdsad');
                            },
                            child: Text(FlutterI18n.translate(context, 'Submit')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        bottomNavigationBar: LanguageSelectionBottomBar(),
      ),
    );
  }
}
