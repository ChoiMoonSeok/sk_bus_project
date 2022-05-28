import 'dart:developer';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;

Future<Acc> createAcc(double acc_x, double acc_y) async { // 가속계 데이터를 서버에 전송하는 함수
  final response = await http.post( // 전송할 json 형태 가져오기
    Uri.parse('http://10.0.2.2:5000/acc_data'), // 전송할 서버 ip
    headers: <String, String>{ // header
      'Content-Type': 'application/json; charset=UTF-8', // 안 넣으면 오류 발생
    },
    body: jsonEncode(<String, dynamic>{ // jsonEncode로 json 형태로 데이터를 변환
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
      acc_y: json['acc_y']
    );
  }
}


void main() =>runApp(d_or_p_1st());

class d_or_p_1st extends StatelessWidget{ // 기본 화면 구성 : 밑바탕

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'aggressive_drive_avoider',
      home: choose_d_or_p(),
    );
  }
}

class choose_d_or_p extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar( // 제목
        title: Text("버스 기사 혹은 승객"),
      ),
      body: Row(

        mainAxisAlignment: MainAxisAlignment.center, // Y축 중앙으로 정렬
        crossAxisAlignment: CrossAxisAlignment.center, // X축 중앙으로 정렬
        mainAxisSize: MainAxisSize.max,
        children: <Widget> [ // body의 row에 Widget을 넣어줌

          FloatingActionButton( // 버스 기사용 버튼
                onPressed: () { // 버튼을 눌렀을 때
                  Navigator.push( // 다른 위젯으로 이동하는 함수
                    context,
                    MaterialPageRoute(builder: (context)=>acc())
                  );
                },
            child: Icon(Icons.directions_bus),
          ),

          Container( // 사이 공간 띄우는 용도의 빈 컨테이너
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.all(30),
          ),

          FloatingActionButton( // 일반 승객용 버튼
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=>aggressive())
                );
              },
            child: Icon(Icons.person),
          )
        ],

      ),

    );

  }

}

class acc extends StatefulWidget {

  @override
  accState createState() => accState();
}

class accState extends State<acc>{

  @override

  Widget build(BuildContext context) {
    accelerometerEvents.listen((AccelerometerEvent event) {
        if (sqrt(event.x * event.x + event.y * event.y) > 10){
          createAcc(event.x, event.y);
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>aggressive())
          );
        }
      });
    return Container(
      color: Colors.blue,
    );
  }
}

class aggressive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    accelerometerEvents.listen((AccelerometerEvent e) {
      if (sqrt(e.x * e.x + e.z * e.z) <
          10) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=>acc())
        );
      }
    });

    return Container(
      color: Colors.red,
    );
  }
}