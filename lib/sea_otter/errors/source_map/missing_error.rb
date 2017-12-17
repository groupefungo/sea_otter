module SeaOtter
  module Errors
    module SourceMap
      class MissingError < StandardError

        def message
          'No source map provided.'
        end
      end
    end
  end
end