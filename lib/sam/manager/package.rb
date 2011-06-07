module Sam
  class InvalidPackageError < StandardError; end # Package isn't in the index
  
  # Packages represent individual gems
  class Package
    def initialize(name, index = nil)
      @name, @index = name, index
      @source_data = nil # loads lazily
      
      index_data # confirm package is in the index
    end
    
    # Methods which operate on the source index
    module SourceMethods
      # Raw hash from the source index
      def source_data
        @source_data ||= SourceIndexes[@name]
      end
      
      # Obtain the latest version
      def latest_version
        p source_data
      end
    end
    include SourceMethods
    
    # Methods which operate on locally installed packages
    module LocalMethods
      # Retrieve the index data
      def index_data
        raise "no index specified for this package" unless @index
        @index[@name]
      end
    
      # Is the package installed?
      def installed?
        data = index_data
        data && index_data[:installed]
      end
    end
    include LocalMethods
  end
end