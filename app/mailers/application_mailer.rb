class ApplicationMailer < ActionMailer::Base

  # Formatting email is tricky because you cannot use the same CSS as you can in web pages,
  # and some email servers (like Google) will strip out a lot of stuff you would
  # typically put into the <head></head> section -- like references to stylesheets.
  # So you have to make sure that most things (styles, images, etc.) are *inline*
  # in the email html source.
  # This blog post is particularly helpful describing the issues and how to handle things:
  #
  #  @url http://www.simonnordberg.com/creating-robust-email-templates-in-action-mailer/
  #

  include MailgunConfig

  include CommonMailUtils


  default from: ENV['SHF_NOREPLY_EMAIL']

  layout 'mailer'

  helper :application # gives access to all helpers defined within `application_helper`.


  # if there is a problem communicating with the MailGun REST server, log the problem
  def self.deliver_mail(mail)

    begin
      super

    rescue => e

      # This would be a great place to use the ExceptionNotification gem so we
      # can also do other notifications in case we cannot communicate at all with MailGun.

      # LOG the error
      error_prefix = '>>> MAILGUN ERROR!  '
      logger.debug ( error_prefix + "Could not send email via mailgun at #{Time.now}" )
      logger.debug { error_prefix + " Error received from Mailgun: #{e}" }

      raise e

    end
  end


  def test_email(user)
    @action_name = __method__.to_s
    @greeting_name = set_greeting_name(user)

    mail to: set_recipient_email(user), subject: t('application_mailer.greeting', greeting_name: @greeting_name)

  end


end
