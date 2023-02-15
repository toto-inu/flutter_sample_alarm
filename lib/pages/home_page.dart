import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:sample_alarm/alarm.dart';
import 'package:sample_alarm/pages/add_edit_alarm_page.dart';
import 'package:sample_alarm/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Alarm> alarmList = [];
  Timer? _timer;
  DateTime time = DateTime.now();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  int id = 0;

  Future<void> initDb() async {
    await DbProvider.setDb();
    alarmList = await DbProvider.getData();
    setState(() {});
  }

  Future<void> reBuild() async {
    print("now rebuilding...");
    alarmList = await DbProvider.getData();
    alarmList.sort((a, b) => a.alarmTime.compareTo(b.alarmTime));
    setState(() {});
  }

  // void notification() {
  //  flutterLocalNotificationsPlugin.show(
  //       1,
  //       'アラーム',
  //       '時間になりました',
  //       NotificationDetails(
  //           android: AndroidNotificationDetails('id', 'name',
  //               importance: Importance.max, priority: Priority.high),
  //           iOS: DarwinNotificationDetails()));
  // }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      await initDb();
      await reBuild();
    });
    flutterLocalNotificationsPlugin.initialize(InitializationSettings(
      // android: AndroidInitializationSettings('ic_launcher'),
      // [Tips] 適切なアプリのアイコンアセットを設定する必要がある。
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // iOS: DarwinInitializationSettings()
    ));

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      print("定期実行🐕 ${DateFormat('HH:mm:ss').format(time)}");
      // time.add(Duration(seconds: 1));
      time = DateTime.now();
      alarmList.forEach((alarm) {
        if (alarm.isActive == true &&
            alarm.alarmTime.hour == time.hour &&
            alarm.alarmTime.minute == time.minute &&
            time.second == 0) {
          print("!!!!!!🐕");
          _showNotification();
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: Colors.black,
            largeTitle: Text('アラーム', style: TextStyle(color: Colors.white)),
            trailing: GestureDetector(
                child: Icon(Icons.add, color: Colors.orange),
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddEditAlarmPage(alarmList)));
                  reBuild();
                }),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              Alarm alarm = alarmList[index];
              return Column(
                children: [
                  if (index == 0) Divider(color: Colors.grey, height: 1),
                  Slidable(
                    key: ValueKey(index),
                    // dismissible: DismissiblePane(onDismissed: (){}),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                            onPressed: (BuildContext context) async {
                              await DbProvider.deleteData(alarmList[index].id);
                              reBuild();
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: "Delete"),
                        SlidableAction(
                            onPressed: (BuildContext context) {
                              print("🐕");
                            },
                            backgroundColor: Color(0xFF21B7CA),
                            foregroundColor: Colors.white,
                            icon: Icons.share,
                            label: "Share"),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          // An action can be bigger than the others.
                          flex: 2,
                          onPressed: (BuildContext context) {
                            print("🐈");
                          },
                          backgroundColor: Color(0xFF7BC043),
                          foregroundColor: Colors.white,
                          icon: Icons.archive,
                          label: 'Archive',
                        ),
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            print("🐈");
                          },
                          backgroundColor: Color(0xFF0392CF),
                          foregroundColor: Colors.white,
                          icon: Icons.save,
                          label: 'Save',
                        ),
                      ],
                    ),
                    child: ListTile(
                        title: Text(DateFormat('H:mm').format(alarm.alarmTime),
                            style:
                                TextStyle(color: Colors.white, fontSize: 50)),
                        trailing: CupertinoSwitch(
                          value: alarm.isActive,
                          onChanged: (newValue) async {
                            alarm.isActive = newValue;
                            await DbProvider.updateData(alarm);
                            reBuild();
                          },
                        ),
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddEditAlarmPage(
                                      alarmList,
                                      index: index)));
                          reBuild();
                        }),
                  ),
                  Divider(color: Colors.grey, height: 0)
                ],
              );
            }, childCount: alarmList.length),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("押したなぁ～");
            _showNotification();
          },
          child: Icon(Icons.mail)),
    );
  }
}
