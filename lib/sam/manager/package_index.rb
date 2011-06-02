require 'zlib'
require 'stringio'

module Sam
  # Maintains an index of packages available on a given gem server
  class PackageIndex
    GZIP_MAGIC = [31, 139] # Magic numbers for gzip files
    
    # Create a new package index at the given path
    def initialize(path)
      @path  = path
      @index = Index.new path
    end
    
    # Find a gem in the index
    def find(name)
      @index[name]
    end
    alias_method :[], :find
    
    # Load Marshalled specification data (e.g. specs.4.8)
    def load_specs(data)
      old_data = data
      
      if data.bytes.first(2) == GZIP_MAGIC
        gz = Zlib::GzipReader.new StringIO.new(data)
        data = gz.read
        gz.close
      end
      
      packages = @index.to_hash
      
      Marshal.load(data).each do |name, version, platform|
        version = version.to_s
        
        versions = packages[name] || {} # Don't clobber existing data
        versions[version] ||= {} # Ditto
        versions[version][platform] ||= nil # specific data unfetched
        packages[name] = versions
      end
      
      Index.create_file @path, packages
    end
    
    # List all gems currently in the index
    def list
      @index.keys
    end
    
    # Count of how many gems are in the index
    def count
      @index.size
    end
  end
end