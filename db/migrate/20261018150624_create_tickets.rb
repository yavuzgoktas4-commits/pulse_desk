class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :customer_email, null: false
      t.string :status, default: "new", null: false
      t.string :priority, default: "normal", null: false
      t.datetime :sla_deadline
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :tickets, :status
    add_index :tickets, :priority
    add_index :tickets, :sla_deadline
  end
end
