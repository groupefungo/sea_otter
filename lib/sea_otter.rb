require 'mini_racer'
require 'sea_otter/configuration'
require 'sea_otter/engine'
require 'sea_otter/js_context/base'
require 'sea_otter/js_context/error'
require 'sea_otter/version'

module SeaOtter
  class Railtie < Rails::Railtie

    initializer 'adds sea_otter view helpers' do
      ActiveSupport.on_load(:action_view) {
        include SeaOtter::ApplicationHelper
      }
    end
  end
end