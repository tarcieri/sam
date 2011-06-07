require 'uri'
require 'net/http'
require 'zlib'
require 'stringio'

module Sam
  class FetchError < StandardError; end # Something went wrong fetching a file
  # General purpose HTTP fetcher
  class Fetcher
    MAX_REDIRECTS  = 10 # Maximum number of HTTP redirects to follow
    
    def initialize(uri)
      @uri = URI.parse uri
      @filename = uri[/[\w\-\.]+$/]
    end
    
    # Retrieve the data 
    def data(filter = nil)
      body = ""
      download body, filter
      body
    end
    
    # Save the data to disk
    def save_to(path)
      File.open(path, 'w', 0644) do |file|
        download file
      end
      true
    end
    
    #######
    private
    #######
    
    # Download the file to the given handle
    def download(output, filter = nil)
      redirects = MAX_REDIRECTS
      response = nil
      uri = @uri
      
      success = false
      until success
        raise FetchError, "too many redirects" unless redirects > 0 
        
        Net::HTTP.get_response(uri) do |response|
          case response.code.to_i
          when 301, 302, 303, 307 # redirect     
            redirects -= 1
            uri = URI.parse response['Location']
          when 200
            success = true
            read_body response, output, filter
          else raise FetchError, "#{response.code} #{response.message}"
          end
        end
      end
          
      output
    end
    
    # Fetch the body returned from a request
    def read_body(response, output, filter_type)
      total_bytes = Integer(response['Content-Length'])
      progress = Progress.new @filename, total_bytes
      filter = Filter.new filter_type if filter_type
      
      response.read_body do |data|
        progress.update data.size
        data = filter.process data if filter
        output << data
      end
      
      filter.finish if filter
      progress.done
      true
    end
    
    # Filter for decompressing data on the fly
    class Filter
      def initialize(type)
        raise ArgumentError, "invalid filter: #{type}" unless type == :gz
        
        @io = StringIO.new
        @zstream = Zlib::Inflate.new(-Zlib::MAX_WBITS)
        @unskipped = 10 # gzip header size
      end
      
      def process(input)
        # Strip gzip headers
        if @unskipped > 0
          if input.size < @unskipped
            @unskipped -= input.size
            return ""
          else
            input = input.slice @unskipped, input.size - @unskipped
            @unskipped = 0
          end
        end
        
        @zstream.inflate input
      end
      
      def finish
        @zstream.finish
        @zstream.close
      end
    end
    
    # Display download progress
    class Progress
      OUTPUT_TTY = STDERR # Print to STDERR by default
      BAR_WIDTH  = 16 # Number of cells in the progress bar
      BAR_CHAR   = "#"
      
      # Transfer rate moving average stuffins
      MIN_SAMPLES = 5   # Minimum number of samples needed to display rate
      MAX_SAMPLES = 10  # Number of samples in transfer rate moving average
      SAMPLE_RATE = 0.05 # Minimum amount of time for a transfer rate sample
      
      def initialize(filename, total_bytes)
        @filename, @total_bytes = filename, total_bytes
        @total_kb = "#{(@total_bytes / 1000.0).ceil} kB"
        @current_bytes = 0
        
        @current_sample = 0
        @rate_samples = []
        @rate_sum = 0.0
        @rate_timestamp = @started_at = Time.now
        
        print false
      end
      
      def update(bytes)
        @current_bytes  += bytes
        @current_sample += bytes
        
        old_timestamp = @rate_timestamp
        new_timestamp = Time.now
        sample_duration = new_timestamp - old_timestamp
        
        if sample_duration >= SAMPLE_RATE
          @rate_timestamp = new_timestamp 
          transfer_rate = @current_sample / sample_duration
          @current_sample = 0
        
          @rate_samples << transfer_rate
          old_rate = @rate_samples.size > MAX_SAMPLES ? @rate_samples.shift : 0
          @rate_sum += transfer_rate - old_rate
        end
        
        print false, true
      end
      
      def done
        @current_bytes = @total_bytes
        
        # Fudge moving average vars to get a real transfer rate
        if @rate_samples.size >= MIN_SAMPLES
          @rate_sum = @total_bytes / (Time.now - @started_at)
          @rate_sum *= MIN_SAMPLES
          @rate_samples = [@rate_sum] * MIN_SAMPLES
        end
        
        print true, true
      end
      
      def print(new_line = true, updating = false)
        percentage = @current_bytes.to_f / @total_bytes
        current_kb = "#{(@current_bytes / 1000.0).ceil} kB"
        
        if @rate_samples.size < MIN_SAMPLES
          transfer_rate = ""
        else
          rate = @rate_sum / (@rate_samples.size * 1000.0)
          transfer_rate = ", %0.2f kB/s" % rate
        end
        
        status = ""
        status << "\r" if updating
        status << "%3d%% [" % (percentage * 100).to_i
        
        full_cells = (percentage * BAR_WIDTH).ceil
        status << BAR_CHAR * full_cells
        status << " " * (BAR_WIDTH - full_cells)
        
        status << "] #{@filename}"  
        status << " (#{current_kb}/#{@total_kb}#{transfer_rate})" if updating
        
        status << "\n" if new_line
        
        OUTPUT_TTY.print status
      end
    end
  end
end