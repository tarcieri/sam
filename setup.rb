#!/usr/bin/env ruby

require 'rbconfig'
require 'fileutils'

include FileUtils

BIN_DIR  = RbConfig::CONFIG['bindir']
SITE_LIB = RbConfig::CONFIG['sitelibdir']
REPO_URL = "https://github.com/tarcieri/sam.git"
REPO_DIR = 'sam_repo'
REPO_PATH = "#{SITE_LIB}/#{REPO_DIR}" 

# TTY functions for controlling colors
module Tty
  # Add all functions to self
  module_function
  
  def blue; bold 34; end
  def white; bold 39; end
  def red; underline 31; end
  
  def reset; escape 0; end
  def bold(n); escape "1;#{n}" end
  def underline(n); escape "4;#{n}" end
  def escape(n); "\033[#{n}m" end
  
  # OHAI!!
  def ohai(something, tty = STDOUT)
    tty.puts "#{blue}*** #{white}#{something}#{reset}"
  end
  
  def yeow(something, tty = STDOUT)
    tty.puts "#{red}#{something}#{reset}"
  end
end

def got_git?
  `git --version`[/^git version/]
end

def git(*args)
  unless system "git", *args
    Tty.yeow "ERROR: git failed"
    exit 1
  end
end

unless got_git?
  Tty.yeow "ERROR: git not found. Please install git first"
  exit 1
end

new_repo = false

mkdir_p SITE_LIB

unless File.directory?("#{REPO_PATH}/.git")
  new_repo = true
  Tty.ohai "Cloning Sam git repository"
  Dir.chdir SITE_LIB
  git "clone", REPO_URL, REPO_DIR
end

unless new_repo
  Tty.ohai "Updating Sam git repository"
  Dir.chdir REPO_PATH
  git "pull"
end

Tty.ohai "Updating symlinks"

rm_f SITE_LIB + "/sam.rb"
ln_s REPO_PATH + "/lib/sam.rb", SITE_LIB + "/sam.rb"

rm_f SITE_LIB + "/sam"
ln_s REPO_PATH + "/lib/sam", SITE_LIB + "/sam"

rm_f BIN_DIR + "/sam"
ln_s REPO_PATH + "/bin/sam", BIN_DIR + "/sam"

Tty.ohai "Done!"

puts <<-ohai

SUCCESS! Sam is now installed as:

\t#{BIN_DIR}/sam

You can install gems with:

\tsam install <gem name>

And list installed gems with:

\tsam list

Type "sam help" for additional usage information

ohai