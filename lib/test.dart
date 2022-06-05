import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Acc> createAcc(double acc_x, double acc_y) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/albums'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'acc_x': acc_x,
      'acc_y': acc_y
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Acc.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create album.');
  }
}

class Acc {
  final double acc_x;
  final double acc_y;

  const Acc({required this.acc_x, required this.acc_y});

  factory Acc.fromJson(Map<String, dynamic> json) {
    return Acc(
      acc_x: json['acc_x'],
      acc_y: json['acc_y'],
    );
  }
}

void main() {
  Future<Acc> a = createAcc(30.2, 40.8);
}