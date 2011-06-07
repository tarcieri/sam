require 'fileutils'

module Sam
  class PackageManager
    include FileUtils
    
    def initialize(path)
      @path  = path
      @index = Index.new File.join(path, 'installed.index')
      @cache = {}
    end
    
    def [](name)
      @cache[name] ||= Package.new(name, @index)
    end
    
    def install(package_name, version = nil, platform = 'ruby')
      package = self[package_name]
      
      cache_path = File.join(@path, 'cache')
      mkdir_p cache_path
      
      version ||= package.latest_version
      fetcher = Fetcher.new package.url(version)
      
      filename = "#{package_name}-#{version}.gem"
      gem_path = File.join(cache_path, filename)
      fetcher.save_to gem_path
      
      #package.install gem_path
    end
  end
end