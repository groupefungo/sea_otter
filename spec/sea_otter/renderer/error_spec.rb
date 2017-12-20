require 'rails_helper'

RSpec.describe SeaOtter::Renderer::Error do
  subject {SeaOtter::Renderer::Error.new(error, {}, server_bundle)}

  let(:error) {
    error = MiniRacer::RuntimeError.new(error_message)
    error.set_backtrace(["JavaScript (alex:#{error_line}:#{error_column})"])

    error
  }

  let(:code_first_line) {error_line - SeaOtter::Renderer::Error::ERROR_LINES_RANGE - SeaOtter::Renderer::Error::SERVER_BUNDLE_OFFSET}
  let(:error_column) {1}
  let(:error_line) {20}
  let(:error_message) {'runtime error'}

  context '.code' do
    context 'without source map' do
      let(:server_bundle) {"#{SeaOtter::Engine.root}/spec/support/server_bundle.js"}
      
      it 'returns the code of the file with an error' do
        expect(subject.code).to eq(File.readlines(server_bundle)[code_first_line..-1])
      end
    end
    
    context 'with source map' do
      let(:sea_otter_source_map) {double(SeaOtter::Renderer::SourceMap)}
      let(:server_bundle) {"#{SeaOtter::Engine.root}/spec/support/params_bundle.js"}
      let(:source_map_file) {"#{SeaOtter::Engine.root}/spec/support/server_bundle.js"}

      before(:each) {
        SeaOtter.configure do |config|
          config.source_path = "#{SeaOtter::Engine.root}/spec/support"
        end
      }

      it 'returns the code of the file with an error' do
        expect(SeaOtter::Renderer::SourceMap).to receive(:new).with(File.read("#{server_bundle}.map")).and_return(sea_otter_source_map)
        expect(sea_otter_source_map).to receive(:original_position_for).with(error_line - SeaOtter::Renderer::Error::SERVER_BUNDLE_OFFSET, error_column).and_return({file_path: 'server_bundle.js', line: 1})

        expect(subject.code).to eq(File.readlines(source_map_file))
      end
    end
  end

  context '.code_first_line' do
    context 'without source map' do
      let(:server_bundle) {"#{SeaOtter::Engine.root}/spec/support/server_bundle.js"}

      context 'with a '
      it 'returns the code first line' do
        expect(subject.code_first_line).to eq(code_first_line)
      end
    end
  end
end