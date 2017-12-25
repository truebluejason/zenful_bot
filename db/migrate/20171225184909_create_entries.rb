class CreateEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :entries do |t|
      t.string :date
      t.string :mood
      t.string :text
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :entries, [:user_id, :created_at]
  end
end
