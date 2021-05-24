class AddParentNameToAssessmentAttribute < ActiveRecord::Migration[6.1]
  def change
    add_column :assessment_attributes, :parent_name, :string
    add_index :assessment_attributes, :parent_name
  end
end
