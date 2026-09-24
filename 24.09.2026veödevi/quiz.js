const readline = require("node:readline/promises");
const { stdin: input, stdout: output } = require("node:process");

async function main() {
  const rl = readline.createInterface({ input, output });

  // 1. Terminalden soruları tek tek sorup cevapları alıyoruz
  const mevcutGirdi = await rl.question("Arabanın şu anki şarj yüzdesini gir (Örn: 20): ");
  const hedefGirdi = await rl.question("Arabanın şarjını kaça kadar dolduracaksın? (Örn: 80): ");
  const bataryaGirdi = await rl.question("Arabanın bataryası toplam kaç kWh? (Örn: 60): ");
  const istasyonGirdi = await rl.question("Taktığın şarj istasyonu kaç kW güç veriyor? (Örn: 22): ");
  const saatGirdi = await rl.question("Saat kaçta şarja taktın? (0 ile 23 arası tam saat gir, Örn: 23): ");

  // Metin olarak gelen verileri sayıya çeviriyoruz
  const mevcutYuzde = Number(mevcutGirdi);
  const hedefYuzde = Number(hedefGirdi);
  const bataryaKwh = Number(bataryaGir15di);
  const istasyonKw = Number(istasyonGirdi);
  const baslamaSaati = Number(saatGirdi);

  // KONTROLLER
  if (mevcutYuzde < 0 || hedefYuzde > 100) {
    console.log("Hata: Yüzde 0 ile 100 arasında olmalıdır.");
  } else if (hedefYuzde <= mevcutYuzde) {
    console.log("Hata: Hedef yüzde, mevcut yüzden büyük olmalıdır.");
  } else if (bataryaKwh <= 0 || istasyonKw <= 0) {
    console.log("Hata: Batarya kapasitesi ve istasyon gücü 0'dan büyük olmalıdır.");
  } else if (baslamaSaati < 0 || baslamaSaati > 23) {
    console.log("Hata: Saat 0 ile 23 arasında geçerli bir değer olmalıdır.");
  } else {
    // HESAPLAMA ADIMLARI
    const doldurulacakYuzde = hedefYuzde - mevcutYuzde;
    const gerekenEnerji = (bataryaKwh * doldurulacakYuzde) / 100;
    const sureSaat = gerekenEnerji / istasyonKw;
    const sureDakika = Math.round(sureSaat * 60);

    // TARİFE KONTROLÜ (22:00 - 05:59 Gece, 06:00 - 21:59 Gündüz)
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

    // SONUCU TERMİNALE YAZDIRMA
    console.log("\n================ SONUÇ ================");
    console.log(`Tarife Türü     : ${tarifeAdi} (${birimFiyat} TL/kWh)`);
    console.log(`Gereken Enerji  : ${gerekenEnerji.toFixed(1)} kWh`);
    console.log(`Tahmini Süre    : ${sureDakika} dakika`);
    console.log(`Toplam Tutar    : ${toplamUcret} TL`);
    console.log("=======================================");
  }

  rl.close();
}

main();