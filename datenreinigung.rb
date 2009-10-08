#!/usr/bin/env ruby

# dependencies
require "rubygems"
require "activerecord"

# classes
require "config"
require "cleaner"
require "distance"
require "kunde"
require "versand"
require "marketing"
require "webshop"
require "key"

# steps
require 'clean'
require 'detector'

# ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(Datenreinigung::Config['database'][Datenreinigung::Config['database']['adapter']].merge(:adapter => Datenreinigung::Config['database']['adapter']))

if __FILE__ == $0
  if ARGV.size != 1 || !%w(all clean detect).include?(ARGV[0])
    puts "usage: datenreinigung {all|clean|detect}"
  else
    if ARGV[0] == "all" || ARGV[0] == "clean"
      Clean.process
    end
    if ARGV[0] == "all" || ARGV[0] == "detect"
      Detector.process
    end
  end
end
