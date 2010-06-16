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
