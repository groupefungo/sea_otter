require 'sea_otter/renderer/source_map'

module SeaOtter
  module Renderer
    class Error

      attr_accessor :error, :text

      SERVER_BUNDLE_OFFSET = 2
      ERROR_LINES_RANGE = 15

      def initialize(error, json_props, server_bundle)
        @error = error
        @json_props = json_props
        @server_bundle = server_bundle
        @text = error.to_s
      end

      def code
        @code ||= begin
          code_last_line = line + ERROR_LINES_RANGE

          File.readlines(file_name)[code_first_line..code_last_line]
        end
      end

      def code_first_line
        @code_first_line ||= [line - ERROR_LINES_RANGE, 0].max
      end

      def line
        @line ||= (source_map[:line] || infos[:line])
      end

      def file_name
        @file_name ||= (source_map[:file_path].blank? ? @server_bundle : "#{SeaOtter.configuration.source_path}/#{source_map[:file_path]}")
      end

        private

        def infos
          @infos ||= begin
            regex = '.*:(\d*):(\d*)'

            backtrace = [@error.backtrace].flatten.select {|line| line.match?(/JavaScript#{regex}/)}
            match = backtrace.first.match(/#{regex}/)

            {line: match[1].to_i - SERVER_BUNDLE_OFFSET, column: match[2].to_i}
          end
        end

        def source_map
          @source_map ||= begin
            mapping = {}
            source_map_url = SeaOtter::Renderer::SourceMap.source_map_url(@server_bundle)

            unless source_map_url.blank?
              source_map = SeaOtter::Renderer::SourceMap.new(File.read("#{File.dirname(@server_bundle)}/#{source_map_url}"))
              mapping = source_map.original_position_for(infos[:line], infos[:column])
            end

            mapping
          end
        end
      end
    end
end