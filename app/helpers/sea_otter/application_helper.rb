module SeaOtter
  module ApplicationHelper

    def render_react_app(props = {})
      @react_server_exports = {}

      json_props = props.to_json

      @react_server_exports = SeaOtter::JSContext::Base.eval_js(json_props: json_props)

      content_for(SeaOtter.configuration.content_for_name) do
        [
            SeaOtter::JSContext::Base.print_preloaded_state(json_props),
            SeaOtter::JSContext::Base.print_console_logs(@react_server_exports['logs']),
            SeaOtter::JSContext::Base.set_preloaded_state(json_props),
        ].join("\n").html_safe
      end

      @react_server_exports['html']&.html_safe
    rescue MiniRacer::RuntimeError => error
      render(partial: '/sea_otter/errors', locals: {
          error: SeaOtter::JSContext::Error.new(error, json_props, SeaOtter.configuration.server_bundle_path)
      })
    end
  end
end
