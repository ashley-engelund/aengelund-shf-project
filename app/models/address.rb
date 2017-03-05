class Address < ApplicationRecord

  belongs_to :addressable, polymorphic: true

  belongs_to :region


  validates_presence_of :addressable

  validates_presence_of :country


  scope :has_region, -> { where('region_id IS NOT NULL') }

  scope :lacking_region, -> { where('region_id IS NULL') }


  geocoded_by :entire_address

  after_validation :geocode,
                   :if => lambda{ |obj| obj.changed? }


  private

  def entire_address
    # Google can't handle 'Sveriges' as the country :-(
    [street_address, city,  post_code].compact.join(', ')
  end



end