class ShfMailer < ApplicationMailer

  #   @see https://github.com/mailgun/mailgun-ruby/docs for examples

  # Helper methods for creating and working with Mailgun messages and API:

  DEFAULT_MAILGUN_DOMAIN = 'sverigeshundforetagare.se'


  def mailgun_client
    Mailgun::Client.new(ENV['MAILGUN_API_KEY'])
  end


  def message_builder
    mb = Mailgun::MessageBuilder.new
    mb.from ENV['SHF_SENDER_EMAIL'] # default 'from: ' email (can overwrite as needed)
    mb
  end


  # the specific SHF domain for the Mailgun account (it's not the sandbox domain)
  def domain
    ENV.fetch('MAILGUN_DOMAIN', DEFAULT_MAILGUN_DOMAIN)
  end

end
