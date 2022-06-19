import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:smartbreath/Anasayfa.dart';
import 'package:smartbreath/deneme2.dart';
import 'package:smartbreath/models_providers/theme_provider.dart';
import 'package:smartbreath/services/Configuration.dart';
import 'models_providers/ChangeThemeButton.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    super.initState();
  }

  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? primaryGreen : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (themeProvider.isDarkMode) {
      _animationController.forward(from: 0.0);
    } else {
      _animationController.reverse(from: 0.0);
    }

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: () {
                    if (_currentPage != _numPages - 1) {
                      _pageController.jumpToPage(_numPages);
                    }
                  },
                  child: _currentPage != _numPages - 1
                      ? LocaleText(
                          'geç',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        )
                      : Text(""),
                ),
              ),
              Container(
                height: size.height * 0.78,
                child: PageView(
                  physics: ClampingScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    ListView(
                      children: [
                        SafeArea(
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                                top: size.height * 0.03,
                                bottom: size.height * 0.03),
                            child: Column(
                              children: [
                                Container(
                                  child: Lottie.asset(
                                      'assets/image/lf20_gwsharow.json',
                                      width: size.width * 0.55,
                                      height: size.width * 0.55),
                                ),
                                LocaleText(
                                  'dilustyazi',
                                  style: TextStyle(
                                      fontSize: size.width * .06,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: size.height * 0.02),
                                Container(
                                  width: size.width * .6,
                                  child: LocaleText(
                                    'dilaltyazi',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * .05,
                                ),
                                ListTile(
                                  onTap: () => Locales.change(context, 'tr'),
                                  title: Text('Türkçe'),
                                  leading: CircleAvatar(
                                    child:
                                        Image.asset("assets/image/turkey.png"),
                                  ),
                                ),
                                ListTile(
                                  onTap: () => Locales.change(context, 'en'),
                                  title: Text('English'),
                                  leading: CircleAvatar(
                                    child: Image.asset(
                                        "assets/image/united-kingdom.png"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListView(children: [
                      SafeArea(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: size.height * 0.1),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: size.width * 0.35,
                                    height: size.width * 0.35,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).cursorColor,
                                            Theme.of(context).canvasColor
                                          ],
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.topRight),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: Offset(40, 0),
                                    child: ScaleTransition(
                                      scale: _animationController.drive(
                                        Tween<double>(begin: 0.0, end: 1.0)
                                            .chain(
                                          CurveTween(curve: Curves.decelerate),
                                        ),
                                      ),
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        width: size.width * .26,
                                        height: size.width * .26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: size.height * 0.035),
                              LocaleText(
                                'temaustyazi',
                                style: TextStyle(
                                    fontSize: size.width * .06,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: size.height * 0.03),
                              Container(
                                width: size.width * .6,
                                child: LocaleText(
                                  'temaaltyazi',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                height: size.height * .15,
                              ),
                              ChangeThemeButtonWidget(),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    ListView(children: [
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/image/icon2.png',
                                ),
                                height: 300.0,
                                width: 300.0,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'Get a new experience\nof imagination',
                              style: TextStyle(fontSize: 25),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
              _currentPage != _numPages - 1
                  ? Expanded(
                      child: Align(
                        alignment: FractionalOffset.bottomRight,
                        child: FlatButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LocaleText(
                                'ileri',
                                style: TextStyle(
                                  fontSize: 22.0,
                                ),
                              ),
                              SizedBox(width: 10.0),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Align(
                        alignment: FractionalOffset.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('ON_BOARDING', false);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Anasayfa()));
                              },
                              child: LocaleText(
                                "bitti",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(width: 30)
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
