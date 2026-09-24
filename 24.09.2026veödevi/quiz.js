const prompt = require("prompt-sync")();

const mevcutYuzde = Number(prompt("Mevcut yüzdeyi giriniz: "));
const hedefYuzde = Number(prompt("Hedef yüzdeyi giriniz: "));
const bataryaKwh = Number(prompt("Batarya kapasitesini giriniz (kWh): "));
const istasyonKw = Number(prompt("İstasyon gücünü giriniz (kW): "));
const baslamaSaati = Number(prompt("Başlama saatini giriniz (0-23): "));

// Kontroller
if (
  isNaN(mevcutYuzde) ||
  isNaN(hedefYuzde) ||
  isNaN(bataryaKwh) ||
  isNaN(istasyonKw) ||
  isNaN(baslamaSaati)
) {
  console.log("Hata: Girdiğiniz değerler sayı olmalıdır.");
} else if (mevcutYuzde < 0 || hedefYuzde > 100) {
  console.log("Hata: Yüzde değerleri 0 ile 100 arasında olmalıdır.");
} else if (hedefYuzde <= mevcutYuzde) {
  console.log("Hata: Hedef yüzde, mevcut yüzden büyük olmalıdır.");
} else if (bataryaKwh <= 0 || istasyonKw <= 0) {
  console.log("Hata: Batarya kapasitesi ve istasyon gücü 0'dan büyük olmalıdır.");
} else if (baslamaSaati < 0 || baslamaSaati > 23) {
  console.log("Hata: Saat 0 ile 23 arasında bir tam sayı olmalıdır.");
} else {
  // Hesaplamalar
  const doldurulacakYuzde = hedefYuzde - mevcutYuzde;
  const gerekenEnerji = (bataryaKwh * doldurulacakYuzde) / 100;

  const sureSaat = gerekenEnerji / istasyonKw;
  const sureDakika = Math.round(sureSaat * 60);

  let birimFiyat = 0;
  let tarifeAdi = "";

  if (baslamaSaati >= 22 || baslamaSaati < 6) {
    birimFiyat = 5;
    tarifeAdi = "Gece";
  } else {
    birimFiyat = 8;
    tarifeAdi = "Gündüz";
  }

  const toplamUcret = Math.round(gerekenEnerji * birimFiyat);

  console.log(`\nTarife: ${tarifeAdi} (${birimFiyat} TL/kWh)`);
  console.log(`Gereken Enerji: ${gerekenEnerji.toFixed(1)} kWh`);
  console.log(`Tahmini Süre: ${sureDakika} dakika`);
  console.log(`Toplam Ücret: ${toplamUcret} TL`);
}