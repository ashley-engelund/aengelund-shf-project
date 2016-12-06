class User < ApplicationRecord
  has_many :membership_applications
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def has_membership_application?
    membership_applications.size > 0
  end

  def has_company?
    has_membership_application? && !membership_applications.last.company.nil?
  end

end
