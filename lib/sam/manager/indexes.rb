module Sam
  module Indexes
    DEFAULT_SOURCES = ['rubygems.org']
    
    # Make all methods callable via self
    module_function
    
    # Path to the index files
    def path
      "~/.sam/indexes"
    end
    
    # Gem sources
    def sources; DEFAULT_SOURCES; end
  end
end