import 'dart:developer';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:dio/dio.dart';

// https://velog.io/@leeeeeoy/Flutter-Dio-간단-정리


void main() =>runApp(d_or_p_1st());

List<double> accelator_x = [];
List<double> accelator_y = [];
List<DateTime> time = [];

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
  void setState(VoidCallback fn) {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (sqrt(event.x * event.x + event.y * event.y + event.z + event.z) > 20){
        accelator_x.add(event.x); // 가속도 x
        accelator_x.add(event.y); // 가속도 y
        accelator_x.add(event.z); // 가속도 z
        time.add(new DateTime.now()); // 난폭 운전이 감지된 시간 저장
        setState(() { });
      }
    });
  }
  @override

  Widget build(BuildContext context) {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (sqrt(event.x * event.x + event.y * event.y + event.z * event.z) > 20) {
        accelator_x.add(event.x); // 가속도 x
        accelator_y.add(event.y); // 가속도 y
        time.add(new DateTime.now());
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
      if (sqrt(e.x * e.x + e.y * e.y + e.z * e.z) <
          20) {
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