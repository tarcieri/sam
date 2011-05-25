require 'pstore'

module Sam
  # Maintains an index of packages available on a given gem server
  class PackageIndex
    # Create a new package index at the given path
    def initialize(filename)
      @store = PStore.new filename
    end
    
    # Load raw gem specification data
    def load_specs(data)
      # Load all specs in a single transaction
      @store.transaction do
        Marshal.load(data).each do |name, version, platform|
          name = name.intern
          platforms = @store[name] || {}
          platforms[platform] = version.to_s
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