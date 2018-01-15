module SeaOtter
  module RenderingHelper

    def render_react_app(props = {})
      @sea_otter_exports = {}

      @sea_otter_exports = SeaOtter::Renderer::Base.render(props: props)

      content_for(SeaOtter.configuration.content_for_name) do
        [
            SeaOtter::Renderer::Base.print_preloaded_state(props),
            SeaOtter::Renderer::Base.print_console_logs(@sea_otter_exports['logs']),
            SeaOtter::Renderer::Base.set_preloaded_state(props),
        ].join("\n").html_safe
      end

      @sea_otter_exports['html']&.html_safe
    rescue MiniRacer::RuntimeError => error
      renderer_error = SeaOtter::Renderer::Error.new(error, props.to_json, SeaOtter.configuration.server_bundle_path)

      render(partial: '/sea_otter/partials/errors', locals: {error: renderer_error})
    end
  end
end