require 'rubygems'
require 'bundler'

Bundler.require

Dir[File.dirname(__FILE__) + '/initializers/*.rb'].each {|file| require file }

Dir[File.dirname(__FILE__) + '/../lib/*.rb'].each {|file| require file }

require File.dirname(__FILE__) + '/../tantrum'