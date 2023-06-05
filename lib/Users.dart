import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final String id;
  final String name;
  final String phone;
  final String password;
  final String email;
  final String nationalId;
  final String accountType;
  final int age;
  final DateTime addedDate;
  final DateTime deletionDate;
  final String accountStatus;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.email,
    required this.nationalId,
    required this.accountType,
    required this.age,
    required this.addedDate,
    DateTime? deletionDate,
    required this.accountStatus,
  }) : this.deletionDate = deletionDate ?? DateTime.now();
  static Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('http://ec2-35-177-161-78.eu-west-2.compute.amazonaws.com:8000/users'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => User(
        id: user['ID'],
        name: user['Name'],
        phone: user['Phone'],
        password: user['Password'],
        email: user['Email'],
        nationalId: user['National_ID'],
        accountType: user['Account_Type'],
        age: user['Age'],
        addedDate: DateTime.parse(user['Added_Date']),
        deletionDate: user['Deletion_Date'] != null ? DateTime.parse(user['Deletion_Date']) : null,
        accountStatus: user['Account_Status'],
      )).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }
}
