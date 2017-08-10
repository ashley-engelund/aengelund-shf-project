class ShfMailer < Devise::Mailer

  # @see https://github.com/mailgun/mailgun-ruby/tree/master/docs for examples
  # @see https://github.com/plataformatec/devise/wiki/How-To:-Use-custom-mailer
  #   for instructions on using this custom mailer with Devise

  default from: ENV['SHF_NOREPLY_EMAIL']
  layout 'mailer'


  # the following 2 lines are required to use this with Devise:
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # access to  eg. `confirmation_url`

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
    ENV['MAILGUN_DOMAIN']
  end


  # Set the instance var @greeting_name before calling each Devise method via super
  %w(
      confirmation_instructions
      reset_password_instructions
      unlock_instructions
      email_changed
      password_change
      ).each do |method|

    define_method(method) do |resource, *args|
      set_greeting_name(resource)
      super(resource, *args)
    end

  end


  def accept(member_application)

    #member_application = MembershipApplication.find(7)
    @action_name = 'accept'
    @greeting_name = set_greeting_name(member_application.user)

    mail(to: member_application.user.email , subject: t('shf_mailer.membership_application.accept.subject') )

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
