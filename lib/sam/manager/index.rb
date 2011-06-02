

module Sam
  class Index
    MAGIC_DATA   = "SamI" # Identify Sam Index files
    KEYS_PADDING = 50 # Additional space to provide for keys data
    
    # Create a new index file from the given hash
    def self.create_file(path, hash = {})
      keys = {}
      data = ""
      data_index = 0
      
      hash.each do |key, obj|
        obj_data = Marshal.dump obj
        
        length_header = [obj_data.size].pack("N")
        data << length_header
        data << obj_data
        
        keys[key] = data_index
        data_index += 4 + obj_data.size        
      end
      
      keys_data = Marshal.dump keys
      keys_data << 0.chr * KEYS_PADDING
      
      # Add a length 
      header = MAGIC_DATA.dup
      header << [keys_data.size].pack("N")
      
      File.open(path, 'w', 0644) do |index_file|
        index_file << header
        index_file << keys_data
        index_file << data
      end
    end
    
    # Open a Sam Index
    def initialize(path)
      @path = path
      
      if File.exist? path
        process_header
      else
        @keys = {}
      end
    end
    
    def [](key)
      File.open(@path) do |file|
        read_entry file, key
      end
    end
    
    def keys
      @keys.keys
    end
    
    def each
      File.open(@path) do |file|
        keys.each do |key, _|
          yield key, read_entry(file, key)
        end
      end
    end
    
    def to_hash
      hash = {}
      each { |key, value| hash[key] = value }
      hash
    end
    
    #######
    private
    #######
    
    # Read the file header and cache the keys
    def process_header
      File.open(@path) do |file|
        unless file.read(4) == MAGIC_DATA
          raise ArgumentError, "couldn't find Sam Index header"
        end
      
        keys_size, _ = file.read(4).unpack("N")
        @keys = Marshal.load file.read(keys_size)
        @offset = 8 + keys_size
      end
    end
    
    # Read an entry from the given file
    def read_entry(file, key)
      index = @keys[key]
      return unless index
      
      file.seek @offset + index
      length, _ = file.read(4).unpack("N")
      Marshal.load file.read(length)
    end
  end
end