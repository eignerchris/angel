# sets up environment (database, dependencies, etc.) for angel

require 'rubygems'
require 'bundler'
require 'yaml'

Bundler.setup
Bundler.require :default

# require .rb files in ext/ and lib/
cwd = File.expand_path(File.join(File.dirname(__FILE__)))
['lib', 'ext'].each do |d|
	Dir.glob(File.join(cwd, d, '*.rb')).each { |f| require f }
end

# load yaml config file from home dir
CONFIG_FILE = File.join("#{ENV['HOME']}/.angel.conf")
CONFIG = YAML::load_file(CONFIG_FILE)

# setup connection to mysql database named 'angel'.
# can be local or external, preferably external.
# DataMapper.setup(:external, 'mysql://user:password@39.120.32.11/db_name')
DataMapper.setup(:default, {
    :adapter  => 'mysql',
    :host     => 'localhost',
    :username => CONFIG['mysql_user'],
    :password => CONFIG['mysql_pass'],
    :database => 'angel'
})

DataMapper.auto_upgrade!

# setup mailer config for notifications
if CONFIG['notify_admin']
	SMTP_CONFIG = {
    :address              => CONFIG['smtp_server'],
    :port                 => CONFIG['smtp_port'],
    :enable_starttls_auto => true,
    :user_name            => CONFIG['smtp_user'],
    :password             => CONFIG['smtp_pass'],
    :authentication       => :plain
	}
end
