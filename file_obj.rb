require 'rubygems'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'

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

