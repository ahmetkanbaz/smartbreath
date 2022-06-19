import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartbreath/services/Configuration.dart';
import 'package:smartbreath/services/user_model.dart';

class LoComments extends StatefulWidget {
  final LatLng LocId;
  final double RaitingValue;
  final String placeName;
  final String userName;

  const LoComments(
      {required this.LocId,
      required this.RaitingValue,
      required this.placeName,
      required this.userName});

  @override
  _LoCommentsState createState() => _LoCommentsState();
}

class _LoCommentsState extends State<LoComments> {
  TextEditingController? commentcontroller = TextEditingController();
  double? raitingValue;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 8, sigmaX: 8),
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
          body: SafeArea(
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 15,
                    left: 10.0,
                    right: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context).focusColor,
                          ),
                          onTap: Navigator.of(context).pop),
                      SizedBox(width: 5),
                      Flexible(
                        child: Center(
                          child: Text(
                            widget.placeName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 22,
                                color: Theme.of(context).focusColor),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          addComment(
                              context, widget.LocId, commentcontroller!.text);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Breath'le",
                          style: TextStyle(fontSize: 19, color: primaryGreen),
                        ),
                      )
                    ],
                  ),
                ),
                Center(
                  child: Row(
                    children: [
                      SizedBox(width: 30),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.width * 0.15,
                        child: ClipOval(
                          child: indirmeBaglantisi == null
                              ? Icon(
                                  Icons.person,
                                  color: Theme.of(context).focusColor,
                                )
                              : Image.network(
                                  indirmeBaglantisi!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(width: 30),
                      Text(widget.userName,
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).focusColor))
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Center(
                  child: RatingBar.builder(
                    unratedColor: Theme.of(context).focusColor.withOpacity(0.1),
                    initialRating: widget.RaitingValue,
                    itemPadding: EdgeInsets.all(10),
                    updateOnDrag: true,
                    minRating: 1,
                    glowRadius: 0.2,
                    glowColor: Colors.transparent,
                    itemCount: 5,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      raitingValue = rating;
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.height * 0.05),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: TextField(
                    cursorColor: Theme.of(context).primaryColor,
                    maxLines: 5,
                    maxLength: 150,
                    controller: commentcontroller,
                    decoration: InputDecoration(
                      hintText: "Yorum Ekle",
                      hintStyle: TextStyle(color: Theme.of(context).focusColor),
                      labelText: "Breathle",
                      labelStyle: TextStyle(color: primaryGreen),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      fillColor: Colors.red,
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: primaryGreen)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: primaryGreen)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  UserModel? userModel = UserModel();
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? indirmeBaglantisi;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFirebase();
    WidgetsBinding.instance!.addPostFrameCallback((_) => fotografAl());
    raitingValue = widget.RaitingValue;
  }

  Future getFirebase() async {
    await FirebaseFirestore.instance
        .collection("person")
        .doc(user?.uid)
        .get()
        .then((value) => {
              this.userModel = UserModel.fromMap(value.data()),
              setState(() {}),
            });
  }

  fotografAl() async {
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

  Future addComment(BuildContext context, LatLng locid, String comment) async {
    await FirebaseFirestore.instance
        .collection('loComment')
        .doc(locid.toString())
        .collection('Comments')
        .doc(comment)
        .set({
      'comment': comment,
      'username': userModel?.name,
      'time': DateTime.now(),
      'raiting': raitingValue,
      'userid': userModel?.uid
    });
  }
}
