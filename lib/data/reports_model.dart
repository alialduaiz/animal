// To parse this JSON data, do
//
//     final reports = reportsFromJson(jsonString);

import 'dart:convert';

List<Reports> reportsFromJson(String str) => List<Reports>.from(json.decode(str).map((x) => Reports.fromJson(x)));

String reportsToJson(List<Reports> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Reports {
  String image;
  String id;
  String title;
  double alt;
  double lag;
  String note;
  String type;
  String verificationStatus;
  String reportStatus;
  DateTime addedDate;
  dynamic cancellationDate;
  bool isCancellation;
  dynamic deletedDate;
  bool isDeleted;
  String userIdId;

  Reports({
    required this.image,
    required this.id,
    required this.title,
    required this.alt,
    required this.lag,
    required this.note,
    required this.type,
    required this.verificationStatus,
    required this.reportStatus,
    required this.addedDate,
    this.cancellationDate,
    required this.isCancellation,
    this.deletedDate,
    required this.isDeleted,
    required this.userIdId,
  });

  factory Reports.fromJson(Map<String, dynamic> json) => Reports(
    image: json["image"],
    id: json["ID"],
    title: json["Title"],
    alt: json["alt"]?.toDouble(),
    lag: json["lag"]?.toDouble(),
    note: json["Note"],
    type: json["Type"],
    verificationStatus: json["Verification_Status"],
    reportStatus: json["Report_Status"],
    addedDate: DateTime.parse(json["Added_Date"]),
    cancellationDate: json["Cancellation_Date"],
    isCancellation: json["IsCancellation"],
    deletedDate: json["Deleted_Date"],
    isDeleted: json["IsDeleted"],
    userIdId: json["User_ID_id"],
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "ID": id,
    "Title": title,
    "alt": alt,
    "lag": lag,
    "Note": note,
    "Type": type,
    "Verification_Status": verificationStatus,
    "Report_Status": reportStatus,
    "Added_Date": addedDate.toIso8601String(),
    "Cancellation_Date": cancellationDate,
    "IsCancellation": isCancellation,
    "Deleted_Date": deletedDate,
    "IsDeleted": isDeleted,
    "User_ID_id": userIdId,
  };
}
