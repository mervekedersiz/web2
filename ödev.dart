class Urun {
  String id;
  String ad;
  double fiyat;
  int stok;
  String tip;

  Urun(
    this.id,
    this.ad,
    this.fiyat,
    this.stok,
    this.tip,
  );
}


// LSP düzeltmesi:
// Dijital ürün artık kargo metodu override edip Exception fırlatmıyor.
class KargoServisi {
  static const double kargoUcreti = 29.90;

  double kargoUcretiHesapla(Urun urun) {
    if (urun.tip == "FIZIKSEL") {
      return kargoUcreti;
    }

    return 0;
  }

  void kargoGonder(String adres) {
    print("MNG Kargo gönderildi: $adres");
  }
}


class DijitalUrun extends Urun {
  DijitalUrun(
    String id,
    String ad,
    double fiyat,
    int stok,
  ) : super(
          id,
          ad,
          fiyat,
          stok,
          "DIJITAL",
        );
}


class SqliteVeritabani {
  void kaydet(String sql) {
    print("DB calistirildi: $sql");
  }
}


class SiparisRepository {
  final SqliteVeritabani db;

  SiparisRepository(this.db);

  void siparisKaydet(String orderId, double tutar) {
    db.kaydet(
      "INSERT INTO siparisler VALUES ('$orderId', $tutar)",
    );
  }
}


// OCP düzeltmesi:
// Ödeme yöntemleri ayrı sınıflara ayrıldı.
// Yeni ödeme yöntemi eklemek için mevcut sınıfları değiştirmek gerekmez.
abstract class OdemeServisi {
  void odemeYap(double tutar);
}

class KrediKartiOdeme implements OdemeServisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Kredi kartından POS ile çekildi.");
  }
}

class HavaleOdeme implements OdemeServisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Havale kontrol edildi.");
  }
}

class KapidaOdeme implements OdemeServisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Kapıda ödeme tahsil edilecek.");
  }
}

class CryptoOdeme implements OdemeServisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL USDT transferi onaylandı.");
  }
}


class MailServisi {
  void mailGonder(String email, String mesaj) {
    print("SMTP Mail gönderildi: $email");
  }
}


class SmsServisi {
  void smsGonder(String telefon, String mesaj) {
    print("SMS iletildi: $telefon");
  }
}


class FaturaServisi {
  void faturaOlustur(String orderId) {
    print("Fatura PDF oluşturuldu: $orderId");
  }
}


// Clean Code düzeltmesi:
// Müşteri bilgileri tek bir sınıfta toplandı.
// Böylece sipariş metodundaki parametre sayısı azaltıldı.
class Musteri {
  String ad;
  String email;
  String telefon;
  String adres;

  Musteri(
    this.ad,
    this.email,
    this.telefon,
    this.adres,
  );
}


class Siparis {
  String id;
  List<Urun> sepet;
  OdemeServisi odemeServisi;
  Musteri musteri;
  String kuponKodu;

  Siparis(
    this.id,
    this.sepet,
    this.odemeServisi,
    this.musteri,
    this.kuponKodu,
  );
}


// SRP düzeltmesi:
// Sipariş işlemleri yardımcı sınıflara ayrıldı.
// SiparisYoneticisi artık işlemleri organize ediyor.
class SiparisYoneticisi {
  final SiparisRepository siparisRepository;
  final KargoServisi kargoServisi;
  final MailServisi mailServisi;
  final SmsServisi smsServisi;
  final FaturaServisi faturaServisi;
  final IndirimServisi indirimServisi;

  // Clean Code düzeltmesi:
  // Kullanılmayan odemeServisi parametresi kaldırıldı.
  SiparisYoneticisi({
    required this.siparisRepository,
    required this.kargoServisi,
    required this.mailServisi,
    required this.smsServisi,
    required this.faturaServisi,
    required this.indirimServisi,
  });

  void siparisTamamla(Siparis siparis) {
    if (!_stokKontrolEt(siparis.sepet)) {
      return;
    }

    final toplam = _toplamHesapla(siparis.sepet);

    final indirimliToplam = indirimServisi.indirimUygula(
      toplam,
      siparis.kuponKodu,
    );

    final sonTutar = _kdvEkle(indirimliToplam);

    siparis.odemeServisi.odemeYap(sonTutar);

    _stokAzalt(siparis.sepet);

    siparisRepository.siparisKaydet(
      siparis.id,
      sonTutar,
    );

    faturaServisi.faturaOlustur(siparis.id);

    _mailGonder(siparis, sonTutar);
    _smsGonder(siparis);

    _kargoGonder(siparis);
  }


  bool _stokKontrolEt(List<Urun> sepet) {
    for (final urun in sepet) {
      if (urun.stok <= 0) {
        print("Hata: ${urun.ad} tükenmiş!");
        return false;
      }
    }

    return true;
  }


  double _toplamHesapla(List<Urun> sepet) {
    double toplam = 0;

    for (final urun in sepet) {
      toplam += urun.fiyat;
      toplam += kargoServisi.kargoUcretiHesapla(urun);
    }

    return toplam;
  }


  // Clean Code düzeltmesi:
  // KDV oranı magic number olmaktan çıkarıldı.
  double _kdvEkle(double toplam) {
    const kdvOrani = 0.20;

    return toplam + (toplam * kdvOrani);
  }


  void _stokAzalt(List<Urun> sepet) {
    for (final urun in sepet) {
      urun.stok--;
    }
  }


  void _mailGonder(
    Siparis siparis,
    double sonTutar,
  ) {
    final mesaj =
        "Sayın ${siparis.musteri.ad}, "
        "siparişiniz alındı. "
        "Tutar: $sonTutar TL";

    mailServisi.mailGonder(
      siparis.musteri.email,
      mesaj,
    );
  }


  void _smsGonder(Siparis siparis) {
    final mesaj =
        "Siparişiniz onaylandı: ${siparis.id}";

    smsServisi.smsGonder(
      siparis.musteri.telefon,
      mesaj,
    );
  }


  void _kargoGonder(Siparis siparis) {
    final fizikselUrunVar = siparis.sepet.any(
      (urun) => urun.tip == "FIZIKSEL",
    );

    if (fizikselUrunVar) {
      kargoServisi.kargoGonder(
        siparis.musteri.adres,
      );
    }
  }
}


// Clean Code / SRP düzeltmesi:
// İndirim işlemi SiparisYoneticisi'nden ayrıldı.
class IndirimServisi {
  double indirimUygula(
    double toplam,
    String kuponKodu,
  ) {
    if (kuponKodu == "INDIRIM10") {
      return toplam * 0.90;
    }

    if (kuponKodu == "YAZ20") {
      return toplam * 0.80;
    }

    if (kuponKodu == "SEPETTE50") {
      return toplam - 50;
    }

    return toplam;
  }
}


void main() {
  final urun1 = Urun(
    "1",
    "Kablosuz Mouse",
    450.0,
    5,
    "FIZIKSEL",
  );

  final urun2 = DijitalUrun(
    "2",
    "Flutter Kursu E-Kitap",
    150.0,
    100,
  );

  final musteri = Musteri(
    "Selahaddin",
    "selahaddin@kodvance.com",
    "05551112233",
    "Kadıköy / İstanbul",
  );

  final siparis = Siparis(
    "SP-9921",
    [urun1, urun2],
    KrediKartiOdeme(),
    musteri,
    "INDIRIM10",
  );

  final siparisci = SiparisYoneticisi(
    siparisRepository: SiparisRepository(
      SqliteVeritabani(),
    ),
    kargoServisi: KargoServisi(),
    mailServisi: MailServisi(),
    smsServisi: SmsServisi(),
    faturaServisi: FaturaServisi(),
    indirimServisi: IndirimServisi(),
  );

  siparisci.siparisTamamla(siparis);
}