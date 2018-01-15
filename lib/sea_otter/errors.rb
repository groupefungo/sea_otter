module SeaOtter
  class Error < StandardError
  end

  module SourceMap
    class MissingError < Error
      def message
        'No source map provided.'
      end
    end

    class ParsingError < Error
      def message
        'An error occured while parsing the source map. Please make sure the source map is valid.'
      end
    end
  end

  module ServerBundle
    class NotConfiguredError < Error
      def message
        'Server bundle not configured. Please make sure to add the server bundle path in the sea_otter initializer.'
      end
    end

    class NotFoundError < Error
      def message
        'Server bundle not found. Please make sure the server bundle path is valid.'
      end
    end
  end
end