require 'rails/generators'

module SeaOtter
  class InitializerGenerator < Rails::Generators::Base
    source_root(File.expand_path('../templates', __FILE__))

    desc 'Generates the initializer for the sea_otter gem'

    def install
      template('initializer.erb', 'config/initializers/sea_otter.rb')
    end
  end
end
