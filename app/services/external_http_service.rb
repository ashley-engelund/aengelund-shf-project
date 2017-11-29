class ExternalHTTPService

  require 'httparty'

  SUCCESS_CODES = [200, 201, 202].freeze


  # Basic method for getting a response from some external service
  # via HTTParty
  #
  # subclasses can just override the 'get_ ...' methods or they can
  # override this method completely
  def self.get_response(*args)

    response = HTTParty.get(response_url(args),
                            headers: response_headers(args))

    return response.parsed_response if return_immediately?(response)

    processed_response = process(response)

    return processed_response if return_after_processing?(processed_response)

    error = set_error(processed_response)

    begin
      raise "Error: #{error['type']}, #{error['message']}"
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end

  end


  # child classes MUST override this
  # @param args [Array] - arguments passed in to self.get_item so that they are all available as needed for any subclass that overrides this method
  # @return [String] the url that will be sent to HTTParty to get the response
  def self.response_url(*args)
    raise ::NotImplementedError, "You must define the 'response_url' class method."
  end


  # child classes can override as needed
  # @param args [Array] - arguments passed in to self.get_item so that they are all available as needed for any subclass that overrides this method
  # @return [Hash]  headers that must be explicitly set
  def self.response_headers(*args)
    {}
  end


  # child classes can override as needed
  #
  # If needed, this can test the response immediately after it is received.
  # Return true if the calling method should return immediately after this is called
  # @return [Boolean]
  def self.return_immediately?(response)
    response.respond_to?(:code) && SUCCESS_CODES.include?(response.code)
  end


  # opportunity to do something with the response
  # child classes can override this as needed
  def self.process(response)
    response
  end


  # child classes can override as needed
  #
  # If needed, this can test the response immediately after it is received.
  # Return true if the calling method should return immediately after this is called
  # @return [Boolean]
  def self.return_after_processing?(processed_response)
    false
  end

  # child classes can override as needed
  #
  # @return error information that can be used if an Error is raised
  def self.set_error(processed_response)
    processed_response.nil? ? nil : processed_response.fetch('error', nil)
  end

end
