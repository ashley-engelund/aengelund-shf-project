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
    has_membership_application? && (membership_applications.select { |app| app.company }).count > 0
  end


  def membership_application
    has_membership_application? ? membership_applications.last : nil
  end


  def company
    has_company? ? membership_application.company : nil
  end


  def admin?
    admin
  end


  def is_member?
    has_membership_application? && (membership_applications.select{|m| m.is_member? }.count > 0 )
  end


  def is_member_or_admin?
    admin? || is_member?
  end


  def is_in_company_numbered?(company_num)
    is_member? && !(companies.detect { |c| c.company_number == company_num }).nil?
  end


  def companies
    if admin?
      Company.all
    elsif is_member_or_admin? && has_membership_application?
      cos = membership_applications.reload.map(&:company).compact
      cos.uniq(&:company_number)
    else
      [] # no_companies
    end
  end
end

