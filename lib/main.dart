import 'dart:convert';

import 'package:app_checkstd/apiprovider.dart';
import 'package:app_checkstd/menu.dart';
import 'package:app_checkstd/noti_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKenty = GlobalKey<FormState>();
  api_Pro apiPro = api_Pro();
  final TextEditingController _txtid = TextEditingController();
  final TextEditingController _txtemail = TextEditingController();
  String? id;
  // late SharedPreferences prefs;
  late SharedPreferences prefs;
  bool check_load_data = true;
  String? lati;
  String? long;

  docheck() async {
    // print("object");
    try {
      if (_formKenty.currentState!.validate()) {
        var rs = await apiPro.doChecklogin(_txtid.text, _txtemail.text);
        if (rs.statusCode == 200) {
          var jsonRes = await json.decode(rs.body);
          if (jsonRes["success"] == true) {
            // thawitchapon.trv
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            String std_id = jsonRes["data"][0]['id'].toString();
            String std_id_full = jsonRes["data"][0]['std_id'].toString();
            print(std_id);
            // String id = std_id.substring(std_id.length - 5);
            // print(id); // 7890

            prefs.setString("id", std_id);
            String name_id = jsonRes["data"][0]['nickname'].toString();
            print(name_id);
            // String id = std_id.substring(std_id.length - 5);
            // print(id); // 7890

            prefs.setString("name", name_id);
            prefs.setString("std_id", std_id_full);
            // pushReplacement
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => PageMenu()));
            // print("dsd");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text("ไม่พบข้อมูล", style: TextStyle(color: Colors.black)),
                  ],
                ),
                backgroundColor: Colors.white, // สีพื้นหลังของ SnackBar
                duration: Duration(seconds: 5), // ระยะเวลาที่ SnackBar จะแสดง.
                behavior: SnackBarBehavior.floating, // แสดงในลักษณะแบบ floating
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text("ข้อมูลไม่ครบถ้วนกรุณาตรวจสอบข้อมูล",
                    style: TextStyle(color: Colors.black)),
              ],
            ),
            backgroundColor: Colors.white, // สีพื้นหลังของ SnackBar
            duration: Duration(seconds: 5), // ระยะเวลาที่ SnackBar จะแสดง
            behavior: SnackBarBehavior.floating, // แสดงในลักษณะแบบ floating
          ),
        );
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
              Text("เกิดข้อผิดพลาดกรุณาตรวจสอบข้อมูลอีกครั้ง222",
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

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    NotificationService().initNotification();
    getuser();
    super.initState();
  }

  getuser() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id') == null ? "" : prefs.getString('id');
    });
    if (id != "") {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => PageMenu()));
      });
    } else {
      check_load_data = false;
    }
  }

  Widget box_datablank() {
    return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
      color: Colors.blue,
      size: 100,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: const Text("เข้าสู่ระบบ"),
      // ),
      body: check_load_data
          ? box_datablank()
          : Form(
              key: _formKenty,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // width: 200,
                    child: Image.asset(
                      "images/index.png",
                      height: 250,
                      width: 360,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 20, 17, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                        validator: (value) {
                          if (value == "" || value!.isEmpty) {
                            return "ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบข้อมูล";
                          }
                        },
                        controller: _txtemail,
                        decoration: const InputDecoration(
                            fillColor: Colors.white70,
                            filled: true,
                            labelText: "อีเมล",
                            labelStyle: TextStyle(fontSize: 18),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 20, 17, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                        validator: (value) {
                          if (!RegExp(r'^\d{3}').hasMatch(value!) ||
                              value!.isEmpty ||
                              value.length != 5 ||
                              !value.contains('-') ||
                              value.indexOf('-') != 3) {
                            if (!value!.contains('-')) {
                              return "กรุณาเติม - ให้ครบถ้วน";
                            } else if (value.length != 5 ||
                                value.indexOf('-') != 3) {
                              return "กรุณากรอกรหัสนักศึกษา 4 ตัวท้ายให้ถูกต้อง";
                            } else {
                              return "กรุณากรอกข้อมูลให้ถูกต้อง";
                            }
                          }
                        },
                        controller: _txtid,
                        decoration: const InputDecoration(
                            fillColor: Colors.white70,
                            filled: true,
                            labelText: "รหัสนักศึกษา 4 ตัวท้ายมีขีด",
                            labelStyle: TextStyle(fontSize: 18),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 20, 7, 0),
                    child: SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: TextButton(
                          onPressed: () {
                            docheck();
                            // Navigator.push(context,
                            //     MaterialPageRoute(builder: (context) => PageMenu()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.blue),
                            child: const Center(
                              child: Text("เข้าสู่ระบบ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      letterSpacing: 3.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
    );
  }
}
