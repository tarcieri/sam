require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe Sam::SourceIndexes do
  before :all do
    @index_path = Dir.mktmpdir('sam_indexes_spec')
  end
  after :all do
    FileUtils.rm_rf @index_path
  end
  
  context :environment do
    it "configures path to indexes" do
      Sam::SourceIndexes.path = @index_path
      Sam::SourceIndexes.path.should == @index_path
    end
    
    it "knows the sources" do
      Sam::SourceIndexes.sources.should == ["http://rubygems.org"]
    end
    
    it "sets up the environment" do
      Sam::SourceIndexes.path = @index_path
      
      proc do
        Sam::SourceIndexes.setup
      end.should_not raise_exception
    end
    
    it "locates packages" do
      Sam::SourceIndexes.path = @index_path
      Sam::SourceIndexes.setup
      
      info = Sam::SourceIndexes['rack']
      info.should be_an_instance_of(Hash)
    end
  end
end

INDEX_FILE    = '/tmp/package.index'
EXAMPLE_SPECS = FIXTURE_PATH + "/source/latest_specs.4.8"

describe Sam::SourceIndex do
  before do
    FileUtils.rm_rf INDEX_FILE 
    @index = Sam::SourceIndex.new INDEX_FILE
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
    @index['dependency_free']['0.0.1'].should be_has_key('ruby')
  end
  
  context :import do
    before :each do
      FileUtils.rm_rf INDEX_FILE 
      @index = Sam::SourceIndex.new INDEX_FILE
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