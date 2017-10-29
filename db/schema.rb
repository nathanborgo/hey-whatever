# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171028223746) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "slack_authorizations", id: :serial, force: :cascade do |t|
    t.string "team_id"
    t.string "team_name"
    t.string "user_id"
    t.string "user_access_token"
    t.string "bot_id"
    t.string "bot_access_token"
  end

  create_table "tacos", force: :cascade do |t|
    t.string "giver_id"
    t.string "recipient_id"
    t.string "original_text"
    t.string "channel_id"
  end

end
