class OneTimeTasker::TaskAttempt < ApplicationRecord

  validates_presence_of :task_name, :attempted_on

  # Note that Rails will still allow a _string_ for the value if you use these
  # two validations as given in the Rails 5.x guide:
  # https://guides.rubyonrails.org/active_record_validations.html
  #   validates :was_successful, inclusion: { in: [true, false] }
  #   validates :was_successful, exclusion: { in: [nil] }
  # So a custom validator is used
  validate :was_successful_is_boolean

  scope :successful, -> { where(was_successful: true) }
  scope :unsuccessful, -> { where(was_successful: false) }



  # Validation method for was_successful
  def was_successful_is_boolean

    i18n_error_key = 'activerecord.errors.models.task_attempt.attributes.was_successful.invalid'
    is_valid =  self.was_successful.is_a?(TrueClass) || self.was_successful.is_a?(FalseClass)

    errors.add(:was_successful, I18n.t(i18n_error_key, value: self.was_successful)) unless is_valid
    is_valid
  end


  # methods for readability
  def successful?
    !!was_successful  # the double '!'s ensure that you get a TrueClass or FalseClass returned. Ex: original value could be a 1 or 0
  end

  def failed?
    !was_successful
  end


end
