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

ActiveRecord::Schema.define(:version => 20130208193322) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth"
    t.datetime "oauth_expires_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "instructables", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "approved",                  :default => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "location"
    t.string   "name"
    t.integer  "material_limit"
    t.integer  "handout_limit"
    t.text     "description_web"
    t.integer  "handout_fee"
    t.integer  "material_fee"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.float    "duration"
    t.string   "culture"
    t.string   "topic"
    t.string   "subtopic"
    t.text     "description_book"
    t.boolean  "location_camp",             :default => false
    t.string   "camp_name"
    t.string   "camp_address"
    t.string   "camp_reason"
    t.boolean  "adult_only",                :default => false
    t.string   "adult_reason"
    t.text     "fee_itemization"
    t.integer  "repeat_count",              :default => 0
    t.text     "scheduling_additional"
    t.text     "special_needs_description"
    t.boolean  "heat_source",               :default => false
    t.text     "heat_source_description"
    t.string   "additional_instructors",                                       :array => true
    t.date     "requested_days",                                               :array => true
    t.string   "special_needs",                                                :array => true
    t.string   "requested_times",                                              :array => true
    t.string   "tract"
  end

  create_table "instructor_profile_contacts", :force => true do |t|
    t.integer  "instructor_profile_id"
    t.string   "protocol"
    t.string   "address"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "instructor_profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "sca_name"
    t.string   "sca_title"
    t.string   "phone_number"
    t.string   "mundane_name"
    t.integer  "class_limit"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "kingdom"
    t.string   "phone_number_onsite"
    t.text     "contact_via"
    t.boolean  "no_contact",          :default => false
    t.date     "available_days",                                         :array => true
  end

  create_table "users", :force => true do |t|
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
    t.string   "name"
    t.string   "access_token"
    t.boolean  "admin",          :default => false
    t.string   "coordinator_tract"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
