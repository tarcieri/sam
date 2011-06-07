module Sam
  VERSION = "0.0.1"
  def self.version; VERSION; end
  
  # Path to Sam indexes and caches
  def self.path; File.expand_path("~/.sam"); end
  
  # Path to installed packages
  def self.package_path(environment = :default)
    data_root_dir = RbConfig::CONFIG['datarootdir']
    File.join data_root_dir, 'sam', environment.to_s
  end
end