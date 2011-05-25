require 'spec_helper'
require 'fileutils'

INDEX_FILE    = '/tmp/package.index'
EXAMPLE_SPECS = FIXTURE_PATH + "/source/latest_specs.4.8"

describe Sam::PackageIndex do
  before do
    FileUtils.rm_rf INDEX_FILE 
    @index = Sam::PackageIndex.new INDEX_FILE
    @index.load_specs File.read(EXAMPLE_SPECS)
  end
  
  it "lists available packages" do
    list = @index.list
    gems = Dir[FIXTURE_PATH + "/gems/*"].map { |path| path[/\w+$/] }
    gems.each do |gem|
      list.should include(gem)
    end
  end
  
  it "counts available packages" do
    @index.count.should == Dir[FIXTURE_PATH + "/gems/*"].size
  end
  
  it "locates packages" do
    @index['dependency_free'].should be_an_instance_of(Hash)
  end
  
  it "extracts package versions correctly" do
    @index['dependency_free'][:version].should == "0.0.1"
  end
  
  context :import do
    before :each do
      FileUtils.rm_rf INDEX_FILE 
      @index = Sam::PackageIndex.new INDEX_FILE
    end
    
    it "imports latest_specs.4.8 files" do
      @index.load_specs File.read(EXAMPLE_SPECS)
      @index.count.should == Dir[FIXTURE_PATH + "/gems/*"].size
    end
    
    it "imports latest_specs.4.8.gz files" do
      @index.load_specs File.read(EXAMPLE_SPECS + '.gz')
      @index.count.should == Dir[FIXTURE_PATH + "/gems/*"].size
    end
  end
end