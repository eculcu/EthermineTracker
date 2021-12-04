import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/CurrentStat.dart';
import 'package:provider/provider.dart';
import 'package:admin/constants.dart';

import '../../../constants.dart';
import 'file_info_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:loading_animations/loading_animations.dart';

class MyMiners extends StatelessWidget {
  const MyMiners({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyMinerList();
  }
}

class MyMinerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var isReady = Provider.of<CurrentStatNotifier>(context).getIsReady();
    var widgetList = <Widget>[];
    widgetList.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "My Miners",
          style: Theme.of(context).textTheme.subtitle1,
        ),
        ElevatedButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: buttonColor,
            padding: EdgeInsets.symmetric(
              horizontal: defaultPadding * 1.5,
              vertical: defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () {
            Provider.of<CurrentStatNotifier>(context, listen: false)
                .getAllStat();
          },
          icon: Icon(Icons.refresh),
          label: Text("Refresh"),
        ),
      ],
    ));
    if (isReady == false) {
      widgetList.add(CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber)));
      Provider.of<CurrentStatNotifier>(context, listen: false).initialize();
    } else {
      widgetList.add(Row(children: [
        Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Etherium'),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                        Provider.of<CurrentStatNotifier>(context)
                                .getEthPrice()
                                .toStringAsFixed(1) +
                            ' USD',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ))
      ]));
      var list = Provider.of<CurrentStatNotifier>(context).getWalletList();
      for (var i = 0; i < list.length; i++) {
        widgetList.add(SizedBox(height: defaultPadding));
        widgetList.add(MyMinerContainer(i));
      }
    }
    return Column(children: widgetList);
  }
}

// ignore: must_be_immutable
class MyMinerContainer extends StatelessWidget {
  int walletIdx = -1;
  MyMinerContainer(idx) {
    walletIdx = idx;
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showAlertDialog(context);
      },
      child: Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, size: 15),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                      Provider.of<CurrentStatNotifier>(context)
                          .getStat(walletIdx)
                          .walletId,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              MyMinerRow(
                  keyVal: 'Reported Hashrate',
                  val: Provider.of<CurrentStatNotifier>(context)
                          .getStat(walletIdx)
                          .reportedHash
                          .toStringAsFixed(1) +
                      ' Mh/s'),
              MyMinerRow(
                  keyVal: 'Current Hashrate',
                  val: Provider.of<CurrentStatNotifier>(context)
                          .getStat(walletIdx)
                          .currentHash
                          .toStringAsFixed(1) +
                      ' Mh/s'),
              MyMinerRow(
                  keyVal: 'Avarage Hashrate',
                  val: Provider.of<CurrentStatNotifier>(context)
                          .getStat(walletIdx)
                          .averageHash
                          .toStringAsFixed(1) +
                      ' Mh/s'),
              MyMinerRow(
                  keyVal: 'Valid Shares',
                  val: Provider.of<CurrentStatNotifier>(context)
                      .getStat(walletIdx)
                      .validShares),
              MyMinerRow(
                  keyVal: 'Invalid Shares ',
                  val: Provider.of<CurrentStatNotifier>(context)
                      .getStat(walletIdx)
                      .invalidShares),
              MyMinerRow(
                  keyVal: 'Unpaid ETH',
                  val: Provider.of<CurrentStatNotifier>(context)
                          .getStat(walletIdx)
                          .unPaidEth
                          .toStringAsFixed(5) +
                      ' ETH'),
              MyMinerRow(
                  keyVal: 'Unpaid USD',
                  val: Provider.of<CurrentStatNotifier>(context)
                          .getStat(walletIdx)
                          .unPaidUsd
                          .toStringAsFixed(5) +
                      ' USD')
            ],
          )),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Provider.of<CurrentStatNotifier>(context, listen: false)
            .deleteWalletId(walletIdx);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Wallet Id was deleted"),
        ));
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Wallet Id"),
      content: Text("Would you like to continue to delete this wallet id?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

// ignore: must_be_immutable
class MyMinerRow extends StatelessWidget {
  String _key = "";
  String _val = "";
  MyMinerRow({Key? key, required String keyVal, required String val})
      : _key = keyVal,
        _val = val,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(_key + " :"),
          flex: 2,
        ),
        Expanded(
          child: Text(_val),
          flex: 3,
        )
      ],
    );
  }
}
