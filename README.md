Sam: A Ruby Package Manager
===========================

Sam provides unobtrusive management for Ruby gems

Goals
-----

* Be fast
* Be *really* fast
* Minimize the runtime component as much as possible
* Stay mostly compatible with the existing RubyGems ecosystem
* Be complimentary to RubyGems instead of trying to replace it
* Combine package management and dependency resolution into a single tool
* Depend only on the Ruby standard library

Installation
------------

Sam installation presently requires git. Install Sam with the following:

    curl -s https://github.com/tarcieri/sam/raw/master/setup.rb | ruby

This script can also be used to update Sam to the latest version.

Usage
-----

Sam isn't quite ready to use yet

Why?
----

A lot of people aren't happy with how RubyGems works today. This has lead to
a slew of alternative Ruby package managers like SlimGems, rip, rup, and jerk.
While these are all noble attempts, none of them provide automatic dependency
management. Sam attempts to provide similar functionality to RubyGems and
Bundler in a single, simple-as-possible package.

Contributing
------------

* Fork Sam on github
* Make your changes and send me a pull request
* If I like them I'll merge them and give you commit access to my repository

Name
----

The name comes from the given name "Sam", but if you insist on making it into
an acronym, here are a few suggestions. Pick whichever one you like best:

* Standalone Archive Manager
* Simple Archive Manager
* Spiffy Archive Manager
* Silly Archive Manager
* Stupid Archive Manager