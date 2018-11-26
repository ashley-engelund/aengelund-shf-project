module ConvertArgsToHashUtility

  private

  # @param arg_string [String] - a comma separated list, where each item is of
  #         the form 'key=value'
  #         Ex: "keyOne=valueOne"
  #         Ex: "keyOne=valueOne,keyTwo=valueTwo"
  # @return [Hash] - a Hash where each key is the key from each item, converted to a symbol,
  #         and the value is the associated value for that key.
  #         Ex: "keyOne=valueOne" returns {keyOne: "valueOne"}
  #         Ex: "keyOne=valueOne,keyTwo=valueTwo"
  #           returns {keyOne: "valueOne", keyTwo: "valueTwo"}
  def hash_from_argstring(arg_string)
    hash = {}
    arg_string.split(',').each do |arg|
      key, value = arg.split('=')
      hash[key.to_sym] = value
    end
    hash
  end

end
