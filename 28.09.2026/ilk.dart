//print("ilk dersimiz -Dart SDK aktif olmalı");
//Jsdeki gibi let x="ahmet"; x=42;
/*
  //1.açık belirtilen veri tipleri
  int seansSuresiDakika = 45;
  double seansucretiTl = 2750.50;
  String uzmanAdi = "dr aygen yıldırım";
  bool aktifMi = true;

  //2.string interpolation
  //js'deki `${}` bunun yerine sadece $degisken işlem varsa ${degisken+2} kullanılır.

  print(
    "uzman:$uzmanAdi | süre:$seansSuresiDakika dk | ücret $seansucretiTl ₺",
  );
  print("KDV dahil (%20) ${seansucretiTl + 1.20}₺");

  //3.var ile tip çıkarım;
  var tedaviAdi = "kahve ile peeling";
  //tedaviAdi =99;
  print(tedaviAdi);

  //4. dynamic veri tiğini bağımsız kullanabillirsiniz ancak fluterda önerilmez
  dynamic serbestKutu = "Lazer epilasyon";
  serbestKutu = 1000; //izin verilir ama veri tip güvenliğini yok eder.


  //const:derleme anında değeri belli olan veriler,bellekte tek bir yerde saklanır.

  const String KLINIK_ADI = "Soft Ito GÜZELLİK MERKEZİ";
  const double KDV_ORANI = 0.20;

  //const DateTime suankiZaman=DateTime.now();
  //hata derleme anında bunu bilemeyiz.

  //final:çalışma anında hesaplanır.bir kere atandıktan sonra değişmez.

  final DateTime randevuZamani = DateTime.now();
  final String takipKodu =
      "SOFT-" + randevuZamani.microsecondsSinceEpoch.toString();

  print("Klinik adı: $KLINIK_ADI");
  print("Oluşturulma Tarihi: $randevuZamani: Kod: $takipKodu");



  //Dartta değişken varsayılan olarak null olamaz bunun yerine null safety operatörleri kullanırız.(?,??,!)

  String zorunluDanisanAdi = "Meltem Demir";
  String? danisanAlerjiNotu;
  print("alerji notu: $danisanAlerjiNotu");

  // ifNull operatörü-null ise varsayılan değer atama

  String goruntulenecekNot = danisanAlerjiNotu ?? "bilinen bir alerjisi yok";
  print("rapor: $goruntulenecekNot");

  //null aware
  print("alerji metin uzunluğu: ${danisanAlerjiNotu?.length}");
    */

//klasik sıralı fonksiyon
double topla(double a, double b) => a + b;

//modern dart/flutter standartları:Named parametresi({});

void seansKaydiOlustur({
  required String danisan,
  required String tedavi,
  required double birimFiyat,
  int seansSayisi = 1,
  double indirimOrani = 0.0, //default değer
  String? uzmanHekim, //null olabilir
}) {
  final double brutTutar = birimFiyat * seansSayisi;
  final double indirimTutari = brutTutar * (indirimOrani / 100);
  final double netTutar = brutTutar - indirimTutari;

  print("""
=============================

SoftIto Seans Sözleşmesi

-----------------------------

Danışan         :$danisan
Tedavi          :$tedavi (x$seansSayisi Seans)
Uzman Hekim.    :${uzmanHekim ?? "Nöbetçi Estetisyen"}
Brüt Tutar.     : $brutTutar ₺
İndirim.        : -$indirimTutari ₺ ($indirimOrani)
Ödenecek Tutar. : $netTutar ₺

=============================
""");
}

void main() {
  seansKaydiOlustur(
    danisan: "sümeyye muhammed",
    tedavi: "medikal cilt yenileme",
    birimFiyat: 4500.0,
    seansSayisi: 3,
    indirimOrani: 15.0,
    uzmanHekim: "Dr. Shad",
  );
}