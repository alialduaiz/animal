import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../ChatScreen.dart';
import '../ChatsScreen.dart';

String userId='';
List<Map<String, dynamic>> chats = [];  // Replace with your actual list of chats
final ImagePicker _picker = ImagePicker();
final TextEditingController messageController = TextEditingController();
List<Map<String, dynamic>> messages = [];

Future<void> fetchUsers() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  userId = prefs.getString('userId') ?? '';
  print('debug0');

  final responseUsers = await http.get(
      Uri.parse('http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/users'));

  if (responseUsers.statusCode == 200) {
    final responseDataUsers = jsonDecode(utf8.decode(responseUsers.bodyBytes));
    List<Map<String, dynamic>> tempChats = [];
    for (Map<String, dynamic> user in responseDataUsers) {
      if (user['ID'] != userId) {
        final responseMessages = await http.get(Uri.parse(
            'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/mmmss/?SenderId=${userId}&ReceiverId=${user['ID']}'));
        final messagesData = jsonDecode(utf8.decode(responseMessages.bodyBytes));
        if (messagesData.length > 0) { // If any message exists
          tempChats.add(user); // Add the user to the chats
        }
      }
    }


    chats = tempChats;
    print('chat is:${chats[0]}');


  }
}

Future<void> initiateChat(String phone, BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId  = prefs.getString('userId')??'';

  String apiUrl = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/users';

  final response = await http.post(Uri.parse(apiUrl) );

  if (response.statusCode == 200) {
    print('Chat initiated successfully');
    var responseJson = json.decode(response.body);
    final _fetchedUsers = responseJson as List<dynamic>;
    final _filteredUser = _fetchedUsers.cast<Map<String, dynamic>>().firstWhere(
          (user) => user['phone'].toString() == phone,
      orElse: () => {},
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          ChatScreen(userId: userId, otherUserId: _filteredUser['ID']), ), // assuming the response contains the other user's id

    );
  } else {
    print('Failed to initiate chat');
    // Error initiating chat, handle it if needed.
  }
}

Future<void> sendMessage({File? imageFile, bool sendLocation = false,required String otherUserId,required BuildContext context}) async {
  Map<String, String> messageData = {
    'Sender': userId!,
    'Receiver': otherUserId!,
    'Text': messageController.text,
    'alt': '0',
    'lag': '0',
  };

  if (sendLocation) {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to send your current location?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirm'),
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
    messageController.text = ''; // Clear the message input field after a successful send
    fetchMessages(otherUserId); // Refresh messages after sending
  } else {
    print('Failed to send message');
  }
}
Future<void> pickImage(BuildContext context) async {
  final ImageSource? source = await showDialog<ImageSource>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('Select image source'),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      );
    },
  );

  if (source != null) {
    final XFile? imageFile = await _picker.pickImage(source: source);
    if (imageFile != null) {
      sendImage(File(imageFile.path),context);
    }
  }
}
Future<void> sendImage(File imageFile, BuildContext context) async {
  await sendMessage(imageFile: imageFile, sendLocation: false, otherUserId: '', context: context);
}
Future<void> fetchMessages(String otherUserId) async {
  final url = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/mmmss/?SenderId=${userId}&ReceiverId=${otherUserId}';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));

    messages = List<Map<String, dynamic>>.from(data);

  } else {
    print('Failed to fetch messages. Response: ${response.body}');
  }
}
