require "telegram/bot"
require "net/http"
require "uri"
require "json"

class TelegramBotService
  WELCOME_MESSAGE = "AbisiDesk Destek Sistemine hoş geldiniz! Uzun formlarla uğraşmanıza gerek yok; sorununuzu doğrudan buraya yazın, Abisi halleder.".freeze

  class << self
    # 5. Çift Yönlü Bildirim Fonksiyonu:
    # Bir ticket'ın durumu güncellendiğinde ilgili telegram_chat_id'ye otomatik bildirim fırlatır.
    def send_status_update(ticket_id, new_status)
      ticket = Ticket.find_by(id: ticket_id)
      return false unless ticket && ticket.telegram_chat_id.present?

      status_display = format_status_label(new_status)
      message = <<~MSG.strip
        🔔 Bilet Durumu Güncellendi!
        📌 Takip No: ##{ticket.id}
        📝 Başlık: #{ticket.subject}
        🔄 Yeni Durum: #{status_display}

        — AbisiDesk Bildirimi
      MSG

      send_telegram_message(ticket.telegram_chat_id, message)
    end

    def send_telegram_message(chat_id, text)
      return false if defined?(Rails) && Rails.env.test?

      token = ENV["TELEGRAM_BOT_TOKEN"]
      if token.blank? || token == "your_telegram_bot_token_here"
        Rails.logger.warn("[TelegramBotService] TELEGRAM_BOT_TOKEN tanımlı değil, mesaj gönderilemedi: #{text}")
        return false
      end

      uri = URI.parse("https://api.telegram.org/bot#{token}/sendMessage")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 15

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request.body = {
        chat_id: chat_id.to_s,
        text: text
      }.to_json

      response = http.request(request)
      response.is_a?(Net::HTTPSuccess)
    rescue StandardError => e
      Rails.logger.error("[TelegramBotService] Mesaj gönderim hatası: #{e.message}")
      false
    end

    # Gelen Telegram mesajını işler (/start veya serbest metin -> Groq LLM -> DB Ticket -> Bildirim)
    def handle_incoming_message(chat_id:, text:, username: nil)
      cleaned_text = text.to_s.strip
      return if cleaned_text.empty?

      if cleaned_text.start_with?("/start")
        send_telegram_message(chat_id, WELCOME_MESSAGE)
        return { action: :start, reply: WELCOME_MESSAGE }
      end

      # a) Mesajı Groq LLM servisine gönder
      extracted = GroqExtractorService.extract(cleaned_text)

      # b) Çıkan veriyi veritabanına ticket olarak kaydet
      ticket = Ticket.create_from_telegram!(
        telegram_chat_id: chat_id.to_s,
        subject: extracted["subject"],
        category: extracted["category"],
        priority: extracted["priority"],
        summary: extracted["summary"],
        description: cleaned_text,
        customer_email: username.present? ? "#{username}@telegram.user" : "tg_#{chat_id}@telegram.user"
      )

      # c) Kullanıcıya geri Telegram mesajı at
      reply_text = <<~MSG.strip
        ✅ Talebiniz Alındı!
        📌 Takip No: ##{ticket.id}
        📝 Başlık: #{ticket.subject}
        ⚡ Öncelik: #{ticket.priority}
        Durum değiştikçe buradan anlık bildirim alacaksınız.

        — AbisiDesk Bildirimi
      MSG

      send_telegram_message(chat_id, reply_text)
      puts "[Telegram] Bilet ##{ticket.id} oluşturuldu: #{ticket.subject} (Öncelik: #{ticket.priority}, Kategori: #{ticket.category})"
      { action: :ticket_created, ticket: ticket, reply: reply_text }
    rescue StandardError => e
      puts "[TelegramBotService] HATA: #{e.class} - #{e.message}"
      Rails.logger.error("[TelegramBotService] Hata: #{e.class} - #{e.message}")
      error_reply = "⚠️ Talebiniz işlenirken geçici bir hata oluştu: #{e.message}\n\n— AbisiDesk Bildirimi"
      send_telegram_message(chat_id, error_reply)
      { action: :error, error: e.message }
    end

    # Yerelde uzun yoklama (Long Polling) ile Telegram botunu çalıştırır
    def run_polling
      token = ENV["TELEGRAM_BOT_TOKEN"]
      if token.blank? || token == "your_telegram_bot_token_here"
        raise "TELEGRAM_BOT_TOKEN tanımlı değil! Lütfen .env dosyasına geçerli bir Telegram Bot Token girin."
      end

      puts "🤖 AbisiDesk Telegram Bot başlatıldı (Groq LLM entegrasyonu aktif)... Çıkmak için Ctrl+C"
      Telegram::Bot::Client.run(token) do |bot|
        bot.listen do |message|
          next unless message.is_a?(Telegram::Bot::Types::Message) && message.text.present?

          chat_id = message.chat.id
          username = message.from&.username || message.from&.first_name
          puts "[Telegram] Mesaj alındı (chat_id=#{chat_id}): #{message.text}"
          handle_incoming_message(chat_id: chat_id, text: message.text, username: username)
        end
      end
    end

    private

    def format_status_label(status)
      case status.to_s.downcase
      when "new" then "New (Yeni)"
      when "open" then "Open (Açık)"
      when "in progress", "in_progress" then "In Progress (İncelemede)"
      when "resolved", "solved" then "Resolved (Çözüldü)"
      else status.to_s
      end
    end
  end
end
