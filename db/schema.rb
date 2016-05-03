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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160426211921) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.integer  "start_time"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                limit: 255
    t.string   "day",                 limit: 255
    t.string   "gist_url",            limit: 255
    t.text     "instructions"
    t.text     "teacher_notes"
    t.string   "file_name",           limit: 255
    t.boolean  "allow_submissions",               default: true
    t.string   "media_filename",      limit: 255
    t.string   "revisions_gistid",    limit: 255
    t.integer  "code_review_percent",             default: 60
    t.boolean  "allow_feedback",                  default: true
    t.integer  "section_id"
  end

  create_table "activity_messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "cohort_id"
    t.integer  "activity_id"
    t.string   "kind",          limit: 50
    t.string   "day",           limit: 5
    t.string   "subject",       limit: 1000
    t.text     "body"
    t.text     "teacher_notes"
    t.boolean  "for_students"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_messages", ["activity_id"], name: "index_activity_messages_on_activity_id", using: :btree
  add_index "activity_messages", ["cohort_id"], name: "index_activity_messages_on_cohort_id", using: :btree
  add_index "activity_messages", ["user_id"], name: "index_activity_messages_on_user_id", using: :btree

  create_table "activity_submissions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.datetime "completed_at"
    t.string   "github_url",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "finalized",                default: false
    t.text     "data"
  end

  add_index "activity_submissions", ["activity_id"], name: "index_activity_submissions_on_activity_id", using: :btree
  add_index "activity_submissions", ["user_id"], name: "index_activity_submissions_on_user_id", using: :btree

  create_table "activity_tests", force: :cascade do |t|
    t.text    "test"
    t.integer "activity_id"
  end

  create_table "assistance_requests", force: :cascade do |t|
    t.integer  "requestor_id"
    t.integer  "assistor_id"
    t.datetime "start_at"
    t.datetime "assistance_start_at"
    t.datetime "assistance_end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assistance_id"
    t.datetime "canceled_at"
    t.string   "type",                   limit: 255
    t.integer  "activity_submission_id"
    t.text     "reason"
  end

  add_index "assistance_requests", ["activity_submission_id"], name: "index_assistance_requests_on_activity_submission_id", using: :btree

  create_table "assistances", force: :cascade do |t|
    t.integer  "assistor_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assistee_id"
    t.integer  "rating"
    t.text     "student_notes"
    t.boolean  "imported",      default: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "code_reviews", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cohorts", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.string   "code",                limit: 255
    t.string   "teacher_email_group", limit: 255
    t.integer  "program_id"
    t.integer  "location_id"
  end

  add_index "cohorts", ["program_id"], name: "index_cohorts_on_program_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type", limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "day_feedbacks", force: :cascade do |t|
    t.string   "mood",                limit: 255
    t.string   "title",               limit: 255
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "day",                 limit: 255
    t.datetime "archived_at"
    t.integer  "archived_by_user_id"
    t.text     "notes"
  end

  create_table "day_infos", force: :cascade do |t|
    t.string   "day",         limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "evaluations", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "student_id"
    t.integer  "teacher_id"
    t.boolean  "accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "url"
    t.text     "notes"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "teacher_id"
    t.integer  "technical_rating"
    t.integer  "style_rating"
    t.text     "notes"
    t.integer  "feedbackable_id"
    t.string   "feedbackable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rating"
  end

  create_table "item_outcomes", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "outcome_id"
    t.integer  "activity_id"
    t.string   "item_type"
    t.integer  "item_id"
  end

  add_index "item_outcomes", ["item_id"], name: "index_item_outcomes_on_item_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "calendar",         limit: 255
    t.string   "timezone",         limit: 255
    t.boolean  "has_code_reviews",             default: true
  end

  create_table "outcome_results", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "outcome_id"
    t.string   "source_name"
    t.integer  "source_id"
    t.string   "source_type"
    t.float    "rating"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "outcome_results", ["outcome_id"], name: "index_outcome_results_on_outcome_id", using: :btree
  add_index "outcome_results", ["source_type", "source_id"], name: "index_outcome_results_on_source_type_and_source_id", using: :btree
  add_index "outcome_results", ["user_id"], name: "index_outcome_results_on_user_id", using: :btree

  create_table "outcome_skills", force: :cascade do |t|
    t.integer "outcome_id"
    t.integer "skill_id"
  end

  create_table "outcomes", force: :cascade do |t|
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "skill_id"
  end

  add_index "outcomes", ["skill_id"], name: "index_outcomes_on_skill_id", using: :btree

  create_table "programs", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.text     "lecture_tips"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recordings_folder", limit: 255
    t.string   "recordings_bucket", limit: 255
    t.string   "tag",               limit: 255
  end

  create_table "recordings", force: :cascade do |t|
    t.string   "file_name",      limit: 255
    t.datetime "recorded_at"
    t.integer  "presenter_id"
    t.integer  "cohort_id"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "program_id"
    t.string   "title",          limit: 255
    t.string   "presenter_name", limit: 255
  end

  create_table "sections", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "order"
    t.text     "description"
    t.string   "type"
  end

  create_table "skills", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "category_id"
  end

  add_index "skills", ["category_id"], name: "index_skills_on_category_id", using: :btree

  create_table "streams", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "description", limit: 255
    t.string   "wowza_id",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "email",                  limit: 255
    t.string   "phone_number",           limit: 255
    t.string   "twitter",                limit: 255
    t.string   "skype",                  limit: 255
    t.string   "uid",                    limit: 255
    t.string   "token",                  limit: 255
    t.boolean  "completed_registration"
    t.string   "github_username",        limit: 255
    t.string   "avatar_url",             limit: 255
    t.integer  "cohort_id"
    t.string   "type",                   limit: 255
    t.string   "custom_avatar",          limit: 255
    t.string   "unlocked_until_day",     limit: 255
    t.datetime "last_assisted_at"
    t.datetime "deactivated_at"
    t.string   "slack",                  limit: 255
    t.boolean  "remote",                             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code_review_percent",                default: 80
    t.boolean  "admin",                              default: false, null: false
    t.string   "company_name",           limit: 255
    t.string   "company_url",            limit: 255
    t.text     "bio"
    t.string   "quirky_fact",            limit: 255
    t.string   "specialties",            limit: 255
    t.integer  "location_id"
    t.boolean  "on_duty",                            default: false
    t.integer  "mentor_id"
    t.boolean  "mentor",                             default: false
  end

  add_index "users", ["cohort_id"], name: "index_users_on_cohort_id", using: :btree

  add_foreign_key "outcome_results", "outcomes"
  add_foreign_key "outcome_results", "users"
end
