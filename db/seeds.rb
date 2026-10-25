# AbisiDesk — Gerçekçi B2B SaaS Destek Biletleri (Seed Verisi)
# Her durum (new, open, solved), her öncelik (low, medium, high, urgent) ve
# her SLA durumunu (süresi geçmiş ihlal, kritik son 1 saat, normal ve çözülmüş) temsil eden 6 kayıt.

now = Time.current

seeds = [
  {
    title: "ACİL: Kurumsal SSO (Okta SAML 2.0) Entegrasyonu Çöktü — 450 Kullanıcı Giriş Yapamıyor",
    description: "Sabah 08:30 itibarıyla Okta üzerinden SAML 2.0 ile oturum açmaya çalışan tüm kurumsal kullanıcılarımız 'Invalid Signature / Assertion Consumer Service' hatası alıyor. Operasyon ekibimiz sisteme erişemediği için müşteri çağrıları beklemeye alındı.",
    customer_email: "cto@fintechcorp.com.tr",
    status: "new",
    priority: "urgent",
    sla_deadline: now - 45.minutes,
    resolved_at: nil,
    created_at: now - 105.minutes
  },
  {
    title: "Ödeme Gateway Webhook Hatası — Yıllık Enterprise Abonelik Yenilemeleri Düşmüyor",
    description: "Stripe ve Iyzico üzerinden gerçekleşen başarılı kurumsal abonelik tahsilatlarında 'invoice.payment_succeeded' webhook çağrıları 502 Bad Gateway dönüyor. Ödemesi çekilen müşterilerin lisansları otomatik uzatılmıyor, kritik SLA süresi içindeyiz.",
    customer_email: "billing-ops@globalretail.io",
    status: "open",
    priority: "urgent",
    sla_deadline: now + 28.minutes,
    resolved_at: nil,
    created_at: now - 32.minutes
  },
  {
    title: "Production REST API Rate Limit (HTTP 429) ve ERP Stok Senkronizasyon Gecikmesi",
    description: "SAP ERP entegrasyonumuz saatlik toplu sipariş aktarımı yaparken dakikada 1.200 istek sınırına takılıyor ve kuyrukta 18.000 sipariş birikti. Kurumsal paketimiz kapsamında API rate-limit kotasının acilen artırılmasını talep ediyoruz.",
    customer_email: "devops@lojistikplus.com",
    status: "open",
    priority: "high",
    sla_deadline: now - 2.hours,
    resolved_at: nil,
    created_at: now - 6.hours
  },
  {
    title: "Yeni Bölge Ofisi İçin Özel Rol Tabanlı Yetkilendirme (RBAC) ve Denetim İzi Talebi",
    description: "EMEA operasyon ekibimiz için yalnızca kendi bölgesindeki biletleri görüntüleyebilen ancak fatura modülüne erişemeyen 'Regional Support Lead' adında özel bir yetki profili tanımlanması konusunda destek rica ediyoruz.",
    customer_email: "it.admin@anadoluholding.com.tr",
    status: "new",
    priority: "medium",
    sla_deadline: now + 165.minutes,
    resolved_at: nil,
    created_at: now - 75.minutes
  },
  {
    title: "Q4 Müşteri Memnuniyeti (CSAT) CSV Dışa Aktarımında ISO-8601 Tarih Formatı Talebi",
    description: "Haftalık SLA ve CSAT performans raporlarını PowerBI panomuza aktarırken tarih sütununun yerel saat dilimi yerine UTC ISO-8601 formatında dışa aktarılması için hesap ayarlarımızda güncelleme yapılabilir mi?",
    customer_email: "analitik@bulutmedya.net",
    status: "open",
    priority: "low",
    sla_deadline: now + 210.minutes,
    resolved_at: nil,
    created_at: now - 30.minutes
  },
  {
    title: "Canlı Veritabanı Replikasyon Hata Uyarısı ve Read-Replica Bağlantı Havuzu Optimizasyonu",
    description: "Raporlama sorgularının çalıştığı ikincil PostgreSQL replikasında 12 saniyelik gecikme (replication lag) gözlemlendi. Bağlantı havuzu (PgBouncer) parametreleri güncellenerek sorun SLA süresi dolmadan giderildi.",
    customer_email: "sre-team@paystream.io",
    status: "solved",
    priority: "urgent",
    sla_deadline: now - 3.hours,
    resolved_at: now - 200.minutes,
    created_at: now - 4.hours
  }
]

seeds.each do |attrs|
  ticket = Ticket.find_or_initialize_by(title: attrs[:title])
  ticket.assign_attributes(
    description: attrs[:description],
    customer_email: attrs[:customer_email]
  )
  ticket.save!

  ticket.update_columns(
    status: attrs[:status],
    priority: attrs[:priority],
    sla_deadline: attrs[:sla_deadline],
    resolved_at: attrs[:resolved_at],
    created_at: attrs[:created_at],
    updated_at: now
  )
end

puts "AbisiDesk Seed tamamlandı: #{Ticket.count} B2B SaaS destek bileti hazır."
