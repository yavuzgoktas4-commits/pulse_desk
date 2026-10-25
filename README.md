[![AbisiDesk CI](https://github.com/yavuzgoktas4-commits/pulse_desk/actions/workflows/ci.yml/badge.svg)](https://github.com/yavuzgoktas4-commits/pulse_desk/actions/workflows/ci.yml)
[![Canlı Uygulama / Live Demo](https://img.shields.io/badge/Canl%C4%B1_Uygulama_%2F_Live_Demo-Render-46E3B7?style=flat&logo=render&logoColor=white)](https://pulse-desk-6e5q.onrender.com)

**Canlı Uygulama / Live Demo:** [https://pulse-desk-6e5q.onrender.com](https://pulse-desk-6e5q.onrender.com)

# AbisiDesk — Akıllı SLA, Yapay Zeka Triyaj ve Bilet Yönetim Sistemi

> **Canlı Render URL:** [https://pulse-desk-6e5q.onrender.com](https://pulse-desk-6e5q.onrender.com)  
> **Resmi Telegram AI Botu:** [`@Abisinin_Destek_Bot`](https://t.me/Abisinin_Destek_Bot)  
> **GitHub Actions CI Durumu:** [![AbisiDesk CI](https://github.com/yavuzgoktas4-commits/pulse_desk/actions/workflows/ci.yml/badge.svg)](https://github.com/yavuzgoktas4-commits/pulse_desk/actions/workflows/ci.yml)

**AbisiDesk**, kurumsal müşteri destek ekiplerinin en büyük operasyonel darboğazı olan **"uzun destek formları ve acil biletlerin manuel triyaj beklerken SLA süresini aşması"** problemini **Telegram Botu (`@Abisinin_Destek_Bot`)**, **Groq LLM Anlamsal Çıkarım (Semantic Extraction)** ve **dinamik SLA atamasıyla** çözen, **Rails 8**, **PostgreSQL** ve **Tailwind CSS** ile geliştirilmiş modern bir B2B SaaS bilet yönetim sistemidir.

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

Kurumsal şirketlerin en kritik operasyonel omurgalarından biri **Müşteri Destek ve Bilet Yönetimi (ITSM / Customer Service Helpdesk)** yazılımıdır. Bu doğrultuda hedef referans SaaS olarak **Zendesk** incelenmiş ve çekirdek işlevi **AbisiDesk** markasıyla yeniden inşa edilmiştir.

**Fortune 500 & Küresel Ölçek Kanıtları:**
- **Uber:** Milyonlarca sürücü ve yolcu etkileşimini küresel ölçekte gerçek zamanlı yönetmek ve destek SLA sürelerini korumak için Zendesk altyapısını kullanmaktadır.  
  🔗 [Uber Başarı Hikayesi (Zendesk Customer Story)](https://www.zendesk.com/customer/uber/)
- **Shopify:** Yüz binlerce e-ticaret satıcısına özellikle yüksek trafikli dönemlerde (Black Friday / Cyber Monday) kesintisiz destek sağlamak için Zendesk'i tercih etmektedir.  
  🔗 [Shopify Başarı Hikayesi (Zendesk Customer Story)](https://www.zendesk.com/customer/shopify/)

---

## Faz 2 — Maliyet Tahmini: Geleneksel Mühendislik vs. Coding Agent

### 1. Zendesk Satır Sayısı (~350.000+ LOC) Tahmini ve Yöntemi
Zendesk'in çekirdek **Support (Ticketing)** ürününün yaklaşık **~350.000+ satır (LOC)** olduğu tahmini şu 3 veri noktası birleştirilerek yapılmıştır:
1. **Modül Bazlı Fonksiyon Noktası Ayrıştırması:** Kurumsal bir bilet sisteminde Ticket/Comment/SLA motoru (~45K LOC), Omnichannel E-posta/Chat/Ses yönlendirme (~80K LOC), RBAC/SSO/Audit güvenlik katmanı (~50K LOC), REST/GraphQL API ve Webhook altyapısı (~65K LOC), Raporlama/Explore analitiği (~55K LOC) ve Frontend/Admin arayüzleri (~60K LOC) toplamda ~355.000 satıra ulaşmaktadır.
2. **Zendesk Mühendislik Ölçeği:** [Zendesk Engineering Blog](https://zendesk.engineering/) verilerine göre çekirdek uygulama yıllar içinde devasa bir **Ruby on Rails monoliti** ve etrafındaki servislerden oluşmakta olup yüzlerce mühendis tarafından geliştirilmektedir.
3. **Aort Dilimi Oranı:** Müşterilerin %80'inin her gün asıl para ödediği **"Aort Dilimi" (bilet açma, aciliyet triyajı, SLA takibi ve `new -> open -> solved` durum yönetimi)** yaklaşık **~750 satır** temiz Rails 8 koduyla uçtan uca çalışır hale getirilebilmektedir.

### 2. Başlangıç Tahminimiz vs. Gerçekte Harcadığımız

| Metrik | Geleneksel SaaS Ekibi (Zendesk Ölçeği) | Başlangıçtaki Kendi Tahminimiz (Coding Agent ile) | Gerçekte Harcadığımız (Antigravity ile Gerçekleşen) |
| :--- | :--- | :--- | :--- |
| **Kod Büyüklüğü** | ~350.000+ satır (LOC) | ~1.200 satır (LOC) | **~750 satır** temiz Rails 8 + Tailwind CSS + Groq/Telegram kodu |
| **Geliştirme Süresi** | 12 – 24 Ay (Çoklu Scrum Ekipleri) | **3 – 4 Gün** | **< 2 Gün (Aktif Oturum: ~55 Dakika)** |
| **Token / Abonelik Maliyeti** | \$1.5M – \$5M+ (Maaş + Altyapı) | **~\$45 Token + \$20/ay Abonelik** | **~\$15 Token Maliyeti** (\~1M Token) + \$0 Render Free |
| **Test & Canlıya Alma** | Haftalar süren QA ve DevOps | 1 Gün (Manuel Docker/Render) | **15 Dakika** (GitHub Actions CI + Render Auto-Deploy) |

---

## 100 Puanlık Çözüm: Formsuz Telegram AI Bilet Açma & Otomatik SLA Kısaltma

### Gerçek Kullanıcı Acısı (G2 Kanıtı)
G2 üzerindeki kurumsal müşteri destek yazılımı incelemelerinde en sık dile getirilen operasyonel şikayetlerden biri şudur:
> **Kullanıcı Acısı:** Müşteriler acil sorun yaşadığında karmaşık destek formlarını doldurmak zorunda kalmakta; destek kuyruğuna yüzlerce bilet düştüğünde ise temsilciler biletleri tek tek manuel okuyup öncelik (`Urgent` / `Normal`) atayana kadar **"sistem çöktü"** veya **"ödeme alınamıyor"** gibi kritik biletler standart kuyrukta saatlerce beklemekte ve daha ilk müdahale yapılmadan **SLA ihlaline (SLA Breach)** uğramaktadır.  
> 🔗 **Kaynak:** [G2 — Zendesk Support Suite Kullanıcı Yorumları ve SLA/Triyaj Şikayetleri](https://www.g2.com/products/zendesk-support-suite/reviews)

### AbisiDesk'in Kod İçi Otomatik Çözümü
1. **Formsuz Telegram Botu (`@Abisinin_Destek_Bot`) & Groq LLM Anlamsal Çıkarım:**
   - Kullanıcı destek formu doldurmak yerine Telegram üzerinden serbest dilde mesaj yazar.
   - `GroqExtractorService` mesajı anlamsal olarak analiz ederek JSON formatında `subject`, `category`, `priority` (`Low`, `Medium`, `High`, `Critical`) ve `summary` alanlarını çıkarır ve bileti otomatik oluşturur.
   - Bilet durumu (`Open` -> `In Progress` / `Resolved`) değiştiğinde `TelegramBotService.send_status_update` ile kullanıcının Telegram hesabına **"AbisiDesk Bildirimi"** imzalı anlık bildirim gönderilir.
2. **Acil Durum Tespiti (1 Saatlik SLA):**  
   Bilet içeriğinde veya önceliğinde acil durum tespit edildiğinde:
   - `priority = "urgent"` olarak otomatik yükseltilir.
   - `sla_deadline = Time.current + 1.hour` olarak kısaltılır.
3. **Standart Akış (4 Saatlik SLA):**  
   Standart destek talepleri için `sla_deadline = Time.current + 4.hours` olarak belirlenir.
4. **Görsel SLA İhlal Alarmı (`sla_breached?`):**  
   Bilet henüz çözülmemişse (`status != "solved"`) ve mevcut zaman `sla_deadline` değerini aşmışsa `ticket.sla_breached?` metodu `true` döner; arayüzde satır kırmızıya döner ve yanıp sönen kırmızı **`SLA İHLALİ / BREACHED`** rozetiyle temsilciyi uyarır.

---

## Yapamadıklarım (Bilinen Kısıtlamalar ve Eksikler)

Bu prototip, 2 günlük süre ve "Aort Dilimi" odaklanması kapsamında çekirdek SLA, Telegram AI botu ve bilet yaşam döngüsünü eksiksiz çalıştırmaktadır; ancak aşağıdaki 2 özellik bilinçli olarak kapsam dışı bırakılmıştır:

1. **Gerçek SMTP E-posta Sunucusu Bağlanmadı:**  
   Bildirimler Telegram Botu (`@Abisinin_Destek_Bot`) ve uygulama ekranındaki **Flash mesajları (`notice` / `alert`)** üzerinden iletilmektedir; harici bir SMTP e-posta sunucusu (SendGrid, Postmark, AWS SES vb.) bağlanmamıştır.
2. **Canlı WebSocket / ActionCable ile Anlık Tablo Yenileme Eklenmedi:**  
   Yeni bir bilet düştüğünde veya arka planda bir biletin SLA süresi dolduğunda temsilci ekranına WebSocket (`ActionCable` / `Turbo Streams broadcast`) üzerinden sayfa yenilemeden anlık tablo güncellemesi düşmemektedir. Bilet listesi ve kalan SLA sayaçları sayfa yenilendiğinde (**F5**) güncellenmektedir.

---

## Yerel Kurulum ve Çalıştırma

```bash
# Bağımlılıkları yükleyin
bundle install

# Veritabanını oluşturun ve migration'ları çalıştırın
bin/rails db:create db:migrate

# Birim testlerini çalıştırın (travel_to zaman testleri dahil)
bin/rails test

# Web sunucusunu başlatın (http://localhost:3000)
bin/rails server

# Telegram AI Botunu (@Abisinin_Destek_Bot) başlatın
ruby bin/telegram_bot
```
