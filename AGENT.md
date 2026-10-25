# AGENT.md — Antigravity Geliştirme Süreci ve Mühendislik Günlüğü

Bu belge, **AbisiDesk** (Akıllı SLA, Yapay Zeka Triyaj ve Bilet Yönetim Sistemi) projesinin **Google DeepMind Antigravity** kodlama ajanı ile sıfırdan canlıya alınma sürecini, ajana verilen temel direktifleri, karşılaşılan teknik engelleri/hataları ve token/zaman maliyeti dökümünü şeffaf biçimde kayıt altına alır.

---

## 1. Antigravity'ye Verilen Temel Direktifler

Geliştirme süreci, monolitik bir "her şeyi yap" komutu yerine **Aort Dilimi (Aortic Slice)** metodolojisine uygun olarak ardışık mühendislik fazlarında yürütülmüştür:

1. **Faz 1 — Temiz Rails 8 Kurulumu ve Altyapı Direktifi:**
   - *"Bir Rails 8 projesi oluşturacağız. Adı 'AbisiDesk'. Veritabanı PostgreSQL olsun (`--database=postgresql`), CSS için Tailwind kullan (`--css=tailwind`). Gereksiz asset ve test karmaşasından kaçınmak için temiz, modern Rails 8 yapısını koru. Kurulum bittikten sonra veritabanını oluştur (`bin/rails db:create`) ve sunucunun çalıştığını doğrula."*
2. **Faz 2 — Aort Dilimi Veri Modeli (`Ticket`) ve Otomatik SLA Motoru Direktifi:**
   - *"Model adı: `Ticket`. Sütunlar: `title`, `description`, `customer_email`, `status` (default: 'new'), `priority` (default: 'normal'), `sla_deadline`, `resolved_at`, `telegram_chat_id`, `category`, `summary`. Kayıt oluşturulmadan önce (`before_validation :set_initial_rules, on: :create`) aciliyet analizine göre `priority = 'urgent'` ve `sla_deadline = Time.current + 1.hour`, aksi halde `priority = 'normal'` ve `sla_deadline = Time.current + 4.hours` yapılsın. `mark_as_open!`, `mark_as_solved!` ve `sla_breached?` metotlarını yaz."*
3. **Faz 3 — Controller, Rotalar ve Koyu Tema (Dark Mode) Tailwind CSS UX Direktifi:**
   - *"Kök dizin `tickets#index` olsun. Durum geçişleri için `patch :mark_as_open` ve `patch :mark_as_solved` rotalarını ekle. Marka adı 'AbisiDesk' olsun (asla Zendesk logosu veya ismi görünmesin). Bilet listesinde `sla_breached?` true ise belirgin kırmızı bir 'SLA İHLALİ / BREACHED' rozeti çıksın. Detay sayfasında durum değiştirme butonları ve işlemlerde flash mesajları bulunsun."*
4. **Faz 4 — Telegram AI Botu (`@Abisinin_Destek_Bot`) & Groq LLM Anlamsal Çıkarım Direktifi:**
   - *"Formu devreden çıkarıp Telegram botuna gelen serbest dildeki kullanıcı mesajını Groq LLM (`GroqExtractorService`, `response_format: { type: 'json_object' }`) ile analiz edip otomatik ticket açan ve durum güncellemelerinde `send_status_update` ile 'AbisiDesk Bildirimi' gönderen çift yönlü mimariyi kur."*
5. **Faz 5 — Zaman Yolculuğu (`travel_to`) ile Minitest, GitHub Actions CI & Render.com Canlıya Geçiş Direktifi:**
   - *"Rails Minitest kullanarak `test/models/ticket_test.rb` dosyasını oluştur. `.github/workflows/ci.yml` ile PostgreSQL 15 ve Ruby 3.3 üzerinde otomatik test boru hattını kur. Render.com için `bin/render-build.sh` ve `render.yaml` oluştur, `DATABASE_URL` ve SSL (`assume_ssl`, `force_ssl`) ayarlarını tamamla."*

---

## 2. Ajanın Hata Yaptığı Aşamalar ve Çözüm Süreci

Otonom geliştirme sırasında ajan aşağıdaki teknik engellerle karşılaşmış ve hata-çözüm döngüsüyle bu sorunlar aşılmıştır:

### Hata 1: Tailwind CSS v4 ve Asset Precompile / Derleme Farklılığı
- **Sorun:** Rails 8 ile birlikte gelen `tailwindcss-rails` (v4.x), eski Tailwind v3'teki `tailwind.config.js` yapısını terk edip CSS-first (`@import "tailwindcss";`) mimarisine geçmiştir. View katmanında yeni eklenen dinamik renk/rozet sınıflarının derlenmiş CSS'e yansıması ve production `assets:precompile` aşamasında Propshaft ile sorunsuz paketlenmesi için derleme adımının açıkça tetiklenmesi gerekmiştir.
- **Nasıl Aşıldı:** Ajan, görünüm ve helper dosyalarını oluşturduktan sonra `bin/rails tailwindcss:build` adımını iş akışına dahil etti; ayrıca Render dağıtım betiğine (`bin/render-build.sh`) `bin/rails assets:precompile` ve `bin/rails assets:clean` adımlarını sırasıyla ekleyerek stil dosyalarının canlı ortamda eksik yüklenmesi riskini ortadan kaldırdı.

### Hata 2: Yerel Eklenti (`websocket-driver` / `pg`) Derleme ve MSYS2 Ortam Değişkenleri
- **Sorun:** İlk `gem install rails` denemesinde ajan `make: *** [Makefile:251: websocket_mask.o] Error 1` ve `make failed: No such file or directory` hatası aldı. MSYS2 UCRT64 araç zinciri kurulmuş olmasına rağmen, standart kabukta derleyici ortam değişkenleri aktif değildi.
- **Nasıl Aşıldı:** Komutlar `ridk exec` sarmalayıcısı ve MSYS2 `ucrt64/bin` yolu ile çalıştırılarak C eklentileri (`pg`, `websocket-driver`, `nio4r`) hatasız derlendi.

### Hata 3: Rails 8 Çoklu Veritabanı (Solid Cache/Queue/Cable) ve Render Free PostgreSQL Çakışması
- **Sorun:** Rails 8 varsayılan olarak `config/database.yml` içinde `production` ortamı için 4 ayrı veritabanı (`primary`, `cache`, `queue`, `cable`) tanımlar. Ancak Render.com ücretsiz PostgreSQL paketi yalnızca **tek bir veritabanı** (`DATABASE_URL`) sunar; bu da `ActiveRecord::AdapterNotSpecified: The 'cache' database is not configured` hatasına yol açmaktadır.
- **Nasıl Aşıldı:** `config/database.yml` içindeki `production` bloğu doğrudan tekil `url: <%= ENV["DATABASE_URL"] %>` kullanacak şekilde sadeleştirildi ve `config/cache.yml` ile `config/environments/production.rb` tek veritabanı mimarisine uygun hale getirildi.

### Hata 4: GitHub Actions Ubuntu Runner'da `ruby.exe` Binstub Hatası (Exit Code 127)
- **Sorun:** Proje Windows ortamında oluşturulduğu için `bin/` dizinindeki binstub dosyalarının shebang satırı `#!/usr/bin/env ruby.exe` olarak üretilmişti. Ubuntu tabanlı GitHub Actions ortamında `bin/rails db:test:prepare` çalıştırıldığında `/usr/bin/env: 'ruby.exe': No such file or directory (exit code 127)` hatasıyla CI patladı.
- **Nasıl Aşıldı:** `.github/workflows/ci.yml` ve `bin/render-build.sh` içindeki komutlar `bundle exec rails db:test:prepare` ve `bundle exec rails test` olarak güncellendi; ayrıca `bin/*` altındaki tüm binstub shebang satırları platform bağımsız `#!/usr/bin/env ruby` olarak düzeltildi.

---

## 3. Token ve Zaman Maliyeti Dökümü

Projenin tamamı yaklaşık **55 dakikalık** aktif ajan-geliştirici eşli çalışmasıyla (kurulum ve paket indirme süreleri dahil) tamamlanmıştır. İterasyonlar ve ince ayarlar dahil toplam LLM kullanımı **~$15.00** seviyesindedir.

| Faz / Görev Adımı | Harcanan Süre | Yaklaşık Token (Girdi + Çıktı) | Tahmini Maliyet (USD) | Çıktı Özeti |
| :--- | :---: | :---: | :---: | :--- |
| **1. Ortam Kurulumu & Rails 8 İskeleti** | ~15 dk | ~180K token | $2.40 | Ruby, PostgreSQL, Tailwind v4, Propshaft ve **AbisiDesk** kurulumu |
| **2. Veri Modeli (`Ticket`) & Otomatik SLA** | ~6 dk | ~140K token | $2.10 | Migration, `set_initial_rules`, `mark_as_open!`, `mark_as_solved!`, `sla_breached?` |
| **3. Controller, Rotalar & Koyu Tema UX** | ~10 dk | ~290K token | $4.50 | `TicketsController`, `index`/`show`/`new` görünümleri, kırmızı SLA İhlali rozetleri |
| **4. Telegram AI Botu & Groq LLM Entegrasyonu** | ~10 dk | ~180K token | $2.50 | `@Abisinin_Destek_Bot`, `GroqExtractorService`, `TelegramBotService`, `send_status_update` |
| **5. Minitest, CI/CD (`ci.yml`), Render & Dokümantasyon** | ~14 dk | ~250K token | $3.50 | `test/models/ticket_test.rb`, GitHub Actions, Render deploy, `README.md`, `CHALLENGE_LOG.md` |
| **TOPLAM** | **~55 dk (Proje Süresi: < 2 Gün)** | **~1.04M Token** | **~$15.00** | **Üretime hazır, test edilmiş AbisiDesk SaaS Uygulaması** |
