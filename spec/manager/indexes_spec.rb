require 'spec_helper'

describe Sam::Indexes do
  context :environment do
    it "knows the path to the indexes" do
      Sam::Indexes.path.should == "~/.sam/indexes"
    end
    
    it "knows the sources" do
      Sam::Indexes.sources.should == ["rubygems.org"]
    end
  end
end