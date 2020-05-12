module Helper
  class DataExtractorHelper
    def fetch_data(raw_data, data_settings)
      data = {}

      data_settings.each do |key, settings|
        path =
          if settings.key?(:root)
            root = settings[:root].to_sym

            data_settings[root][:path].map(&:to_sym)
          else
            []
          end

        path += settings[:path].map(&:to_sym)

        data[key] = raw_data.dig(*path)

        if settings.key?(:extract)
          unless data[key]
            data[key] = []
          end

          if settings.key?(:bury_key)
            output_data = []
            data[key] = data[key].map do |inner_data, inner_key|
              inner_data, inner_key = inner_key, inner_data

              inner_data = [inner_data] unless inner_data.is_a? Array

              inner_data.map do |inner_inner_data|
                inner_inner_data = fetch_data(inner_inner_data, settings[:extract])
                inner_inner_data[settings[:bury_key]] = inner_key.to_s

                output_data.push(inner_inner_data)
              end
            end

            data[key] = output_data
          else
            data[key] = [data[key]] unless data[key].is_a? Array

            data[key] = data[key].map do |inner_data, _inner_key|
              fetch_data(inner_data, settings[:extract])
            end
          end
        end
      end

      data
    end
  end
end
