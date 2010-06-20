module Notifier

  def clean
    print "[\e[32mCLEAN\e[0m]"
  end

  def warn
    print "[\e[31mWARNING\e[0m]"
  end

  def notify_admin(fo)
		begin
		  Pony.mail(
						:to => CONFIG['admin_to_email'],
						:via => :smtp,
						:via_options => SMTP_CONFIG,
						:subject => 'WARNING!',
		        :body => "#{fo.abs_path} is dirty!")
		rescue Exception => e
			puts e.inspect
		end 
  end
end
