# CHALLENGE_LOG.md — AbisiDesk (Formsuz, AI-First Destek & SLA Platformu)

## Başlangıç noktası
- **Klonlanan Kurumsal SaaS Ürünü:** **Zendesk Support Suite** (Kurumsal Müşteri Destek, ITSM ve SLA Yönetim Platformu) -> Kendi markamızla **AbisiDesk** olarak yeniden inşa edildi.
- **Canlı Render URL:** [https://pulse-desk-6e5q.onrender.com](https://pulse-desk-6e5q.onrender.com)
- **GitHub Repository:** [https://github.com/yavuzgoktas4-commits/pulse_desk](https://github.com/yavuzgoktas4-commits/pulse_desk)
- **Geçen Haftanın (Temel Klon / Aort Dilimi) Commit Linki:** [`d214be4` — Redesign with Dark Mode and Sidebar Dashboard layout](https://github.com/yavuzgoktas4-commits/pulse_desk/commit/d214be4)
- **Bu Ürüne Kimler, Neden Para Ödüyor?**
  - **Uber** ([Zendesk Müşteri Kanıtı](https://www.zendesk.com/customer/uber/)) ve **Shopify** ([Zendesk Müşteri Kanıtı](https://www.zendesk.com/customer/shopify/)) başta olmak üzere yüzlerce Fortune 500 ve küresel ölçekli şirket; milyonlarca müşteri/tedarikçi destek talebini tek merkezde toplamak, aciliyet sırasına (triyaj) koymak ve kurumsal **SLA (Service Level Agreement — Hizmet Seviyesi Taahhüdü)** sürelerini ihlal etmeden çözmek için bu ürüne yılda yüz binlerce dolar lisans ücreti ödemektedir.

---

## Acı
Kurumsal destek yazılımlarında (Zendesk, Freshdesk, Jira Service Management vb.) hem son kullanıcıların hem de destek operasyon ekiplerinin yaşadığı en büyük sürtünme noktası **"uzun web formları ve manuel/hatalı kategori-öncelik triyajı"** sorunudur:
1. **Kullanıcı Tarafındaki Acı:** Sorun yaşayan bir müşteri, acil bir ödeme veya sistem çökmesi anında 6–8 zorunlu alandan oluşan karmaşık web formlarını (Kategori, Alt Kategori, Öncelik, Başlık, E-posta, Açıklama) doldurmak zorunda kalmaktadır.
2. **Operasyon Tarafındaki Acı:** Kullanıcılar formu doldururken ya yanlış kategori/öncelik seçmekte ya da temsilciler yüzlerce bileti manuel okuyup sınıflandırana kadar kritik biletler standart kuyrukta bekleyerek **SLA ihlaline (SLA Breach)** uğramaktadır.
- **Doğrulanabilir Kaynaklar:**
  - 🔗 [G2 — Zendesk Support Suite Kullanıcı Yorumları ve Karmaşık Form / Triyaj Şikayetleri](https://www.g2.com/products/zendesk-support-suite/reviews)
  - 🔗 [Capterra — Zendesk Kullanıcı Deneyimi ve Bilet Sınıflandırma İncelemeleri](https://www.capterra.com/p/160053/Zendesk/reviews/)

---

## Bu haftanın vaadi
Klasik web destek formunu tamamen devreden çıkarıp kullanıcıya **"tam ayağına gelen pası"** atmak:
- Kullanıcının her gün kullandığı **Telegram** üzerinden (`@Abisinin_Destek_Bot`) hiçbir form doldurmadan, doğrudan doğal dilde (serbest metin olarak) sorununu yazmasını sağlamak.
- Gelen serbest metni **Groq LLM** anlamsal zekâsı ile (`response_format: { type: "json_object" }`) analiz ederek **Konu Başlığı (`subject`)**, **Kategori (`category`)**, **Öncelik (`priority`: Low, Medium, High, Critical)** ve **Tek Cümlelik Özet (`summary`)** alanlarını otomatik çıkarmak ve SLA hedefini dinamik başlatmak.
- Destek ekibi web panelinden biletin durumunu güncellediğinde (`Open` -> `In Progress` / `Solved`), kullanıcının web panelini kontrol etmesine gerek kalmadan **Telegram üzerinden anlık durum bildirimi (`— AbisiDesk Bildirimi`)** göndermek.

---

## Yapılanlar ve kanıt
1. **Groq LLM Anlamsal Çıkarım Servisi (`app/services/groq_extractor_service.rb`):**
   - `GroqExtractorService.extract(user_text)` metodu, hiçbir anahtar kelime eşleştirmesi (`regex`/`keyword` tuzağı) kullanmadan mesajı doğrudan Groq API'ye gönderir ve JSON şeması zorlamasıyla (`response_format: { type: "json_object" }`) `subject`, `category`, `priority` ve `summary` alanlarını üretir.
2. **Veritabanı Şeması ve Model Entegrasyonu (`db/migrate/20261025160500_add_telegram_and_llm_fields_to_tickets.rb` & `app/models/ticket.rb`):**
   - `tickets` tablosuna `telegram_chat_id` (indeksli), `category` ve `summary` sütunları eklendi.
   - `Ticket.create_from_telegram!` metodu ile LLM'den dönen `Critical`/`High` önceliklerin SLA motorunda otomatik olarak 1 saatlik kritik SLA hedefine bağlanması sağlandı.
3. **Çift Yönlü Telegram Bot Servisi (`app/services/telegram_bot_service.rb` & `bin/telegram_bot`):**
   - `/start` komutunda: *"AbisiDesk Destek Sistemine hoş geldiniz! Uzun formlarla uğraşmanıza gerek yok; sorununuzu doğrudan buraya yazın, Abisi halleder."* karşılama mesajı döner.
   - Kullanıcı serbest metin gönderdiğinde bilet açılır ve takip numarası, başlık ve öncelik bilgisi **`— AbisiDesk Bildirimi`** imzasıyla anında kullanıcıya iletilir.
   - Web panelinden bilet durumu değiştirildiğinde (`mark_as_open!`, `mark_as_solved!`, `update_status!`), `TelegramBotService.send_status_update(ticket_id, new_status)` tetiklenerek kullanıcının `telegram_chat_id` adresine anlık durum güncellemesi gönderilir.
4. **Web Paneli Görselleştirmesi (`app/views/tickets/index.html.erb` & `app/views/tickets/show.html.erb`):**
   - Bilet listesinde Telegram üzerinden gelen kayıtlar **`🤖 Telegram AI`** rozeti, LLM kategorisi ve tek cümlelik AI özetiyle işaretlendi; detay sayfasına **"🤖 Groq LLM Anlamsal Analiz Özeti"** kartı eklendi.
5. **Otomatik Birim Testleri (`test/models/ticket_test.rb`):**
   - `travel_to` zaman yolculuğu testlerine ek olarak Telegram + Groq LLM bilet oluşturma ve çift yönlü bildirim akışı Minitest ile doğrulandı (`6 runs, 23 assertions, 0 failures`).

---

## Zaman
- **İnsan Zamanı:** ~1 saat (Problem tanımı, Telegram `@BotFather` üzerinden `@Abisinin_Destek_Bot` kurulumu, Groq API anahtarı temini, uçtan uca canlı Telegram testi ve mimari yönlendirme).
- **Agent Zamanı:** ~1 saat (Kod tabanı entegrasyonu, veritabanı migration'ı, `GroqExtractorService` ve `TelegramBotService` geliştirilmesi, Dark Mode UI güncellemeleri, Minitest doğrulaması ve CI/CD dağıtımı).
- **İlk Verdiğimiz Prompt Metni:**
  > *"Şimdi ödevin çekirdek görevine geçiyoruz. Hedefimiz: Formu devreden çıkarmak, Telegram botuna gelen serbest dildeki kullanıcı mesajını Groq LLM ile analiz edip otomatik ticket açmak ve durum bildirimlerini bota göndermek. Lütfen sırasıyla şu adımları projeye entegre et: 1. Bağımlılıkları Yönet (groq, telegram-bot, dotenv)... 2. LLM Extraction Modülü (response_format: {"type": "json_object"} ile subject, category, priority, summary)... 3. Ticket Veritabanı Modeli (telegram_chat_id)... 4. Telegram Bot Mantığı (/start ve serbest metin -> Groq -> DB -> Yanıt)... 5. Çift Yönlü Bildirim Fonksiyonu (send_status_update(ticket_id, new_status))..."*

---

## Karar
- **Karar:** **DEVAM (Go / Scale)**
- **Gerekçe:** Geleneksel B2B SaaS destek ürünlerindeki çok alanlı web formları, hem müşterinin bildirim yapma süresini uzatmakta hem de yanlış öncelik/kategori seçimi yüzünden kritik operasyonel kayıplara yol açmaktadır. **AbisiDesk** ile kanıtlandığı üzere; formsuz, **Agent-First (Telegram + Groq LLM)** destek modeli müşteri sürtünmesini (friction) sıfıra indirmekte, mesajın anlamsal aciliyetini saniyeler içinde tespit ederek doğru SLA kuyruğuna sokmakta ve çift yönlü anlık bildirimle müşteri bekleme belirsizliğini tamamen ortadan kaldırmaktadır.
