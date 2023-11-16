import 'dart:convert';

import 'package:app_checkstd/apiprovider.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pagescore extends StatefulWidget {
  final String? data;
  const Pagescore({Key? key, required this.data}) : super(key: key);

  @override
  State<Pagescore> createState() => _PagescoreState();
}

class _PagescoreState extends State<Pagescore> {
  late SharedPreferences prefs;
  String? id;
  String? name;
  String? id_sub;
  bool check_load_data = true;
  api_Pro apiPro = api_Pro();
  final List<Widget> List_datascore = [];

  @override
  void initState() {
    // TODO: implement initState
    getUser();
    id_sub = widget.data;
    print("sssssss=>" + id_sub!);
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
      var rs = await apiPro.dohistoryscore(id!, id_sub.toString());
      if (rs.statusCode == 200) {
        var jsonRes = await json.decode(rs.body);
        if (jsonRes["success"] == true) {
          for (var val in jsonRes["data_history"]) {
            List_datascore.add(box_data(val["name_type_quiz"],
                val["score"] + " / " + val["total"], val["text"]));
            setState(() {});
          }
           check_load_data = false;
           setState(() {
            
          });
          //  print(check_load_data);
        } else{
          check_load_data = false;
          setState(() {
            
          });
        }
        print(check_load_data);
      }
    } catch (err) {
      // ignore: use_build_context_synchronously
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

  Widget box_data(String Head, String score, String content) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          // leading: CircleAvatar(),
          title: Text('$Head $score',
              style: TextStyle(fontSize: 18, color: Colors.black)),
          subtitle: Text('$content',
              style: TextStyle(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 109, 109, 109))),
          // trailing: Text('12:45 am', style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }

  Widget box_datablank() {
    return Center(
      child: Text("ไม่พบข้อมูล"),
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
        title: const Text("สรุปคะแนนทั้งหมด"),
      ),
      body: check_load_data
          ? box_laoddata()
          : SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height),
                child: List_datascore.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: Column(children: List_datascore),
                      )
                    : box_datablank(),
              ),
            ),
    );
  }
}
