module SeaOtter
  class Configuration
    attr_accessor :content_for_name, :server_bundle_path, :source_path
  end

  class << self

    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end