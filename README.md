# smartbreath
ESP32'nin bluetooth modülü ile Flutter mobil uygulamasına sensörlerin ölçüm sonuçları gönderilmektedir.

ESP32'nin bluetooth modülü düşük enerji bluetooth (Bluetooth Low Energy (BLE)) olarak tanımlanmıştır. Bu sayede hem IOS hem de Android işletim sistemlerinin bluetooth modülleri ile iletişime geçmesi sağlanmıştır.
ESP32'ye bağlı olan sensörlerin ölçüm sonuçları alınır ve bluetooth yardımı ile mobil uygulamaya gönderimi sağlanmaktadır.

Flutter kısmında ise ESP32'nin bluetooth modülünden gelen veriler mobil uygulamada gösterilmekte ve sensörlerin ölçüm sonuçları insanların solunum sistemlerini olumsuz etkileyebilecek herhangi bir düzeye geldiği zaman kullanıcı bildirim yoluyla uyarılmaktadır.
Mobil uygulamaya google haritalar eklenerek kullanıcıların gitmek istedikleri konumu seçmeleri veya aramaları sağlanmıştır.
Sensörlerin ölçüm sonuçları insanların solunum sistemlerini olumsuz etkileyebilecek herhangi bir düzeye geldiği zaman haritalarda konum renklendirilerek riskli olarak işaretlenmektedir. Böylece kullanıcılar konumlar hakkında bilgi sahibi olmaları sağlanmıştır.
Haritalarda konumlar hakkında yorumlar yapılabilmekte ve farklı kullanıcıların yapmış oldukları yorumlar görüntülenebilmektedir.

Mobil uygulamaya profil fotoğrafı eklenebilmesi ve güncellenebilmesi sağlanmıştır. Profil fotoğrafında kırpma gibi düzenlemeler gerçekleştirilebilmesi sağlanmıştır.
