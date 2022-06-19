import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartbreath/services/Configuration.dart';

import 'services/user_model.dart';

class AverageRate extends StatefulWidget {
  final LatLng targetpos;
  const AverageRate({required this.targetpos});

  @override
  _AverageRateState createState() => _AverageRateState();
}

class _AverageRateState extends State<AverageRate> {
  UserModel? userModel = UserModel();
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? indirmeBaglantisi;
  String? baglanti;
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

  Future<String> fotografyukle(String path) async {
    String baglanti = await FirebaseStorage.instance
        .ref()
        .child('profilresimleri')
        .child(path)
        .child('profilResmi.png')
        .getDownloadURL();
    return baglanti.toString();
  }

  Widget fotografAl(String path) {
    fotografyukle(path);
    baglanti = indirmeBaglantisi;
    return CircleAvatar(
      child: ClipOval(
        child: indirmeBaglantisi == null
            ? Icon(
                Icons.person,
                color: Theme.of(context).focusColor,
              )
            : Image.network(
                indirmeBaglantisi.toString(),
                fit: BoxFit.cover,
              ),
      ),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
    );
  }

  Widget getRatingBar(double initial, double size) {
    // ignore: missing_required_param
    return Container(
      child: RatingBar.builder(
        initialRating: initial,
        itemCount: 5,
        minRating: 1,
        allowHalfRating: true,
        itemSize: size,
        updateOnDrag: false,
        ignoreGestures: true,
        tapOnlyMode: false,
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {},
      ),
    );
  }

  Future<String> getAverageRating() async {
    double raiting = 0;
    int sayac = 0;
    await FirebaseFirestore.instance
        .collection("loComment")
        .doc(widget.targetpos.toString())
        .collection("Comments")
        .get()
        .then((QuerySnapshot q) {
      q.docs.forEach((element) {
        raiting += element['raiting'];
        sayac = q.size;
      });
      raiting /= sayac;
    });
    return raiting.toStringAsFixed(2);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFirebase();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          body: SafeArea(
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 20,
                    left: 15,
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
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<String>(
                          future: getAverageRating(),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data != "NaN") {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Center(
                                        child: Text(
                                          'Ortalama hava kalitesi',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        getRatingBar(
                                            double.parse(snapshot.data!),
                                            size.height * 0.05),
                                        SizedBox(width: 8),
                                        Text(snapshot.data!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                );
                              } else
                                return Text("Yorum yok");
                            } else
                              return CircularProgressIndicator(
                                color: primaryGreen,
                              );
                          })
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: size.height * 0.75,
                  width: size.width,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("loComment")
                        .doc(widget.targetpos.toString())
                        .collection("Comments")
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String getTimeDifferenceFromNow(DateTime dateTime) {
                        Duration difference =
                            DateTime.now().difference(dateTime);
                        if (difference.inSeconds < 5) {
                          return "Şimdi";
                        } else if (difference.inMinutes < 1) {
                          return "${difference.inSeconds}s önce";
                        } else if (difference.inHours < 1) {
                          return "${difference.inMinutes}dk önce";
                        } else if (difference.inHours < 24) {
                          return "${difference.inHours}saat önce";
                        } else {
                          return "${difference.inDays}gün önce";
                        }
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: primaryGreen,
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data?.size,
                          itemBuilder: (context, index) {
                            DocumentSnapshot documentSnapshot =
                                snapshot.data!.docs[index];
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 30),
                                    FutureBuilder<String>(
                                        future: fotografyukle(
                                            documentSnapshot['userid']),
                                        builder: (context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            if (snapshot.data != "NaN") {
                                              return Container(
                                                width: 50,
                                                height: 50,
                                                child: ClipOval(
                                                  child: snapshot.data == null
                                                      ? Icon(
                                                          Icons.person,
                                                          color:
                                                              Theme.of(context)
                                                                  .focusColor,
                                                        )
                                                      : Image.network(
                                                          snapshot.data!,
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              );
                                            } else
                                              return Text("");
                                          } else
                                            return Container(
                                              width: 50,
                                              height: 50,
                                              child: CircleAvatar(
                                                child: ClipOval(
                                                    child: Icon(
                                                  Icons.person,
                                                  color: Theme.of(context)
                                                      .focusColor,
                                                )),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.4),
                                              ),
                                            );
                                        }),
                                    SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(documentSnapshot['username'],
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Theme.of(context)
                                                    .focusColor)),
                                        getRatingBar(
                                            documentSnapshot['raiting'],
                                            size.height * 0.02)
                                      ],
                                    )
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 8, 8, 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: size.width * 0.73,
                                        child: Text(
                                          documentSnapshot['comment']
                                              .toString()
                                              .replaceAll("\n", " "),
                                          maxLines: 5,
                                        ),
                                      ),
                                      Text(
                                        getTimeDifferenceFromNow(
                                            documentSnapshot["time"].toDate()),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
