require 'sea_otter/errors/server_bundle/not_configured_error'
require 'sea_otter/errors/server_bundle/not_found_error'

module SeaOtter
  module Renderer
    class Base
      class << self

        def render(props: {}, server_bundle: SeaOtter.configuration.server_bundle_path)
          raise SeaOtter::Errors::ServerBundle::NotConfiguredError if server_bundle.blank?

          server_js = File.read(server_bundle)

          js = <<-JS
            __PRELOADED_STATE__ = #{props.to_json};

            #{server_js}        
            
            if (typeof exports === 'undefined') {
              exports = {};
            }                 
              
            exports.logs = console.history;
            exports;
          JS

          js_context.eval(js, filename: File.basename(server_bundle))
        rescue Errno::ENOENT => error
          raise SeaOtter::Errors::ServerBundle::NotFoundError
        end

        def print_console_logs(logs = nil)
          return if logs.blank? || !development_env?

          "<script>#{logs.map {|log| "console.log('#{log.gsub(/'/, '\'')}')"}.join(';')}</script>".html_safe
        end

        def print_preloaded_state(props = {})
          return unless development_env?

          "<script>console.log('[PRELOADED_STATE] : ', #{props.to_json})</script>".html_safe
        end

        def set_preloaded_state(props = {})
          "<script>window.__PRELOADED_STATE__ = #{props.to_json}</script>".html_safe
        end

        private

        def console_polyfill
          <<-JS
          const console = {history: []};
  
          ['error', 'log', 'info', 'warn'].forEach((level) => {
            console[level] = function() {
              for(let arg of arguments) {
                console.history.push(`[SERVER] ${arg}`)
              }
            };
          });
          JS
        end

        def development_env?
          Rails.env.development? || Rails.env.test?
        end

        def js_context
          context = MiniRacer::Context.new
          context.eval(console_polyfill)

          context
        end
      end
    end
  end
end