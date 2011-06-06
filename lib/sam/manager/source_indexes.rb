require 'fileutils'
require 'uri'
require 'zlib'
require 'stringio'

module Sam
  module SourceIndexes
    DEFAULT_SOURCES = ['http://rubygems.org']
    
    # Make all methods callable via self
    module_function
    
    # Path to the index files
    def path
      @@path ||= File.join(Sam.path, 'indexes')
    end
    def path=(new_path)
      @@path = new_path
    end
    
    # Gem sources
    def sources; DEFAULT_SOURCES; end
    
    # Setup the indexes
    def setup
      FileUtils.mkdir_p path
      @@index_files = {}
      
      sources.each do |source|
        uri = URI.parse(source)
        file = "#{path}/#{uri.host}.index"
        @@index_files[source] = file
        
        update source unless File.exist? file
      end
      
      true
    end
    
    # Update a given source
    def update(source)
      Tty.ohai "Updating package index for #{source}"
      specs = Fetcher.new("#{source}/specs.4.8.gz").data
      
      Tty.print "Rebuilding index... "
      
      started_at = Time.now
      SourceIndex.new(@@index_files[source]).load_specs specs
      indexing_time = Time.now - started_at
      
      Tty.puts "done. (#{"%.2f" % indexing_time} secs)"
    end
  end
  
  # Maintains an index of packages available on a given gem server
  class SourceIndex
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
      
      packages = {}
      
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