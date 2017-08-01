class ShfMailer < Devise::Mailer

  # @see https://github.com/mailgun/mailgun-ruby/docs for examples
  # @see https://github.com/plataformatec/devise/wiki/How-To:-Use-custom-mailer
  #   for instructions on using this custom mailer with Devise

  default from: ENV['SHF_NOREPLY_EMAIL']
  layout 'mailer'

  DEFAULT_MAILGUN_DOMAIN = 'sverigeshundforetagare.se'

  # the following 2 lines are required to use this with Devise:
  helper :application   # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers   # access to  eg. `confirmation_url`

  # vars used in the layout:
  # @greeting_name: the name used in the greeting line.  If it is nil, no greeting line is shown


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


  # Devise methods  (is there a way to refactor these? they are all so similar)

  def confirmation_instructions(record, token, opts={})
    set_greeting_name(record)
    super
  end

  def reset_password_instructions(record, token, opts={})
    set_greeting_name(record)
    super
  end

  def unlock_instructions(record, token, opts={})
    set_greeting_name(record)
    super
  end

  def email_changed(record, opts={})
    set_greeting_name(record)
    super
  end

  def password_change(record, opts={})
    set_greeting_name(record)
    super
  end



  private

  def set_greeting_name(record)

    if record.respond_to?(:full_name)
      @greeting_name = "#{record.full_name}"
    elsif record.respond_to? :email
      @greeting_name = record.email
    end

  end

end
