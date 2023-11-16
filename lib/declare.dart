import 'dart:convert';

import 'package:app_checkstd/apiprovider.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Page_declare extends StatefulWidget {
  const Page_declare({super.key});

  @override
  State<Page_declare> createState() => _Page_declareState();
}

class _Page_declareState extends State<Page_declare> {
  late SharedPreferences prefs;
  String? id;
  String? name;
   bool check_load_data = true;
  api_Pro apiPro = api_Pro();
  final List<Widget> List_dataannounce = [];
  @override
  void initState() {
    // TODO: implement initState
    getUser();

    super.initState();
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id')!;
      name = prefs.getString('name')!;
    });
    getdatahistory();
  }

  getdatahistory() async {
    try {
      var rs = await apiPro.dodataannounce(id.toString());
      if (rs.statusCode == 200) {
        print("sss");
        var jsonRes = await json.decode(rs.body);
        print(jsonRes);
        if (jsonRes["success"] == true) {
          if (jsonRes["success"] == true) {
            for (var val in jsonRes["data_announce"]) {
              List_dataannounce.add(
                  box_data(val["head_content"], val["content"].toString()));
              setState(() {});
            }
          }
          check_load_data = false;
        } else {
              check_load_data = false;
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text("เกิดข้อผิดพลาดกรุณาตรวจสอบข้อมูลอีกครั้ง",
                  style: TextStyle(color: Colors.black)),
            ],
          ),
          backgroundColor: Colors.white, // สีพื้นหลังของ SnackBar
          duration: Duration(seconds: 5), // ระยะเวลาที่ SnackBar จะแสดง
          behavior: SnackBarBehavior.floating, // แสดงในลักษณะแบบ floating
        ),
      );
    }
  }

  Widget box_data(String Head, String content) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        height: 80,
         decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child:  ListTile(
        leading: CircleAvatar(),
        title: Text('$Head',
            style: TextStyle(fontSize: 18, color: Colors.black)),
        subtitle:
            Text('$content', style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 109, 109, 109))),
        // trailing: Text('12:45 am', style: TextStyle(color: Colors.black)),
      ),
      ),
    );
  }

  Widget box_laoddata() {
    return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
      color: Colors.blue,
      size: 100,
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ประกาศ"),
      ),
      body: check_load_data ? box_laoddata() : SingleChildScrollView(
        child: 
      List_dataannounce.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                 child: Column(children: List_dataannounce))
              : Text("ไม่พบข้อมูล"),
        
      ),
    );
  }
}
