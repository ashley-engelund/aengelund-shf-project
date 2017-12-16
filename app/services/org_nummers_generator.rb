# Generate a valid Swedish OrganisationNummer (OrgNummer; OrgNr).
#
# It must be 10 digits and the last digit must be the valid Luhn checksum, per
# https://sv.wikipedia.org/wiki/Organisationsnummer
#

require_relative './luhn_checksum'

require 'set'

class OrgNummersGenerator

  MAX_NUM = 9999999999 unless defined?(MAX_NUM)
  MIN_NUM = 0 unless defined?(MIN_NUM)

  NONE_FOUND = nil  unless defined?(NONE_FOUND)


  def self.generate(number_to_generate = 1)

    results = Set.new

    num_tries = 0
    all_possible = MAX_NUM - MIN_NUM

    # num_tries keeps use from trying forever.
    # It is a somewhat arbitrary limit on how many times we can try.
    # Even though each try is a Random number, so it is possible to get the same number more than once,
    # this is a reasonble (if clunky) limit.
    while results.count < number_to_generate && (num_tries < all_possible) do
      number_to_generate.times do
        org_num = generate_one
        if results.add? org_num
          results.add org_num
          num_tries += 1
        end
      end

    end

    results
  end


  def self.generate_one

    current_try = Random.rand(MIN_NUM..MAX_NUM)

    # just brute force keep trying until we blindly find one that validates
    # Note that LuhnChecksum.valid?(9999999999) == true So if we hit our max, we're OK because we've found one that validates with the checksum
    until LuhnChecksum.valid?(current_try)
      current_try += 1
    end
    "%010d" % "#{current_try}" # pad with zeros as needed
  end

end
