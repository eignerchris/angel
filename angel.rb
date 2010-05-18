#!/usr/bin/ruby

require 'rubygems'
require 'yaml'
require 'file_obj'
require 'file'
require 'notifier'
require 'env'

class App
  include Notifier

  def initialize
    @action = ARGV[0]
    run
  end

	# initial scan populates db with sha1 and perms of all files listed in ~/.angel.conf
  def initial_scan
    entries = []
    CONFIG["files"].each do |f|
			if File.directory? f
        Dir.chdir(f)
        entries = Dir['**/*'].map! {|s| "#{Dir.pwd}/#{s}"}.reject { |e| File.directory? e }					# recursively collects all files in a directory
				entries.each { |f| store_file_data f }
			else
				store_file_data f
			end
    end
  end

  def store_file_data(f)
    fd = File.open(f) 
    sha1 = fd.sha1
    perms = fd.stat.mode
    fo = FileObj.create(:abs_path => f, :sha1 => sha1, :perms => perms)
		puts "added #{fo.abs_path}"
  end

	# checks if file has been tampered with
  def dirty?(fo, fd)
    (fo.sha1 == fd.sha1 and fo.perms == fd.perms) == false ? true : false
  end

	# file integrity scan compares sha's and perms of each file in ~/.angel.conf with those in database; reports any dirty files.
  def fi_scan
    FileObj.all.each do |fo|
      fd = File.open(fo.abs_path)
      dirty?(fo, fd) ? warn : clean
      puts fo.abs_path
    end
  end

  def usage
    puts "
     -i, init		populates database with sha1 and perms of files listed in ~/.angel.conf
     -s, scan		performs file integrity scan against files in database
		"
  end

	def clear_db
		FileObj.all.destroy
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
