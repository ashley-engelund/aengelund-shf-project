class MembershipApplication < ApplicationRecord
  belongs_to :user

  has_many :uploaded_files
  accepts_nested_attributes_for :uploaded_files, allow_destroy: true,
                                reject_if: lambda {|attributes| attributes['actual_file_file_name'].blank?}

  validates_presence_of :company_name,
                        :company_number,
                        :company_email,
                        :contact_person,
                        :status
  validates_length_of :company_number, is: 10
  validates_format_of :company_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]

end
