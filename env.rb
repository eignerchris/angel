require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'

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

DataMapper.auto_upgrade!
