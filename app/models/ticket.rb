class Ticket < ApplicationRecord
  alias_attribute :subject, :title

  STATUSES = %w[new open solved Open In\ Progress Resolved].freeze
  PRIORITIES = %w[low normal medium high urgent critical Low Medium High Critical].freeze
  URGENT_KEYWORDS = %w[çöktü acil ödeme hata down critical].freeze

  attr_accessor :skip_keyword_rules

  before_validation :set_initial_rules, on: :create

  validates :title, :description, :customer_email, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  # 3. Telegram + Groq LLM üzerinden gelen ticket'ları kaydeden sınıf metodu
  def self.create_from_telegram!(telegram_chat_id:, subject:, priority:, category:, summary: nil, description: nil, status: "Open", customer_email: nil)
    sla = priority.to_s.downcase.in?(%w[critical high urgent]) ? (Time.current + 1.hour) : (Time.current + 4.hours)

    create!(
      skip_keyword_rules: true,
      title: subject,
      description: description.presence || summary.presence || subject,
      summary: summary.presence || subject,
      category: category,
      priority: priority,
      status: status.presence || "Open",
      telegram_chat_id: telegram_chat_id.to_s,
      customer_email: customer_email.presence || "tg_#{telegram_chat_id}@telegram.user",
      sla_deadline: sla
    )
  end

  # 5. Çift yönlü bildirim yardımcı metodu
  def self.send_status_update(ticket_id, new_status)
    TelegramBotService.send_status_update(ticket_id, new_status)
  end

  def mark_as_open!
    new_status = telegram_chat_id.present? ? "In Progress" : "open"
    update!(status: new_status)
    TelegramBotService.send_status_update(id, new_status) if telegram_chat_id.present?
  end

  def mark_as_solved!
    new_status = telegram_chat_id.present? ? "Resolved" : "solved"
    update!(status: new_status, resolved_at: Time.current)
    TelegramBotService.send_status_update(id, new_status) if telegram_chat_id.present?
  end

  def update_status!(new_status)
    attrs = { status: new_status }
    attrs[:resolved_at] = Time.current if new_status.to_s.downcase.in?(%w[solved resolved])
    update!(attrs)
    TelegramBotService.send_status_update(id, new_status) if telegram_chat_id.present?
  end

  def sla_breached?
    return false if status.to_s.downcase.in?(%w[solved resolved]) || sla_deadline.nil?

    Time.current > sla_deadline
  end

  private

  def set_initial_rules
    if skip_keyword_rules
      self.status = "Open" if status.blank?
      self.priority = "Medium" if priority.blank?
      self.sla_deadline ||= priority.to_s.downcase.in?(%w[critical high urgent]) ? (Time.current + 1.hour) : (Time.current + 4.hours)
      return
    end

    self.status = "new" if status.blank?

    combined_text = "#{title} #{description}".tr("İIÇÖÜĞŞ", "iıçöüğş").downcase
    is_urgent = URGENT_KEYWORDS.any? { |keyword| combined_text.include?(keyword) }

    if is_urgent
      self.priority = "urgent"
      self.sla_deadline = Time.current + 1.hour
    else
      self.priority = "normal"
      self.sla_deadline = Time.current + 4.hours
    end
  end
end
