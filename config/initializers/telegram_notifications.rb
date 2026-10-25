# Global helper function for two-way Telegram status notifications:
# send_status_update(ticket_id, new_status)
module Kernel
  def send_status_update(ticket_id, new_status)
    TelegramBotService.send_status_update(ticket_id, new_status)
  end
end

# Render Free Plan üzerinde ayrı bir Background Worker olmadan da
# web sunucusu içinde Telegram Long-Polling çalıştırılabilmesi için:
Rails.application.config.after_initialize do
  if defined?(Rails::Server) && ENV["TELEGRAM_POLLING_IN_WEB"] == "true" && ENV["TELEGRAM_BOT_TOKEN"].present?
    Thread.new do
      loop do
        begin
          Rails.logger.info("[AbisiDesk] Web süreci içinde Telegram Bot Polling başlatılıyor...")
          TelegramBotService.run_polling
        rescue StandardError => e
          Rails.logger.error("[AbisiDesk] Telegram Polling hatası (5 sn sonra yeniden denenecek): #{e.message}")
          sleep 5
        end
      end
    end
  end
end
