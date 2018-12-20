require 'mini_racer'
require 'sea_otter/errors'

module SeaOtter
  # JavaScript to html renderer module.
  module Renderer
    # Base class for the renderer.
    class Base
      class << self

        # Renders a JavaScript server bundle to html.
        #
        # @param props [Hash] the props used to create the preloaded state.
        # @param server_bundle [string] the server bundle path to render.
        #
        # @return [Hash] a hash containing the exported data from the JavaScript server bundle.
        #
        # @raise [SeaOtter::ServerBundle::NotConfiguredError] if the server bundle path is not present.
        # @raise [SeaOtter::ServerBundle::NotFoundError] if the server bundle file is not found.
        def render(props: {}, server_bundle: SeaOtter.configuration.server_bundle_path)
          raise SeaOtter::ServerBundle::NotConfiguredError if server_bundle.blank?

          server_js = File.read(server_bundle)

          js = <<-JS.strip_heredoc
            __PRELOADED_STATE__ = #{props.to_json};

            #{server_js}        
            
            if (typeof exports === 'undefined') {
              exports = {};
            }                 
              
            exports.logs = console.history;
            exports;
          JS

          MiniRacer::Context.new(snapshot: snapshot).eval(js, filename: File.basename(server_bundle))
        rescue Errno::ENOENT => error
          raise SeaOtter::ServerBundle::NotFoundError
        end


        # Returns a script tag containing the server bundle console.log.
        #
        # @param logs [Array] the logs to output.
        #
        # @return [string] the html safe script tag with the console.log().
        # @return [nil] if there are no logs.
        def print_console_logs(logs = nil)
          return if logs.blank? || !development_env?

          formatted_logs = logs.map do |log|
            formatted_log = log.gsub(/'/, "\\\\'").gsub(/\n/, "\\\\n")

            "console.log('#{formatted_log}')"
          end

          "<script>#{formatted_logs.join(';')}</script>".html_safe
        end

        # Returns a script tag containing the log of the preloaded state.
        #
        # @param props [Hash] the state to preload.
        #
        # @return [string] the html safe script tag with the console.log() of the preloaded state.
        # @return [nil] if not in a development environment.
        def print_preloaded_state(props = {})
          return unless development_env?

          "<script>console.log('<PRELOADED STATE> : ', #{props.to_json})</script>".html_safe
        end

        # Returns a script tag containing the preloaded state.
        #
        # @param props [Hash] the state to preload.
        #
        # @return [string] the html safe script tag with the preloaded state added to the window object.
        def set_preloaded_state(props = {})
          "<script>window.__PRELOADED_STATE__ = #{props.to_json}</script>".html_safe
        end

        private

        # Returns the JavaScript polyfills.
        #
        # @return [string] the JavaScript heredoc.
        def polyfills
          <<-JS.strip_heredoc
            const console = {history: []};
    
            ['error', 'log', 'info', 'warn'].forEach((level) => {
              console[level] = function() {
                for(let arg of arguments) {
                  console.history.push(`<SERVER> : ${arg}`)
                }
              };
            });                  

            const clearTimeout = setTimeout = () => {};

            self = {};
          JS
        end

        # Returns true if in a development environment
        #
        # @return [bool] truthy if in a development environment.
        def development_env?
          Rails.env.development? || Rails.env.test?
        end

        # Returns the JavaScript context initial snapshot.
        #
        # @return [MiniRacer::Snapshot] the JavaScript snapshot.
        def snapshot
          @snapshot ||= MiniRacer::Snapshot.new(polyfills)
        end
      end
    end
  end
end
