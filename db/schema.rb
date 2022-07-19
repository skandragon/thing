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

ActiveRecord::Schema.define(version: 20210118001311) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider",         limit: 255
    t.string   "uid",              limit: 255
    t.string   "oauth",            limit: 255
    t.datetime "oauth_expires_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["user_id"], name: "index_authentications_on_user_id", using: :btree
  end

  create_table "changelogs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "action",      limit: 255
    t.integer  "target_id"
    t.string   "target_type", limit: 255
    t.text     "changelog"
    t.boolean  "notified",                default: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.text     "original"
    t.text     "committed"
    t.integer  "year"
  end

  create_table "instances", force: :cascade do |t|
    t.integer  "instructable_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "location",          limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "override_location"
    t.integer  "year"
    t.index ["instructable_id"], name: "index_instances_on_instructable_id", using: :btree
  end

  create_table "instructables", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "approved",                              default: false
    t.string   "name",                      limit: 255
    t.integer  "material_limit"
    t.integer  "handout_limit"
    t.text     "description_web"
    t.float    "handout_fee"
    t.float    "material_fee"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.float    "duration"
    t.string   "culture",                   limit: 255
    t.string   "topic",                     limit: 255
    t.string   "subtopic",                  limit: 255
    t.text     "description_book"
    t.string   "additional_instructors",    limit: 255,                                array: true
    t.string   "camp_name",                 limit: 255
    t.string   "camp_address",              limit: 255
    t.string   "camp_reason",               limit: 255
    t.boolean  "adult_only",                            default: false
    t.string   "adult_reason",              limit: 255
    t.text     "fee_itemization"
    t.date     "requested_days",                                                       array: true
    t.integer  "repeat_count",                          default: 0
    t.text     "scheduling_additional"
    t.string   "special_needs",             limit: 255,                                array: true
    t.text     "special_needs_description"
    t.boolean  "heat_source",                           default: false
    t.text     "heat_source_description"
    t.string   "requested_times",           limit: 255,                                array: true
    t.string   "track",                     limit: 255
    t.boolean  "scheduled",                             default: false
    t.string   "location_type",             limit: 255, default: "track"
    t.boolean  "proofread",                             default: false
    t.integer  "proofread_by",                          default: [],                   array: true
    t.text     "proofreader_comments"
    t.integer  "year"
    t.string   "schedule",                  limit: 255
    t.string   "info_tag",                  limit: 255
    t.boolean  "in_person_class",                       default: false
    t.boolean  "virtual_class",                         default: false
    t.boolean  "contingent_class",                      default: false
    t.boolean  "waiver_signed",                         default: false
    t.boolean  "check_schedule_later",                  default: false
  end

  create_table "instructor_profile_contacts", force: :cascade do |t|
    t.string   "protocol",   limit: 255
    t.string   "address",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id"
  end

  create_table "policies", force: :cascade do |t|
    t.string   "area"
    t.integer  "user_id"
    t.datetime "accepted_on"
    t.string   "version"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "mailed_on"
    t.index ["user_id"], name: "index_policies_on_user_id", using: :btree
  end

  create_table "schedules", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "instructables", default: [],                 array: true
    t.boolean  "published",     default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "year"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "mundane_name",           limit: 255
    t.string   "access_token",           limit: 255
    t.boolean  "admin",                              default: false
    t.boolean  "pu_staff"
    t.string   "tracks",                 limit: 255, default: [].to_yaml
    t.string   "sca_name",               limit: 255
    t.string   "sca_title",              limit: 255
    t.string   "phone_number",           limit: 255
    t.integer  "class_limit"
    t.string   "kingdom",                limit: 255
    t.string   "phone_number_onsite",    limit: 255
    t.text     "contact_via"
    t.boolean  "no_contact",                         default: false
    t.date     "available_days",                                                  array: true
    t.boolean  "instructor",                         default: false
    t.boolean  "proofreader",                        default: false
    t.datetime "profile_updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

end
