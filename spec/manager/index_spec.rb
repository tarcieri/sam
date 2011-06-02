require 'spec_helper'
require 'tempfile'

describe Sam::Index do
  it "creates index files" do
    Tempfile.open "sam_create_index_spec" do |file|
      Sam::Index.create_file(file.path, :foo => 1, :bar => 2, :baz => 3)    
      
      index = Sam::Index.new(file.path)
      index[:foo].should == 1
      index[:bar].should == 2
      index[:baz].should == 3
    end
  end
end