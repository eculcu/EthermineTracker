import 'package:admin/constants.dart';
import 'package:admin/controllers/MenuController.dart';
import 'package:admin/models/CurrentStat.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:admin/constants.dart';

class AddMiner extends StatelessWidget {
  const AddMiner({Key? key}) : super(key: key);
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
                  "Add Miner",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: AddMinerContent()),
              ],
            )
          ],
        ),
      ),
    ));
  }
}

class AddMinerContent extends StatelessWidget {
  String _value = "";
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        decoration: InputDecoration(hintText: "Wallet Id"),
        onChanged: (value) {
          _value = value;
        },
      ),
      SizedBox(height: defaultPadding),
      ElevatedButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: buttonColor,
          padding: EdgeInsets.symmetric(
            horizontal: defaultPadding * 1.5,
            vertical: defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          if (_value != "") {
            Provider.of<CurrentStatNotifier>(context, listen: false)
                .addWalletId(_value);
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.add),
        label: Text("Add"),
      ),
    ]);
  }
}
