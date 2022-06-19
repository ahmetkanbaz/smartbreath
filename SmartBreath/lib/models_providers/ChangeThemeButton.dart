import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:smartbreath/models_providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ChangeThemeButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
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
    );
  }
}
