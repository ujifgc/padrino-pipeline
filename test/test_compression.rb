require File.expand_path(File.dirname(__FILE__) + '/helpers/helper')

shared_examples_for :pipeline do
  describe :asset_compression do
    let(:app) { rack_app }
    before do
      assets_location = "#{fixture_path('asset_pack_app')}/assets/"
      pipeline        = @pipeline
      mock_app do
        register Padrino::Pipeline
        configure_assets do |config|
          config.pipeline   = pipeline
          config.css_assets = "#{assets_location}/stylesheets"
          config.js_assets  = "#{assets_location}/javascripts"
        end
      end
    end

    it 'should not compress css in development mode' do
      get '/assets/stylesheets/app.css'
      assert_match "body {\n", last_response.body
    end

    it 'should not compress js in development mode' do
      get '/assets/javascripts/app.js'
      assert_match "function test() {\n", last_response.body
    end

  end
end

describe :default_compression do
  before do
    class SomeApp < Padrino::Application; end
    @config = Padrino::Pipeline::Configuration.new(SomeApp)

    @warn_level = $VERBOSE
    $VERBOSE    = nil

    reset_consts
  end

  after do
    $VERBOSE = @warn_level
  end

  def reset_consts
    Object.send(:remove_const, :PADRINO_ENV) if defined? PADRINO_ENV
    Object.send(:remove_const, :RACK_ENV) if defined? RACK_ENV
  end

  def in_env(env)
    %w(PADRINO_ENV RAKE_ENV).each do |const|
      Object.const_set(const, env)
      yield
    end
  end

  it 'serve_compressed? is false for test' do
    in_env "test" do
      refute @config.serve_compressed? 
    end
  end

  it 'serve_compressed? is false for development' do
    in_env "development" do
      refute @config.serve_compressed? 
    end
  end

  it 'serve_compressed? is true for production' do
    in_env "production" do
      assert @config.serve_compressed? 
    end
  end
end
  
describe Padrino::Pipeline::Sprockets do
  before { @pipeline = Padrino::Pipeline::Sprockets }
  it_behaves_like :pipeline
end

describe Padrino::Pipeline::AssetPack do
  before { @pipeline = Padrino::Pipeline::AssetPack }
  it_behaves_like :pipeline 
end