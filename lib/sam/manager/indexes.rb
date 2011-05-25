require 'fileutils'

module Sam
  module Indexes
    DEFAULT_SOURCES = ['rubygems.org']
    
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
        file = "#{path}/#{source}.index"
        @@index_files[source] = file
      end
    end
  end
end