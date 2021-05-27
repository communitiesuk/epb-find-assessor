require 'elasticsearch'

desc "Update list of JSON assessments to elasticsearch"
task :upload_to_elasticsearch do
  puts "Elasticsearch import started"

  es_client = Elasticsearch::Client.new(
    host: "https://#{ENV['ES_USER']}:#{ENV['ES_PASS']}@localhost:4430",
    transport_options: { ssl: { verify: false } }
  )
  storage_gateway = ApiFactory.storage_gateway(bucket_name: ENV['bucket_name'])

  begin
    count = 0
    start_after = nil
    id = nil
    loop do
      bucket_objects = storage_gateway.list_objects(directory: "export/", start_after: start_after)

      bulk_request = []
      bucket_objects.contents.each do |object|
        id = object.key[/export\/(.*)\.json/, 1]
        data = JSON.parse(storage_gateway.get_file_io(object.key).read)
        index = data["type_of_assessment"] == "CEPC" ? "register-cepc" : "register-domestic"
        bulk_request << {
          index: {
            _index: index,
            _id: id,
            data: data
          }
        }
        count += 1
      end
      es_client.bulk(body: bulk_request)
      puts "Processed #{count} files"

      break unless bucket_objects.is_truncated
      start_after = bucket_objects.contents.last.key
    end
    puts "Elasticsearch import completed"
  rescue Exception => e
    puts "Error on file #{id}"
    puts e.backtrace
  end

end
