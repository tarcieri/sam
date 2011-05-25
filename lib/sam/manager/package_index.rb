require 'pstore'
require 'zlib'
require 'stringio'

module Sam
  # Maintains an index of packages available on a given gem server
  class PackageIndex
    GZIP_MAGIC = [31, 139] # Magic numbers for gzip files
    
    # Create a new package index at the given path
    def initialize(filename)
      @store = PStore.new filename
    end
    
    # Find a gem in the index
    def find(name, platform = 'ruby')
      @store.transaction do 
        package = @store[name]
        package[platform] if package
      end
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
            
      # Load all specs in a single transaction
      @store.transaction do
        Marshal.load(data).each do |name, version, platform|
          platforms = @store[name] || {} # Don't clobber existing data
          platforms[platform] ||= {} # Ditto
          platforms[platform][:latest_version] = version.to_s
          @store[name] = platforms
        end
      end
    end
    
    # List all gems currently in the index
    def list
      @store.transaction { @store.roots }
    end
    
    # Count of how many gems are in the index
    def count
      list.size
    end
  end
end