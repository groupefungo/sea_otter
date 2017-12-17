module SeaOtter
  module Errors
    module ServerBundle
      class NotConfiguredError < StandardError

        def message
          'Server bundle not configured. Please make sure to add the server bundle path in the sea_otter initializer.'
        end
      end
    end
  end
end