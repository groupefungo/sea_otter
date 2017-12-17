module SeaOtter
  module ApplicationHelper

    def render_react_app(props = {})
      @react_server_exports = {}

      json_props = props.to_json

      @react_server_exports = SeaOtter::Renderer::Base.render(props: props)

      content_for(SeaOtter.configuration.content_for_name) do
        [
            SeaOtter::Renderer::Base.print_preloaded_state(json_props),
            SeaOtter::Renderer::Base.print_console_logs(@react_server_exports['logs']),
            SeaOtter::Renderer::Base.set_preloaded_state(json_props),
        ].join("\n").html_safe
      end

      @react_server_exports['html']&.html_safe
    rescue MiniRacer::RuntimeError => error
      renderer_error = SeaOtter::Renderer::Error.new(error, json_props, SeaOtter.configuration.server_bundle_path)

      render(partial: '/sea_otter/errors', locals: {error: renderer_error})
    end
  end
end
