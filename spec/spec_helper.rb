$LOAD_PATH << File.expand_path('../../lib', __FILE__)
FIXTURE_PATH = File.expand_path('../fixtures', __FILE__)

# Pull in RSpec mocks ahead of time before we disable RubyGems
require 'rspec/mocks'

# Remove RubyGems so we're sure we're testing our stubs
Object.send :remove_const, :Gem

# Fix RubyGems' modifications to Kernel.require
module Kernel
  alias_method :require, :gem_original_require
end

require 'sam'
require 'sam/manager'