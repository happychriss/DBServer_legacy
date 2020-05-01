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

ActiveRecord::Schema.define(:version => 20200426202452) do

  create_table "connectors", :force => true do |t|
    t.integer  "uid"
    t.string   "service"
    t.integer  "prio"
    t.string   "uri"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "covers", :force => true do |t|
    t.integer  "folder_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "counter"
  end

  create_table "documents", :force => true do |t|
    t.string   "comment"
    t.integer  "status",          :default => 0,     :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "first_page_only", :default => false, :null => false
    t.integer  "page_count",      :default => 0,     :null => false
    t.date     "delete_at"
    t.boolean  "no_delete"
    t.boolean  "complete_pdf",    :default => false
    t.integer  "folder_id"
    t.integer  "cover_id"
    t.boolean  "delta",           :default => true,  :null => false
  end

  add_index "documents", ["delta"], :name => "index_documents_on_delta"

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "cover_ind"
    t.string   "short_name"
  end

  create_table "logs", :force => true do |t|
    t.string   "source"
    t.string   "message"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "messagetype"
  end

  create_table "pages", :force => true do |t|
    t.integer  "org_folder_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "original_filename"
    t.integer  "source"
    t.text     "content"
    t.integer  "document_id"
    t.integer  "position",          :default => 0,     :null => false
    t.integer  "status",            :default => 0,     :null => false
    t.boolean  "backup",            :default => false, :null => false
    t.integer  "org_cover_id"
    t.integer  "fid"
    t.string   "mime_type"
    t.boolean  "ocr",               :default => false
    t.boolean  "pdf_exists",        :default => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", :limit => 20
    t.integer  "tagger_id"
    t.string   "tagger_type",   :limit => 20
    t.string   "context",       :limit => 50
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

end
