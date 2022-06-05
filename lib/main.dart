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

Future<Acc> getAcc() async { // 서버에서 마지막으로 측정된 가속도를 가져오는 함수
  final response = await http.get(
    Uri.parse('http://10.0.2.2:5000/acc_data'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8', // 안 넣으면 오류 발생
    },
  );
  return Acc.fromJson(jsonDecode(response.body));
}

class Acc { // 서버와 통신할 데이터의 형태를 정의하는 클래스
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
                  MaterialPageRoute(builder: (context)=>datas())
                );
              },
            child: Icon(Icons.person),
          )
        ],

      ),

    );

  }

}

class acc extends StatefulWidget { // 속도가 정상적일 떄의 화면

  @override
  accState createState() => accState();
}

class accState extends State<acc>{

  @override

  Widget build(BuildContext context) {
    accelerometerEvents.listen((AccelerometerEvent event) { // 가속도를 측정하는 함수
        if (sqrt(event.x * event.x + event.y * event.y) > 10){ // 가속도가 10을 넘을 경우 함수 실행
          createAcc(event.x, event.y); // 서버에 가속도 전송
          Navigator.push( // 빨간 경고 화면으로 전환하는 함수
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

class aggressive extends StatelessWidget { // 난폭운전 경고 화면
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

class datas extends StatefulWidget{ // 서버에서 데이터를 받아와 보여주는 페이지

  @override
  dataState createState() => dataState();
}

class dataState extends State<datas>{


  @override
  Widget build(BuildContext context){


    var a = getAcc().then((value){ // 서버에서 마지막으로 측정된 데이터를 받아와 저장
    });
    return Scaffold(
      appBar: AppBar( // 페이지 제목
        title: Text('최근의 가속도 기록'),
      ),

      body: Row( // 글자 위치 설정
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FutureBuilder( // future 변수를 출력하게 도와주는 함수
            future: getAcc(),
            builder: ((context, snapshot) {
             if (snapshot.connectionState == ConnectionState.done){
               Acc a = snapshot.data as Acc;
               return Text('acc_x : ${a.acc_x} ' + 'acc_y : ${a.acc_y}',
               style: TextStyle(
                 fontSize: 30,
                 color: Colors.blue,
                 fontWeight: FontWeight.bold
               ));
             }
             else{
               return Text('error');
             }
            }),
          ),
        ]
      ),
    );
  }
}
