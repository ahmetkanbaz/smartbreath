import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smartbreath/login.dart';
import 'package:smartbreath/services/Configuration.dart';
import 'package:smartbreath/services/user_model.dart';
import 'package:email_auth/email_auth.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //formkey

  final _formkey = GlobalKey<FormState>();

  //textcontrolller
  final TextEditingController namecontroller = new TextEditingController();
  final TextEditingController emailcontroller = new TextEditingController();
  final TextEditingController passwordcontroller = new TextEditingController();
  final TextEditingController passwordagaincontroller =
      new TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  EmailAuth? emailAuth;
  bool isObscure = true;
  bool isLoading = false;

  bool isVisible = false;

  void sendOTP() async {
    emailAuth = new EmailAuth(sessionName: "SmartBreath");
    bool res = await emailAuth!
        .sendOtp(recipientMail: emailcontroller.value.text, otpLength: 6);
    if (res) {
      Fluttertoast.showToast(
          msg:
              "${emailcontroller.text} E-Posta Adresinize Doğrulama Kodu Gönderildi",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.5),
          textColor: Colors.white,
          fontSize: 14.0);
    } else {
      Fluttertoast.showToast(
          msg:
              "Doğrulama Kodu Gönderilemedi. Lütfen E-Posta Adresinizi Kontrol Ediniz.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.5),
          textColor: Colors.white,
          fontSize: 14.0);
    }
  }

  void verifyOTP() async {
    var res = emailAuth!.validateOtp(
        recipientMail: emailcontroller.text, userOtp: _otpController.text);
    if (res) {
      Fluttertoast.showToast(
          msg: "Doğrulama Kodu Doğru.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.5),
          textColor: Colors.white,
          fontSize: 14.0);
      signUp(emailcontroller.text, passwordcontroller.text);
    } else {
      Fluttertoast.showToast(
          msg: "Doğrulama Kodunu Hatalı Girdiniz. Lütfen Kontrol Ediniz.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.5),
          textColor: Colors.white,
          fontSize: 14.0);
    }
  }



  Widget buildAd() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocaleText(
          'adsoyad',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
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
            controller: namecontroller,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 15),
                prefixIcon: Icon(
                  Icons.account_circle,
                  color: Theme.of(context).primaryColor,
                ),
                hintText: Locales.string(context, 'adsoyad'),
                hintStyle:
                    TextStyle(color: Theme.of(context).secondaryHeaderColor)),
          ),
        )
      ],
    );
  }

  Widget buildEposta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocaleText(
          'eposta',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
          child: TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return Locales.string(context, 'mailbos');
              }
              if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                  .hasMatch(value)) {
                return Locales.string(context, 'mailhata');
              }
              return null;
            },
            onSaved: (value) {
              emailcontroller.text = value!;
            },
            controller: emailcontroller,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 15),
              prefixIcon: Icon(
                Icons.email,
                color: Theme.of(context).primaryColor,
              ),
              hintText: Locales.string(context, 'eposta'),
              hintStyle:
                  TextStyle(color: Theme.of(context).secondaryHeaderColor),
            ),
          ),
        )
      ],
    );
  }

  Widget buildSifre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocaleText(
          'sifre',
          style: TextStyle(
            color: Color(0xff40b65b),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
          child: TextFormField(
            validator: (value) {
              RegExp regexp = new RegExp(r'^.{6,}$');
              if (value!.isEmpty) {
                return Locales.string(context, 'sifrebos');
              }
              if (!regexp.hasMatch(value)) {
                return Locales.string(context, 'sifrehata');
              }
              return null;
            },
            onSaved: (value) {
              passwordcontroller.text = value!;
            },
            controller: passwordcontroller,
            keyboardType: TextInputType.visiblePassword,
            obscureText: isObscure,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 15),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).primaryColor,
                ),
                hintText: Locales.string(context, 'sifre'),
                hintStyle:
                    TextStyle(color: Theme.of(context).secondaryHeaderColor)),
          ),
        )
      ],
    );
  }

  Widget buildYeniSifre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocaleText(
          'sifretekrar',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
          child: TextFormField(
            validator: (value) {
              if (passwordcontroller.text != passwordagaincontroller.text) {
                return Locales.string(context, 'sifreeslesmiyor');
              }
              return null;
            },
            onSaved: (value) {
              passwordagaincontroller.text = value!;
            },
            controller: passwordagaincontroller,
            keyboardType: TextInputType.visiblePassword,
            obscureText: isObscure,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 15),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).primaryColor,
                ),
                hintText: Locales.string(context, 'sifretekrar'),
                hintStyle: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                )),
          ),
        )
      ],
    );
  }

  Widget dogrulamaKodu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocaleText(
          'dogrulama',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
          child: TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return Locales.string(context, 'dogrulamabos');
              }
              return null;
            },
            controller: _otpController,
            keyboardType: TextInputType.number,
            obscureText: isObscure,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 15),
                prefixIcon: Icon(
                  Icons.account_circle,
                  color: Theme.of(context).primaryColor,
                ),
                hintText: Locales.string(context, 'dogrulamagir'),
                hintStyle:
                TextStyle(color: Theme.of(context).secondaryHeaderColor)),
          ),
        )
      ],
    );
  }

  Widget buildKayitolbuton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5,
        child: LocaleText('kayitol',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold)),
        onPressed: () {
          verifyOTP();
        },
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: primaryGreen,
      ),
    );
  }

  Widget buildSignInbuton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: Locales.string(context, 'hesabinizvarmı'),
              style: TextStyle(
                  color: primaryGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            TextSpan(
                text: Locales.string(context, 'giris'),
                style: TextStyle(
                  fontSize: 18,
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.07,
                    vertical: size.height * 0.14,
                  ),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.6,
                          child: FittedBox(
                            child: LocaleText(
                              'kayitol',
                              style: TextStyle(
                                  color: primaryGreen,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        buildAd(),
                        SizedBox(height: size.height * 0.02),
                        buildEposta(),
                        SizedBox(height: size.height * 0.02),
                        buildSifre(),
                        SizedBox(height: size.height * 0.02),
                        buildYeniSifre(),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        Visibility(
                          child: dogrulamaKodu(),
                          visible: isVisible,
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        TextButton(
                            child: Text("Doğrulama Kodu Gönder", style: TextStyle(color: primaryGreen),),
                            onPressed: () {
                              sendOTP();
                              setState(() {
                                isVisible = true;
                              });
                            },),
                        SizedBox(height: 20),
                        isLoading
                            ? Container(
                                padding: EdgeInsets.symmetric(vertical: 25),
                                child: CircularProgressIndicator(
                                  color: primaryGreen,
                                ),
                              )
                            : buildKayitolbuton(),
                        buildSignInbuton(),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then(
            (value) => {
              postDetailsToFirestore(),
            },
          )
          .catchError((e) {
        Fluttertoast.showToast(msg: "Daha Önceden Bu E-Posta İle Kayıt Yapılmıştır. Lütfen Farklı Bir E-Posta Adresi Giriniz.");
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    setState(() {
      isLoading = true;
    });
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    userModel.uid = user?.uid;
    userModel.name = namecontroller.text;
    userModel.email = user?.email;

    await firebaseFirestore
        .collection("person")
        .doc(user?.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: Locales.string(context, 'basarilikayit'));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
    setState(() {
      isLoading = false;
    });
  }
}
