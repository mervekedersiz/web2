// 1. ENUMLAR (Derleme Zamanı Güvenliği - Tip Güvenliği Sağlar)
// Kliniğin sunduğu ana işlem kategorilerini tanımlayan sabit seçenek listesi.
enum HizmetKategorisi {
  ciltYenileme,
  medikalEstetik,
  lazerEpilasyon,
  Lipo,
}

// Bir seansın yaşam döngüsündeki anlık durumlarını temsil eden enum yapısı.
enum SeansDurumu {
  bekliyor,
  odadaIslemde,
  tamamlandi,
  iptalEdildi,
}

// Ödeme esnasında kabul edilen finansal yöntemleri belirleyen enum yapısı.
enum OdemeYontemi {
  krediKarti,
  havaleEft,
  nakit,
  klinikPaketKredisi,
}

// 2. DANIŞAN (MÜŞTERİ) MODELİ
// Kliniğe başvuran danışanların kişisel ve medikal profilini tutan sınıf.
class Danisan {
  // Danışanın benzersiz kayıt numarası (Örn: 'DAN-101').
  final String id;
  // Danışanın ad ve soyad bilgisi.
  final String adSoyad;
  // İletişim amaçlı telefon numarası.
  final String telefon;
  // VIP ayrıcalığı bulunup bulunmadığını tutan mantıksal bayrak.
  final bool vipUyeMi;
  // Bilinen alerjileri saklayan liste (boş olabilir fakat null değer alamaz).
  final List<String> alerjiler;
  // Cilde dair özel notlar veya uyarılar (isteğe bağlı, null kalabilir).
  final String? ozelCiltNotu;

  // Danışan nesnesini oluşturan kurucu metot (const constructor ile bellek optimizasyonu).
  const Danisan({
    required this.id,
    required this.adSoyad,
    required this.telefon,
    this.vipUyeMi = false, // Varsayılan değer olarak standart üyelik atanır.
    this.alerjiler = const [], // Varsayılan olarak alerji listesi boş kümedir.
    this.ozelCiltNotu,
  });

  // Alerji listesi doluysa danışanı otomatik hassas ciltli kabul eden getter.
  bool get hassasCiltMi => alerjiler.isNotEmpty;

  // Danışanın profil özetini tek bir formatlı metin halinde sunan getter.
  String get bilgiOzeti {
    // Alerji listesi boşsa bilgilendirme metni, doluysa virgülle ayrılmış liste döner.
    final String alerjiBilgisi = alerjiler.isEmpty
        ? "Kayıtlı Alerji Yok"
        : "Alerjiler: ${alerjiler.join(', ')}";

    // Cilt notu girilmemişse varsayılan metni kullanır (Null-coalescing operatörü).
    final String notBilgisi = ozelCiltNotu ?? "Özel medikal not girilmemiş";

    // VIP üyeliğe göre profil etiketi oluşturur.
    final String vipRozeti = vipUyeMi ? "VİP" : "Standart";

    // Tüm parçaları tek bir metin satırı olarak birleştirir ve döndürür.
    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi";
  }
}

// 3. SEANS (RANDEVU) MODELİ
// Her randevunun fiyat, indirim, uzman ve süreç takibini yürüten sınıf.
class SeansKaydi {
  // Seansa özel üretilmiş tekil takip kodu (Örn: 'SNS-2026-1').
  final String seansKodu;
  // İşlemin uygulanacağı danışanın nesne referansı.
  final Danisan danisan;
  // İşlemin bağlı bulunduğu hizmet dalı.
  final HizmetKategorisi kategori;
  // Gerçekleştirilecek spesifik uygulamanın adı.
  final String islemAdi;
  // Tek bir seans için uygulanan baz ücret.
  final double birimFiyat;
  // Toplam planlanan seans adedi.
  final int seansSayisi;
  // Bu randevu için tanımlanan temel indirim yüzdesi.
  final double indirimOrani;
  // İşlemi yapacak uzman estetisyen/doktor (henüz atanmamışsa null olabilir).
  final String? sorumluUzman;
  // Randevunun ilerleme durumu (süreç içinde güncelleneceği için final değildir).
  SeansDurumu durum;
  // Tamamlama aşamasında belirlenen ödeme aracı.
  OdemeYontemi? odemeTipi;

  // Yeni bir seans kaydı oluşturan kurucu metot.
  SeansKaydi({
    required this.seansKodu,
    required this.danisan,
    required this.kategori,
    required this.islemAdi,
    required this.birimFiyat,
    this.seansSayisi = 1, // Belirtilmediğinde tek seans varsayılır.
    this.indirimOrani = 0.0, // Varsayılan kampanya indirimi sıfırdır.
    this.sorumluUzman,
    this.durum = SeansDurumu.bekliyor, // Her seans bekleme durumunda sisteme girer.
    this.odemeTipi,
  });

  // İndirimsiz toplam tutarı birim fiyat ile seans sayısını çarparak bulur.
  double get brutTutar => birimFiyat * seansSayisi;

  // Varsa VIP ilavesini (%10) ekleyip toplam iskonto miktarını para birimi cinsinden hesaplar.
  double get indirimTutari {
    double toplamOran = indirimOrani;

    // Danışan VIP üye ise mevcut oranın üzerine ekstra %10 indirim eklenir.
    if (danisan.vipUyeMi) {
      toplamOran += 10.0;
    }

    // Toplam orana göre düşülecek para miktarını döndürür.
    return brutTutar * (toplamOran / 100.0);
  }

  // Müşterinin kasaya ödeyeceği son net rakamı hesaplar.
  double get netTutar => brutTutar - indirimTutari;
}

// 4. KLİNİK YÖNETİCİSİ (Yönetim Servisi)
// Kliniğin operasyonel listelerini ve finansal hesaplama akışlarını barındırır.
class KlinikYoneticisi {
  // Şube adı bilgisi.
  final String subeAdi;
  // Kliniğe ait tüm randevuların tutulduğu private (özel) liste.
  final List<SeansKaydi> _seanslar = [];
  // Danışanlara ID üzerinden hızlı erişim sunan private harita koleksiyonu.
  final Map<String, Danisan> _danisanRehberi = {};

  // Klinik yöneticisi sınıfını şube adıyla başlatan kurucu metot.
  KlinikYoneticisi({required this.subeAdi});

  // Danışanı kimlik numarası anahtarıyla rehbere ekler ve konsola bilgi basar.
  void danisanKaydet(Danisan danisan) {
    _danisanRehberi[danisan.id] = danisan;
    print("Rehbere Eklendi: ${danisan.adSoyad} (${danisan.vipUyeMi ? "VİP" : "Standart"})");
  }

  // Oluşturulan yeni bir seans kaydını operasyon listesine dahil eder.
  void randevuOlustur(SeansKaydi seans) {
    _seanslar.add(seans);
    print("Randevu Kaydedildi [${seans.seansKodu}]: ${seans.danisan.adSoyad} -> ${seans.islemAdi}");
  }

  // Seansı tamamlandı durumuna çeker, ödeme türünü işler ve başarı mesajı verir.
  void seansiTamamla({required String seansKodu, required OdemeYontemi odeme}) {
    // Listeyi tarayarak ilgili seans kodunu arar.
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.tamamlandi; // Seans durumunu günceller.
        seans.odemeTipi = odeme; // Seçilen ödeme yöntemini atar.
        print("Seans Tamamlandı: [${seans.seansKodu}]: ${seans.netTutar.toStringAsFixed(2)} TL tahsil edildi (${odeme.name})");
        return; // İşlem tamamlandığında metottan doğrudan çıkar.
      }
    }
    // Kod listede bulunamazsa hata mesajını ekrana yansıtır.
    print("Hata [$seansKodu] kodlu seans bulunamadı.");
  }

  // Seansı gerekçesiyle birlikte iptal statüsüne geçirir.
  void seansiIptalEt(String seansKodu, {String? iptalNedeni}) {
    // Listedeki seansları gezerek eşleşen kodu bulur.
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.iptalEdildi; // Durumu iptale çeker.
        print("Seans İptal Edildi [${seans.seansKodu}]: ${iptalNedeni ?? "Gerekçe Belirtilmedi"}");
        return; // İşlem yapıldığı için metottan çıkar.
      }
    }
    // Eşleşme sağlanamazsa hata bildirimi basar.
    print("Hata [$seansKodu] kodlu seans iptal edilemedi, kayıt bulunamadı.");
  }

  // Tamamlanan seansları filtreleyip net tutarlarını toplayarak gerçek ciroyu bulur.
  double get toplamTahsilEdilenCiro => _seanslar
      .where((s) => s.durum == SeansDurumu.tamamlandi) // Sadece tamamlananları seçer.
      .fold(0.0, (toplam, s) => toplam + s.netTutar); // Değerleri üst üste toplar.

  // Bekleyen veya odada işlem gören seansların potansiyel tahsilat tutarını hesaplar.
  double get beklenenPotansiyelCiro => _seanslar
      .where((s) => s.durum == SeansDurumu.bekliyor || s.durum == SeansDurumu.odadaIslemde)
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  // Hizmet kategorilerine göre toplam seans dağılım istatistiğini döndürür.
  Map<HizmetKategorisi, int> kategoriBazliSeansDagilimi() {
    final Map<HizmetKategorisi, int> dagilim = {};

    // Önce her enum kategorisi için sayaç değerini 0 olarak başlatır.
    for (var kat in HizmetKategorisi.values) {
      dagilim[kat] = 0;
    }

    // Her seansın ait olduğu kategorinin sayacını bir artırır.
    for (var s in _seanslar) {
      dagilim[s.kategori] = (dagilim[s.kategori] ?? 0) + 1;
    }

    return dagilim;
  }

  // Görevli olan tüm tekil uzmanların isimlerini küme (Set) yapısında toplar.
  Set<String> gorevliUzmanKadrosu() {
    return _seanslar
        .map((s) => s.sorumluUzman) // Seanslardan uzman adlarını seçer.
        .whereType<String>() // Null olmayan String kayıtları filtreler.
        .toSet(); // Yinelenen isimleri eleyerek benzersiz küme oluşturur.
  }

  // Uzmanı henüz belirlenmemiş sahipsiz seansları filtreleyerek döndürür.
  List<SeansKaydi> uzmansizSeanslariGetir() {
    return _seanslar.where((s) => s.sorumluUzman == null).toList();
  }

  // Kliniğin gün sonu çizelgesini ve finansal özetini tablo formatında yazdırır.
  void gunSonuRaporuYazdir() {
    print("\n================ Günlük Seans ve İşlem Çizelgesi ================");
    print("-----------------------------------------------------------------");
    // Tablo sütun başlıklarını sabit genişliklerle hizalar.
    print(
      "${'Kod'.padRight(12)} | "
      "${'Danışan'.padRight(16)} | "
      "${'İşlem'.padRight(22)} | "
      "${'Uzman'.padRight(18)} | "
      "${'Tutar'.padRight(12)} | "
      "Durum",
    );
    print("-----------------------------------------------------------------");

    // Tüm seans kayıtlarını satır satır dolaşarak tabloya döker.
    for (var s in _seanslar) {
      // Uzman atanmamışsa varsayılan nöbetçi metnini kullanır.
      final String uzman = s.sorumluUzman ?? "Nöbetçi Bekliyor";

      // Dart switch-expression yapısıyla durum değerini kullanıcı dostu metne dönüştürür.
      final String durumRozet = switch (s.durum) {
        SeansDurumu.tamamlandi => "Tamamlandı",
        SeansDurumu.odadaIslemde => "İşlemde",
        SeansDurumu.bekliyor => "Bekliyor",
        SeansDurumu.iptalEdildi => "İptal",
      };

      // Seans bilgilerini biçimlendirip konsola satır olarak basar.
      print(
        "${s.seansKodu.padRight(12)} | "
        "${s.danisan.adSoyad.padRight(16)} | "
        "${s.islemAdi.padRight(22)} | "
        "${uzman.padRight(18)} | "
        "${s.netTutar.toStringAsFixed(2).padRight(12)} | "
        "$durumRozet",
      );
    }

    print("-----------------------------------------------------------------");
    print("Finansal Özet:");
    // Kasaya giren reel ciroyu 2 ondalık basamak hassasiyetle yazdırır.
    print(" * Gerçekleşen (Kasadaki Net Ciro) : ${toplamTahsilEdilenCiro.toStringAsFixed(2)} TL");
    // Henüz tamamlanmamış seanslardan beklenen alacağı gösterir.
    print(" * Bekleyen Potansiyel Alacak       : ${beklenenPotansiyelCiro.toStringAsFixed(2)} TL");
    // Toplam randevu adedini gösterir.
    print(" * Toplam Seans Adedi               : ${_seanslar.length} Randevu");
    print("-----------------------------------------------------------------");

    print("Aktif Uzmanlar:");
    final uzmanlar = gorevliUzmanKadrosu();
    // Görevli uzman kadrosunu kontrol edip listeler.
    if (uzmanlar.isEmpty) {
      print(" Kayıtlı uzman bulunamadı.");
    } else {
      print(" ${uzmanlar.join(', ')}");
    }

    // Uzman atanmamış kritik randevuları denetler ve uyarısını basar.
    final uzmansizlar = uzmansizSeanslariGetir();
    if (uzmansizlar.isNotEmpty) {
      print("\nDikkat: ${uzmansizlar.length} adet seansa henüz sorumlu uzman atanmamıştır!");
      for (var u in uzmansizlar) {
        print(" -> [${u.seansKodu}] ${u.danisan.adSoyad} (${u.islemAdi})");
      }
    }
    print("=================================================================\n");
  }
}

// 5. UYGULAMA GİRİŞ NOKTASI (Main Metodu)
void main() {
  print("Klinik yönetim sistemi başlatılıyor....\n");

  // Klinik yöneticisi nesnesini şube bilgisiyle ayağa kaldırıyoruz.
  final yonetici = KlinikYoneticisi(subeAdi: "Softito Bağcılar Şubesi");

  // --- DANIŞAN VERİLERİNİN OLUŞTURULMASI ---
  // Alerjisi ve medikal notu bulunan VIP danışan kaydı.
  final d1 = Danisan(
    id: "DAN-101",
    adSoyad: "Merve Kedersiz",
    telefon: "0532 100 20 30",
    vipUyeMi: true, // VIP indirimi alacak.
    alerjiler: ["Retinol", "Aspirin"],
    ozelCiltNotu: "Cilt bariyeri hassas ve kuru",
  );

  // Herhangi bir alerjisi bulunmayan standart üye kaydı.
  final d2 = Danisan(
    id: "DAN-102",
    adSoyad: "Deniz Kaya",
    telefon: "0544 200 30 40",
    vipUyeMi: false,
    alerjiler: [],
  );

  // Alerjisi bulunan fakat medikal notu girilmemiş VIP üye kaydı.
  final d3 = Danisan(
    id: "DAN-103",
    adSoyad: "Selim Arslan",
    telefon: "0555 300 40 50",
    vipUyeMi: true,
    alerjiler: ["Lateks"],
  );

  // Alerjisi olmayan ancak özel cilt notu bulunan VIP üye kaydı.
  final d4 = Danisan(
    id: "DAN-104",
    adSoyad: "Zeynep Güneş",
    telefon: "0505 400 50 60",
    vipUyeMi: true,
    alerjiler: [],
    ozelCiltNotu: "Leke tedavisine yatkın cilt",
  );

  // Danışanları klinik rehberine (Map koleksiyonuna) kaydediyoruz.
  yonetici.danisanKaydet(d1);
  yonetici.danisanKaydet(d2);
  yonetici.danisanKaydet(d3);
  yonetici.danisanKaydet(d4);

  print("\n--- Danışan Güvenlik Kontrolleri ---");
  // Danışanların kart özetlerini kontrol amacıyla konsola yazdırıyoruz.
  print(d1.bilgiOzeti);
  print(d2.bilgiOzeti);
  print("------------------------------------\n");

  // --- RANDEVU VE SEANS OLUŞTURMA ADIMI ---
  // 1. Randevu: VIP indirimine ek %5 kampanya indirimi içeren Lipo seansı.
  final seans1 = SeansKaydi(
    seansKodu: "SNS-2026-1",
    danisan: d1,
    kategori: HizmetKategorisi.Lipo,
    islemAdi: "Bölgesel İncelme",
    birimFiyat: 6500.0,
    seansSayisi: 2,
    indirimOrani: 5.0,
    sorumluUzman: "Kübra Akyol",
  );

  // 2. Randevu: Uzmanı henüz atanmamış olan cilt bakım seansı (uzmansız uyarısı verecek).
  final seans2 = SeansKaydi(
    seansKodu: "SNS-2026-2",
    danisan: d2,
    kategori: HizmetKategorisi.ciltYenileme,
    islemAdi: "Medikal Cilt Bakımı",
    birimFiyat: 2500.0,
    seansSayisi: 3,
    indirimOrani: 10.0,
    sorumluUzman: null, // Uzman boş bırakıldı.
  );

  // 3. Randevu: 10 seanslık lazer epilasyon randevusu.
  final seans3 = SeansKaydi(
    seansKodu: "SNS-2026-3",
    danisan: d3,
    kategori: HizmetKategorisi.lazerEpilasyon,
    islemAdi: "Tüm Vücut Epilasyon",
    birimFiyat: 20000.0,
    seansSayisi: 1,
    indirimOrani: 0.0,
    sorumluUzman: "Hasbiyenur Çoban",
  );

  // 4. Randevu: Medikal estetik operasyon randevusu.
  final seans4 = SeansKaydi(
    seansKodu: "SNS-2026-4",
    danisan: d4,
    kategori: HizmetKategorisi.medikalEstetik,
    islemAdi: "Burun Dolgusu",
    birimFiyat: 4500.0,
    seansSayisi: 1,
    indirimOrani: 0.0,
    sorumluUzman: "Büşra Akyol",
  );

  // Oluşturulan randevuları klinik yönetim listesine işliyoruz.
  yonetici.randevuOlustur(seans1);
  yonetici.randevuOlustur(seans2);
  yonetici.randevuOlustur(seans3);
  yonetici.randevuOlustur(seans4);

  print("\n--- İşlemler ve Tahsilat Akışı ---");

  // Seans 1 kredi kartı ile tamamlanıyor (Kasadaki ciroya dahil edilir).
  yonetici.seansiTamamla(
    seansKodu: "SNS-2026-1",
    odeme: OdemeYontemi.krediKarti,
  );

  // Seans 2 nakit tahsil edilerek tamamlanıyor (Kasadaki ciroya dahil edilir).
  yonetici.seansiTamamla(
    seansKodu: "SNS-2026-2",
    odeme: OdemeYontemi.nakit,
  );

  // Seans 4 mazeret belirtilerek iptal ediliyor.
  yonetici.seansiIptalEt(
    "SNS-2026-4",
    iptalNedeni: "Danışan randevusunu şehir dışı seyahati sebebiyle erteledi",
  );

  // Tüm günün seans dökümünü ve finansal analiz raporunu yazdırıyoruz.
  yonetici.gunSonuRaporuYazdir();
}