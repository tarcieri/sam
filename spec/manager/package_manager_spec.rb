require 'spec_helper'
require 'tmpdir'

describe Sam::PackageManager do
  before do
    @package_path = Dir.mktmpdir('sam_package_manager_spec')
    @pm = Sam::PackageManager.new @package_path
  end
  after do
    FileUtils.rm_rf @index_path
  end
  
  it "installs packages" do
    @pm.install 'rack'
    @pm['rack'].should be_installed
  end
end