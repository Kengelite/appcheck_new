import 'package:app_checkstd/noti_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Mynoti extends StatefulWidget {
  const Mynoti({super.key});

  @override
  State<Mynoti> createState() => _MynotiState();
}

class _MynotiState extends State<Mynoti> {
  @override
  void initState() {
    // TODO: implement initState
    WidgetsFlutterBinding.ensureInitialized();
    NotificationService().initNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("show noti"),
      ),
      body: Center(
          child: ElevatedButton(
        child: const Text('Show notifications'),
        onPressed: () {
          NotificationService()
              .showNotification(title: 'Sample title', body: 'It works!');
          print("ds");
        },
      )),
    );
  }
}
