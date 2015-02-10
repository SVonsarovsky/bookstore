class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.string :number
      t.string :code
      t.integer :expiration_month
      t.integer :expiration_year
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
