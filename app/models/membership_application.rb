class MembershipApplication < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :business_categories
  has_many :uploaded_files

  validates_presence_of :first_name,
                        :last_name,
                        :company_number,
                        :contact_email,
                        :status
  validates_length_of :company_number, is: 10
  validates_format_of :contact_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]
  accepts_nested_attributes_for :uploaded_files, allow_destroy: true

end
