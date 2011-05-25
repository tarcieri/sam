# Stubs of various RubyGems classes needed for unmarshaling indexes
module Gem
  class Version
    attr_reader :version
    alias_method :to_s, :version
    
    def marshal_load(version)
      @version = version.first
    end
  end
end