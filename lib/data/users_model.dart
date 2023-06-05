// To parse this JSON data, do
//
//     final users = usersFromJson(jsonString);

import 'dart:convert';

List<Users> usersFromJson(String str) => List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String usersToJson(List<Users> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Users {
  String id;
  String name;
  String phone;
  String password;
  String email;
  String nationalId;
  String accountType;
  String nationality;
  String gender;
  int age;
  DateTime addedDate;
  dynamic deletionDate;
  String accountStatus;

  Users({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.email,
    required this.nationalId,
    required this.accountType,
    required this.nationality,
    required this.gender,
    required this.age,
    required this.addedDate,
    this.deletionDate,
    required this.accountStatus,
  });



  factory Users.fromJson(Map<String, dynamic> json) => Users(
    id: json["ID"],
    name: json["Name"],
    phone: json["Phone"],
    password: json["Password"],
    email: json["Email"],
    nationalId: json["National_ID"],
    accountType: json["Account_Type"],
    age: json["Age"],
    addedDate: DateTime.parse(json["Added_Date"]),
    deletionDate: json["Deletion_Date"],
    accountStatus: json["Account_Status"],
    nationality: json['Nationality'],
    gender: json['Gender']
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "Name": name,
    "Phone": phone,
    "Password": password,
    "Email": email,
    "National_ID": nationalId,
    "Account_Type": accountType,
    "Age": age,
    "Added_Date": addedDate.toIso8601String(),
    "Deletion_Date": deletionDate,
    "Account_Status": accountStatus,
    "Gender": gender,
    "Nationality":nationality
  };
}
