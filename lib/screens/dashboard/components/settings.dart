import 'dart:async';

import 'package:ethermine_tracker/responsive.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:ethermine_tracker/models/CurrentStat.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:ethermine_tracker/constants.dart';
import 'package:flutter_switch/flutter_switch.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                BackButton(),
                Text(
                  "Settings",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [SettingsContent()],
            ),
          ],
        ),
      ),
    ));
  }
}

class SettingsContent extends StatefulWidget {
  _SettingsContentState createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  bool _notificationStatus = false;
  int _timerValueInMin = 3;
  Timer? _timer;
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Send notification periodically"),
              Container(
                alignment: Alignment.centerRight,
                child: FlutterSwitch(
                  width: 55.0,
                  height: 25.0,
                  valueFontSize: 12.0,
                  toggleSize: 18.0,
                  value: _notificationStatus,
                  onToggle: (val) {
                    setState(() {
                      _notificationStatus = val;
                      if (_notificationStatus) {
                        _timer = Timer.periodic(
                            Duration(minutes: _timerValueInMin), (timer) {
                          setState(() {
                            Provider.of<CurrentStatNotifier>(context,
                                    listen: false)
                                .getNotificationBody();
                          });
                        });
                      } else {
                        _timer?.cancel();
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: NumberPicker(
                  value: _timerValueInMin,
                  minValue: 1,
                  maxValue: 60,
                  axis: Axis.horizontal,
                  onChanged: (value) => setState(() {
                    _timerValueInMin = value;
                    if (_notificationStatus) {
                      _timer?.cancel();
                      _timer = Timer.periodic(
                          Duration(minutes: _timerValueInMin), (timer) {
                        setState(() {
                          Provider.of<CurrentStatNotifier>(context,
                                  listen: false)
                              .getNotificationBody();
                        });
                      });
                    }
                  }),
                ),
              ),
              Text('Current timer : $_timerValueInMin' + ' in minutes'),
            ],
          ),
        ]);
  }

  void createTimer(int val) {}
}
