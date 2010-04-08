class FileObj
	include DataMapper::Resource
	include DataMapper::Timestamps

	property :id, Serial
	property :file_name, String, :length => 50
	property :abs_path, String, :length => 250
	property :sha1, String
	property :permissions, String
	property :last_checked, DateTime
	property :created_at, DateTime

	validates_is_unique :file_name

	def sha1
		SHA1.new(File.read(self.file_name)).to_s
	end
end
