// 1. Cihaz Tipleri
enum CihazTipi {
  sensor,
  gateway,
  edgeServer,
  router,
}

// 8. Özel Exception Sınıfı
class CihazErisilemezException implements Exception {
  final String mesaj;

  CihazErisilemezException(this.mesaj);

  @override
  String toString() => "Bağlantı Hatası: $mesaj";
}

// 2. IoTCihaz Sınıfı
class IoTCihaz {
  final String seriNo;
  final String cihazAdi;
  final CihazTipi tip;
  final double cpuYukYuzdesi;
  final int bellekMb;
  final Set<String> acikPortlar;
  final bool sslSertifikasiGecerliMi;
  final bool aktifMi; // Ormandaki panel/batarya veya sinyal durumu

  IoTCihaz({
    required this.seriNo,
    required this.cihazAdi,
    required this.tip,
    required this.cpuYukYuzdesi,
    required this.bellekMb,
    required this.acikPortlar,
    required this.sslSertifikasiGecerliMi,
    this.aktifMi = true,
  });

  // Güvenlik açığı getter'ı
  bool get guvenlikAcigiVarMi =>
      !sslSertifikasiGecerliMi || acikPortlar.contains("23/TELNET");

  // Yangın hattı risk durumu: Güvenlik açığı veya aşırı telemetri yükü (CPU > %85)
  bool get riskliMi => guvenlikAcigiVarMi || cpuYukYuzdesi > 85.0;
}

// 6. Seri Numarasına Göre Cihaz Bulma (Dart 3 Record)
(String cihazAdi, CihazTipi tip, bool alarmDurumu)? cihazBilgisiGetir(
  List<IoTCihaz> ormanAgi,
  String seriNo,
) {
  try {
    final cihaz = ormanAgi.firstWhere((c) => c.seriNo == seriNo);
    return (cihaz.cihazAdi, cihaz.tip, cihaz.riskliMi);
  } on StateError {
    return null;
  }
}

// 7. Cihaz Tipine Göre İzolasyon Bölgesi (Dart 3 Switch Expression)
String izolasyonBolgesiBelirle(CihazTipi tip) => switch (tip) {
      CihazTipi.sensor => "ZONE-S (Ağaç Gövdesi Uç Algılayıcı Alanı)",
      CihazTipi.gateway => "ZONE-G (Kule LoRaWAN / GSM Geçidi)",
      CihazTipi.edgeServer => "ZONE-E (Yangın Gözetleme Kulesi Uç Analiz)",
      CihazTipi.router => "ZONE-R (Bölge Orman İşletme Omurga Hattı)",
    };

// 8. Cihaza Uzaktan Telemetri Bağlantısı (Exception Testi)
void cihazaBaglan(IoTCihaz cihaz) {
  if (!cihaz.aktifMi) {
    throw CihazErisilemezException(
      "${cihaz.cihazAdi} (${cihaz.seriNo}) güneş paneli/batarya arızası nedeniyle çevrimdışı, telemetri alınamadı!",
    );
  }
  print("Bağlantı kuruldu: ${cihaz.cihazAdi} telemetri hattı devrede.");
}

void main() {
  print("=== ORMAN YANGINI ERKEN UYARI VE IOT AĞI BAŞLATILDI ===\n");

  // 3. Orman Ağına Ait 6 Farklı IoT Cihazı
  final List<IoTCihaz> ormanAgi = [
    IoTCihaz(
      seriNo: "FIRE-S101",
      cihazAdi: "Kızılçam Duman & Gaz Sensörü",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 22.0,
      bellekMb: 64,
      acikPortlar: {"1883/MQTT"},
      sslSertifikasiGecerliMi: true,
      aktifMi: true,
    ),
    IoTCihaz(
      seriNo: "FIRE-G201",
      cihazAdi: "Gözetleme Kulesi LoRaWAN Gateway",
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 91.5, // Ani veri akışından CPU > 85 (Riskli)
      bellekMb: 1024,
      acikPortlar: {"443/HTTPS"},
      sslSertifikasiGecerliMi: true,
      aktifMi: true,
    ),
    IoTCihaz(
      seriNo: "FIRE-E301",
      cihazAdi: "Termal Kamera Görüntü İşleme Edge Server",
      tip: CihazTipi.edgeServer,
      cpuYukYuzdesi: 60.0,
      bellekMb: 8192,
      acikPortlar: {"22/SSH", "23/TELNET"}, // Telnet açık (Riskli)
      sslSertifikasiGecerliMi: true,
      aktifMi: false, // Panel arızası - Kapalı cihaz
    ),
    IoTCihaz(
      seriNo: "FIRE-R401",
      cihazAdi: "Orman İşletme Müdürlüğü Mikrodalga Router",
      tip: CihazTipi.router,
      cpuYukYuzdesi: 38.0,
      bellekMb: 2048,
      acikPortlar: {"22/SSH", "443/HTTPS"},
      sslSertifikasiGecerliMi: true,
      aktifMi: true,
    ),
    IoTCihaz(
      seriNo: "FIRE-S102",
      cihazAdi: "Vadi Tabanı Nem ve Sıcaklık Sensörü",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 18.0,
      bellekMb: 128,
      acikPortlar: {"80/HTTP"},
      sslSertifikasiGecerliMi: false, // SSL sertifikası dolmuş (Riskli)
      aktifMi: true,
    ),
    IoTCihaz(
      seriNo: "FIRE-G202",
      cihazAdi: "Yedek Kanyon GSM Gateway",
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 87.0, // CPU yüksek ve Telnet açık (Riskli)
      bellekMb: 512,
      acikPortlar: {"23/TELNET"},
      sslSertifikasiGecerliMi: false,
      aktifMi: false, // Akü tükenmiş - Kapalı cihaz
    ),
  ];

  // 4. .where() ile Riskli / Açığı Bulunan Cihazların Tespiti
  final riskliCihazlar = ormanAgi
      .where((cihaz) => cihaz.guvenlikAcigiVarMi || cihaz.cpuYukYuzdesi > 85.0)
      .toList();

  print("--- 1. KRİTİK / RİSKLİ YANGIN CİHAZLARI (.where) ---");
  for (var c in riskliCihazlar) {
    print("• ${c.cihazAdi} [${c.seriNo}] -> CPU: %${c.cpuYukYuzdesi} | Güvenlik Açığı: ${c.guvenlikAcigiVarMi}");
  }
  print("Riskli cihaz adedi: ${riskliCihazlar.length}\n");

  // 5. .fold() ile Ağdaki Toplam Bellek Tüketimi
  final int toplamBellek = ormanAgi.fold<int>(
    0,
    (toplam, cihaz) => toplam + cihaz.bellekMb,
  );

  print("--- 2. ORMAN AĞI TOPLAM BELLEK TÜKETİMİ (.fold) ---");
  print("Sistemde tahsis edilen toplam bellek: $toplamBellek MB\n");

  // 6. Seri Numarasına Göre Sorgulama & Record (Dart 3 Record)
  print("--- 3. SERİ NO İLE CİHAZ VE ALARM DURUMU SORGULAMA (Record) ---");
  final sorgulanacakSeriler = ["FIRE-S101", "FIRE-E301", "FIRE-X999"];

  for (var seri in sorgulanacakSeriler) {
    final sonuc = cihazBilgisiGetir(ormanAgi, seri);
    if (sonuc != null) {
      final (adi, tip, alarm) = sonuc;
      print("Seri: $seri | İsim: $adi | Tür: ${tip.name} | Alarm Durumu: ${alarm ? '⚠️ ALARM VERİYOR (RİSKLİ)' : '✅ GÜVENLİ'}");
    } else {
      print("Seri: $seri | Kayıt bulunamadı (Bilinmeyen donanım)!");
    }
  }
  print("");

  // 7. Cihaz Tipine Göre İzolasyon Bölgeleri (Switch Expression)
  print("--- 4. AĞ İZOLASYON BÖLGELERİ (Switch Expression) ---");
  for (var cihaz in ormanAgi) {
    print("${cihaz.cihazAdi} (${cihaz.tip.name}) -> ${izolasyonBolgesiBelirle(cihaz.tip)}");
  }
  print("");

  // 8. Cihaz Bağlantı Kontrolü & İstisna Yönetimi (try-catch)
  print("--- 5. SAHA ERİŞİM TESTİ VE HATA YÖNETİMİ (try-catch) ---");
  // Biri açık (FIRE-S101), biri kapalı (FIRE-E301) cihaz test edilir
  final testEdilecekler = [ormanAgi[0], ormanAgi[2]];

  for (var cihaz in testEdilecekler) {
    try {
      print("Bağlanıyor: ${cihaz.cihazAdi}...");
      cihazaBaglan(cihaz);
    } on CihazErisilemezException catch (e) {
      print("[YAKALANAN HATA] $e");
    } catch (e) {
      print("[BEKLENMEYEN HATA] $e");
    }
  }

  print("\n=== TÜM AĞ KONTROLLERİ TAMAMLANDI ===");
}