class CreateBlob < ActiveRecord::Migration[6.0]
  def change
    create_table :blob_dbs do |t|
      t.string :uuid
      t.string :data
    end
  end
end
