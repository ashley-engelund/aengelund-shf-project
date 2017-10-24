class DinkursEvent < ApplicationRecord

  belongs_to :company

  validates_presence_of :dinkurs_id
  validates_presence_of :event_name
  validates_presence_of :event_start
  validates_presence_of :event_key
  validates_presence_of :event_url_id
  validates_presence_of :event_url_key


end
