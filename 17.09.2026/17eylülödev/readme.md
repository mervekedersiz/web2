Öğrenci, Bölüm ve Ders ilişkilerini 3NF kurallarına uygun olarak normalize edip DDL sorgularını yazın.
Hocam, Öğrenci, Bölüm ve Ders varlıkları arasındaki yapıyı kurarken adım adım 3NF yani Üçüncü Normal Form kurallarını uyguladık.

İlk olarak 1NF gereği tüm sütunlarımızı atomik yaptık; yani bir hücreye virgülle birden fazla ders veya telefon yazmak gibi tekrarlayan gruplardan tamamen kaçındık.

İkinci olarak 2NF'ye baktığımızda, tablolardaki anahtar olmayan alanların birincil anahtarın tamamına tam bağımlı olması gerekiyordu. Burada asıl kritik nokta Öğrenci ve Ders arasındaki çoka-çok (N-N) ilişkiydi. Bir öğrenci birden fazla ders alabiliyor, bir dersi de birden fazla öğrenci seçebiliyor. Eğer ders ve not bilgilerini doğrudan Öğrenci tablosuna koysaydık hem kısmi bağımlılık oluşur hem de korkunç bir veri tekrarı yaşanırdı. Bu yüzden araya bir köprü tablo, yani ogrenci_dersler tablosunu açtık. Bu tabloda birincil anahtar olarak (ogrenci_id, ders_id, donem) bileşik anahtarını kullandık. Öğrencinin aldığı harf_notu sadece öğrenciye ya da sadece derse bağlı değil; o dönemdeki o spesifik eşleşmeye tam fonksiyonel bağımlı. Böylece 2NF şartını eksiksiz sağladık.

Son adımımız olan 3NF'de ise kuralımız net: Hiçbir sütun, anahtar olmayan başka bir sütuna geçişli olarak bağımlı olamaz (transitive dependency).
Örneğin Öğrenci tablosunda sadece bolum_id tuttuk. Eğer kalkıp öğrencinin yanına bolum_adi veya fakulte gibi bilgileri de yazsaydık; ogrenci_no -> bolum_id -> fakulte şeklinde zincirleme bir geçişli bağımlılık doğacaktı. Bölümün adı değiştiğinde binlerce öğrenci kaydını güncellemek zorunda kalırdık. Biz bu bilgileri ayrı bir bolumler tablosuna taşıyıp sadece bolum_id ile yabancı anahtar ilişkisi kurarak bu geçişli bağımlılığı ortadan kaldırdık. Aynı kuralı Ders ve Bölüm ilişkisinde de uyguladık.

Sonuç olarak; gereksiz veri tekrarını sıfıra indirdik, ekleme, silme ve güncelleme anomalilerinin önüne geçtik ve veri tabanımızı tamamen 3NF standartlarına uygun hale getirdik.
-- 1. BÖLÜM TABLOSU
CREATE TABLE bolumler (
    bolum_id SERIAL PRIMARY KEY,
    bolum_kod VARCHAR(10) NOT NULL UNIQUE,
    bolum_ad VARCHAR(100) NOT NULL,
    fakulte VARCHAR(100) NOT NULL
);

-- 2. ÖĞRENCİ TABLOSU
CREATE TABLE ogrenciler (
    ogrenci_id SERIAL PRIMARY KEY,
    ogrenci_no VARCHAR(20) NOT NULL UNIQUE,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    kayit_tarihi DATE NOT NULL DEFAULT CURRENT_DATE,
    bolum_id INT NOT NULL,
    CONSTRAINT fk_ogrenci_bolum 
        FOREIGN KEY (bolum_id) 
        REFERENCES bolumler(bolum_id) 
        ON DELETE RESTRICT
);

-- 3. DERS TABLOSU
CREATE TABLE dersler (
    ders_id SERIAL PRIMARY KEY,
    ders_kod VARCHAR(15) NOT NULL UNIQUE,
    ders_ad VARCHAR(100) NOT NULL,
    kredi INT NOT NULL CHECK (kredi > 0),
    akts INT NOT NULL CHECK (akts > 0),
    bolum_id INT NOT NULL,
    CONSTRAINT fk_ders_bolum 
        FOREIGN KEY (bolum_id) 
        REFERENCES bolumler(bolum_id) 
        ON DELETE RESTRICT
);

-- 4. ÖĞRENCİ-DERS KAYIT TABLOSU (N-N Çözümleme)
CREATE TABLE ogrenci_dersler (
    ogrenci_id INT NOT NULL,
    ders_id INT NOT NULL,
    donem VARCHAR(20) NOT NULL,
    harf_notu VARCHAR(3),
    PRIMARY KEY (ogrenci_id, ders_id, donem),
    CONSTRAINT fk_kayit_ogrenci 
        FOREIGN KEY (ogrenci_id) 
        REFERENCES ogrenciler(ogrenci_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_kayit_ders 
        FOREIGN KEY (ders_id) 
        REFERENCES dersler(ders_id) 
        ON DELETE CASCADE
);