# Generate a valid Swedish OrganisationNummer (OrgNummer; OrgNr).
#
# It must be 10 digits and the last digit must be the valid Luhn checksum, per
# https://sv.wikipedia.org/wiki/Organisationsnummer
#

require_relative '../../app/services/luhn_checksum'

class FakeOrgNummers

  MAX_NUM = 9999999999 unless defined?(MAX_NUM)
  MIN_NUM = 1 unless defined?(MIN_NUM)


  def self.generate(number_to_generate = 1)
    if number_to_generate == 1
      generate_one
    else
      generate_many(number_to_generate)
    end
  end


  def self.generate_many(number_to_generate = 2)
    results = []

    number_to_generate.times {  results << generate_one }

    results
  end


  def self.generate_one

    current_try = Random.rand(MIN_NUM..MAX_NUM)

    # just brute force keep trying until we blindly find one that validates
    # Note that LuhnChecksum.valid?(9999999999) == true So if we hit our max, we're OK because we've found one that validates with the checksum
    until LuhnChecksum.valid?(current_try)
      current_try += 1
    end
    "%010d" % "#{current_try}"  # pad with zeros as needed
  end

end
