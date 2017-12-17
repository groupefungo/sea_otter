require 'sea_otter/renderer/source_map'

module SeaOtter
  module Renderer
    class Error

      attr_accessor :error, :text

      SERVER_BUNDLE_OFFSET = 2
      ERROR_LINES_RANGE = 10

      def initialize(error, json_props, server_bundle)
        @error = error
        @json_props = json_props
        @server_bundle = server_bundle
        @text = error.to_s
      end

      def code
        @code ||= begin
          file_path = source_map[:file_path].blank? ? @server_bundle : "#{SeaOtter.configuration.source_path}/#{source_map[:file_path]}"

          File.readlines(file_path)[code_first_line..code_last_line]
        end
      end

      def code_first_line
        @code_first_line ||= (source_map[:file_path].blank? ? error_line - ERROR_LINES_RANGE : 0)
      end

      def code_last_line
        @code_last_line ||= (source_map[:file_path].blank? ? error_line + ERROR_LINES_RANGE : -1)
      end

      def error_line
        @error_line ||= (source_map[:line] || error_infos[:line])
      end

      private

      def error_infos
        @error_infos ||= begin
          backtrace = @error.backtrace.select {|line| line.include?('JavaScript')}
          match = backtrace.first.match(/\(.*:(\d*):(\d*)\)/)

          {line: match[1].to_i - SERVER_BUNDLE_OFFSET, column: match[2].to_i}
        end
      end

      def source_map
        @source_map ||= begin
          mapping = {}
          source_map_url = SeaOtter::Renderer::SourceMap.source_map_url(@server_bundle)

          unless source_map_url.blank?
            source_map = SeaOtter::Renderer::SourceMap.new(File.read("#{File.dirname(@server_bundle)}/#{source_map_url}"))
            mapping = source_map.original_position_for(error_infos[:line], error_infos[:column])
          end

          mapping
        end
      end
    end
  end
end