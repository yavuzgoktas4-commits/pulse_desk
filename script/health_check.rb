# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "dotenv"

env_path = File.expand_path("../.env", __dir__)
Dotenv.load(env_path)

puts "=== 1. .env Dosyası Kontrolü (#{env_path}) ==="
if File.exist?(env_path)
  File.readlines(env_path).each_with_index do |line, idx|
    clean = line.strip
    next if clean.empty? || clean.start_with?("#")
    key, val = clean.split("=", 2)
    masked = if key == "GROQ_API_KEY" && val && val.gsub('"', '').start_with?("gsk_")
               "\"#{val.gsub('"', '')[0..7]}...#{val.gsub('"', '')[-4..]}\" (Format: Geçerli gsk_...)"
             else
               val
             end
    puts "Satır #{idx + 1}: #{key}=#{masked}"
  end
else
  puts "HATA: .env dosyası bulunamadı!"
end

puts "\n=== 2. Telegram Bot API (getMe) Health Check ==="
tg_token = ENV["TELEGRAM_BOT_TOKEN"].to_s.strip
if tg_token.empty? || tg_token.include?("your_telegram")
  puts "DURUM: BAŞARISIZ - TELEGRAM_BOT_TOKEN eksik veya yer tutucu (placeholder) içeriyor."
else
  begin
    uri = URI.parse("https://api.telegram.org/bot#{tg_token}/getMe")
    response = Net::HTTP.get_response(uri)
    body = JSON.parse(response.body)
    if response.is_a?(Net::HTTPSuccess) && body["ok"]
      result = body["result"]
      puts "DURUM: BAŞARILI (HTTP #{response.code})"
      puts "Bot ID: #{result['id']}"
      puts "Bot Adı: #{result['first_name']}"
      puts "Kullanıcı Adı: @#{result['username']}"
      puts "Mesaj Alma Yetkisi (can_join_groups): #{result['can_join_groups']}"
    else
      puts "DURUM: BAŞARISIZ (HTTP #{response.code}) - #{body['description']}"
    end
  rescue StandardError => e
    puts "DURUM: BAĞLANTI HATASI - #{e.class}: #{e.message}"
  end
end

puts "\n=== 3. Groq API Health Check ==="
groq_key = ENV["GROQ_API_KEY"].to_s.strip
groq_model = ENV.fetch("GROQ_MODEL", "llama-3.3-70b-versatile")
if groq_key.empty? || groq_key == "your_groq_api_key_here" || !groq_key.start_with?("gsk_")
  puts "DURUM: BAŞARISIZ - GROQ_API_KEY geçersiz veya yer tutucu ('#{groq_key}') durumunda!"
else
  begin
    uri = URI.parse("https://api.groq.com/openai/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 20

    candidates = [
      groq_model,
      "llama-3.3-70b-versatile",
      "llama-3.1-8b-instant",
      "openai/gpt-oss-120b",
      "openai/gpt-oss-20b",
      "qwen/qwen3.8-27b"
    ].uniq

    response = nil
    used_model = nil

    candidates.each do |candidate|
      request = Net::HTTP::Post.new(uri.request_uri)
      request["Authorization"] = "Bearer #{groq_key}"
      request["Content-Type"] = "application/json"
      request.body = JSON.generate({
        model: candidate,
        temperature: 0.1,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: "Sen kurumsal bir B2B SaaS müşteri destek yapay zeka asistanısın. Yanıtını JSON formatında {\"status\": \"ok\", \"subject\": \"...\", \"category\": \"...\", \"priority\": \"...\"} olarak döndür." },
          { role: "user", content: "test: Ödeme ekranında kurumsal kredi kartımızla 2 kez çekim yapıldı, acil kontrol eder misiniz?" }
        ]
      })

      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        used_model = candidate
        break
      end
    end

    body = JSON.parse(response.body)
    if response.is_a?(Net::HTTPSuccess)
      content = body.dig("choices", 0, "message", "content")
      puts "DURUM: BAŞARILI (HTTP #{response.code})"
      puts "Aktif Model: #{body['model']} (Seçilen: #{used_model})"
      puts "Groq Test Yanıtı: #{content}"
    else
      puts "DURUM: BAŞARISIZ (HTTP #{response.code}) - #{body.dig('error', 'message') || response.body}"
    end
  rescue StandardError => e
    puts "DURUM: BAĞLANTI HATASI - #{e.class}: #{e.message}"
  end
end
