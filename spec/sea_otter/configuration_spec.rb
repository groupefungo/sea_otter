require 'rails_helper'

RSpec.describe SeaOtter::Configuration do
  let(:content_for_name) {:new_content_for_name}
  let(:server_bundle_path) {:path_to_file}
  let(:source_path) {:source_path}

  it 'should configure the library' do
    expect(SeaOtter.configuration.content_for_name).to be(:sea_otter)
    expect(SeaOtter.configuration.server_bundle_path).to be_nil
    expect(SeaOtter.configuration.source_path).to be_nil

    SeaOtter.configure do |config|
      config.content_for_name = content_for_name
      config.server_bundle_path = server_bundle_path
      config.source_path = source_path
    end

    expect(SeaOtter.configuration.content_for_name).to be(content_for_name)
    expect(SeaOtter.configuration.server_bundle_path).to be(server_bundle_path)
    expect(SeaOtter.configuration.source_path).to be(source_path)
  end
end
