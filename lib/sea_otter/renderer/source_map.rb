require 'mini_racer'
require 'sea_otter/errors'

module SeaOtter
  module Renderer
    class SourceMap

      def initialize(source_map)
        @source_map = source_map
      end

      def original_position_for(line, column)
        raise SeaOtter::SourceMap::MissingError if @source_map.blank?
        
        js = <<-JS.strip_heredoc
          new sourceMap.SourceMapConsumer(#{@source_map}).originalPositionFor({line: #{line}, column: #{column}});
        JS

        result = SeaOtter::Renderer::SourceMap.js_context.eval(js)

        {file_path: result['source'].gsub(/webpack:\/\/\//, ''), line: result['line'], column: result['column']}
      rescue MiniRacer::ParseError => error
          raise SeaOtter::SourceMap::ParsingError
      end

      class << self

        def js_context
          @js_context ||= begin
            context = MiniRacer::Context.new
            context.eval(File.read("#{SeaOtter::Engine.root}/vendor/source-map.min.js"))

            context
          end
        end

        def source_map_url(file_path)
          file_name = File.basename(file_path)
          server_bundle = File.read(file_path)

          match = server_bundle.match(/sourceMappingURL=(#{file_name}.map)/)

          match && match[1]
        end
      end
    end
  end
end