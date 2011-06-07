require 'spec_helper'
require 'benchmark'
require 'tmpdir'

describe Sam::Fetcher do
  it "fetches files via HTTP" do
    fetcher = Sam::Fetcher.new "http://rubygems.org/latest_specs.4.8"
    data = fetcher.data
    Marshal.load(data).should be_an_instance_of(Array)
  end
  
  it "downloads files to disk" do
    Dir.mktmpdir('sam_fetcher_download_spec') do |tempdir|
      path = File.join(tempdir, "latest-specs.4.8")
      fetcher = Sam::Fetcher.new "http://rubygems.org/latest_specs.4.8"
      fetcher.save_to path
      
      File.should be_exists(path)
    end
  end
  
  it "fetches files via HTTP and gunzips them" do
    fetcher = Sam::Fetcher.new "http://rubygems.org/latest_specs.4.8.gz"
    data = fetcher.data :gz
    Marshal.load(data).should be_an_instance_of(Array)
  end
end