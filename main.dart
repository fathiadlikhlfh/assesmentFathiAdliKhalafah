import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Price Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StockPage(),
    );
  }
}

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  String stockData = '';

  Future<void> fetchData() async {
    String apiKey = 'i6PJke9Md3qABJd2RKlBBJGas7FpwTDs'; // Ganti dengan kunci API Polygon.io Anda
    String symbol = 'FDTS'; // Ganti dengan simbol saham yang ingin Anda ambil data-nya
    String startDate = '2023-09-25';
    String endDate = '2023-10-25';

    String apiUrl =
        'https://api.polygon.io/v2/aggs/ticker/FDTS/range/1/day/2023-09-25/2023-10-25?apiKey=i6PJke9Md3qABJd2RKlBBJGas7FpwTDs';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        stockData = response.body;
      });
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Saham FDTS'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Kode Saham: FDTS',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 200,
              child: stockData.isNotEmpty
                  ? LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: parseStockData(jsonDecode(stockData)),
                      isCurved: true,
                      colors: [
                        Colors.yellow, // Warna kuning untuk angkatan 2020
                      ],
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: false),
                ),
              )
                  : Center(child: CircularProgressIndicator()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fetchData(); // Panggil fungsi fetchData saat tombol ditekan
              },
              child: Text('Refresh Data'),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  'Data yang ditampilkan merupakan data harga Pembukaan dan Diagram Garisnya berwarna kuning karena angkatan 2020',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> parseStockData(Map<String, dynamic> jsonData) {
    List<FlSpot> spots = [];
    var results = jsonData['results'];
    for (var i = 0; i < results.length; i++) {
      double value;
      if (i % 2 == 0) {
        value = results[i]['o'].toDouble();
      } else {
        value = results[i]['c'].toDouble();
      }

      // Tentukan warna berdasarkan tahun angkatan
      Color color;
      if (i < results.length ~/ 2) {
        color = Colors.yellow; // Warna kuning untuk angkatan 2020
      }

      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }
}
