class AddUserToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :user_id, :integer, index: true
  end
end
