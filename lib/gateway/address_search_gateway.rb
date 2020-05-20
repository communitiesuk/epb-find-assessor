module Gateway
  class AddressSearchGateway
    def search_by_postcode(postcode)
      postcode = postcode.delete " "

      results =
        ActiveRecord::Base.connection.exec_query(
          "SELECT
           assessment_id,
           address_line1,
           address_line2,
           address_line3,
           address_line4,
           town,
           postcode
         FROM assessments
         WHERE REPLACE(postcode, ' ', '') = $1",
          "SQL",
          [
            ActiveRecord::Relation::QueryAttribute.new(
              "postcode",
              postcode,
              ActiveRecord::Type::String.new,
            ),
          ],
        )

      results.map { |row| record_to_address_domain row }
    end

    def search_by_rrn(rrn)
      results =
        ActiveRecord::Base.connection.exec_query(
          'SELECT
           assessment_id,
           address_line1,
           address_line2,
           address_line3,
           address_line4,
           town,
           postcode
         FROM assessments
         WHERE assessment_id = $1',
          "SQL",
          [
            ActiveRecord::Relation::QueryAttribute.new(
              "rrn",
              rrn,
              ActiveRecord::Type::String.new,
            ),
          ],
        )

      results.map { |row| record_to_address_domain row }
    end

  private

    def record_to_address_domain(row)
      Domain::Address.new building_reference_number:
                            "RRN-#{row['assessment_id']}",
                          line1: row["address_line1"],
                          line2: row["address_line2"],
                          line3: row["address_line3"],
                          town: row["town"],
                          postcode: row["postcode"]
    end
  end
end
