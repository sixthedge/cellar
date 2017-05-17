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

ActiveRecord::Schema.define(version: 20170517190910) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.string   "tagger_type"
    t.integer  "tagger_id"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context", using: :btree
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "thinkspace_builder_templates", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.string   "templateable_type"
    t.integer  "templateable_id"
    t.boolean  "domain",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "value"
  end

  create_table "thinkspace_casespace_assignment_types", force: :cascade do |t|
    t.string   "title"
    t.string   "path"
    t.string   "description"
    t.string   "img_src"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_casespace_assignments", force: :cascade do |t|
    t.integer  "space_id"
    t.string   "title"
    t.string   "name"
    t.string   "bundle_type"
    t.text     "description"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.json     "settings"
    t.integer  "assignment_type_id"
    t.index ["assignment_type_id"], name: "index_thinkspace_casespace_assignments_on_assignment_type_id", using: :btree
    t.index ["space_id"], name: "idx_thinkspace_casespace_assignments_on_space", using: :btree
    t.index ["state"], name: "idx_thinkspace_casespace_assignments_on_state", using: :btree
  end

  create_table "thinkspace_casespace_case_manager_templates", force: :cascade do |t|
    t.string   "templateable_type"
    t.integer  "templateable_id"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_casespace_phase_components", force: :cascade do |t|
    t.integer  "component_id"
    t.integer  "phase_id"
    t.string   "componentable_type"
    t.integer  "componentable_id"
    t.string   "section"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["component_id"], name: "idx_thinkspace_casespace_phase_components_on_component", using: :btree
    t.index ["phase_id"], name: "idx_thinkspace_casespace_phase_components_on_phase", using: :btree
  end

  create_table "thinkspace_casespace_phase_scores", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "phase_state_id"
    t.decimal  "score",          precision: 9, scale: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["phase_state_id"], name: "idx_thinkspace_casespace_phase_scores_on_phase_state", using: :btree
    t.index ["user_id"], name: "idx_thinkspace_casespace_phase_scores_on_user", using: :btree
  end

  create_table "thinkspace_casespace_phase_states", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "phase_id"
    t.string   "ownerable_type"
    t.integer  "ownerable_id"
    t.string   "current_state"
    t.datetime "archived_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["archived_at"], name: "idx_thinkspace_casespace_phase_states_on_archived", using: :btree
    t.index ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_casespace_phase_states_on_ownerable", using: :btree
    t.index ["phase_id"], name: "idx_thinkspace_casespace_phase_states_on_phase", using: :btree
    t.index ["user_id"], name: "idx_thinkspace_casespace_phase_states_on_user", using: :btree
  end

  create_table "thinkspace_casespace_phase_templates", force: :cascade do |t|
    t.string   "title"
    t.string   "name"
    t.string   "description"
    t.boolean  "domain",      default: false
    t.text     "template"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "value"
  end

  create_table "thinkspace_casespace_phases", force: :cascade do |t|
    t.integer  "assignment_id"
    t.integer  "phase_template_id"
    t.integer  "team_category_id"
    t.string   "title"
    t.text     "description"
    t.integer  "position"
    t.string   "default_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.json     "settings"
    t.index ["assignment_id"], name: "idx_thinkspace_casespace_phases_on_assignment", using: :btree
    t.index ["phase_template_id"], name: "idx_thinkspace_casespace_phases_on_phase_template", using: :btree
    t.index ["state"], name: "idx_thinkspace_casespace_phases_on_state", using: :btree
  end

  create_table "thinkspace_common_agreements", force: :cascade do |t|
    t.string   "doc_type"
    t.datetime "effective_at"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_api_sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "idx_thinkspace_common_api_sessions_on_user", using: :btree
  end

  create_table "thinkspace_common_colors", force: :cascade do |t|
    t.string   "color"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "thinkspace_common_components", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.jsonb    "value"
    t.jsonb    "preprocessors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["title"], name: "idx_thinkspace_common_components_on_title", using: :btree
  end

  create_table "thinkspace_common_configurations", force: :cascade do |t|
    t.string   "configurable_type"
    t.integer  "configurable_id"
    t.jsonb    "settings",          default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["configurable_id", "configurable_type"], name: "idx_thinkspace_common_configurations_on_configurable", using: :btree
  end

  create_table "thinkspace_common_disciplines", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_institution_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "institution_id"
    t.string   "role"
    t.string   "state"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["institution_id"], name: "index_thinkspace_common_institution_users_on_institution_id", using: :btree
    t.index ["state"], name: "idx_thinkspace_common_institution_users_on_state", using: :btree
    t.index ["user_id"], name: "index_thinkspace_common_institution_users_on_user_id", using: :btree
  end

  create_table "thinkspace_common_institutions", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "state"
    t.json     "info"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["state"], name: "idx_thinkspace_common_institutions_on_state", using: :btree
    t.index ["title"], name: "idx_thinkspace_common_institutions_on_title", using: :btree
  end

  create_table "thinkspace_common_invitations", force: :cascade do |t|
    t.string   "invitable_type"
    t.integer  "invitable_id"
    t.integer  "user_id"
    t.integer  "sender_id"
    t.string   "role"
    t.string   "token"
    t.string   "email"
    t.string   "state"
    t.datetime "expires_at"
    t.datetime "accepted_at"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_password_resets", force: :cascade do |t|
    t.string   "token"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_space_space_types", force: :cascade do |t|
    t.integer  "space_id"
    t.integer  "space_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["space_id"], name: "idx_thinkspace_common_space_space_types_on_space", using: :btree
    t.index ["space_type_id"], name: "idx_thinkspace_common_space_space_types_on_space_type", using: :btree
  end

  create_table "thinkspace_common_space_types", force: :cascade do |t|
    t.string   "title"
    t.string   "lookup_model"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_space_users", force: :cascade do |t|
    t.integer  "space_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.index ["space_id", "user_id"], name: "idx_thinkspace_common_space_users_on_space_user", using: :btree
    t.index ["state"], name: "idx_thinkspace_common_space_users_on_state", using: :btree
  end

  create_table "thinkspace_common_spaces", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.integer  "sandbox_space_id"
    t.integer  "institution_id"
    t.index ["institution_id"], name: "index_thinkspace_common_spaces_on_institution_id", using: :btree
    t.index ["state"], name: "idx_thinkspace_common_spaces_on_state", using: :btree
  end

  create_table "thinkspace_common_timetables", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "timeable_type"
    t.integer  "timeable_id"
    t.string   "ownerable_type"
    t.integer  "ownerable_id"
    t.datetime "release_at"
    t.datetime "due_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "unlock_at"
    t.datetime "unlocked_at"
    t.index ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_common_timetables_on_ownerable", using: :btree
    t.index ["timeable_id", "timeable_type"], name: "idx_thinkspace_common_timetables_on_timeable", using: :btree
  end

  create_table "thinkspace_common_user_disciplines", force: :cascade do |t|
    t.string   "user_type"
    t.integer  "user_id"
    t.string   "discipline_type"
    t.integer  "discipline_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_users", force: :cascade do |t|
    t.integer  "oauth_user_id"
    t.string   "oauth_access_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                 default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.string   "activation_token"
    t.datetime "activated_at"
    t.datetime "activation_expires_at"
    t.integer  "parent_id"
    t.boolean  "superuser",             default: false
    t.datetime "last_sign_in_at"
    t.boolean  "email_optin",           default: true
    t.jsonb    "profile",               default: {}
    t.datetime "terms_accepted_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.index ["email"], name: "idx_thinkspace_common_users_on_email", using: :btree
    t.index ["parent_id"], name: "idx_thinkspace_common_users_on_parent_id", using: :btree
  end

  create_table "thinkspace_importer_files", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "importable_type"
    t.integer  "importable_id"
    t.string   "custom_url"
    t.string   "generated_model"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.json     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "idx_thinkspace_importer_files_on_user", using: :btree
  end

  create_table "thinkspace_peer_assessment_assessment_templates", force: :cascade do |t|
    t.string   "ownerable_type"
    t.integer  "ownerable_id"
    t.json     "value"
    t.string   "title"
    t.text     "description"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_peer_assessment_assessments", force: :cascade do |t|
    t.string   "authable_type"
    t.integer  "authable_id"
    t.string   "state"
    t.json     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_template_id"
  end

  create_table "thinkspace_peer_assessment_review_sets", force: :cascade do |t|
    t.string   "ownerable_type"
    t.integer  "ownerable_id"
    t.integer  "team_set_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_peer_assessment_reviews", force: :cascade do |t|
    t.string   "state"
    t.json     "value"
    t.string   "reviewable_type"
    t.integer  "reviewable_id"
    t.integer  "review_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_peer_assessment_team_sets", force: :cascade do |t|
    t.integer  "assessment_id"
    t.integer  "team_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_pub_sub_server_events", force: :cascade do |t|
    t.string   "authable_type"
    t.integer  "authable_id"
    t.integer  "user_id"
    t.string   "state"
    t.string   "origin"
    t.string   "channel"
    t.string   "event"
    t.string   "room_event"
    t.jsonb    "rooms"
    t.json     "value"
    t.json     "records"
    t.json     "timer_settings"
    t.datetime "timer_start_at"
    t.datetime "timer_end_at"
    t.datetime "timer_cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["authable_id", "authable_type"], name: "idx_thinkspace_pub_sub_server_events_on_authable", using: :btree
    t.index ["channel"], name: "idx_thinkspace_pub_sub_server_events_on_channel", using: :btree
    t.index ["created_at"], name: "idx_thinkspace_pub_sub_server_events_on_created_at", using: :btree
    t.index ["event"], name: "idx_thinkspace_pub_sub_server_events_on_event", using: :btree
    t.index ["room_event"], name: "idx_thinkspace_pub_sub_server_events_on_room_event", using: :btree
    t.index ["rooms"], name: "idx_thinkspace_pub_sub_server_events_on_rooms", using: :gin
    t.index ["state"], name: "idx_thinkspace_pub_sub_server_events_on_state", using: :btree
    t.index ["timer_end_at"], name: "idx_thinkspace_pub_sub_server_events_on_end_at", using: :btree
    t.index ["user_id"], name: "idx_thinkspace_pub_sub_server_events_on_user", using: :btree
  end

  create_table "thinkspace_readiness_assurance_assessments", force: :cascade do |t|
    t.string   "authable_type"
    t.integer  "authable_id"
    t.integer  "user_id"
    t.string   "title"
    t.string   "state"
    t.json     "settings"
    t.json     "questions"
    t.json     "answers"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["authable_id", "authable_type"], name: "idx_thinkspace_readiness_assurance_assessments_on_authable", using: :btree
    t.index ["state"], name: "idx_thinkspace_readiness_assurance_assessments_on_state", using: :btree
  end

  create_table "thinkspace_readiness_assurance_chats", force: :cascade do |t|
    t.integer  "response_id"
    t.json     "messages"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["response_id"], name: "idx_thinkspace_readiness_assurance_chats_on_response", using: :btree
  end

  create_table "thinkspace_readiness_assurance_responses", force: :cascade do |t|
    t.integer  "assessment_id"
    t.string   "ownerable_type"
    t.integer  "ownerable_id"
    t.integer  "user_id"
    t.decimal  "score",          precision: 9, scale: 3
    t.json     "settings"
    t.json     "answers"
    t.json     "justifications"
    t.json     "userdata"
    t.json     "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["assessment_id"], name: "idx_thinkspace_readiness_assurance_responses_on_assessment", using: :btree
    t.index ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_readiness_assurance_responses_on_ownerable", using: :btree
  end

  create_table "thinkspace_readiness_assurance_statuses", force: :cascade do |t|
    t.integer  "response_id"
    t.json     "settings"
    t.json     "questions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["response_id"], name: "idx_thinkspace_readiness_assurance_statuses_on_response", using: :btree
  end

  create_table "thinkspace_report_files", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "report_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "idx_thinkspace_report_files_on_user", using: :btree
  end

  create_table "thinkspace_report_report_tokens", force: :cascade do |t|
    t.string   "token"
    t.datetime "expires_at"
    t.integer  "report_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["report_id"], name: "idx_thinkspace_report_report_tokens_on_report", using: :btree
    t.index ["token"], name: "idx_thinkspace_report_report_tokens_on_token", using: :btree
    t.index ["user_id"], name: "idx_thinkspace_report_report_tokens_on_user", using: :btree
  end

  create_table "thinkspace_report_reports", force: :cascade do |t|
    t.string   "title"
    t.integer  "user_id"
    t.string   "authable_type"
    t.integer  "authable_id"
    t.json     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["authable_type", "authable_id"], name: "idx_thinkspace_report_reports_on_authable", using: :btree
    t.index ["user_id"], name: "idx_thinkspace_report_reports_on_user", using: :btree
  end

  create_table "thinkspace_resource_file_tags", force: :cascade do |t|
    t.integer  "file_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["file_id"], name: "idx_thinkspace_resource_file_tags_on_file", using: :btree
    t.index ["tag_id"], name: "idx_thinkspace_resource_file_tags_on_tag", using: :btree
  end

  create_table "thinkspace_resource_files", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "resourceable_type"
    t.integer  "resourceable_id"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_fingerprint"
    t.index ["resourceable_id", "resourceable_type"], name: "idx_thinkspace_resource_files_on_resourceable", using: :btree
    t.index ["user_id"], name: "idx_thinkspace_resource_files_on_user", using: :btree
  end

  create_table "thinkspace_resource_link_tags", force: :cascade do |t|
    t.integer  "link_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["link_id"], name: "idx_thinkspace_resource_link_tags_on_link", using: :btree
    t.index ["tag_id"], name: "idx_thinkspace_resource_link_tags_on_tag", using: :btree
  end

  create_table "thinkspace_resource_links", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "resourceable_type"
    t.integer  "resourceable_id"
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["resourceable_id", "resourceable_type"], name: "idx_thinkspace_resource_links_on_resourceable", using: :btree
    t.index ["user_id"], name: "idx_thinkspace_resource_links_on_user", using: :btree
  end

  create_table "thinkspace_resource_tags", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["taggable_id", "taggable_type"], name: "idx_thinkspace_resource_tags_on_taggable", using: :btree
    t.index ["user_id"], name: "idx_thinkspace_resource_tags_on_user", using: :btree
  end

  create_table "thinkspace_team_team_categories", force: :cascade do |t|
    t.string   "title"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category"], name: "idx_thinkspace_team_team_categories_on_category", using: :btree
  end

  create_table "thinkspace_team_team_set_teamables", force: :cascade do |t|
    t.integer  "team_set_id"
    t.string   "teamable_type"
    t.integer  "teamable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["team_set_id"], name: "idx_thinkspace_team_team_set_teamables_on_team_set", using: :btree
    t.index ["teamable_id", "teamable_type"], name: "idx_thinkspace_team_team_set_teamables_on_teamable", using: :btree
  end

  create_table "thinkspace_team_team_sets", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "space_id"
    t.integer  "user_id"
    t.boolean  "default"
    t.json     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.jsonb    "scaffold",    default: {"teams"=>[]}
    t.jsonb    "transform",   default: {}
    t.index ["space_id"], name: "idx_thinkspace_team_team_sets_on_space", using: :btree
  end

  create_table "thinkspace_team_team_teamables", force: :cascade do |t|
    t.integer  "team_id"
    t.string   "teamable_type"
    t.integer  "teamable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["team_id"], name: "idx_thinkspace_team_team_teamables_on_team", using: :btree
    t.index ["teamable_id", "teamable_type"], name: "idx_thinkspace_team_team_teamables_on_teamable", using: :btree
  end

  create_table "thinkspace_team_team_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "team_id"], name: "idx_thinkspace_team_team_users_on_user_team", using: :btree
  end

  create_table "thinkspace_team_team_viewers", force: :cascade do |t|
    t.integer  "team_id"
    t.string   "viewerable_type"
    t.integer  "viewerable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["team_id"], name: "idx_thinkspace_team_team_viewers_on_team", using: :btree
    t.index ["viewerable_id", "viewerable_type"], name: "idx_thinkspace_team_team_viewers_on_viewerable", using: :btree
  end

  create_table "thinkspace_team_teams", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "color"
    t.string   "state"
    t.string   "authable_type"
    t.integer  "authable_id"
    t.integer  "team_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["authable_id", "authable_type"], name: "idx_thinkspace_team_teams_on_authable", using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

end
