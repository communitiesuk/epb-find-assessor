desc "Insert a number of assessments into the entity attribute values"

task :import_assessment_attributes do
  require "nokogiri"

  assessment_attribute_gateway = Gateway::AssessmentAttributesGateway.new
  import_xml_attribute_values = UseCase::ImportXmlAttributeValues.new
  start_number = ENV["START"] || 1
  number_of_assessments = ENV["END"] || 1

  path = File.join Dir.pwd, "spec/fixtures/samples/RdSAP-Schema-20.0.0/epc.xml"
  File.read path
  xml_doc = Nokogiri::XML(File.read(path))

  start_number.to_i.upto(number_of_assessments.to_i) do |_index|
    import_xml_attribute_values.execute(xml_doc)
  end
end
