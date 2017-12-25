class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :facebook_id
      t.string :actions

      t.timestamps
    end
    add_index :users, :facebook_id
  end
end
