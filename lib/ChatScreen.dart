
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:untitled6/ImageScreen.dart';
import 'package:untitled6/globals.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String? userId;
  final String? otherUserId;
  final String? otherUserName;

  ChatScreen({Key? key, this.userId, this.otherUserId,this.otherUserName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.userId != null && widget.otherUserId != null) {
      fetchMessages();
    }
  }

  Future<void> fetchMessages() async {
    final url = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/mmmss/?SenderId=${widget.userId}&ReceiverId=${widget.otherUserId}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        messages = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print('Failed to fetch messages. Response: ${response.body}');
    }
  }

  Future<void> sendMessage({File? imageFile, bool sendLocation = false}) async {
    Map<String, String> messageData = {
      'Sender': widget.userId!,
      'Receiver': widget.otherUserId!,
      'Text': _messageController.text,
      'alt': '0',
      'lag': '0',
    };

    if (sendLocation) {
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(FlutterI18n.translate(context, 'Confirmation')),
            content: Text(FlutterI18n.translate(context, 'Are you sure you want to send your current location?')),
            actions: <Widget>[
              TextButton(
                child: Text(FlutterI18n.translate(context, 'Cancel')),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(FlutterI18n.translate(context, 'Confirm')),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      ) ?? false;

      if (!confirm) return;

      Location location = new Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();

      messageData['alt'] = _locationData.latitude.toString();
      messageData['lag'] = _locationData.longitude.toString();
      messageData['Text'] = 'Location';
    }

    var request = http.MultipartRequest('POST', Uri.parse('http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/messages/'));
    request.fields.addAll(messageData);

    if (imageFile != null) {
      request.files.add(http.MultipartFile('Attachment', imageFile.readAsBytes().asStream(), imageFile.lengthSync(),
          filename: imageFile.path.split("/").last));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Message sent successfully');
      _messageController.text = ''; // Clear the message input field after a successful send
      fetchMessages(); // Refresh messages after sending
    } else {
      print('Failed to send message');
    }
  }
  Future<void> pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title:  Text(FlutterI18n.translate(context, 'Select image source')),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera),
              title:  Text(FlutterI18n.translate(context, 'Camera')),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title:  Text(FlutterI18n.translate(context, 'Gallery')),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final XFile? imageFile = await _picker.pickImage(source: source);
      if (imageFile != null) {
        sendImage(File(imageFile.path));
      }
    }
  }


  Future<void> sendImage(File imageFile) async {
    await sendMessage(imageFile: imageFile, sendLocation: false);
  }



  void launchMaps(double lat, double lon) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not launch $googleUrl';
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text('${widget.otherUserName }'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isOwnMessage = message['Sender']['ID'] == widget.userId;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: isOwnMessage ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (message['Text'] == 'Location') {
                              launchMaps(double.parse(message['alt']), double.parse(message['lag']));
                            }
                            else if (message['Attatchment']!=null){

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      ImageFullScreen(imageUrl: '$GServer${message['Attachment']}')
                                  ));
                            }
                          },
                          child: message['Text'] == 'Location'
                              ? Container(
                            width: MediaQuery.of(context).size.width*0.7,
                            height: MediaQuery.of(context).size.height*0.65,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(message['alt'], message['lag']),
                                zoom: 15,
                              ),
                              markers: Set.from([
                                Marker(markerId: MarkerId('location'), position: LatLng(message['alt'], message['lag'])),
                              ]),
                            ),
                          )
                              : message['Attachment'] != null ?



                          Container(
                            width: MediaQuery.of(context).size.width*0.7,
                            child: CachedNetworkImage(
                              imageUrl: '$GServer${message['Attachment']}',
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.error)
                            ),
                          )

                              : Text(message['Text'].toString()),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: FlutterI18n.translate(context, 'Type a message')),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    pickImage();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.location_on),
                  onPressed: () {
                    sendMessage(sendLocation: true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
