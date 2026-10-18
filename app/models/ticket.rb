class Ticket < ApplicationRecord
  STATUSES = %w[new open solved].freeze
  PRIORITIES = %w[low normal medium high urgent].freeze
  URGENT_KEYWORDS = %w[çöktü acil ödeme hata down critical].freeze

  before_validation :set_initial_rules, on: :create

  validates :title, :description, :customer_email, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  def mark_as_open!
    update!(status: "open")
  end

  def mark_as_solved!
    update!(status: "solved", resolved_at: Time.current)
  end

  def sla_breached?
    return false if status == "solved" || sla_deadline.nil?

    Time.current > sla_deadline
  end

  private

  def set_initial_rules
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
