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

ActiveRecord::Schema.define(:version => 20120608135101) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
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

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "devices", :force => true do |t|
    t.string   "kind"
    t.string   "manufacturer"
    t.string   "model"
    t.string   "serial_number"
    t.string   "asset_tag"
    t.string   "status",             :default => "Active"
    t.integer  "purchase_record_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "devices", ["purchase_record_id"], :name => "index_devices_on_purchase_record_id"

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "status",     :default => "Active"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "networks", :force => true do |t|
    t.string   "network_identifier"
    t.string   "network_mask"
    t.string   "default_gateway"
    t.integer  "location_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "networks", ["location_id"], :name => "index_networks_on_location_id"

  create_table "personalities", :force => true do |t|
    t.string   "name"
    t.string   "ip"
    t.integer  "device_id"
    t.integer  "network_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.date     "last_seen"
  end

  add_index "personalities", ["device_id", "network_id"], :name => "index_personalities_on_device_id_and_network_id"

  create_table "personalities_vulnerabilities", :id => false, :force => true do |t|
    t.integer "personality_id"
    t.integer "vulnerability_id"
  end

  add_index "personalities_vulnerabilities", ["personality_id", "vulnerability_id"], :name => "index_personalities_vulnerabilities"

  create_table "purchase_records", :force => true do |t|
    t.text     "description"
    t.date     "purchased",   :default => '2012-06-07'
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "vulnerabilities", :force => true do |t|
    t.string   "qid"
    t.string   "severity"
    t.string   "title"
    t.date     "last_update"
    t.text     "diagnosis"
    t.text     "consequence"
    t.text     "solution"
    t.boolean  "pci"
    t.boolean  "fixable"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
