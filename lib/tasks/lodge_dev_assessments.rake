desc "Lodge assessments to the dev databse for testing"

task :lodge_dev_assessments do
  Tasks::TaskHelpers.quit_if_production

  scheme_id = DevAssessmentsHelper.add_rake_scheme
  DevAssessmentsHelper.add_assessor(scheme_id)
  DevAssessmentsHelper.clean_tables
  DevAssessmentsHelper.lodge_assessments(DevAssessmentsHelper.read_fixtures)
end

class DevAssessmentsHelper
  def self.scheme_array
    %w[CEPC-8.0.0 CEPC-NI-8.0.0 RdSAP-Schema-20.0.0 RdSAP-Schema-NI-20.0.0 SAP-Schema-18.0.0 SAP-Schema-NI-18.0.0]
  end

  def self.assessor_id
    "RAKE000001"
  end

  def self.commercial_fixtures
    %w[ac-cert ac-report cepc cepc-rr dec dec-rr]
  end

  def self.scheme_name
    "ecmk"
  end

  def self.clean_tables
    sql = <<-SQL
    DELETE FROM assessments_xml x
        USING assessments a WHERE a.assessment_id = x.assessment_id AND scheme_assessor_id =  '#{assessor_id}'
    SQL

    ActiveRecord::Base.connection.exec_query(sql, "SQL")
    ActiveRecord::Base.connection.exec_query("DELETE FROM assessments WHERE scheme_assessor_id =  '#{assessor_id}'", "SQL")
  end

  def self.lodge_assessments(file_array)
    use_case = UseCase::LodgeAssessment.new
    id = get_latest_assessment_id

    file_array.each_with_index do |hash, _index|
      id = id.next

      if commercial_fixtures.include? hash[:scheme].to_s.downcase
        schema_type = "CEPC-8.0.0"
        type_of_assessment =  hash[:scheme]
      else
        schema_type = hash[:scheme]
        type_of_assessment = schema_type&.split("-").first
      end
      xml_doc = update_xml(hash[:xml], type_of_assessment.downcase, id)
      data = { assessment_id: id,
               assessor_id: assessor_id,
               raw_data: Helper::SanitizeXmlHelper.new.sanitize(xml_doc.to_s),
               date_of_registration: DateTime.yesterday,
               type_of_assessment: type_of_assessment,
               date_of_assessment: Time.now,
               date_of_expiry: Time.now + 10.years,
               current_energy_efficiency_rating: 1,
               potential_energy_efficiency_rating: 1,
               address: { address_id: "UPRN-000000000001",
                          address_line1: "Some Unit",
                          address_line2: "2 Lonely Street",
                          address_line3: "Some Area",
                          address_line4: "",
                          town: "London",
                          postcode: "SW1A 2AA" } }

      begin
        use_case.execute(data, false, schema_type)
        pp "Lodged assessment ID:#{id}, Type: '#{type_of_assessment}', Schema: '#{schema_type}'"
      rescue UseCase::LodgeAssessment::DuplicateAssessmentIdException
        pp "skipped lodged assessment ID:#{id}"
      end
    end
  end

  def self.update_xml(xml_doc, type, id)
    xml = xml_doc.remove_namespaces!
    assessment_id_node = type == "cepc" ? xml.at("//*[local-name() = 'RRN']") : xml.at("RRN")
    assessment_id_node.children = id
    schema_node = xml_doc.at("//Certificate-Number")
    schema_node.children = assessor_id
    xml_doc
  end

  def self.read_fixtures
    file_array = []
    scheme_array.each do |scheme|
      file_content = read_xml(scheme, scheme.include?("CEPC") ? "cepc" : "epc")
      file_array << { xml: Nokogiri.XML(file_content), scheme: scheme }
    end
    file_array + read_commercial_fixtures
  end

  def self.read_commercial_fixtures
    file_array = []

    commercial_fixtures.each do |item|
      file_content = read_xml("CEPC-8.0.0", item)
      file_array << { xml: Nokogiri.XML(file_content), scheme: item.upcase }
    end
    file_array
  end

  def self.read_xml(schema, type = "epc")
    path = File.join Dir.pwd, "spec/fixtures/samples/#{schema}/#{type}.xml"

    unless File.exist? path
      raise ArgumentError,
            "No #{type} sample found for schema #{schema}, create one at #{
            path
          }"
    end

    File.read path
  end

  def self.add_rake_scheme
    insert_sql = <<-SQL
            INSERT INTO schemes(name,active)
            VALUES ('#{scheme_name}', true)
    SQL
    begin
      ActiveRecord::Base.connection.insert(insert_sql, "SQL")
    rescue ActiveRecord::RecordNotUnique
      ActiveRecord::Base.connection.exec_query("SELECT scheme_id FROM schemes WHERE name ='#{scheme_name}'", "SQL").first["scheme_id"]
    end
  end

  def self.add_assessor(scheme_id)
    insert_sql = <<~SQL
                  INSERT INTO assessors(scheme_assessor_id, first_name,last_name,date_of_birth,registered_by,telephone_number,email,domestic_rd_sap_qualification,non_domestic_sp3_qualification,non_domestic_cc4_qualification,
      non_domestic_dec_qualification,non_domestic_nos3_qualification,non_domestic_nos5_qualification,non_domestic_nos4_qualification,domestic_sap_qualification,gda_qualification)
                  VALUES ('#{assessor_id}', 'test_forename', 'test_surname', '1970-01-05', #{scheme_id}, '0202207459', 'test@barr.com', 'ACTIVE', 'ACTIVE', 'ACTIVE', 'ACTIVE', 'ACTIVE','ACTIVE','ACTIVE','ACTIVE','ACTIVE')
    SQL
    begin
      ActiveRecord::Base.connection.insert(insert_sql, "SQL")
    rescue ActiveRecord::RecordNotUnique
    end
  end

  def self.get_latest_assessment_id
    sql = <<-SQL
    SELECT MAX(assessment_id) as id FROM assessments
    SQL

    result = ActiveRecord::Base.connection.exec_query(sql, "SQL")

    result.first["id"].to_s.empty? ? "0000-0000-0000-0000-0000" : result.first["id"].to_s
  end
end
