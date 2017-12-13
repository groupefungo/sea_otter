module SeaOtter
  module JSContext
    class Base
      class << self

        def eval_js(json_props: {}, server_bundle: SeaOtter.configuration.server_bundle_path)
          server_js = File.read(server_bundle)

          js = <<-JS
            __PRELOADED_STATE__ = #{json_props};

            #{server_js}        
            
            if (typeof exports === 'undefined') {
              exports = {};
            }                 
              
            exports.logs = console.history;
            exports;
          JS

          js_context.eval(js, filename: File.basename(server_bundle))
        end

        def print_console_logs(logs)
          return if !Rails.env.development? || logs.blank?

          "<script>#{logs.map {|log| "console.log('#{log}')"}.join(';')}</script>".html_safe
        end

        def print_preloaded_state(json_props)
          return unless Rails.env.development?

          "<script>console.log('[PRELOADED_STATE] : ', #{json_props})</script>".html_safe
        end

        def set_preloaded_state(json_props)
          "<script>window.__PRELOADED_STATE__ = #{json_props}</script>".html_safe
        end

        private

        def js_context
          context = MiniRacer::Context.new
          context.eval(console_polyfill)

          context
        end

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
      end
    end
  end
end