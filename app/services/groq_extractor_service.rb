require "net/http"
require "uri"
require "json"

class GroqExtractorService
  GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions".freeze
  DEFAULT_MODEL = "llama-3.3-70b-versatile".freeze
  FALLBACK_MODELS = [
    "llama-3.3-70b-versatile",
    "llama-3.1-8b-instant",
    "openai/gpt-oss-120b",
    "openai/gpt-oss-20b",
    "qwen/qwen3.8-27b"
  ].freeze
  VALID_PRIORITIES = %w[Low Medium High Critical].freeze

  SYSTEM_PROMPT = <<~PROMPT.freeze
    Sen kurumsal bir B2B SaaS müşteri destek (Helpdesk) yapay zeka asistanısın.
    Kullanıcının serbest dilde yazdığı destek mesajını anlamsal (semantik) olarak analiz et ve yalnızca aşağıdaki JSON şemasına uygun bir JSON nesnesi döndür:
    {
      "subject": "Kısa ve net konu başlığı",
      "category": "Destek kategorisi (ör. Ödeme, Teknik, Hesap vb.)",
      "priority": "Öncelik seviyesi (Low, Medium, High, Critical)",
      "summary": "Tek cümlelik özet"
    }

    Kurallar:
    - Kesinlikle anahtar kelime eşleştirmesi yapma; kullanıcının niyetini, iş etkisini ve aciliyetini anlamsal olarak değerlendir.
    - "priority" alanı yalnızca şu 4 değerden biri olmalıdır: "Low", "Medium", "High", "Critical".
    - Yanıtın yalnızca geçerli bir JSON nesnesi olsun.
  PROMPT

  def self.extract(user_text, model: ENV.fetch("GROQ_MODEL", DEFAULT_MODEL))
    new(model: model).extract(user_text)
  end

  def initialize(api_key: ENV["GROQ_API_KEY"], model: ENV.fetch("GROQ_MODEL", DEFAULT_MODEL))
    @api_key = api_key
    @model = model.presence || DEFAULT_MODEL
  end

  def extract(user_text)
    raise ArgumentError, "Kullanıcı mesajı boş olamaz" if user_text.to_s.strip.empty?
    raise "GROQ_API_KEY ortam değişkeni tanımlı değil (.env dosyasını kontrol edin)" if @api_key.blank? || @api_key == "your_groq_api_key_here"

    uri = URI.parse(GROQ_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 25

    candidate_models = ([@model] + FALLBACK_MODELS).uniq
    response = nil

    candidate_models.each do |candidate_model|
      request = Net::HTTP::Post.new(uri.request_uri)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Content-Type"] = "application/json"
      request.body = {
        model: candidate_model,
        response_format: { type: "json_object" },
        temperature: 0.1,
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: user_text.to_s }
        ]
      }.to_json

      response = http.request(request)
      break if response.is_a?(Net::HTTPSuccess)
      break unless response.code.to_i == 404 || response.code.to_i == 400
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "Groq API Hatası (#{response.code}): #{response.body}"
    end

    parsed_body = JSON.parse(response.body)
    content = parsed_body.dig("choices", 0, "message", "content")
    extracted = JSON.parse(content.to_s)

    normalize_response(extracted)
  end

  private

  def normalize_response(data)
    priority = data["priority"].to_s.strip
    priority = "Medium" unless VALID_PRIORITIES.include?(priority)

    {
      "subject" => data["subject"].to_s.strip.presence || "Destek Talebi",
      "category" => data["category"].to_s.strip.presence || "Genel",
      "priority" => priority,
      "summary" => data["summary"].to_s.strip.presence || data["subject"].to_s.strip
    }
  end
end
