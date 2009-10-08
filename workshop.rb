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

# Clean.process
# Detector.new("nachvorstrasse", true).process
