# Interface to Dinkurs.se
# https://dinkurs.se

require 'date'



class DinkursService

  require 'httparty'

  SUCCESS_CODES = [200, 201, 202].freeze


  # return a collection of all events for this Dinkurs company id
  #  will return an empty collection if there are no events from Dinkurs
  #   (which may be the case if the company id is not recognized by Dinkurs)
  #
  def self.get_events(dinkurs_company_id)

    dk_events = []

    xml_event_response = get_dikurs_event_xml(dinkurs_company_id)

    unless xml_event_response['events'].nil?

      xml_event_response['events'].fetch('event', []).each do |event|

        #event_place: ['event_place']['__content__'] TODO,

        dk_event = DinkursEvent.new(dinkurs_id: event['event_id'].first,
                                    event_name: event['event_name']['__content__'],
                                    event_start: DateTime.parse( event['event_start']['__content__']),
                                    event_key: event['event_key']['__content__'],
                                    event_url_id: event['event_url_id']['__content__'],
                                    event_url_key: event['event_url_key']['__content__']
        )

        dk_events << dk_event
      end

    end

    dk_events

    #   begin
    #     raise "Error: #{error['type']}, #{error['message']}"
    #   rescue RuntimeError
    #     raise "HTTP Status: #{response.code}, #{response.message}"
    #   end

  end


  def self.get_dikurs_event_xml(dinkurs_company_id)

    url = DINKURS_XML_URL + '?' + DINKURS_COMPANY_ARG + "=#{dinkurs_company_id}"

    response = HTTParty.get(url, debug_output: $stdout)

    return response.parsed_response if SUCCESS_CODES.include?(response.code)

    error = parsed_response['error']

    begin
      raise "Error: #{error['type']}, #{error['message']}"
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end


end
