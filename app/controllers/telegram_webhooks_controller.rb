class TelegramWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    message = params[:message] || params.dig(:telegram_webhook, :message)
    if message.present? && message[:text].present?
      chat_id = message.dig(:chat, :id)
      username = message.dig(:from, :username) || message.dig(:from, :first_name)
      TelegramBotService.handle_incoming_message(
        chat_id: chat_id,
        text: message[:text],
        username: username
      )
    end

    head :ok
  end
end
