require 'spec_helper'

describe Sam::Fetcher do
  it "fetches files via HTTP" do
    fetcher = Sam::Fetcher.new "http://rubygems.org/latest_specs.4.8"
    data = fetcher.data
    Marshal.load(data).should be_an_instance_of(Array)
  end
end