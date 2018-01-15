module SeaOtter
  class Configuration
    attr_accessor :content_for_name, :server_bundle_path, :source_path

    def initialize(
        content_for_name: :sea_otter,
        server_bundle_path: nil,
        source_path: nil
    )
      @content_for_name = content_for_name
      @server_bundle_path = server_bundle_path
      @source_path = source_path
    end
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