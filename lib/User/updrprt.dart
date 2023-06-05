import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../globals.dart';
import '../language.dart';

class UpdateReport extends StatefulWidget {
  final String reportId;

  UpdateReport({required this.reportId});

  @override
  _UpdateReportState createState() => _UpdateReportState();
}

class _UpdateReportState extends State<UpdateReport> {
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
  late bool isEditing = false;
  late Future _init;

  @override
  void initState() {
    super.initState();

    if (widget.reportId.isNotEmpty) {
      isEditing = true;
      _init = _fetchReportDetails();
    }
  }

  Future<void> _fetchReportDetails() async {
    try {
      final response = await http.get(Uri.parse('http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/report'));
     // final response = await http.get(Uri.parse('http://192.168.43.134:8000/report'));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final _fetchedReports = jsonDecode(decodedBody) as List<dynamic>;
        final reportData =
            _fetchedReports.cast<Map<String, dynamic>>().firstWhere(
                  (report) => report['ID'] == widget.reportId,
                  orElse: () => {},
                );
print(reportData.toString());
        setState(() {
          _titleController.text = reportData['Title'] ?? '';
          _noteController.text = reportData['Note'] ?? '';
          _typeController = reportData['Type'] ?? '';
          _markerLatLng = LatLng(
            reportData['alt'] != null
                ? double.parse(reportData['alt'].toString())
                : 0.0,
            reportData['lag'] != null
                ? double.parse(reportData['lag'].toString())
                : 0.0,
          );
        });

        final imageUrl = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000${reportData['image']}';
        //
       // final imageUrl ='http://192.168.43.134:8000${reportData['image']}';
        final imageResponse = await http.get(Uri.parse(imageUrl));
        if (imageResponse.statusCode == 200) {
          final imageData = imageResponse.bodyBytes;
          _imageFile = await _createImageFile(imageData);
        } else {
          print(
              'Failed to fetch image. Status code: ${imageResponse.statusCode}');
        }
      } else {
        throw Exception('Failed to fetch report details.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<File> _createImageFile(List<int> imageData) async {
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/image.jpg';
    return File(imagePath).writeAsBytes(imageData);
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationData currentLocation = await _location.getLocation();
      setState(() {
        _currentLocation = currentLocation;

        _markerLatLng = LatLng(
          _currentLocation.latitude!,
          _currentLocation.longitude!,
        );
      });
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _currentLocation.latitude!,
            _currentLocation.longitude!,
          ),
          zoom: 14.0,
        ),
      ));
    } catch (e) {
      print('Could not get location: $e');
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _markerLatLng = latLng;
    });
  }

  void _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      _imageFile = File(pickedFile?.path ?? '');
    });
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to submit the report?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                updateReport();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateReport() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId != null && _imageFile != null) {
      String apiUrl = "http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/update_report/";
      //String apiUrl = "http://192.168.43.134:8000/update_report/";
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['User_ID'] = userId;
      request.fields['ID'] = widget.reportId;
      request.fields['Title'] = _titleController.text;
      request.fields['alt'] = _markerLatLng!.latitude.toString();
      request.fields['lag'] = _markerLatLng!.longitude.toString();
      request.fields['Note'] = _noteController.text;
      request.fields['Type'] = _typeController;
      request.files
          .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      try {
        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        if (response.statusCode == 201) {
          Fluttertoast.showToast(
            msg: "Report updated successfully.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Navigator.pop(context);
        } else {
          print('Failed to upload report. Status code: ${response.statusCode}');
          print('Response body: $responseBody');
        }
      } catch (e) {
        print('Error uploading report: $e');
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
            isEditing ? 'Edit Report' : 'Add Report',
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
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
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
                            target: _currentLocation.latitude != 0.0 &&
                                    _currentLocation.longitude != 0.0
                                ? LatLng(
                                    _currentLocation.latitude!,
                                    _currentLocation.longitude!,
                                  )
                                : LatLng(0.0, 0.0),
                            zoom: 14.0,
                          ),
                          markers: _markerLatLng == null
                              ? Set<Marker>.identity()
                              : <Marker>{
                                  Marker(
                                    markerId: MarkerId('marker'),
                                    position: _markerLatLng!,
                                  ),
                                },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: Text('My Location'),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Title',
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Color(0xFF087474),
                              border: Border.all(width: 1, color: Colors.black),
                            ),
                            child: Stack(
                              children: [
                                if (_imageFile != null)
                                  Center(
                                    child: Positioned(
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.5 *
                                              0.25,
                                      top: MediaQuery.of(context).size.height *
                                          0.5 *
                                          0.05,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.5 *
                                                0.5,
                                        height:
                                            MediaQuery.of(context).size.height *
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
                                  Positioned.fill(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.white,
                                      size: MediaQuery.of(context).size.height *
                                          0.5 *
                                          0.65,
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
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
                                                ),
                                              ),
                                              child: Center(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.camera_alt_rounded,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      'Take a photo',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
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
                                                ),
                                              ),
                                              child: Center(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.image_sharp,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      'Pick from gallery',
                                                      style: TextStyle(
                                                        color: Colors.white,
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
                                labelText: 'Note',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .1,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Type',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
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
                                  print('Selected type: $_typeController');
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
                                    ),
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.transparent,
                                    borderRadius: !(option == 'Predator')
                                        ? BorderRadius.only(
                                            topLeft: Radius.zero,
                                            topRight: Radius.circular(8),
                                            bottomLeft: Radius.zero,
                                            bottomRight: Radius.circular(8),
                                          )
                                        : BorderRadius.only(
                                            topRight: Radius.zero,
                                            topLeft: Radius.circular(8),
                                            bottomRight: Radius.zero,
                                            bottomLeft: Radius.circular(8),
                                          ),
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
                            _showConfirmationDialog();
                          },
                          child: Text(isEditing ? 'Update' : 'Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: LanguageSelectionBottomBar(),
      ),
    );
  }
}
