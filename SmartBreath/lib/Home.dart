import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbreath/Anasayfa.dart';
import 'package:smartbreath/Notification.dart';
import 'package:smartbreath/services/Configuration.dart';
import 'package:smartbreath/services/user_model.dart';

import 'dart:convert' show utf8;
import 'package:flutter_blue/flutter_blue.dart';

class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return Home();
            }
            return BluetoothOffScreen(state: state);
          });
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, required this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle1
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  BluetoothDevice? device;
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String TARGET_DEVICE_NAME = "SmartBreath";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? scanSubScription;

  BluetoothCharacteristic? targetCharacteristic;

  String connectionText = "";

  var list = [];
  double temp = 0.00;
  double humi = 0.00;
  double oksijen = 0.00;
  double mq9 = 0.00;

  bool sicaklikrenk = false;
  bool nemrenk = false;
  bool oksijenrenk = false;
  bool mq9renk = false;

  double deger = 0.0;

  bool menuIcon = false;

  int tempSayac = 0;
  int nemSayac = 0;
  int mq9Sayac = 0;

  int locationSayac = 0;

  bool notify = false;

  @override
  void initState() {
    super.initState();
    startScan();
    //currentLocation();
    getFirebase();
  }

  startScan() {
    setState(() {
      connectionText = "Start Scanning";
      print(connectionText);
    });

    scanSubScription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == TARGET_DEVICE_NAME) {
        print('DEVICE found');
        stopScan();
        setState(() {
          connectionText = "Found Target Device";
          print(connectionText);
        });

        device = scanResult.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  connectToDevice() async {
    if (device == null) return;

    setState(() {
      connectionText = "Device Connecting";
      print(connectionText);
    });

    await device!.connect();
    print("Device Connect ${device!.name}");
    device?.discoverServices();
    print('DEVICE CONNECTED');
    setState(() {
      connectionText = "Device Connected";
      print(connectionText);
    });
  }

  disconnectFromDevice() {
    if (device == null) return;

    device!.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
      print(connectionText);
    });
  }

  User? user = FirebaseAuth.instance.currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  UserModel? userModel = UserModel();
  Position? position;
  String? indirmeBaglantisi;

  int i = 0;

  void currentLocation() async {
    var pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      position = pos;
    });
    var lat = pos.latitude;
    var long = pos.longitude;

    int i = 0;
    await FirebaseFirestore.instance
        .collection('location')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var uzunluk = doc["latitude"];
        var genislik = doc["longitude"];
        if (pos.latitude >= uzunluk - 0.0001 &&
            pos.latitude <= uzunluk + 0.0001 &&
            pos.longitude >= genislik - 0.0001 &&
            pos.longitude <= genislik + 0.0001) {
          i++;
        }
      });
    });

    if(i == 0){
      await FirebaseFirestore.instance
          .collection('location')
          .add({'latitude': lat, 'longitude': long});
    }
  }

  Future getFirebase() async {
    await FirebaseFirestore.instance
        .collection("person")
        .doc(user!.uid)
        .get()
        .then((value) => {
              this.userModel = UserModel.fromMap(value.data()),
              setState(() {
              }),
            });
  }

  Widget _verilerial(List<BluetoothService> services) {
    Stream<List<int>>? stream;

    services.forEach((service) {
      service.characteristics.forEach((character) async {
        final prefs = await SharedPreferences.getInstance();
        notify = prefs.getBool('notify') ?? true;
        if (character.uuid.toString() == CHARACTERISTIC_UUID) {
          var characteristics = service.characteristics;

          for (BluetoothCharacteristic c in characteristics) {
            List<int> value = await c.read();
            var newValue = _dataParser(value);
            list = newValue.split(",");

            if (list[0] != "nan") {
              temp = double.parse('${list[0]}');
            }
            if (list[1] != "nan") {
              humi = double.parse('${list[1]}');
            }
            if (list[2] != "nan") {
              mq9 = double.parse('${list[2]}');
            }
          }
          device?.discoverServices();
        }
      });
    });

    if (temp != 0.00 && humi != 0.00) {
      if (temp >= 16 && temp <= 35) {
        sicaklikrenk = true;
        tempSayac = 0;
        LocalNotification().cancelNotification(0);
      } else if (temp < 16 || temp > 35) {
        sicaklikrenk = false;
        tempSayac += 1;
        currentLocation();
        if (temp > 35) {
          if(tempSayac == 1 && notify == true){
            LocalNotification.showNotification(
              id: 0,
                title: 'Sıcaklık',
                body:
                'Sıcaklık değeri solunum sisteminizi olumsuz etkileyebilecek düzeye çıktı. Lütfen ortamdan uzaklaşın veya gerekli tedbirleri alınız.');
          }
        } else if (temp < 16) {
          if(tempSayac == 1 && notify == true){
            LocalNotification.showNotification(
              id: 0,
                title: 'Sıcaklık',
                body:
                'Sıcaklık değeri solunum sisteminizi olumsuz etkileyebilecek düzeye düştü. Lütfen ortamdan uzaklaşın veya gerekli tedbirleri alınız.');
          }
        }
      }

      if (humi >= 40 && humi <= 60) {
        nemrenk = true;
        nemSayac = 0;
        LocalNotification().cancelNotification(1);
      } else if (humi < 40 || humi > 60) {
        nemrenk = false;
        nemSayac += 1;
        currentLocation();
        if (humi < 40) {
          if (nemSayac == 1 && notify == true) {
            LocalNotification.showNotification(
                id: 1,
                title: 'Nem',
                body:
                'Nem Oranı solunum sisteminizi olumsuz etkileyebilecek düzeye düştü. Lütfen ortamdan uzaklaşın veya gerekli tedbirleri alınız.');
          }
        } else if (humi > 60) {
          if (nemSayac == 1 && notify == true) {
            LocalNotification.showNotification(
                id: 1,
                title: 'Nem',
                body:
                'Nem Oranı solunum sisteminizi olumsuz etkileyebilecek düzeye çıktı. Lütfen ortamdan uzaklaşın veya gerekli tedbirleri alınız.');
          }
        }
      }

      if (mq9 <= 10) {
        mq9renk = true;
        mq9Sayac = 0;
        LocalNotification().cancelNotification(0);
      } else if (mq9 > 10) {
        mq9renk = false;
        mq9Sayac += 1;
        currentLocation();
        if (mq9 > 10) {
          if(mq9Sayac == 1 && notify == true){
            LocalNotification.showNotification(
                id: 3,
                title: 'Karbonmonoksit',
                body:
                'Karbonmonoksit değeri solunum sisteminizi olumsuz etkileyebilecek düzeydedir. Lütfen ortamdan uzaklaşın veya gerekli tedbirleri alınız.');
          }
        }
      }


      if (oksijen >= 19.5 && oksijen <= 23.5) {
        oksijenrenk = false;
      } else if (oksijen < 19.5 || oksijen > 23.5) {
        oksijenrenk = true;
      }
    }

    return Container(
      child: StreamBuilder<List<int>>(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          Size size = MediaQuery.of(context).size;
          if (snapshot.hasError) return Text('Error : ${snapshot.error}');

          return Container(
            height: size.height - 185.0,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
            ),
            child: ListView(
              primary: false,
              padding: EdgeInsets.only(left: 25.0, right: 20.0),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 45.0),
                  child: Container(
                    height: size.height - 300.0,
                    child: ListView(
                      children: [
                        _buildFoodItem('assets/image/icon-temp.png', 'Sıcaklık',
                            '$temp', sicaklikrenk),
                        Divider(
                          color: Colors.grey[300],
                          height: 20.0,
                          thickness: 3.0,
                          indent: 0.0,
                          endIndent: 0.0,
                        ),
                        _buildFoodItem('assets/image/icon-humudity.png', 'Nem Oranı',
                            '% $humi', nemrenk),
                        Divider(
                          color: Colors.grey[300],
                          height: 20.0,
                          thickness: 3.0,
                          indent: 0.0,
                          endIndent: 0.0,
                        ),
                        _buildFoodItem('assets/image/gaz_ikon.png', 'Karbonmonoksit',
                            '$mq9 ppm', mq9renk),
                        Divider(
                          color: Colors.grey[300],
                          height: 20.0,
                          thickness: 3.0,
                          indent: 0.0,
                          endIndent: 0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  Widget _buildFoodItem(
      String imgPath, String foodName, String price, bool renk) {
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: InkWell(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    child: Row(children: [
                  Hero(
                      tag: imgPath,
                      child: Image(
                          image: AssetImage(imgPath),
                          fit: BoxFit.cover,
                          color: Theme.of(context).focusColor,
                          height: 75.0,
                          width: 75.0)),
                  SizedBox(width: 10.0),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodName,
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 23,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          price,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20.0,
                            color: renk ? primaryGreen : Colors.red,
                          ),
                        )
                      ])
                ])),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
                    backgroundColor: primaryGreen,
                    body: ListView(
                      children: <Widget>[

                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(left: 40.0),
                              child: Image.asset(
                                'assets/image/logo2.png',
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.0),
                        StreamBuilder<List<BluetoothService>>(
                          stream: device?.services,
                          initialData: [],
                          builder: (c, snapshot) {
                            return _verilerial(snapshot.data!);
                          },
                        ),
                      ],
                    ),
                  );
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('BeniHatirla', false);
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Anasayfa()));
  }
}
