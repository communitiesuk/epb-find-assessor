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

ActiveRecord::Schema.define(version: 2020_01_13_165013) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assessors", primary_key: "scheme_assessor_id", id: :string, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "middle_names"
    t.datetime "date_of_birth"
    t.bigint "registered_by"
    t.string "telephone_number"
    t.string "email"
    t.string "search_results_comparison_postcode"
    t.index ["registered_by"], name: "index_assessors_on_registered_by"
    t.index ["search_results_comparison_postcode"], name: "index_assessors_on_search_results_comparison_postcode"
  end

  create_table "domestic_energy_assessments", primary_key: "certificate_id", id: :string, force: :cascade do |t|
    t.datetime "date_of_assessment"
    t.datetime "date_registered"
    t.string "dwelling_type"
    t.string "type_of_assessment"
    t.bigint "total_floor_area"
    t.string "address_summary"
  end

  create_table "postcode_geolocation", force: :cascade do |t|
    t.string "postcode"
    t.decimal "latitude"
    t.decimal "longitude"
  end

  create_table "schemes", primary_key: "scheme_id", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_schemes_on_name", unique: true
  end

  add_foreign_key "assessors", "schemes", column: "registered_by", primary_key: "scheme_id"
end
