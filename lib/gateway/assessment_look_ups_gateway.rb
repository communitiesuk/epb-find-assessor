module Gateway
  class AssessmentLookUpsGateway
    def insert(attribute_id, name, value, schema, version = nil)
      insert_sql = <<-SQL
              INSERT INTO assessment_look_ups(look_up_name, look_up_value, attribute_id, schema,  schema_version)
              VALUES($1,$2,$3,$4,$5)
      SQL

      bindings = []

      bindings <<
        ActiveRecord::Relation::QueryAttribute.new(
          "look_up_name",
          name,
          ActiveRecord::Type::String.new,
        )

      bindings <<
        ActiveRecord::Relation::QueryAttribute.new(
          "look_up_value",
          value,
          ActiveRecord::Type::String.new,
        )

      bindings <<
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_id",
          attribute_id,
          ActiveRecord::Type::Integer.new,
        )

      bindings <<
        ActiveRecord::Relation::QueryAttribute.new(
          "schema",
          schema,
          ActiveRecord::Type::String.new,
        )

      bindings <<
        ActiveRecord::Relation::QueryAttribute.new(
          "version",
          version,
          ActiveRecord::Type::String.new,
        )

      ActiveRecord::Base.connection.insert(
        insert_sql,
        nil,
        nil,
        nil,
        nil,
        bindings,
      )
    end
  end
end
