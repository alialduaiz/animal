import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ChatScreen.dart';
import 'ChatScreen.dart' as chs;
class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Map<String, dynamic>> chats = [];  // Replace with your actual list of chats
  String userId='';
  @override
  void initState() {
    super.initState();
    fetchUsers();  // Fetch chats when the screen opens
  }

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

      setState(() {
        chats = tempChats;
        print('chat is:${chats[0]}');
      });
    }
  }




  Future<void> initiateChat(String phone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId  = prefs.getString('userId')??'';

    String apiUrl = 'http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/users';

    final response = await http.get(Uri.parse(apiUrl) );

    if (response.statusCode == 200) {
      print('Chat initiated successfully');
      var responseJson = json.decode(utf8.decode(response.bodyBytes));
      final _fetchedUsers = responseJson as List<dynamic>;
      final _filteredUser = _fetchedUsers.cast<Map<String, dynamic>>().firstWhere(
            (user) => user['Phone'].toString() == phone,
        orElse: () => {},
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            ChatScreen(userId: userId, otherUserId: _filteredUser['ID'],otherUserName: _filteredUser['Name'],)), // assuming the response contains the other user's id

      );
    } else {
      print('Failed to initiate chat');
      // Error initiating chat, handle it if needed.
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body:  chats.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          :ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            title: Text(chat['Name']), // Display the user's name
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    ChatScreen(userId: userId, otherUserId: chat['ID'],otherUserName: chat['Name'],)), // Pass the current and other user's ID to the chat screen
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              TextEditingController _phoneController = TextEditingController();
              return AlertDialog(
                title: Text('Start a new chat'),
                content: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(hintText: "Enter Phone Number"),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Start Chat'),
                    onPressed: () {
                      initiateChat(_phoneController.text);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),

    );
  }
}
