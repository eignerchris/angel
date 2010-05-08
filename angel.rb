#!/usr/bin/ruby

require 'rubygems'
require 'do_mysql'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'yaml'
require 'sha1'

CONFIG_FILE = File.join(".angel.conf")
CONFIG = YAML::load_file(CONFIG_FILE)

# can be local or external...
# DataMapper.setup(:external, 'mysql://user:password@39.120.32.11/db_name')
DataMapper.setup(:default, 'mysql://root:@localhost/angel')


class FileObj
	include DataMapper::Resource
	include DataMapper::Timestamps

	property :id, Serial
	property :abs_path, String, :length => 500
	property :sha1, String
	property :perms, Integer
	property :created_at, DateTime

	validates_is_unique :abs_path
end

module Notifier
	def notify_admin(f)
		puts "#{f} has been tampered with"
	end
end

class File
	def sha1
		SHA1.new(self.read.to_s)
	end

	def perms
		self.stat.mode
	end
end

class App
	include Notifier

	def initialize
		@action = ARGV[0]
		run
	end

	def initial_scan
		CONFIG["files"].each do |f|
			store_file_data(f)
		end
	end
	
	def store_file_data(f)
		fd = File.open(f) 
		sha1 = fd.sha1
		perms = fd.stat.mode
		FileObj.create(:abs_path => f, :sha1 => sha1, :perms => perms)
	end

	def clean?(fo, fd)
		(fo.sha1 == fd.sha1 and fo.perms != fd.perms) == true ? true : false
	end

	def fi_scan
		CONFIG["files"].each do |f|
			fo = FileObj.first(:abs_path => f)
			fd = File.open(f)
			notify_admin(f) if clean?(fo, fd)
		end
	end

	def usage
		puts "
			-i, init		intializes database with hashes of files listed in .angel.conf
			-s, scan		performs file integrity scan against sha1's in database
		"
	end

	def run
		case @action
		when /init|-i/
			initial_scan
		when /scan|-s/
			fi_scan
		else
			usage
		end
	end

end

App.new
