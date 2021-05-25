module Gateway
  class JsonCertificates
    attr_accessor :dir_path

    def initialize(dir_path)
      @dir_path = dir_path
    end

    def read
      Dir
        .glob(File.join(path, "**", "*"))
        .select { |file| File.file?(file) && File.extname(file) == ".json" }
    rescue StandardError
      []
    end
  end
end
