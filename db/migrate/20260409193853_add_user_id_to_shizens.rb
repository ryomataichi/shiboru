class AddUserIdToShizens < ActiveRecord::Migration[7.1]
  def change
    add_column :shizens, :user_id, :integer
  end
end
