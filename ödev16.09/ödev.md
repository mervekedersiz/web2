
GÖREV 1: Mobil Akış Şeması (Görsel) + Sözde Kod
Seçenek B - Şemaya Uyumlu Sözde Kod:

BAŞLA
    DÖNGÜ
        EĞER kullanıcı_giriş_yapmış_mı DEĞİLSE
            Giriş_Ekranına_Yönlendir()
            Kullanıcı_Giriş_Yapar()
        DEĞİLSE
            DÖNGÜDEN_ÇIK
    DÖNGÜ_BİTİR

    Ürünleri_Seç_ve_Sepete_Ekle()
    Siparişi_Onayla()

    EĞER cüzdan_bakiyesi >= sepet_tutarı İSE
        Cüzdan_Bakiyesinden_Tutarı_Düş()
        Sipariş_Paketini_Sunucuya_Gönder()
        Sipariş_Başarılı_Bildirimi_Göster()
    DEĞİLSE
        'Bakiye_Yükle'_Uyarısı_Ver()
BİTİR

Mantık kontrolleri: Giriş kontrolü akışın başında bir döngü ile yapılır; kullanıcı giriş yapana kadar Giriş Ekranı'na yönlendirilir ve tekrar kontrol edilir. Bakiye kontrolü ise sipariş onayından hemen sonra yapılır; yeterliyse tutar düşülüp sipariş sunucuya gönderilir, yetersizse "Bakiye Yükle" uyarısı gösterilir.

GÖREV 2: REST API Uç Noktası & JSON Tasarımı
1. Sipariş Oluşturma Endpoint'i
HTTP Metodu: POST
URL: /api/v1/siparisler
Header:
  Authorization: Bearer <token>
  Content-Type: application/json
Request Body (JSON):
json
  {
    "kahve_adi": "Latte",
    "boyut": "Orta",
    "adet": 2,
    "toplam_tutar": 95.00
  }
Başarılı Sonuç HTTP Durum Kodu: 201 Created
Kullanıcı Giriş Yapmamışsa Dönecek Durum Kodu: 401 Unauthorized
2. Cüzdan Bakiye Sorgulama Endpoint'i
HTTP Metodu: GET
URL: /api/v1/kullanici/bakiye
Örnek Response (JSON):
json
  {
    "bakiye": 185.50,
    "para_birimi": "TRY"
  }
Sunucuda Beklenmeyen Hata Durum Kodu: 500 Internal Server Error
Mini Mülakat Sorusu

GET isteği idempotenttir; çünkü aynı isteği kaç kez tekrarlarsanız tekrarlayın sunucudaki veri değişmez, sadece mevcut bakiye bilgisi okunur. POST isteği ise idempotent değildir; çünkü her tekrarında sunucuda yeni bir sipariş kaydı oluşur ve bakiye tekrar tekrar düşer, yani aynı isteği iki kez göndermek farklı bir sonuca (iki ayrı sipariş) yol açar.

GÖREV 3: Clean Code & SOLID Prensip Teşhisi

1. SRP (Single Responsibility Principle) İhlali:

KahveSiparisYoneticisi sınıfı; indirim hesaplama, kredi kartından tahsilat yapma, siparişi veritabanına kaydetme ve müşteriyi SMS ile bilgilendirme gibi birbirinden tamamen bağımsız dört farklı sorumluluğu tek bir sınıf içinde topladığı için Tek Sorumluluk Prensibi'ni ihlal etmektedir. Bu sınıf; IndirimHesaplayici, OdemeIslemcisi, SiparisDepolamaServisi ve BildirimServisi gibi her biri tek bir işten sorumlu, küçük ve bağımsız sınıflara bölünmelidir.

2. OCP (Open/Closed Principle) İhlali:

indirimHesapla fonksiyonunda yeni bir müşteri tipi (örn. "DOKTOR") eklendiğinde mevcut if-else bloğunun değiştirilmek zorunda kalması Open/Closed Principle'a aykırıdır. Bu prensibe göre sınıflar yeni davranışlara karşı genişlemeye açık, ancak mevcut koda müdahaleye kapalı olmalıdır; burada ise her yeni müşteri tipi geldiğinde var olan kodun değiştirilmesi gerekmektedir. 