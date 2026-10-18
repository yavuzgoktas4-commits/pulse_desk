[![PulseDesk CI](https://github.com/yavuzgoktas4-commits/pulse_desk/actions/workflows/ci.yml/badge.svg)](https://github.com/yavuzgoktas4-commits/pulse_desk/actions/workflows/ci.yml)
[![Canlı Demo - Render](https://img.shields.io/badge/Canl%C4%B1_Uygulama_(Render)-PulseDesk_Live-46E3B7?style=flat&logo=render&logoColor=white)](https://pulse-desk.onrender.com)

# PulseDesk — Akıllı SLA ve Bilet Yönetim Sistemi

> **Canlı Render URL:** [https://pulse-desk.onrender.com](https://pulse-desk.onrender.com)  
> **GitHub Actions CI Durumu:** [![PulseDesk CI](https://github.com/yavuzgoktas4-commits/pulse_desk/actions/workflows/ci.yml/badge.svg)](https://github.com/yavuzgoktas4-commits/pulse_desk/actions/workflows/ci.yml)

**PulseDesk**, kurumsal müşteri destek ekiplerinin en büyük operasyonel darboğazı olan **"acil biletlerin manuel triyaj beklerken SLA süresini aşması"** problemini otomatik anahtar kelime analizi ve dinamik SLA atamasıyla çözen, **Rails 8**, **PostgreSQL** ve **Tailwind CSS** ile geliştirilmiş modern bir bilet yönetim sistemidir.

---

## Faz 1 — Fortune 500 Kurumsal SaaS İstatistikleri

Fortune 500 şirketlerinin ölçeği ve yıllık yazılım (SaaS) tüketim alışkanlıkları incelendiğinde, kurumsal yazılım pazarının büyüklüğü aşağıdaki temel göstergelerle ortaya çıkmaktadır:

| Metrik | Fortune 500 Aralığı / Değeri | Açıklama ve Sektör bağlamı | Doğrulanabilir Kaynaklar |
| :--- | :--- | :--- | :--- |
| **Şirket Değerleme Aralığı** | **\$7B – \$3T+** | En küçük Fortune 500 şirketlerinden Apple, Microsoft ve NVIDIA gibi \$3 Trilyon+ piyasa değerine sahip teknoloji devlerine uzanan aralık. | [Fortune 500 Resmi Sıralaması](https://fortune.com/ranking/fortune500/) |
| **Çalışan Sayısı Aralığı** | **1.500 – 2.1M (Walmart)** | Orta ölçekli finans/enerji şirketlerinden (~1.500 çalışan), küresel ölçekte **2.1 milyon** çalışanıyla listenin zirvesinde yer alan **Walmart**'a kadar uzanır. | [Fortune 500 — Walmart Profili](https://fortune.com/company/walmart/fortune500/) |
| **Ortalama Kullanılan SaaS** | **200 – 350 Adet** | Kurumsal ölçekteki bir organizasyonun departmanlar genelinde aktif olarak kullandığı ortalama farklı SaaS uygulaması sayısı. | [Zylo SaaS Management Index](https://zylo.com/reports/saas-management-index/) |
| **Yıllık SaaS Harcaması** | **\$100M+ / Yıl** | Büyük ölçekli (Enterprise / Fortune 500) şirketlerin yıllık toplam bulut ve SaaS lisanslama harcaması (çalışan başına yıllık \$4.000–\$10.000+). | [Gartner IT Spending Forecast](https://www.gartner.com/en/newsroom/press-releases/2024-01-17-gartner-forecasts-worldwide-it-spending-to-grow-six-point-eight-percent-in-2024) & [Zylo Enterprise Report](https://zylo.com/reports/saas-management-index/) |

---

## SaaS Seçimi ve Fortune 500 Kanıtı: Zendesk

Kurumsal şirketlerin en kritik operasyonel omurgalarından biri **Müşteri Destek ve Bilet Yönetimi (ITSM / Customer Service Helpdesk)** yazılımıdır. Bu doğrultuda hedef referans SaaS olarak **Zendesk** incelenmiş ve çekirdek işlevi **PulseDesk** markasıyla yeniden inşa edilmiştir.

**Fortune 500 & Küresel Ölçek Kanıtları:**
- **Uber:** Milyonlarca sürücü ve yolcu etkileşimini küresel ölçekte gerçek zamanlı yönetmek ve destek SLA sürelerini korumak için Zendesk altyapısını kullanmaktadır.  
  🔗 [Uber Başarı Hikayesi (Zendesk Customer Story)](https://www.zendesk.com/customer/uber/)
- **Shopify:** Yüz binlerce e-ticaret satıcısına özellikle yüksek trafikli dönemlerde (Black Friday / Cyber Monday) kesintisiz destek sağlamak için Zendesk'i tercih etmektedir.  
  🔗 [Shopify Başarı Hikayesi (Zendesk Customer Story)](https://www.zendesk.com/customer/shopify/)

---

## Faz 2 — Maliyet Tahmini: Geleneksel Mühendislik vs. Coding Agent

Zendesk'in tüm yan modülleriyle (Omnichannel routing, eski API katmanları, yüzlerce entegrasyon, karmaşık yönetim panelleri) birlikte toplam kod tabanının **~350.000+ satır (LOC)** olduğu tahmin edilmektedir. Ancak müşterilerin %80'inin her gün gerçekten kullandığı **"Aort Dilimi" (bilet açma, aciliyet triyajı, SLA takibi ve durum yönetimi)** bu kod yığınının çok küçük ve öz bir kısmıdır.

| Kriter | Geleneksel SaaS Ekibi (Tam Ölçekli Zendesk) | Otonom Coding Agent (PulseDesk Aort Dilimi) |
| :--- | :--- | :--- |
| **Kod Tabanı Büyüklüğü** | ~350.000+ satır (Yılların birikmiş teknik borcu ve şişkinliği) | ~600 satır temiz, modern **Rails 8 + Tailwind CSS** kodu |
| **Geliştirme Süresi** | 12 – 24 Ay (Çoklu Scrum ekipleri) | **2 Gün** (Aktif ajan oturumu: ~45 dakika) |
| **Maliyet** | \$1.5M – \$5M+ (Mühendislik maaşları ve altyapı) | **\$15 Token Maliyeti** + \$0 (Render Ücretsiz Katman) |
| **Bakım & Karmaşıklık** | Yüksek (Mikroservisler, karmaşık JS paketleyiciler) | Düşük (Propshaft, Importmap, PostgreSQL, Minitest) |

---

## 100 Puanlık Çözüm: Kullanıcı Acısı ve Otomatik SLA Kısaltma

### Gerçek Kullanıcı Acısı (G2 Kanıtı)
G2 üzerindeki kurumsal müşteri destek yazılımı incelemelerinde en sık dile getirilen operasyonel şikayetlerden biri şudur:
> **Kullanıcı Acısı:** Destek kuyruğuna yüzlerce bilet düştüğünde, temsilciler biletleri tek tek manuel okuyup öncelik (`Urgent` / `Normal`) atayana kadar **"sistem çöktü"** veya **"ödeme alınamıyor"** gibi kritik biletler standart kuyrukta saatlerce beklemekte ve daha ilk müdahale yapılmadan **SLA ihlaline (SLA Breach)** uğramaktadır.  
> 🔗 **Kaynak:** [G2 — Zendesk Support Suite Kullanıcı Yorumları ve SLA/Triyaj Şikayetleri](https://www.g2.com/products/zendesk-support-suite/reviews)

### PulseDesk'in Kod İçi Otomatik Çözümü
**PulseDesk**, temsilcinin bileti manuel olarak okuyup sınıflandırmasını beklemez. `Ticket` modeli kaydedilmeden hemen önce (`before_validation :set_initial_rules, on: :create`) biletin **başlığını (`title`)** ve **açıklamasını (`description`)** Türkçe büyük/küçük harf duyarlılığıyla tarar:

1. **Acil Durum Tespiti (1 Saatlik SLA):**  
   İçerikte `çöktü`, `acil`, `ödeme`, `hata`, `down`, `critical` anahtar kelimelerinden herhangi biri geçiyorsa:
   - `priority = "urgent"` olarak otomatik yükseltilir.
   - `sla_deadline = Time.current + 1.hour` olarak kısaltılır.
2. **Standart Akış (4 Saatlik SLA):**  
   Kritik anahtar kelime içermeyen biletler için:
   - `priority = "normal"` atanır.
   - `sla_deadline = Time.current + 4.hours` olarak belirlenir.
3. **Görsel SLA İhlal Alarmı (`sla_breached?`):**  
   Bilet henüz çözülmemişse (`status != "solved"`) ve mevcut zaman `sla_deadline` değerini aşmışsa `ticket.sla_breached?` metodu `true` döner; arayüzde satır kırmızıya döner ve yanıp sönen kırmızı **`SLA İHLALİ / BREACHED`** rozetiyle temsilciyi uyarır.

---

## Yapamadıklarım (Bilinen Kısıtlamalar ve Eksikler)

Bu prototip, 2 günlük süre ve "Aort Dilimi" odaklanması kapsamında çekirdek SLA ve bilet yaşam döngüsünü eksiksiz çalıştırmaktadır; ancak aşağıdaki 2 özellik bilinçli olarak kapsam dışı bırakılmıştır:

1. **Gerçek SMTP E-posta Sunucusu Bağlanmadı:**  
   Bilet oluşturulduğunda veya durumu `"open"` / `"solved"` olarak değiştirildiğinde müşteriye (`customer_email`) gerçek bir SMTP sunucusu (SendGrid, Postmark, AWS SES vb.) üzerinden e-posta gönderilmemektedir. Bildirimler şu an için uygulama ekranında **Flash mesajı (`notice` / `alert`)** olarak gösterilmektedir.
2. **Canlı WebSocket / ActionCable ile Anlık Bildirim Eklenmedi:**  
   Yeni bir bilet düştüğünde veya arka planda bir biletin SLA süresi dolduğunda temsilci ekranına WebSocket (`ActionCable` / `Turbo Streams broadcast`) üzerinden sayfa yenilemeden anlık bildirim düşmemektedir. Bilet listesi ve kalan SLA sayaçları sayfa yenilendiğinde (**F5**) güncellenmektedir.

---

## Yerel Kurulum ve Çalıştırma

```bash
# Bağımlılıkları yükleyin
bundle install

# Veritabanını oluşturun ve migration'ları çalıştırın
bin/rails db:create db:migrate

# Birim testlerini çalıştırın (travel_to zaman testleri dahil)
bin/rails test

# Sunucuyu başlatın (http://localhost:3000)
bin/rails server
```
