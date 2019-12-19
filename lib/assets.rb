class Assets < Sprockets::Environment
  class << self
    def instance(root = nil)
      @instance ||= new(root)
    end
  end

  def initialize(root)
    super
    %w[app lib vendor].each do |dir|
      %w[images javascripts stylesheets].each do |type|
        path = File.join(root, dir, 'assets', type)
        self.append_path(path) if File.exist?(path)
      end
    end
    self.css_compressor = YUI::CssCompressor.new
    self.js_compressor = Uglifier.new
    context_class.instance_eval do
      include Helpers
    end
  end

  def precompile
    dir = 'public/assets'
    FileUtils.rm_rf(dir, secure: true)
    Sprockets::staticCompiler.new(self, 'public/assets', ['*']).compile
  end

  module Helpers
    def asset_path(source) "/assets/#{Assets.instance.find_asset(source).digest_path}"
    end
  end
end
