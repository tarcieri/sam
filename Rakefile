require 'rake/clean'
require 'bundler'
require 'rspec/core/rake_task'

desc 'Default: run specs'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new

FIXTURE_GEM_PATHS = Dir["spec/fixtures/gems/*"]
FIXTURE_GEMS = []
FIXTURE_SOURCE_GEMS = []

FIXTURE_GEM_PATHS.each do |gem_dir|
  gem_name = gem_dir[/\w+$/]
  gem_filename = "#{gem_name}-0.0.1.gem"
  gem_path = "#{gem_dir}/pkg/#{gem_filename}"
  FIXTURE_GEMS << gem_path
  
  file gem_path do
    sh "cd #{gem_dir} && rake build"
  end
  
  source_path = "spec/fixtures/source/gems/#{gem_filename}"
  file source_path => gem_path do
    cp gem_path, source_path
  end
  
  FIXTURE_SOURCE_GEMS << source_path
end

namespace :spec do
  desc "Build .gem files for all fixture gems"
  task :gems do
    task :build => FIXTURE_GEMS
  end
  
  latest_specs = "spec/fixtures/source/latest_specs.4.8"
  file latest_specs => FIXTURE_SOURCE_GEMS do
    sh "cd spec/fixtures/source && gem generate"
  end
  
  desc "Build an example gem source"
  task :source => latest_specs
end

Rake::Task['spec'].enhance %w[spec:source]

CLEAN.add FileList["spec/fixtures/gems/**/pkg"]
CLEAN.add FileList["spec/fixtures/source/gems/*.gem"]
CLEAN.add FileList["spec/fixtures/source/**/*4.8*"]
CLEAN.add FileList["spec/fixtures/source/quick"]