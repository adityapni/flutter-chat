import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class CustomDateTimeConverter implements JsonConverter<Timestamp?, String> {
  const CustomDateTimeConverter();

  @override
  Timestamp? fromJson(String json) {
    // if (json.contains(".")) {
    //   json = json.substring(0, json.length - 1);
    // }
    // print('json timestamp $json');
    String seconds = json.split(',')[0];
    String secondstrim = seconds.replaceFirst('Timestamp(seconds=', '');
    // print('trimmed json $secondstrim');

    return Timestamp.fromMillisecondsSinceEpoch(int.parse(secondstrim)*1000);
  }

  @override
  String toJson(Timestamp? json) => json.toString();
}