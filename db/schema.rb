# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130614015236) do

  create_table "bets", :force => true do |t|
    t.integer  "scoresheet_id",                :null => false
    t.integer  "position"
    t.string   "name",                         :null => false
    t.string   "bet_type",                     :null => false
    t.string   "choices"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "points",        :default => 5, :null => false
    t.string   "value"
    t.string   "winner"
  end

  add_index "bets", ["scoresheet_id", "name"], :name => "index_bets_on_scoresheet_id_and_name", :unique => true

  create_table "entries", :force => true do |t|
    t.integer  "participant_id", :null => false
    t.integer  "bet_id",         :null => false
    t.string   "value",          :null => false
    t.string   "winner"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "entries", ["participant_id", "bet_id"], :name => "index_entries_on_participant_id_and_bet_id", :unique => true

  create_table "participants", :force => true do |t|
    t.integer  "scoresheet_id",                    :null => false
    t.integer  "position"
    t.string   "name",                             :null => false
    t.string   "email",                            :null => false
    t.string   "key",                              :null => false
    t.boolean  "accepted",      :default => false, :null => false
    t.boolean  "declined",      :default => false, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "participants", ["key"], :name => "index_participants_on_key", :unique => true
  add_index "participants", ["scoresheet_id", "email"], :name => "index_participants_on_scoresheet_id_and_email", :unique => true
  add_index "participants", ["scoresheet_id", "name"], :name => "index_participants_on_scoresheet_id_and_name", :unique => true

  create_table "scoresheets", :force => true do |t|
    t.integer  "user_id",                               :null => false
    t.string   "name",                                  :null => false
    t.datetime "deadline",                              :null => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.text     "message"
    t.boolean  "consolation",        :default => false, :null => false
    t.decimal  "consolation_points"
  end

  add_index "scoresheets", ["user_id", "name"], :name => "index_scoresheets_on_user_id_and_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name",                   :default => "", :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
