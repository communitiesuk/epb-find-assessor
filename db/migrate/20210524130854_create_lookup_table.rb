class CreateLookupTable < ActiveRecord::Migration[6.1]
  def change
    create_table :assessment_look_ups do |t|
      t.string   :look_up_name, null: false, index: true
      t.string   :look_up_value, null: false, index: true
      t.integer  :attribute_id, null: false, index: true
      t.string   :schema, null: false
      t.string   :schema_version, null: true
    end
  end
end
