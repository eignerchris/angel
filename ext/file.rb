require 'sha1'

class File
  def sha1
    SHA1.new(self.read.to_s).to_s
  end

  def perms
    self.stat.mode.to_s
  end
end
