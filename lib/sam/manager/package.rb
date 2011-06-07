module Sam
  # Packages represent individual gems
  class Package
    def initialize(name, index = nil)
      @name, @index = name, index
      @source_data = nil # loads lazily
    end
    
    # Raw hash from the source index
    def source_data
      @source_data ||= SourceIndexes[@name]
    end
    
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
end