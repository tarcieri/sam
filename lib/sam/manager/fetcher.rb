require 'uri'
require 'net/http'

module Sam
  class FetchError < StandardError; end # Something went wrong fetching a file
  # General purpose HTTP fetcher
  class Fetcher
    MAX_REDIRECTS  = 10 # Maximum number of HTTP redirects to follow
    REDIRECT_CODES = %w(301 302 303 307)
    
    def initialize(uri)
      @uri = URI.parse uri
    end
    
    def data
      redirects = MAX_REDIRECTS
      response = nil
      uri = @uri
      
      while redirects >= 0
        response = Net::HTTP.get_response(uri)
        break unless REDIRECT_CODES.include?(response.code)
        
        redirects -= 1
        uri = URI.parse response['Location']
      end
      
      raise FetchError, "too many redirects" if redirects < 0
      response.body
    end
  end
end