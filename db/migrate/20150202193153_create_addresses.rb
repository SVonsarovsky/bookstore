class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :zip_code
      t.string :city
      t.string :phone
      t.belongs_to :country, index: true

      t.timestamps
    end
  end
end
