require 'sea_otter/renderer/base'
require 'sea_otter/configuration'
require 'sea_otter/renderer/error'

module SeaOtter
  class Railtie < Rails::Railtie

    initializer('Add sea_otter renderer') do
      ActionController::Renderers.add(:sea_otter) do |props, options|
        begin
          @sea_otter_exports = {}

          @sea_otter_exports = SeaOtter::Renderer::Base.render(props: props)

          render('/sea_otter/index', locals: {
              console_logs: SeaOtter::Renderer::Base.print_console_logs(@sea_otter_exports['logs'])&.html_safe,
              html: @sea_otter_exports['html']&.html_safe,
              preloaded_state: SeaOtter::Renderer::Base.set_preloaded_state(props)&.html_safe,
              preloaded_state_log: SeaOtter::Renderer::Base.print_preloaded_state(props)&.html_safe,
          })
        rescue MiniRacer::RuntimeError => error
          renderer_error = SeaOtter::Renderer::Error.new(error, props.to_json, SeaOtter.configuration.server_bundle_path)

          render('/sea_otter/errors', status: :error, layout: 'sea_otter', locals: {error: renderer_error})
        end
      end
    end

    initializer('Add sea_otter view helper') do
      ActiveSupport.on_load(:action_view) do
        include SeaOtter::RenderingHelper
      end
    end
  end
end
