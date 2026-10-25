class AddTelegramAndLlmFieldsToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :telegram_chat_id, :string
    add_column :tickets, :category, :string
    add_column :tickets, :summary, :text

    add_index :tickets, :telegram_chat_id
    add_index :tickets, :category
  end
end
