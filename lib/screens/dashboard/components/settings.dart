import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/CurrentStat.dart';
import 'package:provider/provider.dart';
import 'package:admin/constants.dart';
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
  bool status1 = false;
  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Make notification permanent"),
          Container(
            alignment: Alignment.centerRight,
            child: FlutterSwitch(
              width: 55.0,
              height: 25.0,
              valueFontSize: 12.0,
              toggleSize: 18.0,
              value: status1,
              onToggle: (val) {
                setState(() {
                  status1 = val;
                });
              },
            ),
          ),
        ]);
  }
}
