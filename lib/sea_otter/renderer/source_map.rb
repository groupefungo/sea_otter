require 'sea_otter/errors/source_map/missing_error'
require 'sea_otter/errors/source_map/parsing_error'

module SeaOtter
  module Renderer
    class SourceMap

      def initialize(source_map)
        @source_map = source_map
      end

      def original_position_for(line, column)
        raise SeaOtter::Errors::SourceMap::MissingError if @source_map.blank?
        
        js = <<-JS
          new sourceMap.SourceMapConsumer(#{@source_map}).originalPositionFor({line: #{line}, column: #{column}});
        JS

        result = SeaOtter::Renderer::SourceMap.js_context.eval(js)

        {file_path: result['source'].gsub(/webpack:\/\/\//, ''), line: result['line'], column: result['column']}
      rescue MiniRacer::ParseError => error
          raise SeaOtter::Errors::SourceMap::ParsingError
      end

      class << self

        def source_map_url(file_path)
          server_bundle = File.read(file_path)
          match = server_bundle.match(/sourceMappingURL=(.*)/)

          match && match[1]
        end

        def js_context
          @js_context ||= begin
            context = MiniRacer::Context.new
            context.eval(File.read("#{SeaOtter::Engine.root}/vendor/source-map.min.js"))

            context
          end
        end
      end
    end
  end
end