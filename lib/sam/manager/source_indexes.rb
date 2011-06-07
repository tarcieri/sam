require 'fileutils'
require 'uri'

module Sam
  module SourceIndexes
    DEFAULT_SOURCES = ['http://rubygems.org']
    
    # Make all methods callable via self
    extend self
    
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
      @@index_cache = {}
      
      sources.each do |source|
        uri = URI.parse(source)
        file = "#{path}/#{uri.host}.index"
        @@index_files[source] = file
        
        update source unless File.exist? file
      end
      
      true
    end
    
    # Retrieve a package from all available indexes
    def find(package_name)
      sources.each do |source|
        index = index_cache(source)        
        package = index[package_name]
        return package if package
      end
      
      nil
    end
    alias_method :[], :find
    
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
    
    # Obtain an index from the index cache
    def index_cache(source)
      @@index_cache[source] ||= SourceIndex.new(@@index_files[source])
    end
  end
end