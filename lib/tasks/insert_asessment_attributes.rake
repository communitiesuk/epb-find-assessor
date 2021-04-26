desc "Insert a number of assessments into the entity attribute values"

task :import_assessment_attributes do
  require "nokogiri"

  assessment_attribute_gateway = Gateway::AssessmentAttributesGateway.new
  start_number = ENV["START"] || 1
  number_of_assessments = ENV["END"] || 1

  path = File.join Dir.pwd, "spec/fixtures/samples/RdSAP-Schema-20.0.0/epc.xml"
  File.read path
  xml_doc = Nokogiri::XML(File.read(path))

  start_number.to_i.upto(number_of_assessments.to_i) do |index|
    view_model =
      ViewModel::Factory.new.create(
        xml_doc.to_s,
        "RdSAP-Schema-20.0.0",
      )

    view_model_hash = view_model.to_report
    view_model_hash.each do |key, value|
      assessment_attribute_gateway.add_attribute_value(
        index.to_s,
        key,
        value,
      )
    end
  end
end
