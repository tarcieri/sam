require 'spec_helper'
require 'benchmark'

describe Sam::Fetcher do
  it "fetches files via HTTP" do
    fetcher = Sam::Fetcher.new "http://rubygems.org/latest_specs.4.8"
    data = fetcher.data
    Marshal.load(data).should be_an_instance_of(Array)
  end
  
  it "fetches files via HTTP and gunzips them" do
    fetcher = Sam::Fetcher.new "http://rubygems.org/latest_specs.4.8.gz"
    data = fetcher.data :gz
    
    marshal_time = Benchmark.measure do
      Marshal.load(data).should be_an_instance_of(Array)
    end
    
    puts "Marshal.load time: #{marshal_time}"
  end
end