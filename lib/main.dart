import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CooperBitcoinTracker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // o r simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const BitcoinTracker(),
    );
  }
}

Future<int> fetchBitcoinPrice() async {
  final response = await http.get(Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=CAD'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return jsonDecode(response.body)["bitcoin"]["cad"];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to fetch BTC price');
  }
}

class BitcoinTracker extends StatefulWidget {
  const BitcoinTracker({Key? key}) : super(key: key);

  @override
  _BitcoinTrackerState createState() => _BitcoinTrackerState();
}

class _BitcoinTrackerState extends State<BitcoinTracker> {
  late Future<int> bitcoinPrice;
  late TextEditingController tarkovController;
  double tarkovPrice = 0.0;

  @override
  void initState() {
    super.initState();
    tarkovController = TextEditingController(text: '0.0')
      ..addListener(() {
        setState(() {});
      });
    bitcoinPrice = fetchBitcoinPrice();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooper Bitcoin Tracker',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cooper Bitcoin Tracker'),
        ),
        body: Center(
          child: Column(children: [
            const SizedBox(height: 10),
            Container(
              width: 385,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: tarkovController,
                style: const TextStyle(
                  fontSize: 25.0,
                ),
                decoration: const InputDecoration(
                    labelText: 'How much bitcoin did you spend on Tarkov?'),
                textAlign: TextAlign.center,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(height: 10), // For vertical Spacing
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: FutureBuilder<int>(
                  future: bitcoinPrice,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      int currentBitcoinPrice =
                          int.parse(snapshot.data.toString());
                      double priceOfTarkov = 0.0;
                      try {
                        priceOfTarkov = double.parse(tarkovController.text);
                      } catch (e) {}

                      return Text(
                          "Cooper spent: \$" +
                              (currentBitcoinPrice * priceOfTarkov).toString() +
                              " on Escape from Tarkov!",
                          style: TextStyle(fontSize: 32));
                    } else if (snapshot.hasError) {
                      return const Text('Error getting bitcoin price');
                    }
                    return const CircularProgressIndicator();
                  }),
            ),
            Container(
              height: 340.0,
              width: 340.0,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bitcoinsad.jpeg'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
