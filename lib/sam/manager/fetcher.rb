require 'uri'
require 'net/http'

module Sam
  class FetchError < StandardError; end # Something went wrong fetching a file
  # General purpose HTTP fetcher
  class Fetcher
    MAX_REDIRECTS  = 10 # Maximum number of HTTP redirects to follow
    
    def initialize(uri)
      @uri = URI.parse uri
      @filename = uri[/[\w\.]+$/]
    end
    
    def data(tty = true)
      redirects = MAX_REDIRECTS
      response = nil
      uri = @uri
      
      body = nil
      until body
        Net::HTTP.get_response(uri) do |response|
          case response.code.to_i
          when 301, 302, 303, 307 # redirect
            raise FetchError, "too many redirects" unless redirects > 0  
            redirects -= 1
            uri = URI.parse response['Location']
          when 200
            total_bytes = Integer(response['Content-Length'])
            progress = Progress.new @filename, total_bytes
            body = ""
            
            response.read_body do |chunk|
              body << chunk
              progress.update chunk.size
            end
            
            progress.done
          else raise FetchError, "#{response.code} #{response.message}"
          end
        end
      end
          
      body
    end
    
    # Display download progress
    class Progress
      OUTPUT_TTY = STDERR # Print to STDERR by default
      BAR_WIDTH  = 20 # Number of cells in the progress bar
      BAR_CHAR   = "#"
      
      # Transfer rate moving average stuffins
      MIN_SAMPLES = 5   # Minimum number of samples needed to display rate
      MAX_SAMPLES = 10  # Number of samples in transfer rate moving average
      SAMPLE_RATE = 0.1 # Minimum amount of time for a transfer rate sample
      
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
        @rate_sum = @total_bytes / (Time.now - @started_at)
        @rate_sum *= MIN_SAMPLES
        @rate_samples = [@rate_sum] * MIN_SAMPLES
        
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
        status << "#{@filename}: %3d%%" % (percentage * 100).to_i
        
        if updating
          full_cells = (percentage * BAR_WIDTH).ceil
          
          status << " ["
          status << BAR_CHAR * full_cells
          status << " " * (BAR_WIDTH - full_cells)
          
          status << "] (#{current_kb}/#{@total_kb}#{transfer_rate})"
        end
        
        status << "\n" if new_line
        
        OUTPUT_TTY.print status
      end
    end
  end
end