import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:smartbreath/AverageRate.dart';
import 'package:smartbreath/loComments.dart';
import 'package:smartbreath/services/Configuration.dart';
import 'package:smartbreath/services/user_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:search_map_location/utils/google_search/geo_location.dart';
import 'package:search_map_location/utils/google_search/place.dart';
import 'directions_model.dart';
import 'directions_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_location/search_map_location.dart';
import '.env.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController commentcontroller = TextEditingController();
  GoogleMapController? _googleMapController;
  final Completer<GoogleMapController> mapcontroller = Completer();

  late BitmapDescriptor bitmapDescriptor;
  Uint8List? markerHumi;
  Uint8List? markerTemp;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Position? position;
  String placename = 'İşaretli Konum';
  bool riskli = false;
  bool bottomsheet = false;
  bool yorumvarmi = false;
  bool darkmod = false;
  bool konumizni = true;
  String km = '';
  double maxchildsize = 0.5;
  String suretip = "";
  List<String>? surelist;
  List<String>? time;
  String sure = '';
  LatLng? pos1;
  LatLng? targetpos;
  LatLng? targetpos1;
  LocationPermission? permission;

  Uint8List? _imageBytes;
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  themeGooglemaps() {
    _googleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  Future<String> getAverageRating() async {
    double raiting = 0;
    int sayac = 0;
    await FirebaseFirestore.instance
        .collection("loComment")
        .doc(targetpos.toString())
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

  void setCustomMaker() async {
    markerTemp = await getBytesFromAsset('assets/image/heat.png', 100);
    markerHumi = await getBytesFromAsset('assets/image/heat1.png', 100);
    bitmapDescriptor = BitmapDescriptor.defaultMarker;
  }

  void getMarkers(double lat, double long, Uint8List _bitmapDescriptor) {
    MarkerId markerId;
    markerId = MarkerId(lat.toString() + long.toString());

    Marker marker = Marker(
      anchor: const Offset(0.5, 0.5),
      markerId: markerId,
      flat: false,
      consumeTapEvents: false,
      position: LatLng(lat, long),
      icon: BitmapDescriptor.fromBytes(_bitmapDescriptor),
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  void getMarkerBitmap(double lat, double long) {
    MarkerId markerId;
    markerId = MarkerId('konum');
    Marker marker = Marker(
      anchor: const Offset(0.5, 0.5),
      markerId: markerId,
      flat: false,
      consumeTapEvents: false,
      position: LatLng(lat, long),
      icon: bitmapDescriptor,
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  Marker? _destination;
  Directions? _info;

  void liveLocation() async {
    permission = await Geolocator.requestPermission();
    if (permission.toString() == "LocationPermission.deniedForever") {
      setState(() {
        konumizni = false;
      });
    } else {
      setState(() {
        konumizni = true;
      });
    }
    var pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      position = pos;
    });
    await FirebaseFirestore.instance
        .collection('location')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var uzunluk = doc["latitude"];
        var genislik = doc["longitude"];
        getMarkers(uzunluk, genislik, markerTemp!);
      });
    });
  }

  UserModel userModel = UserModel();
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setCustomMaker();
    setState(() {
      liveLocation();
    });
    getFirebase();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CircularMenu(
        toggleButtonMargin: 30,
        alignment: Alignment.bottomLeft,
        startingAngleInRadian: 5,
        endingAngleInRadian: 6,
        toggleButtonSize: 30,
        toggleButtonIconColor: Theme.of(context).focusColor,
        toggleButtonColor: Colors.grey.shade500,
        items: [
          CircularMenuItem(
              icon: Icons.location_searching,
              color: primaryGreen,
              onTap: () {
                _googleMapController?.animateCamera(
                  _info != null
                      ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
                      : CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(position!.latitude.toDouble(),
                                position!.longitude.toDouble()),
                            zoom: 15.0,
                          ),
                        ),
                );
              }),
          CircularMenuItem(
              icon: Icons.share,
              color: primaryGreen,
              onTap: () async {
                final Uint8List? imageBytes =
                    await _googleMapController?.takeSnapshot();
                setState(() {
                  _imageBytes = imageBytes;
                });
                ShareFilesAndScreenshotWidgets().shareFile(
                    'Share', 'SmartBreath.jpg', _imageBytes!, 'image/jpg',
                    text: 'SmartBreath');
              }),
        ],
        backgroundWidget: Stack(
          alignment: Alignment.center,
          children: [
            konumizni == false
                ? Center(
                    child: GestureDetector(
                      onTap: () async {
                        await Geolocator.openAppSettings();
                        liveLocation();
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Konum Erişim izni reddedildi",
                              style: TextStyle(
                                  color: primaryGreen,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                                text: " Ayarları Aç",
                                style: TextStyle(
                                  color: primaryGreen,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ),
                    ),
                  )
                : position == null
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      )
                    : SafeArea(
                        child: GoogleMap(
                          mapType: MapType.normal,
                          liteModeEnabled: false,
                          buildingsEnabled: false,
                          indoorViewEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(position!.latitude.toDouble(),
                                position!.longitude.toDouble()),
                            zoom: 20.0,
                          ),
                          onMapCreated: (controller) {
                            setState(() {
                              _googleMapController = controller;
                              mapcontroller.complete(controller);
                              if (Theme.of(context).focusColor ==
                                  Colors.white) {
                                darkmod = true;
                                themeGooglemaps();
                              }
                            });
                          },
                          markers: Set<Marker>.of(markers.values),
                          mapToolbarEnabled: true,
                          polylines: {
                            if (_info != null)
                              Polyline(
                                polylineId:
                                    const PolylineId('overview_polyline'),
                                color: Colors.red,
                                width: 5,
                                points: _info!.polylinePoints
                                    .map((e) => LatLng(e.latitude, e.longitude))
                                    .toList(),
                              ),
                          },
                          onLongPress: _addMarker,
                        ),
                      ),
            Positioned(
              top: 70,
              child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5000),
                  ),
                  child: Row(
                    children: [
                      SearchLocation(
                        darkMode: darkmod,
                        apiKey: googleAPIKey,
                        hasClearButton: true,
                        onClearIconPress: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        iconColor: Colors.green,
                        language: Locales.string(context, 'dil'),
                        radius: 500,
                        placeholder: "Bir konum arayın",
                        onSelected: (Place place) async {
                          bottomsheet = false;
                          placename = place.description;
                          Geolocation? geolocationn = await place.geolocation;
                          final latlng = LatLng(
                              geolocationn?.coordinates.latitude,
                              geolocationn?.coordinates.longitude);
                          final bounds = LatLngBounds(
                              southwest: latlng, northeast: latlng);
                          _googleMapController
                              ?.animateCamera(CameraUpdate.newLatLng(latlng));
                          _googleMapController?.animateCamera(
                              CameraUpdate.newLatLngBounds(bounds, 0));
                          searchAddMarker(latlng);
                        },
                      ),
                    ],
                  )),
            ),
            bottomsheet
                ? DraggableScrollableSheet(
                    initialChildSize: 0.15,
                    maxChildSize: maxchildsize,
                    minChildSize: 0.03,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaY: 16, sigmaX: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.4),
                              ),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 12),
                                  Container(
                                    height: 5,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  SizedBox(height: 16),
                                  Center(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(placename,
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Column(
                                    children: [
                                      _info != null
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons
                                                    .directions_car_outlined),
                                                Text(
                                                  '${surelist![0]} ${Locales.string(context, surelist![1])}.',
                                                  style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Icon(Icons.space_bar),
                                                Text(
                                                  '${_info?.totalDistance.toString()}',
                                                  style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              'Uzaklık Hesaplanamadı',
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Gideceğiniz yer:',
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          riskli
                                              ? Text(
                                                  "Riskli",
                                                  style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.red),
                                                )
                                              : Text(
                                                  'Riskli değil',
                                                  style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.green),
                                                )
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  _info != null
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.grey.shade500,
                                            ),
                                            Text(
                                              '( ' +
                                                  targetpos!.latitude
                                                      .toString() +
                                                  ' , ' +
                                                  targetpos!.longitude
                                                      .toString() +
                                                  ' )',
                                              style: TextStyle(
                                                  color: Colors.grey.shade500),
                                            )
                                          ],
                                        )
                                      : Text(""),
                                  SizedBox(height: 12),
                                  placename != 'İşaretli Konum'
                                      ? Column(
                                          children: [
                                            Container(
                                              height: 1,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[600]
                                                      ?.withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                            ),
                                            SizedBox(height: 15),
                                            Container(
                                              child: Column(children: [
                                                Text(
                                                  'Ortamın hava kalitesini yorumlayın',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  'İnsanlara yardımcı olmak için deneyimlerinizi paylaşın',
                                                  textAlign: TextAlign.start,
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  children: [
                                                    SizedBox(width: 30),
                                                    CircleAvatar(
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Theme.of(context)
                                                            .focusColor,
                                                      ),
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                    ),
                                                    SizedBox(width: 30),
                                                    RatingBar.builder(
                                                      initialRating: 3,
                                                      minRating: 1,
                                                      tapOnlyMode: true,
                                                      itemCount: 5,
                                                      itemBuilder:
                                                          (context, _) => Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                      ),
                                                      onRatingUpdate: (rating) {
                                                        showGeneralDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              true,
                                                          barrierLabel:
                                                              MaterialLocalizations
                                                                      .of(context)
                                                                  .modalBarrierDismissLabel,
                                                          transitionDuration:
                                                              Duration(
                                                                  microseconds:
                                                                      200),
                                                          pageBuilder: (
                                                            BuildContext
                                                                context,
                                                            Animation first,
                                                            Animation second,
                                                          ) {
                                                            return LoComments(
                                                              LocId: targetpos!,
                                                              RaitingValue:
                                                                  rating,
                                                              placeName:
                                                                  placename,
                                                              userName:
                                                                  userModel
                                                                      .name!,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                )
                                              ]),
                                            ),
                                            SizedBox(height: 15),
                                            FutureBuilder<String>(
                                                future: getAverageRating(),
                                                builder: (context,
                                                    AsyncSnapshot<String>
                                                        snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.done) {
                                                    if (snapshot.data !=
                                                        "NaN") {
                                                      yorumvarmi = true;
                                                      return Column(
                                                        children: [
                                                          Container(
                                                            child: Center(
                                                              child: Text(
                                                                'Ortalama hava kalitesi',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        18.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ),
                                                          ),
                                                          Text(snapshot.data!,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      18.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                        ],
                                                      );
                                                    } else {
                                                      yorumvarmi = false;
                                                      return Text(
                                                          "Henüz bu konum hakkında yorum yapılmamıştır.");
                                                    }
                                                  } else
                                                    return CircularProgressIndicator(
                                                      color: primaryGreen,
                                                    );
                                                }),
                                            yorumvarmi
                                                ? TextButton(
                                                    onPressed: () {
                                                      showGeneralDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            true,
                                                        barrierLabel:
                                                            MaterialLocalizations
                                                                    .of(context)
                                                                .modalBarrierDismissLabel,
                                                        transitionDuration:
                                                            Duration(
                                                                microseconds:
                                                                    200),
                                                        pageBuilder: (
                                                          BuildContext context,
                                                          Animation first,
                                                          Animation second,
                                                        ) {
                                                          return AverageRate(
                                                            targetpos:
                                                                targetpos!,
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text(
                                                      "Yapılan Yorumları Gör",
                                                      style: const TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ))
                                                : Text(""),
                                          ],
                                        )
                                      : Text(""),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Text(""),
          ],
        ),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    placename = "İşaretli Konum";
    setState(() {
      maxchildsize = 0.25;
      pos1 =
          LatLng(position!.latitude.toDouble(), position!.longitude.toDouble());
      targetpos = LatLng(pos.latitude.toDouble(), pos.longitude.toDouble());
      getMarkerBitmap(pos.latitude, pos.longitude);
      _destination = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: pos,
      );
    });
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

    if (i > 0)
      riskli = true;
    else
      riskli = false;
    // Get directions
    final directions = await DirectionsRepository()
        .getDirections(origin: pos1!, destination: pos);
    setState(() => _info = directions);
    setState(() {
      bottomsheet = true;
    });
    if (_info != null) {
      km = _info!.totalDistance.toString();
      sure = _info!.totalDuration.toString();
      surelist = sure.split(" ");
    }
  }

  void searchAddMarker(LatLng pos) async {
    setState(() {
      maxchildsize = 0.5;
      pos1 =
          LatLng(position!.latitude.toDouble(), position!.longitude.toDouble());
      targetpos = LatLng(pos.latitude.toDouble(), pos.longitude.toDouble());
      getMarkerBitmap(pos.latitude, pos.longitude);
      _destination = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: pos,
      );
    });
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

    if (i > 0)
      riskli = true;
    else
      riskli = false;
    // Get directions
    final directions = await DirectionsRepository()
        .getDirections(origin: pos1!, destination: pos);
    setState(() => _info = directions);
    setState(() {
      bottomsheet = true;
    });
    if (_info != null) {
      km = _info!.totalDistance.toString();
      sure = _info!.totalDuration.toString();
      surelist = sure.split(" ");
    }
  }
}
