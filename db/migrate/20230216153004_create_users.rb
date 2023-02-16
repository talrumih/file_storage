class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :token
      t.boolean :active
      t.timestamp :last_used

      t.timestamps
    end
  end
end
