import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:smartbreath/services/Configuration.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool _customTileExpanded = false;
  bool seciliRenk = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 16, sigmaX: 16),
        child: Scaffold(
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
          body: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
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
              SizedBox(height: 10.0),
              ExpansionTile(
                iconColor: primaryGreen,
                textColor: primaryGreen,
                title: Text(
                  'Herhangi bir konum hakkında nasıl yorum yapabilirim?',
                ),
                children: <Widget>[
                  ListTile(
                      title: Text(
                          "   SmartBreath uygulamasına giriş yaptıktan sonra altta bulunan haritanın görüntülendiği kısma girdikten sonra "
                          "ekranın üst tarafında bulunan arama bölümüne yorum yapmak istediğiniz mekanın/ortamın/yerin ismini yazıktan sonra çıkan ortam/mekan/yer "
                          "isimlerinden uygun olanı seçiniz. Alt kısımda çıkan mekan/ortam/yer hakkındaki bilgilerin görüntülendiği kısımdan değerlendirme "
                          "yapabilmek için kaç yıldız verdiğinizi seçin ve ardından çıkan ekranda yapmak istediğiniz yorumu yazın ve değerlendirmek için de "
                          "yıldızı değiştirebilirsiniz. Yapılan bu işlemlerden sonra Breath'leyebilirsiniz.\n\n"
                          "Harita --> Arama Bölümünden Mekan/Ortam/Yer Adı --> Yıldıza Dokunarak Yorum Kısmı --> Yapmak İstediğiniz Yorumu Yazın --> Breath'le.")),
                ],
              ),
              ExpansionTile(
                iconColor: primaryGreen,
                textColor: primaryGreen,
                title: Text(
                  'Profil fotoğrafımı nereden güncelleyebilirim?',
                ),
                children: <Widget>[
                  ListTile(
                      title: Text(
                          "   SmartBreath uygulamasına giriş yaptıktan sonra altta bulunan profilinizin görüntülendiği kısma girerek "
                          "profil fotoğrafınızın hemen yanında bulunan 'ikon'a dokunduktan sonra ister cihazınızın kamerasından bir fotoğraf çekebilirsiniz "
                          "isterseniz de cihazınızda bulunan herhangi bir fotoğrafı seçebilirsiniz. Seçiminizi gerçekleştirdikten sonra fotoğrafınızı "
                          "kırpabilir, döndürebilir veya ölçeklendirebilirsiniz. Bu işlemlerin sonunda profil fotoğrafınız güncellenecektir.\n\n"
                          "Profil --> Profil Fotoğrafınızın Yanında Bulunan İkon'a Dokunun --> Kameradan veya Galeriden Fotoğraf Yükle --> "
                          "Yüklemeyi Gerçekleştirin --> Fotoğrafınızı Düzenleyin --> Düzenlemiş Olduğunuz Fotoğrafı Yükleyin.")),
                ],
              ),
              ExpansionTile(
                iconColor: primaryGreen,
                textColor: primaryGreen,
                title: Text(
                  'Harita kısmından ekran görüntüsü paylaşımı nasıl yapabilirim?',
                ),
                children: <Widget>[
                  ListTile(
                      title: Text(
                          "   SmartBreath uygulamasına giriş yaptıktan sonra altta bulunan haritanın görüntülendiği kısma girdikten sonra "
                          "ekranın sol altında bulunan butona dokunduktan sonra paylaşım butonuna dokununuz. Ekran görüntüsünü paylaşmak istediğiniz "
                          "platformu seçiniz.\n\n"
                          "Harita --> Sol Alt Kısımda Bulunan Butona Tıklayın --> Paylaşım Tuşuna Basın --> Paylaşmak İstediğiniz Platformu Seçin --> Paylaşın.")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
