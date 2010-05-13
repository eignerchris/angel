#!/usr/bin/ruby

require 'rubygems'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'yaml'
require 'sha1'

CONFIG_FILE = File.join("#{ENV['HOME']}/.angel.conf")
CONFIG = YAML::load_file(CONFIG_FILE)

# setup connection to mysql database.
# can be local or external, preferably external.
# DataMapper.setup(:external, 'mysql://user:password@39.120.32.11/db_name')
DataMapper.setup(:default, {
    :adapter  => 'mysql',
    :host     => 'localhost',
    :username => CONFIG['mysql_user'],
    :password => CONFIG['mysql_pass'],
    :database => 'angel'
})

class FileObj
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :abs_path, String, :length => 500
  property :sha1, String
  property :perms, String
  property :created_at, DateTime

  validates_is_unique :abs_path
end

DataMapper.auto_upgrade!

module Notifier

  def clean
    print "[\e[32mCLEAN\e[0m]"
  end

  def warn
    print "[\e[31mWARNING\e[0m]"
  end

  def notify_admin(fo)
    # TODO: add notify options
    # twitter for easy sms warning?
    # mailer config?
  end
end

class File
  def sha1
    SHA1.new(self.read.to_s).to_s
  end

  def perms
    self.stat.mode.to_s
  end
end

class App
  include Notifier

  def initialize
    @action = ARGV[0]
    run
  end

  def initial_scan
    entries = []
    CONFIG["files"].each do |f|
			if File.directory? f
        Dir.chdir(f)
        entries = Dir['**/*'].map! {|s| "#{Dir.pwd}/#{s}"}.reject { |e| File.directory? e }
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

  def dirty?(fo, fd)
    (fo.sha1 == fd.sha1 and fo.perms == fd.perms) == false ? true : false
  end

  def fi_scan
    FileObj.all.each do |fo|
      fd = File.open(fo.abs_path)
      dirty?(fo, fd) ? warn : clean
      puts fo.abs_path
    end
  end

  def usage
    puts "
     -i, init		intializes database info about files listed in .angel.conf
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
