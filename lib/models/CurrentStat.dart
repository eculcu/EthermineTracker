import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';

class CurrentStat {
  double reportedHash = 0;
  double currentHash = 0;
  double averageHash = 0;
  String validShares = "";
  String invalidShares = "";
  double unPaidEth = 0;
  String walletId = "";
  double unPaidUsd = 0;
  CurrentStat(
      {required this.reportedHash,
      required this.currentHash,
      required this.averageHash,
      required this.validShares,
      required this.invalidShares,
      required this.unPaidEth,
      required this.walletId,
      required this.unPaidUsd});

  factory CurrentStat.fromJson(
      Map<String, dynamic> json, String walletId, double ethPrice) {
    return CurrentStat(
        reportedHash:
            double.parse(json['reportedHashrate'].toString()) / 1000000,
        currentHash: double.parse(json['currentHashrate'].toString()) / 1000000,
        averageHash: double.parse(json['averageHashrate'].toString()) / 1000000,
        validShares: json['validShares'].toString(),
        invalidShares: json['invalidShares'].toString(),
        unPaidEth: double.parse(json['unpaid'].toString()) / 10e17,
        walletId: walletId,
        unPaidUsd: double.parse(json['unpaid'].toString()) / 10e17 * ethPrice);
  }
}

class CurrentStatNotifier with ChangeNotifier {
  static List<String> _walletList = [];
  static List<CurrentStat> _stats = [];
  static double _ethPrice = 0;
  static HttpEthermineService service = HttpEthermineService();
  Future<void> initialize() async {
    await service.getPoolStats().then((Map<String, dynamic> value) {
      _ethPrice = double.parse(value['price']['usd'].toString());
    });
    var prefs = await SharedPreferences.getInstance();
    var walletList = prefs.getStringList('walletList');
    if (walletList == null)
      prefs.setStringList('walletList', _walletList);
    else {
      _walletList = walletList;
      for (var walletId in _walletList) {
        await service
            .getCurrentStats(walletId)
            .then((Map<String, dynamic> value) {
          _stats.add(CurrentStat.fromJson(value, walletId, _ethPrice));
          notifyListeners();
        });
      }
    }
  }

  CurrentStat getStat(int idx) {
    return _stats[idx];
  }

  double getEthPrice() {
    return _ethPrice;
  }

  Future<void> getAllStat() async {
    await service.getPoolStats().then((Map<String, dynamic> value) {
      _ethPrice = double.parse(value['price']['usd'].toString());
    });
    for (var i = 0; i < _walletList.length; i++) {
      service
          .getCurrentStats(_walletList[i])
          .then((Map<String, dynamic> value) {
        _stats[i] = CurrentStat.fromJson(value, _walletList[i], _ethPrice);
        notifyListeners();
      });
    }
  }

  void getCurrentStat(String walletId, int idx) {
    service.getPoolStats().then((Map<String, dynamic> value) {
      _ethPrice = double.parse(value['price']['usd'].toString());
    });
    service.getCurrentStats(walletId).then((Map<String, dynamic> value) {
      _stats[idx] = CurrentStat.fromJson(value, walletId, _ethPrice);
      notifyListeners();
    });
  }

  List<String> getWalletList() {
    return _walletList;
  }

  Future<void> addWalletId(String walletId) async {
    _walletList.add(walletId);
    var prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('walletList', _walletList);
    CurrentStat stat = CurrentStat(
        reportedHash: 0,
        currentHash: 0,
        averageHash: 0,
        validShares: '',
        invalidShares: '',
        unPaidEth: 0,
        walletId: walletId,
        unPaidUsd: 0);
    _stats.add(stat);
    getCurrentStat(walletId, _stats.length - 1);
  }

  Future<void> deleteWalletId(int idx) async {
    _walletList.removeAt(idx);
    _stats.removeAt(idx);
    var prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('walletList', _walletList);
    notifyListeners();
  }
}

class HttpEthermineService {
  Future<Map<String, dynamic>> getPoolStats() async {
    var url = Uri.https('api.ethermine.org', '/poolStats', {'q': '{http}'});
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse['data'];
    }
    return new Map<String, dynamic>();
  }

  Future<Map<String, dynamic>> getCurrentStats(walletId) async {
    var url = Uri.https(
        'api.ethermine.org', '/miner/:$walletId/currentStats', {'q': '{http}'});
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse['data'];
    }
    return new Map<String, dynamic>();
  }
}
