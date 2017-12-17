require 'rails_helper'

RSpec.describe SeaOtter::Renderer::SourceMap do
  let(:server_bundle_with_source_map) {"#{SeaOtter::Engine.root}/spec/support/params_bundle.js"}
  let(:server_bundle_without_source_map) {"#{SeaOtter::Engine.root}/spec/support/server_bundle.js"}

  context 'instance methods' do
    context '.original_position_for' do
      let(:bundle_column) {1}
      let(:bundle_line) {10434}

      context 'with a valid source map' do
        subject {SeaOtter::Renderer::SourceMap.new(File.read("#{SeaOtter::Engine.root}/spec/support/source_map.js"))}

        it('returns the source map infos for a bundle line and column') do
          source_map_infos = subject.original_position_for(bundle_line, bundle_column)

          expect(source_map_infos[:file_path]).to eq('src/App.js')
          expect(source_map_infos[:line]).to eq(8)
          expect(source_map_infos[:column]).to eq(0)
        end
      end

      context 'with a invalid source map' do
        subject {SeaOtter::Renderer::SourceMap.new(File.read(server_bundle_with_source_map))}

        it('returns the source map infos for a bundle line and column') do
          expect {subject.original_position_for(bundle_line, bundle_column)}.to raise_error(SeaOtter::Errors::SourceMap::ParsingError, 'An error occured while parsing the source map. Please make sure the source map is valid.')
        end
      end

      context 'without a source map' do
        subject {SeaOtter::Renderer::SourceMap.new(nil)}

        it('returns the source map infos for a bundle line and column') do
          expect {subject.original_position_for(bundle_line, bundle_column)}.to raise_error(SeaOtter::Errors::SourceMap::MissingError, 'No source map provided.')
        end
      end
    end
  end

  context 'class methods' do
    subject {SeaOtter::Renderer::SourceMap}
    
    context '.source_map_url' do
      context 'with a URL' do
        it 'returns the url' do
          expect(subject.source_map_url(server_bundle_with_source_map)).to eq('server.js.map')
        end
      end

      context 'without a URL' do
        it 'returns the url' do
          expect(subject.source_map_url(server_bundle_without_source_map)).to be_nil
        end
      end
    end

    context '.js_context' do
      it 'returns the js context' do
        expect(subject.js_context).to be_an_instance_of(MiniRacer::Context)
      end
    end
  end
end