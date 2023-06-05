// To parse this JSON data, do
//
//     final messages = messagesFromJson(jsonString);

import 'dart:convert';

List<Messages> messagesFromJson(String str) => List<Messages>.from(json.decode(str).map((x) => Messages.fromJson(x)));

String messagesToJson(List<Messages> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Messages {
  int id;
  String senderId;
  String receiverId;
  DateTime dateCreated;
  String text;
  String attachment;

  Messages({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.dateCreated,
    required this.text,
    required this.attachment,
  });

  factory Messages.fromJson(Map<String, dynamic> json) => Messages(
    id: json["id"],
    senderId: json["Sender_id"],
    receiverId: json["Receiver_id"],
    dateCreated: DateTime.parse(json["Date_Created"]),
    text: json["Text"],
    attachment: json["Attachment"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "Sender_id": senderId,
    "Receiver_id": receiverId,
    "Date_Created": dateCreated.toIso8601String(),
    "Text": text,
    "Attachment": attachment,
  };
}
