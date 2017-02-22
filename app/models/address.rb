class Address < ApplicationRecord

  validates_presence_of :country

  belongs_to :region

end