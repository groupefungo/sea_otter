require 'mini_racer'
require 'sea_otter/configuration'
require 'sea_otter/engine'
require 'sea_otter/renderer/base'
require 'sea_otter/renderer/error'
require 'sea_otter/version'

module SeaOtter
  class Railtie < Rails::Railtie

    initializer 'Add sea_otter view helpers' do
      ActiveSupport.on_load(:action_view) {
        include SeaOtter::ApplicationHelper
      }

      ActionController::Renderers.add(:sea_otter) do |obj, options|
        pp obj
        pp options

        @alex = 'zicat'
        
        render html: '<h1>Alex</h1>'.html_safe
      end
    end
  end
end