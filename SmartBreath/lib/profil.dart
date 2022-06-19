import 'dart:io';

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
    getFirebase();
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 40.0,
          ),
          Center(
            child: Stack(
              children: <Widget>[
                ClipOval(
                  child: indirmeBaglantisi == null
                      ? Image.asset(
                    'assets/image/icon2.png',
                    width: 128.0,
                    height: 128.0,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    indirmeBaglantisi!,
                    width: 128.0,
                    height: 128.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.0,),
          Row(
            children: [
              Text('Kullanıcı Adı:'),
              SizedBox(width: 20.0,),
              Text('${userModel?.name}')
            ],
          ),
          SizedBox(height: 20.0,),
          Row(
            children: [
              Text('Kullanıcı E-Posta:'),
              SizedBox(width: 20.0,),
              Text('${userModel?.email}')
            ],
          ),
          SizedBox(height: 40.0,),
          Row(
            children: [
              Text('Bildirimler ${switchDurum}:'),
              SizedBox(width: 20.0,),
              CupertinoSwitch(
                activeColor: primaryGreen,
                value: switchBildirim,
                onChanged: (value) async{
                  setState(() {
                    switchBildirim = value;
                    switchDurum == 'Kapalı' ? switchDurum = 'Açık' : switchDurum = 'Kapalı';
                  });
                  final prefs =
                  await SharedPreferences.getInstance();
                  await prefs.setBool('notify', value);
                  Fluttertoast.showToast(
                      msg: "Bildirimler ${switchDurum} Hale Getirildi.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black.withOpacity(0.5),
                      textColor: Colors.white,
                      fontSize: 14.0);
                },
              ),
            ],
          ),

          SizedBox(height: 20.0,),
          ElevatedButton(child: LocaleText('sikcasorulansorular'),onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HelpPage()));
          },),

          ElevatedButton(
            child: Text("Editle"),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileEdit()));
            },),

          FlatButton(
            onPressed: () {
              logout(context);
            },
            padding: EdgeInsets.only(right: 0),
            child: LocaleText(
              'logout',
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                dif: 60.0,
                onChanged: (value) {
                  final provider = Provider.of<ThemeProvider>(context, listen: false);
                  provider.toggleTheme(value);
                },
                colorBuilder: (b) => b ? Color(0xFF2F363D) : Color(0xFF2F363D),
                iconBuilder: (b, size, active) => b
                    ? Icon(
                  Icons.nightlight_round,
                  color: Color(0xFFF8E3A1),
                )
                    : Icon(
                  Icons.wb_sunny,
                  color: Color(0xFFFFDF5D),
                ),
                textBuilder: (b, size, active) => b
                    ? Center(
                    child: LocaleText(
                      'gece',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
                    : Center(
                    child: LocaleText(
                      'gunduz',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          ),

        ],
      ),
    );
  }

  void editButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
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
      builder: (context) =>
          AlertDialog(
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
    XFile? secilenResim = await ImagePicker().pickImage(
        source: source!, imageQuality: 25);
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
        .then((value) =>
    {
      this.userModel = UserModel.fromMap(value.data()),
      setState(() {}),
    });
  }

  void _clear() async {

  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('BeniHatirla', false);
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Anasayfa()));
  }
}
