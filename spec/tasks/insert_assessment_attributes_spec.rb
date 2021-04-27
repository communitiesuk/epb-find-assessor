describe "Rake::import_assessment_attributes" do
  include RSpecRegisterApiServiceMixin

  def num_rows
    2
  end

  xcontext "when we execute the rake to insert a single assessment's attribute" do
    before(:all) do
      EnvironmentStub.with("START", "1").with("END", num_rows.to_s)

      get_task("import_assessment_attributes").invoke
    end

    let(:inserted_data) do
      ActiveRecord::Base
        .connection
        .exec_query(
          "SELECT COUNT(*) as numRows FROM assessment_attribute_values ",
        )
        .first
    end

    let(:grouped_data) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT COUNT(assessment_id) FROM assessment_attribute_values GROUP BY assessment_id",
      )
    end

    it "the data has been inserted in the attributes" do
      expect(inserted_data["numrows"].to_i).to eq(80 * num_rows)
    end

    it "the data has been inserted in the attributes" do
      expect(grouped_data.rows.count).to eq(num_rows)
    end
  end
end
