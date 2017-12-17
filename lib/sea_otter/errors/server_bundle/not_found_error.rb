module SeaOtter
  module Errors
    module ServerBundle
      class NotFoundError < StandardError

        def message
          'Server bundle not found. Please make sure the server bundle path is valid.'
        end
      end
    end
  end
end