module Scanner
	# initial scan populates db with sha1 and perms of all files listed in ~/.angel.conf
  def initial_scan
    entries = []
    CONFIG["files"].each do |f|
			if File.directory? f
        Dir.chdir(f)
        entries = Dir['**/*'].map! {|s| "#{Dir.pwd}/#{s}"}.reject { |e| File.directory? e }		# recursively collects all files in a directory
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

	# compares sha's and perms of each file in ~/.angel.conf with those in database
	# TODO has potentional to spam admin if a lot of files end up dirty.
	# needs batching; e.g. construct single email to be sent from all dirty files. 
  def fi_scan
    FileObj.all.each do |fo|
      fd = File.open(fo.abs_path)
      if dirty?(fo, fd)
				warn
				notify_admin fo if CONFIG['notify_admin']
			else
				clean
			end
      puts fo.abs_path
    end
  end

	def clear_db
		FileObj.all.destroy
	end
end
