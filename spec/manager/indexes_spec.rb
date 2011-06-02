require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe Sam::Indexes do
  before do
    @index_path = Dir.mktmpdir('sam_indexes_spec')
  end
  after do
    FileUtils.rm_rf @index_path
  end
  
  context :environment do
    it "configures path to indexes" do
      Sam::Indexes.path = @index_path
      Sam::Indexes.path.should == @index_path
    end
    
    it "knows the sources" do
      Sam::Indexes.sources.should == ["http://rubygems.org"]
    end
    
    it "sets up the environment" do
      Sam::Indexes.path = @index_path
      
      proc do
        Sam::Indexes.setup
      end.should_not raise_exception
    end
  end
end