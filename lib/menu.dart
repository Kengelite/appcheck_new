// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:app_checkstd/aa.dart';
import 'package:app_checkstd/apiprovider.dart';
import 'package:app_checkstd/declare.dart';
import 'package:app_checkstd/main.dart';
import 'package:app_checkstd/score.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class PageMenu extends StatefulWidget {
  const PageMenu({super.key});

  @override
  State<PageMenu> createState() => _PageMenuState();
}

class _PageMenuState extends State<PageMenu> {
  late SharedPreferences prefs;
  String id = "";
  String name = "";
  String lati = "";
  String? fullid;
  bool check_load_data = false;
  String longti = "";
  String? deviceId;
  late LocationPermission permission;
  bool permissionGranted = false;
  api_Pro apiPro = api_Pro();
  int check_bouble_scoresubject = 0;
  String _site = "";
  final List<Widget> List_datasubject = [];

  @override
  void initState() {
    getUser();
    // getlocation();
    getIdname();
    print(permissionGranted);

    super.initState();
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id')!;
      name = prefs.getString('name')!;
      fullid = prefs.getString('std_id')!;
    });
  }

  getIdname() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo? androidInfo = await deviceInfo.androidInfo;
        if (androidInfo != null) {
          deviceId = androidInfo.model;
          print('Running on ${deviceId}');
        } else {
          print('Android device information not available');
        }
      } else if (Platform.isIOS) {
        IosDeviceInfo? iosInfo = await deviceInfo.iosInfo;
        if (iosInfo != null) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor;
          print('Running on ${deviceId}');
        } else {
          print('iOS device information not available');
        }
      }
    } catch (e) {
      print('Error retrieving device information: $e');
    }
  }

  getlocation() async {
    Position posi = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    lati = (posi.latitude).toString();
    longti = (posi.longitude).toString();
    await getIdname();
  }

  checkname() async {
    final now = DateTime.now();

    await getlocation();

    try {
      var rs = await apiPro.dochecktime(
          now.toString(), id.toString(), lati, longti, deviceId!);
      if (rs.statusCode == 200) {
        check_load_data = false;
        setState(() {});
        var jsonRes = await json.decode(rs.body);
        print(jsonRes);
        if (jsonRes["success"] == true) {
          // thawitchapon.trv
          //  print("adsasdasd");
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          // String id = std_id.substring(std_id.length - 5);
          // print(id); // 7890
          final dateFormatter = DateFormat('dd/MM/yyyy');

          // แปลง DateTime เป็นรูปแบบวันที่
          final formattedDate = dateFormatter.format(now);
          final dateTimeFormatter = DateFormat('HH:mm');

          // แปลง DateTime เป็นรูปแบบวันที่
          final formattedDateTime = dateTimeFormatter.format(now);
          return showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                // <-- SEE HERE
                title: Text(
                  'บันทึกเวลาเรียนรหัสวิชา ' + jsonRes["subjectname"],
                  style: TextStyle(fontSize: 18),
                ),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          400.0, // กำหนดความกว้างของ AlertDialog ที่ต้องการ
                    ),
                    child: ListBody(
                      children: <Widget>[
                        Text('วันที่  ' + formattedDate,
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                        Text('บันทึกเวลา ' + formattedDateTime,
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                        Text('ส่วนของ ' + jsonRes["typename"],
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                        Text(jsonRes["text"],
                            style: TextStyle(color: Colors.red, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('ตกลง', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          // print("dsd");
        } else {
          return showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                // <-- SEE HERE
                title: Text(
                  'ข้อผิดพลาด',
                  style: TextStyle(fontSize: 22),
                  // textAlign: TextAlign.center,
                ),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          300.0, // กำหนดความกว้างของ AlertDialog ที่ต้องการ
                    ),
                    child: Center(
                      child: ListBody(
                        children: <Widget>[
                          Text(jsonRes["text"],
                              //  textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('ตกลง', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
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

  getdatahistory() async {
    try {
      var rs = await apiPro.dodatasubject(id!);
      if (rs.statusCode == 200) {
        var jsonRes = await json.decode(rs.body);
        print(jsonRes);
        if (jsonRes["success"] == true) {
          for (var val in jsonRes["data_subjebt"]) {
            List_datasubject.add(
                box_data(val["number_subject"], val["sub_id"].toString()));
            setState(() {});
          }
          check_bouble_scoresubject = 0;
          setState(() {});
        }
      }
      gethistory_or_score();
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

  Widget box_data(String subname, String id_sub) {
    return TextButton(
      child: Text("$subname", style: TextStyle(fontSize: 16)),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Pagescore(data: id_sub)));
      },
    );
  }

  gethistory_or_score() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // contentPadding: EdgeInsets.zero, // ลบ Padding ของ Content
          // titlePadding: EdgeInsets.zero,
          // <-- SEE HERE
          title: const Text(
            'กรุณาเลือกวิชาที่ต้องการ',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300.0, // กำหนดความกว้างของ AlertDialog ที่ต้องการ
              ),
              child: ListBody(children: List_datasubject),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ปิด', style: TextStyle(fontSize: 18)),
              onPressed: () {
                List_datasubject.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget box_datablank() {
    return Container(
// ปรับขนาดตามต้องการ
      color: Colors.grey.withOpacity(0.2), // ตั้งค่าสีพื้นหลังแบบโปร่งแสง
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.blue,
          size: 100, // ปรับขนาดลงตามต้องการ
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 100.0, 
        title:
            // Text('คุณ $name', style: TextStyle(fontSize: 20, color: Colors.black)),
            Text('รหัสนักศึกษา $fullid',
                style: TextStyle(fontSize: 20, color: Colors.black)),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0), // ปรับระยะห่างตามต้องการ
            child: IconButton(
              onPressed: () {
                prefs.remove('id');
                prefs.remove('name');
                prefs.remove('std_id');
                // std_id
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
              icon: Icon(Icons.exit_to_app, size: 30),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        titleSpacing: 5,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: SizedBox(
                          // width: 200,
                          height: 160,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                check_load_data = true;
                              });

                              checkname();
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => PageMenu()));
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 206, 206, 206),
                                      offset: Offset(
                                        5.0,
                                        5.0,
                                      ),
                                      blurRadius: 10.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      child: Container(
                                        width: 160,
                                        child: Image.asset(
                                          "images/checkstd.png",
                                          height: 80,
                                          width: 120,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      child: Text("เช็คชื่อ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black)),
                                    ),
                                  ],
                                )),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: SizedBox(
                          // width: 200,
                          height: 160,
                          child: TextButton(
                            onPressed: () {
                              // gethistory_or_score("1");
                              if (check_bouble_scoresubject == 0) {
                                getdatahistory();

                                setState(() {
                                  check_bouble_scoresubject = 1;
                                });
                              }

                              // getlocation();
                              //          Navigator.push(
                              // context, MaterialPageRoute(builder: (context) => Page_history()));
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 206, 206, 206),
                                      offset: Offset(
                                        5.0,
                                        5.0,
                                      ),
                                      blurRadius: 10.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
                                      child: Container(
                                        width: 160,
                                        child: Image.asset(
                                          "images/checkstd.png",
                                          height: 80,
                                          width: 120,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      child: Text("สรุปคะแนน",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black)),
                                    ),
                                  ],
                                )),
                          )),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: SizedBox(
                          // width: 200,
                          height: 160,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                  // Mynoti
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Page_declare()));
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 206, 206, 206),
                                      offset: Offset(
                                        5.0,
                                        5.0,
                                      ),
                                      blurRadius: 10.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
                                      child: Container(
                                        width: 160,
                                        child: Image.asset(
                                          "images/checkstd.png",
                                          height: 80,
                                          width: 120,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      child: Text("ประกาศ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black)),
                                    ),
                                  ],
                                )),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Visibility(
              visible: check_load_data,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      check_load_data =
                          false; // เมื่อคลิกที่ box_datablank() เพื่อซ่อน
                    });
                  },
                  child: box_datablank()),
            ),
          ),
        ],
      ),
    );
  }
}
