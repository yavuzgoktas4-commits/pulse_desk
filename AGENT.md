# AGENT.md — Antigravity Geliştirme Süreci ve Mühendislik Günlüğü

Bu belge, **PulseDesk** (Akıllı SLA ve Bilet Yönetim Sistemi) projesinin **Google DeepMind Antigravity** kodlama ajanı ile sıfırdan canlıya alınma sürecini, ajana verilen temel direktifleri, karşılaşılan teknik engelleri/hataları ve token/zaman maliyeti dökümünü şeffaf biçimde kayıt altına alır.

---

## 1. Antigravity'ye Verilen Temel Direktifler

Geliştirme süreci, monolitik bir "her şeyi yap" komutu yerine **Aort Dilimi (Aortic Slice)** metodolojisine uygun olarak 5 ardışık mühendislik fazında yürütülmüştür:

1. **Faz 1 — Temiz Rails 8 Kurulumu ve Altyapı Direktifi:**
   - *"Bir Rails 8 projesi oluşturacağız. Adı 'PulseDesk'. Veritabanı PostgreSQL olsun (`--database=postgresql`), CSS için Tailwind kullan (`--css=tailwind`). Gereksiz asset ve test karmaşasından kaçınmak için temiz, modern Rails 8 yapısını koru. Kurulum bittikten sonra veritabanını oluştur (`bin/rails db:create`) ve sunucunun çalıştığını doğrula."*
2. **Faz 2 — Aort Dilimi Veri Modeli (`Ticket`) ve Otomatik SLA Motoru Direktifi:**
   - *"Model adı: `Ticket`. Sütunlar: `title`, `description`, `customer_email`, `status` (default: 'new'), `priority` (default: 'normal'), `sla_deadline`, `resolved_at`. Kayıt oluşturulmadan önce (`before_validation :set_initial_rules, on: :create`) başlık veya açıklamada 'çöktü', 'acil', 'ödeme', 'hata', 'down', 'critical' geçiyorsa `priority = 'urgent'` ve `sla_deadline = Time.current + 1.hour`, aksi halde `priority = 'normal'` ve `sla_deadline = Time.current + 4.hours` yapılsın. `mark_as_open!`, `mark_as_solved!` ve `sla_breached?` metotlarını yaz."*
3. **Faz 3 — Controller, Rotalar ve Tailwind CSS UX Direktifi:**
   - *"Kök dizin `tickets#index` olsun. Durum geçişleri için `patch :mark_as_open` ve `patch :mark_as_solved` rotalarını ekle. Marka adı 'PulseDesk' olsun (asla Zendesk logosu veya ismi görünmesin). Bilet listesinde `sla_breached?` true ise belirgin kırmızı bir 'SLA İHLALİ / BREACHED' rozeti çıksın. Detay sayfasında durum değiştirme butonları ve işlemlerde flash mesajları bulunsun."*
4. **Faz 4 — Zaman Yolculuğu (`travel_to`) ile Minitest Direktifi:**
   - *"Rails Minitest kullanarak `test/models/ticket_test.rb` dosyasını oluştur. Zaman kuralı ve durum geçişi için `travel_to` kullanarak 5 temel senaryoyu (4 saatlik varsayılan SLA, acil kelimesiyle 1 saatlik SLA, durum geçişleri, 5 saat sonra SLA ihlali, çözülen bilette 10 saat sonra bile SLA ihlali olmaması) test et ve `bin/rails test` ile doğrula."*
5. **Faz 5 — GitHub Actions CI & Render.com Canlıya Geçiş Direktifi:**
   - *"`.github/workflows/ci.yml` ile PostgreSQL 15 ve Ruby 3.3 üzerinde otomatik test boru hattını kur. Render.com için `bin/render-build.sh` ve `render.yaml` oluştur, `DATABASE_URL` ve SSL (`assume_ssl`, `force_ssl`) ayarlarını tamamla."*

---

## 2. Ajanın Hata Yaptığı Aşamalar ve Çözüm Süreci

Otonom geliştirme sırasında ajan aşağıdaki teknik engellerle karşılaşmış ve hata-çözüm döngüsüyle bu sorunlar aşılmıştır:

### Hata 1: Tailwind CSS v4 ve Asset Precompile / Derleme Farklılığı
- **Sorun:** Rails 8 ile birlikte gelen `tailwindcss-rails` (v4.x), eski Tailwind v3'teki `tailwind.config.js` yapısını terk edip CSS-first (`@import "tailwindcss";`) mimarisine geçmiştir. View katmanında yeni eklenen dinamik renk/rozet sınıflarının (`bg-red-50/80`, `animate-pulse`, özel durum rozeti sınıfları) derlenmiş CSS'e yansıması ve production `assets:precompile` aşamasında Propshaft ile sorunsuz paketlenmesi için derleme adımının açıkça tetiklenmesi gerekmiştir.
- **Nasıl Aşıldı:** Ajan, görünüm ve helper dosyalarını oluşturduktan sonra `bin/rails tailwindcss:build` adımını iş akışına dahil etti; ayrıca Render dağıtım betiğine (`bin/render-build.sh`) `bin/rails assets:precompile` ve `bin/rails assets:clean` adımlarını sırasıyla ekleyerek stil dosyalarının canlı ortamda eksik yüklenmesi riskini ortadan kaldırdı.

### Hata 2: Yerel Eklenti (`websocket-driver` / `pg`) Derleme ve MSYS2 Ortam Değişkenleri
- **Sorun:** İlk `gem install rails` denemesinde ajan `make: *** [Makefile:251: websocket_mask.o] Error 1` ve `make failed: No such file or directory` hatası aldı. MSYS2 UCRT64 araç zinciri kurulmuş olmasına rağmen, standart kabukta derleyici ortam değişkenleri aktif değildi.
- **Nasıl Aşıldı:** Komutlar `ridk exec` sarmalayıcısı ve MSYS2 `ucrt64/bin` yolu ile çalıştırılarak C eklentileri (`pg`, `websocket-driver`, `nio4r`) hatasız derlendi.

### Hata 3: Rails 8 Çoklu Veritabanı (Solid Cache/Queue/Cable) ve Render Free PostgreSQL Çakışması
- **Sorun:** Rails 8 varsayılan olarak `config/database.yml` içinde `production` ortamı için 4 ayrı veritabanı (`primary`, `cache`, `queue`, `cable`) tanımlar. Ancak Render.com ücretsiz PostgreSQL paketi yalnızca **tek bir veritabanı** (`DATABASE_URL`) sunar; bu da `bin/rails db:migrate` sırasında `database "pulse_desk_production_cache" does not exist` hatasına yol açmaktadır.
- **Nasıl Aşıldı:** `config/database.yml` içindeki `production` bloğu doğrudan tekil `url: <%= ENV["DATABASE_URL"] %>` kullanacak şekilde sadeleştirildi ve `config/environments/production.rb` ile `config/cable.yml` tek veritabanı mimarisine uygun hale getirildi.

### Hata 4: Test Ortamında Bekleyen Migration ve Windows/Linux Satır Sonu (CRLF/LF) Uyumsuzluğu
- **Sorun:** İlk `bin/rails test` çalıştırmasında test veritabanı şeması henüz yüklenmediği için `Migrations are pending` hatası alındı. Ayrıca Windows ortamında oluşturulan `bin/render-build.sh` dosyasında CRLF (`\r\n`) satır sonları oluştuğu için Linux tabanlı Render konteynerinde çalışmama riski ortaya çıktı.
- **Nasıl Aşıldı:** Test öncesi `bin/rails db:test:prepare` adımı hem yerel akışa hem de GitHub Actions CI boru hattına eklendi. `.gitattributes` dosyasına `bin/* text eol=lf` ve `*.sh text eol=lf` kuralları eklenip `git add --chmod=+x bin/render-build.sh` ile Linux çalıştırma izni garanti altına alındı.

---

## 3. Token ve Zaman Maliyeti Dökümü

Projenin tamamı yaklaşık **45 dakikalık** aktif ajan-geliştirici eşli çalışmasıyla (kurulum ve paket indirme süreleri dahil) tamamlanmıştır. İterasyonlar ve ince ayarlar dahil toplam LLM kullanımı **~$15.00** seviyesindedir.

| Faz / Görev Adımı | Harcanan Süre | Yaklaşık Token (Girdi + Çıktı) | Tahmini Maliyet (USD) | Çıktı Özeti |
| :--- | :---: | :---: | :---: | :--- |
| **1. Ortam Kurulumu & Rails 8 İskeleti** | ~15 dk | ~180K token | $2.40 | Ruby, PostgreSQL, Tailwind v4, Propshaft ve `pulse_desk` kurulumu |
| **2. Veri Modeli (`Ticket`) & Otomatik SLA** | ~6 dk | ~140K token | $2.10 | Migration, `set_initial_rules`, `mark_as_open!`, `mark_as_solved!`, `sla_breached?` |
| **3. Controller, Rotalar & Tailwind UX** | ~10 dk | ~290K token | $4.50 | `TicketsController`, `index`/`show`/`new` görünümleri, kırmızı SLA İhlali rozetleri |
| **4. Minitest & `travel_to` Senaryoları** | ~5 dk | ~160K token | $2.50 | `test/models/ticket_test.rb` (5 senaryo, 15 assertion, %100 başarılı) |
| **5. CI/CD (`ci.yml`), Render & Dokümantasyon** | ~9 dk | ~230K token | $3.50 | GitHub Actions, `bin/render-build.sh`, `render.yaml`, `README.md`, `AGENT.md` |
| **TOPLAM** | **~45 dk (Proje Süresi: < 2 Gün)** | **~1.0M Token** | **~$15.00** | **Üretime hazır, test edilmiş Aort Dilimi SaaS Uygulaması** |
