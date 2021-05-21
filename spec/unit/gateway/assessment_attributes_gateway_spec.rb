describe Gateway::AssessmentAttributesGateway do
  context "when there are no attributes reseed the table and insert test data" do
    let(:gateway) { Gateway::AssessmentAttributesGateway.new }

    before(:each) do
      ActiveRecord::Base.connection.reset_pk_sequence!("assessment_attributes")
      gateway.add_attribute("test")
      gateway.add_attribute("test1")
    end

    let(:attributes) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_attributes",
      )
    end

    let(:attribute_values) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_attribute_values",
      )
    end

    it "returns a row from the database for each inserted value " do
      expect(attributes.rows.length).to eq(2)
      expect(attributes.rows[0]).to eq([1, "test"])
      expect(attributes.rows[1]).to eq([2, "test1"])
    end

    it "does not return an additional row where a duplication has been entered" do
      expect(gateway.add_attribute("test")).to eq(1)
      expect(attributes.rows.length).to eq(2)
    end

    it "can access the id of the insert regardless of whether it is created or not" do
      expect(gateway.add_attribute("new one")).to eq(3)
    end

    it "inserts the attribute value into the database" do
      gateway.add_attribute_value("0000-0000-0000-0000-0001", "a", "b")
      expect(attribute_values.rows.length).to eq(1)
      expect(attribute_values.first["assessment_id"]).to eq(
        "0000-0000-0000-0000-0001",
      )
      expect(attribute_values.first["attribute_value"]).to eq("b")
      expect(attribute_values.first["attribute_id"]).to eq(3)
      expect(attribute_values.first["attribute_value_int"]).to be_nil
      expect(attribute_values.first["attribute_value_float"]).to be_nil
    end

    context "when we insert many attributes for one assessment" do
      before do
        gateway.add_attribute_value(
          "0000-0000-0000-0000-0001",
          "construction_age_band",
          "England and Wales: 2007-2011",
        )
        gateway.add_attribute_value(
          "0000-0000-0000-0000-0001",
          "glazed_type",
          "test",
        )
        gateway.add_attribute_value(
          "0000-0000-0000-0000-0001",
          "current_energy_efficiency",
          "50",
        )

        gateway.add_attribute_value(
          "0000-0000-0000-0000-0001",
          "heating_cost_current",
          "365.98",
        )
      end

      let(:assessement_attribute_values) do
        ActiveRecord::Base.connection.exec_query(
          "SELECT * FROM assessment_attribute_values WHERE assessment_id= '0000-0000-0000-0000-0001'
          ORDER BY attribute_id",
        )
      end

      it "returns a row for every attributes" do
        expect(assessement_attribute_values.rows.length).to eq(4)
      end

      it "row 3 will have a value in the integer column for the current_energy_efficiency" do
        expect(assessement_attribute_values[2]["attribute_value_int"]).to eq(50)
      end

      it "row 4 will have a value in the float column for the heating_cost_current" do
        expect(assessement_attribute_values[3]["attribute_value_int"]).to eq(
          365,
        )
        expect(assessement_attribute_values[3]["attribute_value_float"]).to eq(
          365.98,
        )
      end
    end

    context "when we insert the same attribute for many assessments" do
      before do
        gateway.add_attribute_value(
          "0000-0000-0000-0000-0001",
          "glazed_type",
          "another test",
        )
        gateway.add_attribute_value(
          "0000-0000-0000-0000-0002",
          "glazed_type",
          "test",
        )
      end

      it "the attribute table only increments by one" do
        expect(attributes.rows.length).to eq(3)
      end

      it "the attribute value table has two rows" do
        expect(attribute_values.rows.length).to eq(2)
      end
    end

    context "when we add multiple attributes for 3 assessments" do
      before do
        gateway.add_attribute_value(
          "0000-0000-0000-0000-0001",
          "construction_age_band",
          "England and Wales: 2007-2011",
        )
        gateway.add_attribute_value(
          "0000-0000-0000-0000-0001",
          "glazed_type",
          "test 1",
        )

        gateway.add_attribute_value(
          "0000-0000-0000-0000-0001",
          "heating_cost_current",
          "10.98",
        )

        gateway.add_attribute_value(
          "0000-0000-0000-0000-0002",
          "construction_age_band",
          "England: 1865",
        )

        gateway.add_attribute_value(
          "0000-0000-0000-0000-0002",
          "current_energy_efficiency",
          "40",
        )

        gateway.add_attribute_value(
          "0000-0000-0000-0000-0002",
          "heating_cost_current",
          "12.55",
        )

        gateway.add_attribute_value(
          "0000-0000-0000-0000-0003",
          "construction_age_band",
          "England and Wales: 1971-1987",
        )
        gateway.add_attribute_value(
          "0000-0000-0000-0000-0003",
          "glazed_type",
          "test 3",
        )

        gateway.add_attribute_value(
          "0000-0000-0000-0000-0003",
          "heating_cost_current",
          "9.45",
        )
      end

      let(:assessement_attribute_values) do
        ActiveRecord::Base.connection.exec_query(
          "SELECT * FROM assessment_attribute_values",
        )
      end

      it "returns 4 rows for the 2nd assessments" do
        expect(assessement_attribute_values.rows.count).to eq(9)
      end

      context "when fetching the pivoted data" do
        let(:pivoted_data) do
          gateway.fetch_assessment_attributes(
            %w[construction_age_band glazed_type],
          )
        end

        it "has the correct number of rows, one for each assessment" do
          expect(pivoted_data.count).to eq(3)
        end

        it "has the correct assessments" do
          expect(pivoted_data[0]["assessment_id"]).to eq(
            "0000-0000-0000-0000-0001",
          )
          expect(pivoted_data[1]["assessment_id"]).to eq(
            "0000-0000-0000-0000-0002",
          )
          expect(pivoted_data[2]["assessment_id"]).to eq(
            "0000-0000-0000-0000-0003",
          )
        end

        it "has a single column for each of the attributes with the relevant values" do
          expect(pivoted_data[0]["construction_age_band"]).to eq(
            "England and Wales: 2007-2011",
          )
          expect(pivoted_data[1]["construction_age_band"]).to eq(
            "England: 1865",
          )
          expect(pivoted_data[2]["construction_age_band"]).to eq(
            "England and Wales: 1971-1987",
          )
        end

        it "can perform simple data aggregations by calculating the sum and average of 'heating_cost_current' " do
          expect(gateway.fetch_sum("heating_cost_current", "float")).to eq(
            32.98,
          )
        end

        it "can perform simple data aggregations by calculating the sum and average of 'heating_cost_current' " do
          expect(
            gateway.fetch_average("heating_cost_current", "float").to_f,
          ).to eq(10.99)
        end
      end

      context "when fetching the pivoted data based on the value of an attribute" do
        let(:pivoted_data) do
          gateway.fetch_assessment_attributes(
            %w[construction_age_band glazed_type],
            { heating_cost_current: "9.45" },
          )
        end

        it "returns only the row for the assessments with that attibute" do
          expect(pivoted_data.count).to eq(1)
          expect(pivoted_data[0]["assessment_id"]).to eq(
            "0000-0000-0000-0000-0003",
          )
        end
      end

      context "when we delete attribute values for a single assessment" do
        before do
          gateway.delete_attributes_by_assessment("0000-0000-0000-0000-0002")
        end

        it "there are no attributes for that assessment  " do
          expect(
            ActiveRecord::Base
              .connection
              .exec_query(
                "SELECT * FROM assessment_attribute_values WHERE assessment_id ='0000-0000-0000-0000-0002'",
              )
              .rows
              .count,
          ).to eq(0)
        end

        it "there are attributes for other assessments " do
          expect(
            ActiveRecord::Base
              .connection
              .exec_query(
                "SELECT * FROM assessment_attribute_values WHERE assessment_id ='0000-0000-0000-0000-0001'",
              )
              .rows
              .count,
          ).not_to eq(0)
        end
      end

      context "when adding duplicate assessment attribute values" do
      end
    end

    context "when we pass an enum value as a hash to the assessment attributes" do
      let(:assessement_attribute_values) do
        ActiveRecord::Base
          .connection
          .exec_query(
            "SELECT * FROM assessment_attribute_values
          WHERE assessment_id= '0000-0000-0000-0000-0001'
          ",
          )
          .first
      end

      it "returns the description and int value in the assessment_attribute_values table w" do
        gateway.add_attribute_value(
          "0000-0000-0000-0000-0001",
          "transaction_type",
          { "description": "marketed sale", "value": "1" },
        )
        expect(assessement_attribute_values["attribute_value"]).to eq(
          "marketed sale",
        )
        expect(assessement_attribute_values["attribute_value_int"]).to eq(1)
      end

      it "returns the description and int value in the assessment_attribute_values table" do
        gateway.add_attribute_value(
          "0000-0000-0000-0000-0001",
          "transaction_type",
          { "description": "marketed sale", "value": "10.0" },
        )
        expect(assessement_attribute_values["attribute_value"]).to eq(
          "marketed sale",
        )
        expect(assessement_attribute_values["attribute_value_int"]).to eq(10)
      end
    end
  end
end
