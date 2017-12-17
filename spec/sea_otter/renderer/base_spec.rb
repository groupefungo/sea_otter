require 'rails_helper'

RSpec.describe SeaOtter::Renderer::Base do
  subject {SeaOtter::Renderer::Base}

  let(:props) {{key: 1}}

  before(:each, :development) {
    expect(Rails.env).to receive(:development?).and_return(true)
    expect(Rails.env).not_to receive(:test?)
  }

  before(:each, :test) {
    expect(Rails.env).to receive(:development?).and_return(false)
    expect(Rails.env).to receive(:test?).and_return(true)
  }


  before(:each, :other_env) {
    expect(Rails.env).to receive(:development?).and_return(false)
    expect(Rails.env).to receive(:test?).and_return(false)
  }

  context '.render' do
    let(:bad_server_bundle) {"#{SeaOtter::Engine.root}/spec/support/bad_server_bundle.js"}
    let(:server_bundle_not_found_message) {'Server bundle not found. Please make sure the server bundle path is valid.'}

    context 'configured server bundle' do
      context 'with logs' do
        let(:server_html_with_logs) {'server bundle html with logs'}

        before(:each) {
          SeaOtter.configure do |config|
            config.server_bundle_path = "#{SeaOtter::Engine.root}/spec/support/server_bundle_console_log.js"
          end
        }

        context 'with props' do
          it 'should return the rendered bundle' do
            rendered_bundle = subject.render(props: props)

            expect(rendered_bundle['html']).to eq(server_html_with_logs)
            expect(rendered_bundle['props']).to eq(props.stringify_keys)
            expect(rendered_bundle['logs']).to eq(['[SERVER] log A'])
          end
        end

        context 'without props' do
          it 'should return the rendered bundle' do
            rendered_bundle = subject.render

            expect(rendered_bundle['html']).to eq(server_html_with_logs)
            expect(rendered_bundle['props']).to eq({})
            expect(rendered_bundle['logs']).to eq(['[SERVER] log A'])
          end
        end
      end

      context 'without logs' do
        let(:server_html_no_logs) {'server bundle html'}

        before(:each, :existing_bundle) {
          SeaOtter.configure do |config|
            config.server_bundle_path = "#{SeaOtter::Engine.root}/spec/support/server_bundle.js"
          end
        }

        context 'with props', :existing_bundle do
          it 'should return the rendered bundle' do
            rendered_bundle = subject.render(props: props)

            expect(rendered_bundle['html']).to eq(server_html_no_logs)
            expect(rendered_bundle['props']).to eq(props.stringify_keys)
            expect(rendered_bundle['logs']).to eq([])
          end
        end

        context 'without props', :existing_bundle do
          it 'should return the rendered bundle' do
            rendered_bundle = subject.render

            expect(rendered_bundle['html']).to eq(server_html_no_logs)
            expect(rendered_bundle['props']).to eq({})
            expect(rendered_bundle['logs']).to eq([])
          end
        end
      end

      context 'non existing server bundle' do
        it 'raises an error' do
          SeaOtter.configure do |config|
            config.server_bundle_path = bad_server_bundle
          end

          expect {subject.render(props: props)}.to raise_error(SeaOtter::Errors::ServerBundle::NotFoundError, server_bundle_not_found_message)
        end
      end
    end

    context 'params server bundle' do
      context 'with logs' do
        let(:params_html_with_logs) {'params bundle html with logs'}
        let(:params_server_bundle) {"#{SeaOtter::Engine.root}/spec/support/params_bundle_console_log.js"}

        context 'with props' do
          it 'should return the rendered bundle' do
            rendered_bundle = subject.render(props: props, server_bundle: params_server_bundle)

            expect(rendered_bundle['html']).to eq(params_html_with_logs)
            expect(rendered_bundle['props']).to eq(props.stringify_keys)
            expect(rendered_bundle['logs']).to eq(['[SERVER] log A'])
          end
        end

        context 'without props' do
          it 'should return the rendered bundle' do
            rendered_bundle = subject.render(server_bundle: params_server_bundle)

            expect(rendered_bundle['html']).to eq(params_html_with_logs)
            expect(rendered_bundle['props']).to eq({})
            expect(rendered_bundle['logs']).to eq(['[SERVER] log A'])
          end
        end
      end

      context 'without logs' do
        let(:params_html_no_logs) {'params bundle html'}
        let(:params_server_bundle) {"#{SeaOtter::Engine.root}/spec/support/params_bundle.js"}

        context 'with props' do
          it 'should return the rendered bundle' do
            rendered_bundle = subject.render(props: props, server_bundle: params_server_bundle)

            expect(rendered_bundle['html']).to eq(params_html_no_logs)
            expect(rendered_bundle['props']).to eq(props.stringify_keys)
            expect(rendered_bundle['logs']).to eq([])
          end
        end

        context 'without props' do
          it 'should return the rendered bundle' do
            rendered_bundle = subject.render(server_bundle: params_server_bundle)

            expect(rendered_bundle['html']).to eq(params_html_no_logs)
            expect(rendered_bundle['props']).to eq({})
            expect(rendered_bundle['logs']).to eq([])
          end
        end

        context 'non existing server bundle' do
          it 'raises an error' do
            expect {subject.render(server_bundle: bad_server_bundle)}.to raise_error(SeaOtter::Errors::ServerBundle::NotFoundError, server_bundle_not_found_message)
          end
        end
      end
    end

    context 'no server bundle' do
      it 'raises an error' do
        SeaOtter.configure do |config|
          config.server_bundle_path = ''
        end

        expect {subject.render(props: props)}.to raise_error(SeaOtter::Errors::ServerBundle::NotConfiguredError, 'Server bundle not configured. Please make sure to add the server bundle path in the sea_otter initializer.')
      end
    end
  end

  context '.print_console_logs' do
    let(:console_logs) {['[SERVER] 1', '[SERVER] 2', '[SERVER] 3']}
    let(:console_logs_script) {"<script>console.log('[SERVER] 1');console.log('[SERVER] 2');console.log('[SERVER] 3')</script>"}

    before(:each, :no_logs) {
      expect(Rails.env).not_to receive(:development?)
      expect(Rails.env).not_to receive(:test?)
    }

    context 'in development' do
      context 'with logs', :development do
        it 'should return a script tag to print the console.log history' do
          expect(subject.print_console_logs(console_logs)).to eq(console_logs_script)
        end
      end

      context 'without logs', :no_logs do
        it 'should return nil' do
          expect(subject.print_console_logs(nil)).to be_nil
        end
      end
    end

    context 'in test' do
      context 'with logs', :test do
        it 'should return a script tag to print the console.log history' do
          expect(subject.print_console_logs(console_logs)).to eq(console_logs_script)
        end
      end

      context 'without logs', :no_logs do
        it 'should return nil' do
          expect(subject.print_console_logs(nil)).to be_nil
        end
      end
    end

    context 'any environment besides development or test' do
      context 'with logs', :other_env do
        it 'should return a script tag to print the console.log history' do
          expect(subject.print_console_logs(console_logs)).to be_nil
        end
      end

      context 'without logs', :no_logs do
        it 'should return nil' do
          expect(subject.print_console_logs(nil)).to be_nil
        end
      end
    end
  end

  context '.print_preloaded_state' do
    let(:preloaded_state_script) {"<script>console.log('[PRELOADED_STATE] : ', #{props.to_json})</script>"}

    context 'in development', :development do
      it 'should return a script tag to print the preloaded state' do
        expect(subject.print_preloaded_state(props)).to eq(preloaded_state_script)
      end
    end

    context 'in test', :test do
      it 'should return a script tag to print the preloaded state' do
        expect(subject.print_preloaded_state(props)).to eq(preloaded_state_script)
      end
    end

    context 'in any environment except development' do
      it 'should return nil', :other_env do
        expect(subject.print_preloaded_state(props)).to be_nil
      end
    end
  end

  context '.set_preloaded_state' do
    it 'should return a script tag to set the preloaded state' do
      expect(subject.set_preloaded_state(props)).to eq("<script>window.__PRELOADED_STATE__ = #{props.to_json}</script>")
    end
  end
end