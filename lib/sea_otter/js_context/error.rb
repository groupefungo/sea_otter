module SeaOtter
  module JSContext
    class Error

      attr_accessor :error, :text

      ERROR_LINES_RANGE = 10

      def initialize(error, json_props, filename)
        @error = error
        @json_props = json_props
        @filename = filename
        @text = error.to_s
      end

      def backtrace
        @backtrace ||= @error.backtrace.select {|line| line.include?('JavaScript')}
      end

      def code
        @code ||= server_bundle_lines[(error_line - ERROR_LINES_RANGE - 1)..(error_line + ERROR_LINES_RANGE)]
      end

      def error_line
        @error_line ||= begin
          match = backtrace.first.match(/\(.*:(\d*):(\d*)\)/)

          match[1].to_i - 2
        end
      end

      private

      def server_bundle_lines
        @server_bundle_lines ||= File.readlines(@filename)
      end
    end
  end
end