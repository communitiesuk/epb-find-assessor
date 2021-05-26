desc "Import assessments certificates from directory of json files for EAV"

task :import_json_certificates do
  start_time = Time.now

  json_dir_path = ENV["DIR_PATH"] || File.join(Dir.pwd, "spec/fixtures/json_export/")

  certificates_gateway = Gateway::JsonCertificates.new(json_dir_path)
  use_case = UseCase::ImportJsonCertificates.new(certificates_gateway, Gateway::AssessmentAttributesGateway.new)

  use_case.execute

  puts "Rake completed in #{(Time.now.to_f - start_time.to_f)} seconds"
end
