# 🚗 AutoAssist (Araç Asistanı) - Proje Gereksinim ve Mimari Dosyası

## 📌 Proje Özeti
AutoAssist, araç sahiplerinin araçlarıyla ilgili tüm süreçleri tek bir merkezden, akıllı ve proaktif bir şekilde yönetmelerini sağlayan kapsamlı bir yapay zeka destekli mobil uygulamadır. Standart bir takip uygulamasının ötesinde; durumsal farkındalık (hava durumu vb.), AI tabanlı arıza ön-teşhisi, harita entegrasyonları ve akıllı bildirimler ile tam bir "Dijital Araç Asistanı" olarak çalışır.

## 🛠 Teknoloji Yığını (Tech Stack)
* **Frontend:** Flutter (Dart)
* **Backend & Veritabanı:** Supabase (PostgreSQL, Auth, Storage, Edge Functions)
* **AI Entegrasyonu:** Grok Api - Arıza teşhisi ve akıllı asistan sohbetleri için.
* **Harita / Konum:** %100 Ücretsiz MAP api.
* **Durumsal Veri API'leri:** %100 Ücretsiz APİ.

## 🎨 UI / UX Tasarım Dili ve Yönergeleri
* **Estetik:** Apple ekosistemine benzer; premium, profesyonel, kurumsal ve minimalist bir tasarım dili benimsenecektir.
* **Kullanılabilirlik:** Karmaşadan uzak, geniş boşlukların (whitespace) kullanıldığı, temiz tipografi ve ince font ağırlıklarının tercih edildiği modern bir arayüz.
* **Renk Paleti:** Göz yormayan, güven veren kurumsal renkler (Örn: Derin lacivert, mat gümüş, temiz beyaz arka planlar ve dikkat çekici ama bağırmayan vurgu renkleri).
* **Etkileşimler:** Pürüzsüz animasyonlar, micro-interaction'lar ve kullanıcıyı yormayan akıcı form geçişleri. Tasarım, "piyasadaki en iyi UI/UX" standartlarını hedeflemektedir.

## 🚀 Temel Özellikler (Core Features)

### 1. Dijital Garaj ve Araç Profili
* Kullanıcı aracının marka, model, yıl, motor tipi ve kilometre (KM) bilgisini ekleyebilir.
* Birden fazla araç eklenebilme ve araçlar arası hızlı geçiş.
* Araçta bulunması gereken zorunlu ve tavsiye edilen malzemeler listesi (İlk yardım çantası, reflektör, yangın tüpü vb.) ve kontrol onay kutuları (Checklist).

### 2. AI Mekanik Asistanı (Arıza Ön-Teşhis)
* Kullanıcının karşılaştığı sorunu yazarak veya sesli belirterek yapay zekaya danışması.
* (Örn: "Aracımdan tık tık ses geliyor ve titreme var").
* AI'ın kesin teşhis olmadığını vurgulayarak (Yasal sorumluluk reddi) olası sorunları, ciddiyet derecesini ve aracı sürmeye devam edip etmemesi gerektiği konusunda tavsiyeler vermesi.

### 3. Akıllı Harita ve Navigasyon
* Kullanıcının konumuna göre en yakın sanayi siteleri, yetkili servisler ve oto tamircileri.
* En yakın TÜVTÜRK araç muayene istasyonları.
* Kullanıcının AI asistan ile teşhis ettiği olası arızaya göre spesifik ustaları (Örn: rot balansçı, şanzımancı) haritada filtreleme.

### 4. Gider ve Evrak Takibi
* Yakıt, bakım, sigorta, kasko, yıkama, otopark gibi harcama kalemlerinin eklenmesi ve grafiksel raporlanması.
* Aylık/Yıllık bazda araca ne kadar masraf yapıldığının analizi.

### 5. Proaktif Bildirim ve Uyarı Sistemi
* **KM Bazlı Uyarılar:** "10.000 bakımına 500 km kaldı."
* **Tarih Bazlı Uyarılar:** "TÜVTÜRK muayenenize 15 gün kaldı", "Kasko yenileme tarihiniz yaklaşıyor."
* **Durumsal (Contextual) Uyarılar:** Kullanıcının lokasyon verisine göre; "Bulunduğunuz bölgede yoğun yağış / buzlanma uyarısı var, lütfen takip mesafenizi koruyun."

## 📂 Supabase Veritabanı Yapısı (Taslak)
* `users`: auth.uid(), isim, telefon, tercihler.
* `vehicles`: id, user_id, marka, model, yil, plaka, guncel_km.
* `expenses`: id, vehicle_id, kategori (yakıt, bakım vb.), tutar, tarih, aciklama.
* `reminders`: id, vehicle_id, tip (muayene, sigorta, bakim), hedef_tarih, hedef_km, durum.
* `maintenance_logs`: id, vehicle_id, yapilan_islemler, usta_servis_adi, tarih, km.

## 🤖 GitHub Copilot İçin Yönergeler
Sevgili Copilot, bu projeyi geliştirirken şu kurallara dikkat et:
1.  **Klasör Yapısı:** Clean Architecture veya Feature-first (özellik odaklı) dizin yapısı kullan. Klasör yapısını oluştururken ölçeklenebilirliğe dikkat et.
2.  **State Management:** MvvM setState olacak models - views - viewmodels - services ve themes diye
3.  **Supabase Entegrasyonu:** Tüm veritabanı sorgularını repository pattern kullanarak soyutla.
4.  **UI Bileşenleri:** Yeniden kullanılabilir (reusable), Apple tasarım yönergelerine (Human Interface Guidelines) uygun, şık ve minimalist custom widget'lar oluştur.
5.  **Kod Kalitesi:** Her zaman null-safety kurallarına uy, linter hatalarından kaçın ve karmaşık fonksiyonlar için dokümantasyon yorumları ekle.