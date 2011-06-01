require 'fileutils'
require 'uri'

module Sam
  module Indexes
    DEFAULT_SOURCES = ['http://rubygems.org']
    
    # Make all methods callable via self
    module_function
    
    # Path to the index files
    def path
      @@path ||= "~/.sam/indexes"
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
      specs = Fetcher.new("#{source}/specs.4.8.gz")
      PackageIndex.new(@@index_files[source]).load_specs specs.data
    end
  end
end