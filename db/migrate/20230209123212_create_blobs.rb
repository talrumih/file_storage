class CreateBlobs < ActiveRecord::Migration[6.0]
  def change
    create_table :blobs do |t|
      t.string :uuid, null: false
      t.integer :filesize
      t.integer :storage_type
      t.string :content_type
      t.string :ext

      t.timestamps
    end
    add_index :blobs, :uuid, unique: true
  end
end
