import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartbreath/services/Configuration.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartbreath/services/user_model.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({Key? key}) : super(key: key);
  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  File? secilenDosya;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? indirmeBaglantisi;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel? userModel = UserModel();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  TextEditingController namechange = TextEditingController();
  TextEditingController emailchange = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    getFirebase();
    WidgetsBinding.instance!.addPostFrameCallback((_) => baglantiAl());
  }

  @override
  void dispose() {
    namechange.dispose();
    emailchange.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return userModel?.name == null
        ? Center(
            child: CircularProgressIndicator(
              color: primaryGreen,
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 16, sigmaX: 16),
              child: Scaffold(
                backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                body: Container(
                  width: size.width,
                  height: size.height * 0.91,
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 15,
                          left: 10.0,
                          right: 10,
                          bottom: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).focusColor,
                                ),
                                onTap: Navigator.of(context).pop,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40.0),
                      Center(
                        child: Text(
                          "Profili Düzenle",
                          style: TextStyle(
                              color: Theme.of(context).focusColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Center(
                        child: Stack(
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
                                          size: 75,
                                        )),
                                        backgroundColor: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.8),
                                      )
                                    : Image.network(
                                        indirmeBaglantisi!,
                                        width: size.height * .15,
                                        height: size.height * .15,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0.0,
                              right: 4.0,
                              child: ClipOval(
                                child: Container(
                                  color: primaryGreen,
                                  child: IconButton(
                                    onPressed: () {
                                      editButton(context);
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Form(
                        key: _formkey,
                        child: TextFormField(
                          validator: (value) {
                            RegExp regexp = new RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return Locales.string(context, 'adbos');
                            }
                            if (!regexp.hasMatch(value)) {
                              return Locales.string(context, 'adhata');
                            }
                            return null;
                          },
                          controller: namechange,
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                            color: Theme.of(context).focusColor,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).focusColor,
                            ),
                            hintText: Locales.string(context, 'adsoyad'),
                            hintStyle:
                                TextStyle(color: Theme.of(context).focusColor),
                            labelText: Locales.string(context, 'adsoyad'),
                            labelStyle: TextStyle(color: primaryGreen),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: primaryGreen)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: primaryGreen)),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * .03),
                      FlatButton(
                        onPressed: () async {
                          userModel?.name = namechange.text;

                          if (_formkey.currentState!.validate()) {
                            await firebaseFirestore
                                .collection("person")
                                .doc(user?.uid)
                                .set(userModel!.toMap());
                            Fluttertoast.showToast(
                                    msg: Locales.string(
                                        context, 'basarilikayit'))
                                .catchError((e) {});
                            Navigator.pop(context);
                          }
                        },
                        padding: EdgeInsets.only(right: 0),
                        child: LocaleText(
                          'kaydet',
                          style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                      ),
                    ],
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
    namechange.text = userModel!.name.toString();
  }

  void _clear() async {}
}
