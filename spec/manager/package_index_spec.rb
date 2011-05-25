require 'spec_helper'
require 'fileutils'

INDEX_FILE    = '/tmp/package.index'
EXAMPLE_SPECS = FIXTURE_PATH + "/source/latest_specs.4.8"

describe Sam::PackageIndex do
  context :import do
    before :each do
      FileUtils.rm_rf INDEX_FILE 
      @index = Sam::PackageIndex.new INDEX_FILE
    end
    
    it "imports latest_specs.4.8 files" do
      @index.load_specs File.read(EXAMPLE_SPECS)
      @index.count.should == Dir[FIXTURE_PATH + "/gems"].size
    end
    
    it "imports latest_specs.4.8.gz files" do
      @index.load_specs File.read(EXAMPLE_SPECS + '.gz')
      @index.count.should == Dir[FIXTURE_PATH + "/gems"].size
    end
  end
end