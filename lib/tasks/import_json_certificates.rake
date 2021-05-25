desc "Import assessments certificates from directory of json files for EAV"

task :import_json_certificates do
  json_dir_path = ENV["json_dir_path"]

  raise Boundary::ArgumentMissing, "no dir path specificed" unless json_dir_path

  certificates_gateway = Gateway::JsonCertificates.new(json_dir_path)
  use_case = UseCase::ImportJsonCertificates.new(certificates_gateway, Gateway::AssessmentAttributesGateway.new)

  use_case.execute
end
