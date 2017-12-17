include ActionView::Helpers::CaptureHelper
include ActionView::Context
include SeaOtter::ApplicationHelper

RSpec.describe SeaOtter::ApplicationHelper do
  let(:content_for_name) {:sea_otter}
  let(:server_bundle_path) {:path_to_file}

  before(:each) {
    SeaOtter.configure do |config|
      config.content_for_name = content_for_name
      config.server_bundle_path = server_bundle_path
    end
  }

  context '.render_react_app' do
    let(:html) {:html}
    let(:json_props) {props.to_json}
    let(:props) {{key: 'value'}}

    let(:bundle) {
      <<-JS
        (function(){      
          console.log('alex');

          exports = {
            html: '#{html}',
          };
        })()
      JS
    }

    it 'return the server rendered bundle' do
      _prepare_context

      expect(File).to receive(:read).with(server_bundle_path).and_return(bundle)
      expect(SeaOtter::Renderer::Base).to receive(:print_preloaded_state).with(json_props)
      expect(SeaOtter::Renderer::Base).to receive(:print_console_logs).with(["[SERVER] alex"])
      expect(SeaOtter::Renderer::Base).to receive(:set_preloaded_state).with(json_props)

      expect(render_react_app(props)).to eq(html.to_s)
    end
  end
end