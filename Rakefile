require 'bundler'
require 'rspec/core/rake_task'

desc 'Default: run specs'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new

FIXTURE_GEM_PATHS = Dir['spec/fixtures/gems/*']

namespace :spec do
  namespace :gems do
    gem_packages = []
    
    FIXTURE_GEM_PATHS.each do |gem_path|
      gem_name = gem_path[/\w+$/]
      gem_file = "#{gem_path}/pkg/#{gem_name}-0.0.1.gem"
      gem_packages << gem_file
      
      file gem_file do
        sh "cd #{gem_path} && rake build"
      end
    end
    
    desc "Build .gem files for all fixture gems"
    task :build => gem_packages
  end
end