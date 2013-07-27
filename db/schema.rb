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

ActiveRecord::Schema.define(:version => 20130726220922) do

  create_table "activities", :force => true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "activities", ["owner_id", "owner_type"], :name => "index_activities_on_owner_id_and_owner_type"
  add_index "activities", ["recipient_id", "recipient_type"], :name => "index_activities_on_recipient_id_and_recipient_type"
  add_index "activities", ["trackable_id", "trackable_type"], :name => "index_activities_on_trackable_id_and_trackable_type"

  create_table "adherents", :force => true do |t|
    t.string   "full_name",                            :null => false
    t.string   "username"
    t.string   "email",                                :null => false
    t.string   "state",         :default => "created"
    t.boolean  "rezoman",       :default => false
    t.boolean  "externe",       :default => false
    t.boolean  "supelec",       :default => false
    t.boolean  "archived",      :default => false
    t.string   "password_salt",                        :null => false
    t.string   "password_hash",                        :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "admins", :force => true do |t|
    t.string   "password_hash",                    :null => false
    t.string   "password_salt",                    :null => false
    t.string   "username",                         :null => false
    t.integer  "adherent_id"
    t.boolean  "archived",      :default => false
    t.datetime "last_login"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "alias_dns_entries", :force => true do |t|
    t.string   "name",                                     :null => false
    t.integer  "computer_dns_entry_id",                    :null => false
    t.boolean  "archived",              :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "computer_dns_entries", :force => true do |t|
    t.string   "name",                           :null => false
    t.integer  "computer_id",                    :null => false
    t.boolean  "archived",    :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "computers", :force => true do |t|
    t.string   "mac_address",                    :null => false
    t.integer  "adherent_id"
    t.string   "ip_address",                     :null => false
    t.boolean  "archived",    :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "connexions", :force => true do |t|
    t.integer  "vlan_id"
    t.integer  "port_id"
    t.boolean  "tagged",     :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "credits", :force => true do |t|
    t.float    "value",       :default => 0.0
    t.date     "next_debit",  :default => '2013-07-27'
    t.boolean  "archived",    :default => false
    t.integer  "adherent_id",                           :null => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "generic_dns_entries", :force => true do |t|
    t.string   "type",                          :null => false
    t.string   "name",                          :null => false
    t.string   "return",                        :null => false
    t.boolean  "external",   :default => false
    t.boolean  "archived",   :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "mailings", :force => true do |t|
    t.string   "name",                           :null => false
    t.text     "emails",                         :null => false
    t.integer  "adherent_id"
    t.boolean  "system",      :default => false
    t.boolean  "archived",    :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "payments", :force => true do |t|
    t.float    "value",       :default => 0.0
    t.float    "paid_value",  :default => 0.0
    t.string   "mean",                           :null => false
    t.string   "bank_name"
    t.text     "comment"
    t.boolean  "archived",    :default => false
    t.string   "state"
    t.datetime "cashed_date"
    t.integer  "credit_id",                      :null => false
    t.integer  "admin_id",                       :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "ports", :force => true do |t|
    t.integer  "number"
    t.integer  "switch_id",                     :null => false
    t.boolean  "archived",   :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "rooms", :force => true do |t|
    t.string   "building",    :limit => 1,                    :null => false
    t.string   "number",                                      :null => false
    t.integer  "adherent_id"
    t.integer  "port_id"
    t.boolean  "archived",                 :default => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "rooms", ["number", "building"], :name => "index_rooms_on_number_and_building"

  create_table "settings", :force => true do |t|
    t.string   "var",                      :null => false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", :limit => 30
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], :name => "index_settings_on_thing_type_and_thing_id_and_var", :unique => true

  create_table "switches", :force => true do |t|
    t.string   "community",                     :null => false
    t.string   "ip_admin",                      :null => false
    t.boolean  "archived",   :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "vlans", :force => true do |t|
    t.integer  "number"
    t.string   "name"
    t.boolean  "archived",   :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

end
