require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe Sam::SourceIndexes do
  before do
    @index_path = Dir.mktmpdir('sam_indexes_spec')
  end
  after do
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
  end
end