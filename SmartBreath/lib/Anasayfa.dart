import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:smartbreath/SignUp.dart';
import 'package:smartbreath/login.dart';
import 'package:smartbreath/services/Configuration.dart';

class Anasayfa extends StatefulWidget {
  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: ListView(
        children: [
          Center(
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.only(top: size.width * 0.10, bottom: 50),
                child: Column(
                  children: [
                    Container(
                      width: size.width * 0.8,
                      child: FittedBox(
                        child: Text(
                          "SmartBreath",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Bangers', color: primaryGreen),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.6,
                      child: FittedBox(
                        child: LocaleText(
                          "hosgeldiniz",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Bangers', color: primaryGreen),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Container(
                        height: size.height * 0.45,
                        child: Image.asset('assets/image/icon2.png'),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Container(
                      width: size.width * 0.8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(29.0),
                        child: FlatButton(
                          color: primaryGreen,
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 40),
                          child: LocaleText(
                            'giris',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Container(
                      width: size.width * 0.8,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(29.0),
                            side: BorderSide(color: primaryGreen)),
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        child: LocaleText(
                          'kayitol',
                          style: TextStyle(color: primaryGreen),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUp()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
