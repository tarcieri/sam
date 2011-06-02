module Sam
  VERSION = "0.0.1"
  
  def self.version; VERSION; end
  def self.path; File.expand_path("~/.sam"); end
end