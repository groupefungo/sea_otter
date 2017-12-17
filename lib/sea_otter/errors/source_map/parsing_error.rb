module SeaOtter
  module Errors
    module SourceMap
      class ParsingError < StandardError

        def message
          'An error occured while parsing the source map. Please make sure the source map is valid.'
        end
      end
    end
  end
end