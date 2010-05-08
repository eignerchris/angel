#!/usr/bin/ruby

require 'rubygems'
require 'do_mysql'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'yaml'

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
		%x(notify-send "#{f} has been tampered with")
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

	def check_file_integrity(f)
		fo = FileObj.all(:abs_path => f).first
		fd = File.open(f)
		sha = fd.sha1
		perms = fd.perms
		tampered_with?(fo, sha, perms)
	end

	def tampered_with?(fo, sha, perms)
		fo.sha1 != sha or fo.perms != perms
	end

	def fi_scan
		CONFIG["files"].each do |f|
			notify_admin if tampered_with?(f)
		end
	end

	def run
		case @action
		when /init|-i/
			intial_scan
		when /scan|-s/
			fi_scan
		else
			usage
		end
	end

end

App.new
