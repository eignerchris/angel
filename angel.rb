#!/usr/bin/ruby

require 'rubygems'
require 'yaml'
require 'env'

cwd = File.expand_path(File.join(File.dirname(__FILE__)))
['lib', 'ext'].each do |d|
	Dir.glob(File.join(cwd, d, '*.rb')).each { |f| require f }
end

class App
  include Notifier
	include Scanner

  def initialize
    @action = ARGV[0]
    run
  end

  def usage
    puts "
     -i, init		populates database with sha1 and perms of files listed in ~/.angel.conf
     -s, scan		performs file integrity scan against files in database
		"
  end

  def run
    case @action
    when /init|-i/
			clear_db
      initial_scan
    when /scan|-s/
      fi_scan
    when /help|-h/
      usage
    else
      usage
    end
  end
end

App.new
