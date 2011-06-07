require 'spec_helper'
require 'tmpdir'

describe Sam::PackageManager do
  before :all do
    @source_index_path = Dir.mktmpdir('sam_package_manager_spec_source_index')
    Sam::SourceIndexes.path = @source_index_path
    Sam::SourceIndexes.setup
          
    @package_path = Dir.mktmpdir('sam_package_manager_spec_packages')
    @pm = Sam::PackageManager.new @package_path
  end
  after :all do
    FileUtils.rm_rf @source_index_path
    FileUtils.rm_rf @package_path
  end
  
  it "finds packages" do
    @pm['rack'].should be_an_instance_of(Sam::Package)
  end
  
  it "installs packages" do
    @pm.install 'rack'
    @pm['rack'].should be_installed
  end
end