# Calculate the Luhn checksum of a number or a string that represents a number
# Use the Luhn algorithm to calculate the checksum)
#
# Return true or false if a string (that represents a number) or number passes the Luhn checksum test
#
#
# @url https://en.wikipedia.org/wiki/Luhn_algorithm
# @url https://rosettacode.org/wiki/Luhn_test_of_credit_card_numbers
#
class LuhnChecksum

  #
  # Does the last digit of the number meet the Luhn checksum test?
  #
  # @param [ Integer | String ] integer_or_str to check
  # @return Boolean - true if the checksum mod 10 == 0 (meets the test), else false
  #   returns false for nil
  #   returns false for an empty string
  #   returns false if a string does not have any digits
  #   removes any non-digit characters from the string (INCLUDING a PERIOD!) and then checks the resulting Integer
  #
  def self.valid?(integer_or_str)

    if no_digits?(integer_or_str)
      false
    else
      for_number(integer_or_str) % 10 == 0
    end

  end


  # Return the Luhn checksum for a number.
  # @param [ Integer | String ] integer_or_str
  # @return Integer - the Luhn checksum number calculated for the (integer representation of) integer_or_str
  #   if the string is nil or has no digits, return 1 (just need to return any non-zero value)
  #
  # checksum = 0
  # From the rightmost digit, which is the check digit, and moving left:
  #  double the value of every other (2nd) digit.
  #    If the result of this doubling operation is greater than 9 (e.g., 8 × 2 = 16),
  #              then add the digits of the product (e.g., 16: 1 + 6 = 7, 18: 1 + 8 = 9)
  #              or, alternatively, the same result can be found by subtracting 9 from the product (e.g., 16: 16 − 9 = 7, 18: 18 − 9 = 9).
  #    add this value to the checksum
  #  if you aren't doubling the digit, just add it to the checksum.
  #
  #
  # Note the the checksum of 0 = 0
  #  and  any leading zeros will add 0 to the checksum, so they don't matter
  #
  def self.for_number(integer_or_str)

    if no_digits?(integer_or_str)
      1
    else

      checksum = 0
      digits = integer_or_str.to_s.reverse.scan(/\d/).map { |d| d.to_i } # convert to all digits and reverse

      digits.each_slice(2) do |odd, even|
        double = even.to_i * 2
        double -= 9 if double > 9
        checksum += double + odd
      end

      checksum
    end

  end


  private

  def self.no_digits?(integer_or_str)
    integer_or_str.nil? || integer_or_str.to_s.scan(/\d/).empty? # nil or if there are no digits
  end

end
