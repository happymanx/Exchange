/*
  Author: HappyMan
  Date: 2022/02/24
  Topic: HttpClient
 */
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> marketPriceList = [];
  List<double> priceList = [];
  dynamic apiResponse;

  void callGetPriceAPI() {
    marketPriceList = [];
    priceList = [];
    // https://docs.cryptowat.ch/rest-api/
    _getPrice('https://api.cryptowat.ch/markets/coinbase-pro/btcusdt/price', 'Coinbase');
    _getPrice('https://api.cryptowat.ch/markets/binance/btcusdt/price', 'Binance');
    _getPrice('https://api.cryptowat.ch/markets/binance-us/btcusdt/price', 'Binance.US');
    _getPrice('https://api.cryptowat.ch/markets/huobi/btcusdt/price', 'Huobi');
    _getPrice('https://api.cryptowat.ch/markets/gateio/btcusdt/price', 'GateIO');
    _getPrice('https://api.cryptowat.ch/markets/okcoin/btcusdt/price', 'Okcoin');
    _getPrice('https://api.cryptowat.ch/markets/ftx/btcusdt/price', 'FTX');
    _getPrice('https://api.cryptowat.ch/markets/liquid/btcusdt/price', 'Liquid');
    _getPrice('https://api.cryptowat.ch/markets/okex/btcusdt/price', 'Okex');
    _getPrice('https://api.cryptowat.ch/markets/kraken/btcusdt/price', 'Kraken');
    _getPrice('https://api.cryptowat.ch/markets/cexio/btcusdt/price', 'CEX.IO');
    _getPrice('https://api.cryptowat.ch/markets/bitfinex/btcusdt/price', 'Bitfinex');
  }

  _getPrice(String url, String market) async {
    var httpClient = HttpClient();

    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var json = await response.transform(utf8.decoder).join();
        var data = jsonDecode(json);
        result = market + ': ' + data['result']['price'].toString();
        apiResponse = data;
        print('apiResponse');
        print(apiResponse);
      } else {
        result = 'Error getting Bitcoin price:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting Bitcoin price';
      print('exception');
      print(exception);
    }

    setState(() {
      marketPriceList.add(result);

      // 解析取得價格
      var parts = result.split(' ');// Ex: "Binance: 37777.1"
      if (parts.length > 1) {
        priceList.add(double.parse(parts[1]));
      }
      print('priceList');
      print(priceList);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizedBox spacer = SizedBox(height: 10.0);
    DateTime dateTime = DateTime.now();

    // 取得幣價最小值
    double _getMin(){
      if (priceList.length == 0)
        return 0;
      double min = priceList.first;
      for (int i = 1; i < priceList.length; i++) {
        if (min > priceList[i]) {
          min = priceList[i];
        }
      }
      return min;
    }
    // 取得幣價最大值
    double _getMax(){
      if (priceList.length == 0)
        return 0;
      double max = priceList.first;
      for (int i = 1; i < priceList.length; i++) {
        if (max < priceList[i]) {
          max = priceList[i];
        }
      }
      return max;
    }
    // 取得幣價最小值的市場
    String _getMinMarket(){
      double min = _getMin();
      for (int i = 1; i < marketPriceList.length; i++) {
        if (marketPriceList[i].contains(min.toString())) {
          // 解析取得市場
          var parts = marketPriceList[i].split(':');// Ex: "Binance: 37777.1"
          if (parts.length > 1) {
            return parts[0];
          }
        }
      }
      return 'None';
    }
    // 取得幣價最大值的市場
    String _getMaxMarket(){
      double max = _getMax();
      for (int i = 1; i < marketPriceList.length; i++) {
        if (marketPriceList[i].contains(max.toString())) {
          // 解析取得市場
          var parts = marketPriceList[i].split(':');// Ex: "Binance: 37777.1"
          if (parts.length > 1) {
            return parts[0];
          }
        }
      }
      return 'None';
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Your current Bitcoin price is:'),
            spacer,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                border: Border.all(
                  color: Colors.grey,
                  width: 3,
                ),
                color: Colors.black12,
              ),
              margin: EdgeInsets.all(50),
              height: 250,
              width: 200,
              child: Column(
                children: [
                  for (int i = 0; i < marketPriceList.length; i++)
                    Text(marketPriceList[i]),
                ],
              ),
            ),
            Text('Max: ' + _getMax().toString() + ' ' + _getMaxMarket(),
              style: TextStyle(
                color: Colors.redAccent,
              ),
            ),
            Text('Min: ' + _getMin().toString() + ' ' + _getMinMarket(),
              style: TextStyle(
                color: Colors.blueAccent,
              ),
            ),
            spacer,
            Text('Time: ' + dateTime.toString().substring(0,19)),
            spacer,
            ElevatedButton(
              onPressed: callGetPriceAPI,
              child: Text('Get Bitcoin price'),
            ),
            spacer,
            Container(
              margin: EdgeInsets.all(50),
              child: Text(
                apiResponse!=null?apiResponse.toString():'',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}