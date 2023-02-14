import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEditAlarmPage extends StatefulWidget {
  const AddEditAlarmPage({Key? key}) : super(key: key);

  @override
  State<AddEditAlarmPage> createState() => _AddEditAlarmPageState();
}

class _AddEditAlarmPageState extends State<AddEditAlarmPage> {
  TextEditingController timeTextController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leadingWidth: 100,
            leading: GestureDetector(
                child: Container(
                    alignment: Alignment.center,
                    child:
                        Text("キャンセル", style: TextStyle(color: Colors.orange))),
                onTap: () {
                  Navigator.pop(context);
                }),
            backgroundColor: Colors.black87,
            title: Text("アラームを追加", style: TextStyle(color: Colors.white)),
            actions: [
              GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(right: 20),
                    alignment: Alignment.center,
                    child: Text("保存", style: TextStyle(color: Colors.orange)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  })
            ]),
        body: Container(
            height: double.infinity,
            color: Colors.black,
            child: Column(
              children: [
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('時間', style: TextStyle(color: Colors.white)),
                        Container(
                            width: 70,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(10)),
                            child: TextField(
                                controller: timeTextController,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                // キーボード入力を消す
                                readOnly: true,
                                onTap: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoDatePicker(
                                            initialDateTime: selectedDate,
                                            mode: CupertinoDatePickerMode.time,
                                            onDateTimeChanged: (newDate) {
                                              String time = DateFormat('H:mm')
                                                  .format(newDate);
                                              selectedDate = newDate;
                                              timeTextController.text = time;
                                              setState(() {
                                              });
                                            });
                                      });
                                }))
                      ]),
                ),
              ],
            )));
  }
}
