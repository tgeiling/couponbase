import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'elements.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final int savedStamps = prefs.getInt('savedStamps') ?? 0;

  runApp(
    ChangeNotifierProvider(
      create: (context) => StampProvider(initialStamps: savedStamps),
      child: MyApp(),
    ),
  );
}

class StampProvider with ChangeNotifier {
  int _stamps;

  StampProvider({required int initialStamps}) : _stamps = initialStamps;

  int get stamps => _stamps;

  void addStamp() {
    if (_stamps < 9) {
      _stamps++;
      notifyListeners();
      _saveStampsToPrefs();
    }
  }

  Future<void> _saveStampsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('savedStamps', _stamps);
  }

  Future<void> loadStamps() async {
    final prefs = await SharedPreferences.getInstance();
    _stamps = prefs.getInt('savedStamps') ?? 0;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                Icons.menu,
                size: 32,
                color: Colors.grey.shade800,
              ),
              Text(
                '${Provider.of<StampProvider>(context).stamps}',
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(6.0),
          color: Colors.white,
          child: LoyaltyCard(),
        ),
      ),
    );
  }
}

class LoyaltyCard extends StatelessWidget {
  final int totalStamps = 9;

  @override
  Widget build(BuildContext context) {
    var stampProvider = Provider.of<StampProvider>(context);
    int currentStamps = stampProvider.stamps;

    void _onQRViewCreated(
        QRViewController controller, StampProvider stampProvider) {
      controller.scannedDataStream.listen((scanData) {
        if (scanData.code == "STAMP_CODE_123") {
          controller.pauseCamera(); // Stop the camera
          stampProvider.addStamp(); // Add a stamp
          Navigator.pop(context); // Close the scanner view
        }
      });
    }

    return Card(
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/logo.png', height: 60), // Top logo
            SizedBox(height: 20),
            Text(
              'Besuche uns 9 mal und wir belohnen dich',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            Expanded(
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: totalStamps,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: index < currentStamps
                          ? Image.asset('assets/coin.png')
                          : Image.asset('assets/coin_gray.png'),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            PressableButton(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => QRScanPage(
                          onQRViewCreated: (controller) =>
                              _onQRViewCreated(controller, stampProvider),
                        )));
              },
              child: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}

class QRScanPage extends StatelessWidget {
  final Function(QRViewController) onQRViewCreated;

  QRScanPage({required this.onQRViewCreated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: GlobalKey(debugLabel: 'QR'),
        onQRViewCreated: onQRViewCreated,
      ),
    );
  }
}
