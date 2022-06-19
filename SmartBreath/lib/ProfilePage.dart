import 'dart:io';
import 'dart:ui';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbreath/Anasayfa.dart';
import 'package:smartbreath/HelpPage.dart';
import 'package:smartbreath/Notification.dart';
import 'package:smartbreath/models_providers/theme_provider.dart';
import 'package:smartbreath/profiledit.dart';
import 'package:smartbreath/services/Configuration.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartbreath/services/user_model.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  File? secilenDosya;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? indirmeBaglantisi;
  Image nullImage = Image.asset('assets/image/icon2.png');
  User? user = FirebaseAuth.instance.currentUser;
  UserModel? userModel = UserModel();

  bool switchBildirim = true;
  String switchDurum = 'Açık';
  bool notify = true;

  void initState() {
    super.initState();
    getFirebase();
    WidgetsBinding.instance?.addPostFrameCallback((_) => baglantiAl());
    LocalNotification.init();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Size size = MediaQuery.of(context).size;
    getFirebase();
    baglantiAl();
    return Scaffold(
      body: userModel?.name == null
          ? Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            )
          : Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaY: 50, sigmaX: 50),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    width: size.width,
                    height: size.height * 0.91,
                    child: ListView(
                      children: <Widget>[
                        SizedBox(height: 40.0),
                        Center(
                          child: Text(
                            "Profilim",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              width: 120,
                              height: 120,
                              child: ClipOval(
                                child: indirmeBaglantisi == null
                                    ? CircleAvatar(
                                        child: ClipOval(
                                            child: Icon(
                                          Icons.person,
                                          color: Theme.of(context).primaryColor,
                                          size: 70,
                                        )),
                                        backgroundColor: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.8),
                                      )
                                    : Image.network(
                                        indirmeBaglantisi!,
                                        width: size.height * 0.12,
                                        height: size.height * 0.12,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  width: size.width * 0.45,
                                  child: Text(
                                    '${userModel?.name}',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                                onPressed: () {
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierLabel:
                                        MaterialLocalizations.of(context)
                                            .modalBarrierDismissLabel,
                                    transitionDuration:
                                        Duration(microseconds: 200),
                                    pageBuilder: (
                                      BuildContext context,
                                      Animation first,
                                      Animation second,
                                    ) {
                                      return ProfileEdit();
                                    },
                                  );
                                },
                                icon: Icon(Icons.edit)),
                          ],
                        ),
                        SizedBox(height: size.height * .03),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bildirimler ${switchDurum}:',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              AnimatedToggleSwitch<bool>.dual(
                                current: switchBildirim,
                                first: false,
                                second: true,
                                borderColor: Colors.grey,
                                foregroundBoxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1.5),
                                  )
                                ],
                                dif: 0,
                                onChanged: (value) async {
                                  setState(() {
                                    switchBildirim = value;
                                    switchBildirim
                                        ? switchDurum = 'Açık'
                                        : switchDurum = 'Kapalı';
                                  });
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool('notify', value);
                                  Fluttertoast.showToast(
                                      msg:
                                          "Bildirimler ${switchDurum} Hale Getirildi.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor:
                                          Colors.black.withOpacity(0.5),
                                      textColor: Colors.white,
                                      fontSize: 14.0);
                                },
                                colorBuilder: (b) =>
                                    b ? Colors.green : Colors.red,
                                iconBuilder: (b, size, active) => b
                                    ? Icon(
                                        Icons.notifications_active,
                                        color: Colors.grey.shade200,
                                      )
                                    : Icon(
                                        Icons.notifications_off,
                                        color: Colors.grey.shade200,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * .03),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Uygulama Teması:",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              AnimatedToggleSwitch<bool>.dual(
                                current: themeProvider.isDarkMode,
                                first: false,
                                second: true,
                                borderColor: Colors.grey,
                                foregroundBoxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1.5),
                                  )
                                ],
                                dif: 0,
                                onChanged: (value) {
                                  final provider = Provider.of<ThemeProvider>(
                                      context,
                                      listen: false);
                                  provider.toggleTheme(value);
                                },
                                colorBuilder: (b) =>
                                    b ? Color(0xFF2F363D) : Color(0xFF2F363D),
                                iconBuilder: (b, size, active) => b
                                    ? Icon(
                                        Icons.nightlight_round,
                                        color: Color(0xFFF8E3A1),
                                      )
                                    : Icon(
                                        Icons.wb_sunny,
                                        color: Color(0xFFFFDF5D),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              FlatButton(
                                onPressed: () {
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierLabel:
                                        MaterialLocalizations.of(context)
                                            .modalBarrierDismissLabel,
                                    transitionDuration:
                                        Duration(microseconds: 200),
                                    pageBuilder: (
                                      BuildContext context,
                                      Animation first,
                                      Animation second,
                                    ) {
                                      return HelpPage();
                                    },
                                  );
                                },
                                padding: EdgeInsets.only(right: 0),
                                child: LocaleText(
                                  'sikcasorulansorular',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            logout(context);
                          },
                          padding: EdgeInsets.only(right: 0),
                          child: LocaleText(
                            'logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void editButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('Profil Fotoğrafı Yükle'),
              onTap: () {
                _secimFotoGoster(context);
              },
            ),
            ListTile(
              title: Text('Profil Fotoğrafını Kaldır'),
              onTap: () {
                _clear();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _secimFotoGoster(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('Kameradan Fotoğraf Çek'),
              onTap: () {
                setState(() {
                  _secimYukle(ImageSource.camera);
                });
              },
            ),
            ListTile(
              title: Text('Galeriden Fotoğraf Yükle'),
              onTap: () {
                _secimYukle(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _secimYukle(ImageSource? source) async {
    XFile? secilenResim =
        await ImagePicker().pickImage(source: source!, imageQuality: 25);
    setState(() {
      if (secilenResim != null) {
        _fotografKes(File(secilenResim.path));
      }
    });
    Navigator.pop(context);
  }

  void _fotografKes(File? photo) async {
    var kesilenFoto = await ImageCropper().cropImage(
      sourcePath: photo!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      maxWidth: 800,
    );
    if (kesilenFoto != null) {
      setState(() {
        secilenDosya = File(kesilenFoto.path);
      });
    }

    Reference referansYol = FirebaseStorage.instance
        .ref()
        .child('profilresimleri')
        .child(auth.currentUser!.uid)
        .child('profilResmi.png');

    UploadTask yuklemeGorevi = referansYol.putFile(secilenDosya!);

    String imageUrl = await (await yuklemeGorevi).ref.getDownloadURL();

    setState(() {
      indirmeBaglantisi = imageUrl;
    });
  }

  baglantiAl() async {
    String baglanti = await FirebaseStorage.instance
        .ref()
        .child('profilresimleri')
        .child(auth.currentUser!.uid)
        .child('profilResmi.png')
        .getDownloadURL();

    setState(() {
      indirmeBaglantisi = baglanti;
    });
  }

  Future getFirebase() async {
    await FirebaseFirestore.instance
        .collection("person")
        .doc(user!.uid)
        .get()
        .then((value) => {
              this.userModel = UserModel.fromMap(value.data()),
              setState(() {}),
            });
  }

  void _clear() async {}

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('BeniHatirla', false);
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Anasayfa()));
  }
}
