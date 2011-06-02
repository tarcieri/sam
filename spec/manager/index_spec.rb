require 'spec_helper'
require 'tempfile'

describe Sam::Index do
  before do
    @tempfile = Tempfile.new "sam_index_spec"
    @path = @tempfile.path
    
    Sam::Index.create_file(@path, :foo => 1, :bar => 2, :baz => 3)
    @index = Sam::Index.new @path
  end
  
  after do
    @tempfile.close
  end
  
  it "finds entries" do
    @index[:foo].should == 1
    @index[:bar].should == 2
    @index[:baz].should == 3
  end
  
  it "knows its size" do
    @index.size.should == 3
  end
  
  it "enumerates keys" do
    keys = @index.keys
    
    keys.size.should == 3
    keys.should be_include(:foo)
    keys.should be_include(:bar)
    keys.should be_include(:baz)
  end
  
  it "iterates with each" do
    hash = {}
    
    @index.each do |key, value|
      hash[key] = value
    end
    
    hash.size.should == 3
    hash[:foo].should == 1
    hash[:bar].should == 2
    hash[:baz].should == 3
  end
  
  it "converts to a hash" do
    hash = @index.to_hash
    
    hash.size.should == 3
    hash[:foo].should == 1
    hash[:bar].should == 2
    hash[:baz].should == 3
  end
end