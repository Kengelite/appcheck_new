import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final WebSocketChannel channel = IOWebSocketChannel.connect('ws://localhost:3010');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    
    // กำหนดการตั้งค่าการแจ้งเตือน
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('flutter_logo');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: onSelectNotification,
    );

    // รับข้อมูลจาก WebSocket Server
    channel.stream.listen((data) {
      final notificationData = json.decode(data);

      final title = notificationData['title'] as String;
      final body = notificationData['body'] as String;

      // แสดงการแจ้งเตือนในแอป
      showNotification(title, body);
    });
  }

  Future<void> onSelectNotification(String? payload) async {
    // ปรับแต่งการจัดการเหตุการณ์เมื่อผู้ใช้คลิกที่การแจ้งเตือน (ถ้าจำเป็น)
  }

  Future<void> showNotification(String title, String body) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'ewewwdsdd',
      'asdadadasd',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID ของการแจ้งเตือน
      title,
      body,
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Push Notification Demo'),
      ),
      body: Center(
        child: Text('รอรับการแจ้งเตือน...'),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
