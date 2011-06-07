require 'spec_helper'

describe Sam::PackageManager do
  context "source index operations" do
    # TESTME: Sam::Package::SourceMethods#source_data
    it "retrieves source data for a package"
    
    # TESTME: Sam::Package::SourceMethods#latest_version
    it "knows the latest version of a package"
  end
  
  context "local operations" do  
    # TESTME: Sam::Package::LocalMethods#index_data
    it "retrieves data from the local package index"
  
    # TESTME: Sam::Package::LocalMethods#installed?
    it "knows when a package is installed"
  end
end