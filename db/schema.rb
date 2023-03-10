# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_02_16_153004) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blobs", force: :cascade do |t|
    t.string "uuid", null: false
    t.integer "filesize"
    t.integer "storage_type"
    t.string "content_type"
    t.string "ext"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uuid"], name: "index_blobs_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "token"
    t.boolean "active"
    t.datetime "last_used"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
