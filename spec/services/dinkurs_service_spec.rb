require 'rails_helper'


require_relative(File.join(__dir__, '..', '..', 'app', 'services', 'dinkurs_service'))

# record: :new_episodes


# 'fetched_response' must contain the response. ex:
#      it_behaves_like 'a successful company events fetch' do
#           let(:fetched_response) { valid_fetched_event }
#      end
#
RSpec.shared_examples 'a successful company events fetch' do

  it 'is a Hash' do
    expect(fetched_response).to be_instance_of(Hash)
  end

  it 'events is the top level' do
    expect(fetched_response.keys).to match_array(['events'])
  end


end


RSpec.describe DinkursService, :vcr do

  # use this block to ensure the response is in UTF-8 (and not ASCII which may be binary):
  VCR.configure do |c|
    c.before_record do |i|
      i.response.body.force_encoding('UTF-8')
    end
  end


  VALID_COMPANY_ID = 'yFKGQJ'


  describe '.get_events' do

    # mock the response

    # noinspection RubyStringKeysInHashInspection
    let(:valid_co_response) {
      { "events" =>
            { "event" =>
                  [{ "event_id" => ["28613", { "__content__" => "28613", "type" => "PropertyNumber" }],
                     "event_name" => { "__content__" => "Betaling (DKK)", "type" => "PropertyString" },
                     "event_place" => nil,
                     "event_place_geometry_location" => nil,
                     "event_host" => { "__content__" => "Demo Din Kurs", "type" => "PropertyString" },
                     "event_fee" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_fee_tax" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_pub" => { "__content__" => "2015-02-06", "type" => "PropertyDate" },
                     "event_apply" => { "__content__" => "2100-01-01", "type" => "PropertyDate" },
                     "event_start" => { "__content__" => "2100-01-01", "type" => "PropertyDate" },
                     "event_stop" => { "__content__" => "2100-01-01", "type" => "PropertyDate" },
                     "event_participant_number" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participant_reserve" =>
                         { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participants" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_occasions" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_group" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_position" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_instructor_1" => nil,
                     "event_instructor_2" => nil,
                     "event_instructor_3" => nil,
                     "event_parking" => { "__content__" => "3", "type" => "PropertyNumber" },
                     "event_commenttext" => nil,
                     "event_ticket_info" => nil,
                     "event_key" => { "__content__" => "PEpnLgEsMLFBlGjV", "type" => "PropertyString" },
                     "event_currency_id" => { "__content__" => "3", "type" => "PropertyNumber" },
                     "event_default_client_numbers" => nil,
                     "event_url_id" =>
                         { "__content__" => "https://dinkurs.se/appliance/?event_id=28613",
                           "type" => "PropertyString" },
                     "event_url_key" =>
                         { "__content__" =>
                               "https://dinkurs.se/appliance/?event_key=PEpnLgEsMLFBlGjV",
                           "type" => "PropertyString" },
                     "event_infotext" => nil,
                     "event_completion_text" => nil,
                     "event_aftertext" => nil,
                     "event_event_dates" => nil },
                   { "event_id" => ["30016", { "__content__" => "30016", "type" => "PropertyNumber" }],
                     "event_name" => { "__content__" => "Betalning (SEK)", "type" => "PropertyString" },
                     "event_place" => nil,
                     "event_place_geometry_location" => nil,
                     "event_host" => { "__content__" => "Demo Din Kurs", "type" => "PropertyString" },
                     "event_fee" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_fee_tax" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_pub" => { "__content__" => "2015-04-15", "type" => "PropertyDate" },
                     "event_apply" => { "__content__" => "2100-01-01", "type" => "PropertyDate" },
                     "event_start" => { "__content__" => "2100-01-01", "type" => "PropertyDate" },
                     "event_stop" => { "__content__" => "2100-01-01", "type" => "PropertyDate" },
                     "event_participant_number" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participant_reserve" =>
                         { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participants" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_occasions" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_group" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_position" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_instructor_1" => nil,
                     "event_instructor_2" => nil,
                     "event_instructor_3" => nil,
                     "event_parking" => { "__content__" => "3", "type" => "PropertyNumber" },
                     "event_commenttext" => nil,
                     "event_ticket_info" => nil,
                     "event_key" => { "__content__" => "MRCLQjAQUStcThxB", "type" => "PropertyString" },
                     "event_currency_id" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_default_client_numbers" => nil,
                     "event_url_id" =>
                         { "__content__" => "https://dinkurs.se/appliance/?event_id=30016",
                           "type" => "PropertyString" },
                     "event_url_key" =>
                         { "__content__" =>
                               "https://dinkurs.se/appliance/?event_key=MRCLQjAQUStcThxB",
                           "type" => "PropertyString" },
                     "event_infotext" => nil,
                     "event_completion_text" => nil,
                     "event_aftertext" => nil,
                     "event_event_dates" => nil },
                   { "event_id" => ["26296", { "__content__" => "26296", "type" => "PropertyNumber" }],
                     "event_name" =>
                         { "__content__" => "Nyhetsbrevslista", "type" => "PropertyString" },
                     "event_place" => nil,
                     "event_place_geometry_location" => nil,
                     "event_host" => { "__content__" => "Demo", "type" => "PropertyString" },
                     "event_fee" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_fee_tax" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_pub" => { "__content__" => "2014-10-20", "type" => "PropertyDate" },
                     "event_apply" => { "__content__" => "2100-01-01", "type" => "PropertyDate" },
                     "event_start" => { "__content__" => "2100-01-01", "type" => "PropertyDate" },
                     "event_stop" => { "__content__" => "2100-01-01", "type" => "PropertyDate" },
                     "event_participant_number" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participant_reserve" =>
                         { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participants" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_occasions" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_group" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_position" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_instructor_1" => nil,
                     "event_instructor_2" => nil,
                     "event_instructor_3" => nil,
                     "event_parking" => { "__content__" => "4", "type" => "PropertyNumber" },
                     "event_commenttext" =>
                         { "__content__" =>
                               "Här ser du dina sändlistor. En sändlista är en samling adresser som du kan använda för att skicka nyhetsbrev till. Du kan även skicka nyhetsbrev till deltagare i ett evenemang.",
                           "type" => "PropertyString" },
                     "event_ticket_info" => nil,
                     "event_key" => { "__content__" => "qPZFJwFENEqVwcvI", "type" => "PropertyString" },
                     "event_currency_id" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_default_client_numbers" => nil,
                     "event_url_id" =>
                         { "__content__" => "https://dinkurs.se/appliance/?event_id=26296",
                           "type" => "PropertyString" },
                     "event_url_key" =>
                         { "__content__" =>
                               "https://dinkurs.se/appliance/?event_key=qPZFJwFENEqVwcvI",
                           "type" => "PropertyString" },
                     "event_infotext" => nil,
                     "event_completion_text" => nil,
                     "event_aftertext" => nil,
                     "event_event_dates" => nil },
                   { "event_id" => ["42356", { "__content__" => "42356", "type" => "PropertyNumber" }],
                     "event_name" => { "__content__" => "Biljetter", "type" => "PropertyString" },
                     "event_place" => { "__content__" => "Elsewhere AB", "type" => "PropertyString" },
                     "event_place_geometry_location" =>
                         { "__content__" => "(55.6077948, 13.005606100000023)",
                           "type" => "PropertyString" },
                     "event_host" => { "__content__" => "Demo", "type" => "PropertyString" },
                     "event_fee" => { "__content__" => "10", "type" => "PropertyNumber" },
                     "event_fee_tax" => { "__content__" => "2", "type" => "PropertyNumber" },
                     "event_pub" => { "__content__" => "2016-11-18", "type" => "PropertyDate" },
                     "event_apply" => { "__content__" => "2017-11-29", "type" => "PropertyDate" },
                     "event_start" => { "__content__" => "2017-12-15", "type" => "PropertyDate" },
                     "event_stop" => { "__content__" => "2017-12-15", "type" => "PropertyDate" },
                     "event_participant_number" =>
                         { "__content__" => "500", "type" => "PropertyNumber" },
                     "event_participant_reserve" =>
                         { "__content__" => "2", "type" => "PropertyNumber" },
                     "event_participants" => { "__content__" => "91", "type" => "PropertyNumber" },
                     "event_occasions" => { "__content__" => "4", "type" => "PropertyNumber" },
                     "event_group" => { "__content__" => "10", "type" => "PropertyNumber" },
                     "event_position" => { "__content__" => "3", "type" => "PropertyNumber" },
                     "event_instructor_1" => nil,
                     "event_instructor_2" => nil,
                     "event_instructor_3" => nil,
                     "event_parking" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_commenttext" => nil,
                     "event_ticket_info" => nil,
                     "event_key" => { "__content__" => "QKCVGOObDgLCHVRY", "type" => "PropertyString" },
                     "event_currency_id" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_default_client_numbers" => nil,
                     "event_url_id" =>
                         { "__content__" => "https://dinkurs.se/appliance/?event_id=42356",
                           "type" => "PropertyString" },
                     "event_url_key" =>
                         { "__content__" =>
                               "https://dinkurs.se/appliance/?event_key=QKCVGOObDgLCHVRY",
                           "type" => "PropertyString" },
                     "event_infotext" => nil,
                     "event_completion_text" => nil,
                     "event_aftertext" => { "__content__" => "Yolo", "type" => "PropertyString" },
                     "event_event_dates" =>
                         { "event_date" =>
                               [{ "event_date_url" =>
                                      "https://dinkurs.se/forms/event_dates_create_cal.asp?event_id=&event_dates_id=3585",
                                  "event_date_start" => "2011-01-01",
                                  "event_date_stop" => "2011-04-09",
                                  "event_date_place" => nil,
                                  "event_date_info" => nil,
                                  "event_date_id" => "3585" },
                                { "event_date_url" =>
                                      "https://dinkurs.se/forms/event_dates_create_cal.asp?event_id=&event_dates_id=2928",
                                  "event_date_start" => "2016-11-26",
                                  "event_date_stop" => "2016-11-26",
                                  "event_date_place" => nil,
                                  "event_date_info" => nil,
                                  "event_date_id" => "2928" },
                                { "event_date_url" =>
                                      "https://dinkurs.se/forms/event_dates_create_cal.asp?event_id=&event_dates_id=2929",
                                  "event_date_start" => "2016-11-27",
                                  "event_date_stop" => "2016-11-27",
                                  "event_date_place" => nil,
                                  "event_date_info" => nil,
                                  "event_date_id" => "2929" },
                                { "event_date_url" =>
                                      "https://dinkurs.se/forms/event_dates_create_cal.asp?event_id=&event_dates_id=2930",
                                  "event_date_start" => "2016-11-28",
                                  "event_date_stop" => "2016-11-28",
                                  "event_date_place" => nil,
                                  "event_date_info" => nil,
                                  "event_date_id" => "2930" },
                                { "event_date_url" =>
                                      "https://dinkurs.se/forms/event_dates_create_cal.asp?event_id=&event_dates_id=2931",
                                  "event_date_start" => "2016-11-29",
                                  "event_date_stop" => "2016-11-29",
                                  "event_date_place" => nil,
                                  "event_date_info" => nil,
                                  "event_date_id" => "2931" }],
                           "type" => "PropertyString" } },
                   { "event_id" => ["43493", { "__content__" => "43493", "type" => "PropertyNumber" }],
                     "event_name" =>
                         { "__content__" => "Grundkurs om eventry.", "type" => "PropertyString" },
                     "event_place" => { "__content__" => "Fågelvägen 8,", "type" => "PropertyString" },
                     "event_place_geometry_location" =>
                         { "__content__" => "(56.2360185, 14.535028900000043)",
                           "type" => "PropertyString" },
                     "event_host" => { "__content__" => "Demo", "type" => "PropertyString" },
                     "event_fee" => { "__content__" => "10", "type" => "PropertyNumber" },
                     "event_fee_tax" => { "__content__" => "2", "type" => "PropertyNumber" },
                     "event_pub" => { "__content__" => "2017-01-12", "type" => "PropertyDate" },
                     "event_apply" => { "__content__" => "2018-01-30", "type" => "PropertyDate" },
                     "event_start" => { "__content__" => "2018-01-30", "type" => "PropertyDate" },
                     "event_stop" => { "__content__" => "2018-01-30", "type" => "PropertyDate" },
                     "event_participant_number" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participant_reserve" =>
                         { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participants" => { "__content__" => "32", "type" => "PropertyNumber" },
                     "event_occasions" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_group" => { "__content__" => "10", "type" => "PropertyNumber" },
                     "event_position" => { "__content__" => "3", "type" => "PropertyNumber" },
                     "event_instructor_1" => nil,
                     "event_instructor_2" => nil,
                     "event_instructor_3" => nil,
                     "event_parking" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_commenttext" => nil,
                     "event_ticket_info" => nil,
                     "event_key" => { "__content__" => "PPCDTNJrDvrFMBoX", "type" => "PropertyString" },
                     "event_currency_id" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_default_client_numbers" => nil,
                     "event_url_id" =>
                         { "__content__" => "https://dinkurs.se/appliance/?event_id=43493",
                           "type" => "PropertyString" },
                     "event_url_key" =>
                         { "__content__" =>
                               "https://dinkurs.se/appliance/?event_key=PPCDTNJrDvrFMBoX",
                           "type" => "PropertyString" },
                     "event_infotext" => { "__content__" => "ghfddz", "type" => "PropertyString" },
                     "event_completion_text" => nil,
                     "event_aftertext" => nil,
                     "event_event_dates" => nil },
                   { "event_id" => ["47250", { "__content__" => "47250", "type" => "PropertyNumber" }],
                     "event_name" => { "__content__" => "Test", "type" => "PropertyString" },
                     "event_place" => { "__content__" => "Demo", "type" => "PropertyString" },
                     "event_place_geometry_location" => nil,
                     "event_host" => { "__content__" => "Demo", "type" => "PropertyString" },
                     "event_fee" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_fee_tax" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_pub" => { "__content__" => "2017-06-21", "type" => "PropertyDate" },
                     "event_apply" => { "__content__" => "2018-06-21", "type" => "PropertyDate" },
                     "event_start" => { "__content__" => "2018-06-21", "type" => "PropertyDate" },
                     "event_stop" => { "__content__" => "2018-06-21", "type" => "PropertyDate" },
                     "event_participant_number" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participant_reserve" =>
                         { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participants" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_occasions" => { "__content__" => "2", "type" => "PropertyNumber" },
                     "event_group" => { "__content__" => "10", "type" => "PropertyNumber" },
                     "event_position" => { "__content__" => "3", "type" => "PropertyNumber" },
                     "event_instructor_1" => nil,
                     "event_instructor_2" => nil,
                     "event_instructor_3" => nil,
                     "event_parking" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_commenttext" => nil,
                     "event_ticket_info" => nil,
                     "event_key" => { "__content__" => "INhjhxvPAJIDNErZ", "type" => "PropertyString" },
                     "event_currency_id" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_default_client_numbers" => nil,
                     "event_url_id" =>
                         { "__content__" => "https://dinkurs.se/appliance/?event_id=47250",
                           "type" => "PropertyString" },
                     "event_url_key" =>
                         { "__content__" =>
                               "https://dinkurs.se/appliance/?event_key=INhjhxvPAJIDNErZ",
                           "type" => "PropertyString" },
                     "event_infotext" => nil,
                     "event_completion_text" => nil,
                     "event_aftertext" => nil,
                     "event_event_dates" => nil },
                   { "event_id" => ["48712", { "__content__" => "48712", "type" => "PropertyNumber" }],
                     "event_name" =>
                         { "__content__" => "Deltagarhantering har aldrig varit enklare!",
                           "type" => "PropertyString" },
                     "event_place" => { "__content__" => "Östergatan", "type" => "PropertyString" },
                     "event_place_geometry_location" =>
                         { "__content__" => "(55.60756180000001, 13.003679599999941)",
                           "type" => "PropertyString" },
                     "event_host" => { "__content__" => "Demo", "type" => "PropertyString" },
                     "event_fee" => { "__content__" => "125", "type" => "PropertyNumber" },
                     "event_fee_tax" => { "__content__" => "25", "type" => "PropertyNumber" },
                     "event_pub" => { "__content__" => "2017-09-22", "type" => "PropertyDate" },
                     "event_apply" => { "__content__" => "2018-12-31", "type" => "PropertyDate" },
                     "event_start" => { "__content__" => "2018-12-31", "type" => "PropertyDate" },
                     "event_stop" => { "__content__" => "2018-12-31", "type" => "PropertyDate" },
                     "event_participant_number" =>
                         { "__content__" => "1234", "type" => "PropertyNumber" },
                     "event_participant_reserve" =>
                         { "__content__" => "56", "type" => "PropertyNumber" },
                     "event_participants" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_occasions" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_group" => { "__content__" => "10", "type" => "PropertyNumber" },
                     "event_position" => { "__content__" => "3", "type" => "PropertyNumber" },
                     "event_instructor_1" => nil,
                     "event_instructor_2" => nil,
                     "event_instructor_3" => nil,
                     "event_parking" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_commenttext" => nil,
                     "event_ticket_info" => nil,
                     "event_key" => { "__content__" => "kNzMWFFQTWKBgLPM", "type" => "PropertyString" },
                     "event_currency_id" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_default_client_numbers" => nil,
                     "event_url_id" =>
                         { "__content__" => "https://dinkurs.se/appliance/?event_id=48712",
                           "type" => "PropertyString" },
                     "event_url_key" =>
                         { "__content__" =>
                               "https://dinkurs.se/appliance/?event_key=kNzMWFFQTWKBgLPM",
                           "type" => "PropertyString" },
                     "event_infotext" =>
                         { "__content__" =>
                               "<p><strong>Office 365 är en samlingsterm för Microsoft's cloud tjänster.&amp;nbsp;</strong></p><p>&amp;nbsp;</p><p>Saas (Software as a Service) modelen ersätter den gamla standarden av köp, nedladdgning samt installation av mjukvara på varje dator på arbetsplatsen. Grundtanken är att premuneration på tjänster ger åtkomst till ditt office 24 timmar om dygnet 365 dagar om året. Så även om du loggar in på en tablet eller smart telefon på resa, en bärbar dator i sängen eller en arbetsstation på ditt kontor, kan du komma åt alla de verktyg eller information du behöver. Flera enhe</p>",
                           "type" => "PropertyString" },
                     "event_completion_text" => nil,
                     "event_aftertext" => nil,
                     "event_event_dates" => nil },
                   { "event_id" => ["13343", { "__content__" => "13343", "type" => "PropertyNumber" }],
                     "event_name" =>
                         { "__content__" => "Beställningsformulär", "type" => "PropertyString" },
                     "event_place" => nil,
                     "event_place_geometry_location" => nil,
                     "event_host" => { "__content__" => "Demo Din Kurs", "type" => "PropertyString" },
                     "event_fee" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_fee_tax" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_pub" => { "__content__" => "2012-08-21", "type" => "PropertyDate" },
                     "event_apply" => { "__content__" => "2022-06-08", "type" => "PropertyDate" },
                     "event_start" => { "__content__" => "2022-06-08", "type" => "PropertyDate" },
                     "event_stop" => { "__content__" => "2022-06-08", "type" => "PropertyDate" },
                     "event_participant_number" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participant_reserve" =>
                         { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participants" => { "__content__" => "2", "type" => "PropertyNumber" },
                     "event_occasions" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_group" => { "__content__" => "10", "type" => "PropertyNumber" },
                     "event_position" => { "__content__" => "3", "type" => "PropertyNumber" },
                     "event_instructor_1" => nil,
                     "event_instructor_2" => nil,
                     "event_instructor_3" => nil,
                     "event_parking" => { "__content__" => "2", "type" => "PropertyNumber" },
                     "event_commenttext" => nil,
                     "event_ticket_info" => nil,
                     "event_key" => { "__content__" => "pTPQREGNgBXGNMQn", "type" => "PropertyString" },
                     "event_currency_id" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_default_client_numbers" => nil,
                     "event_url_id" =>
                         { "__content__" => "https://dinkurs.se/appliance/?event_id=13343",
                           "type" => "PropertyString" },
                     "event_url_key" =>
                         { "__content__" =>
                               "https://dinkurs.se/appliance/?event_key=pTPQREGNgBXGNMQn",
                           "type" => "PropertyString" },
                     "event_infotext" => nil,
                     "event_completion_text" => nil,
                     "event_aftertext" => nil,
                     "event_event_dates" => nil },
                   { "event_id" => ["26230", { "__content__" => "26230", "type" => "PropertyNumber" }],
                     "event_name" => { "__content__" => "Intresselista", "type" => "PropertyString" },
                     "event_place" =>
                         { "__content__" => "Intresselista/Nyhetsbrev", "type" => "PropertyString" },
                     "event_place_geometry_location" => nil,
                     "event_host" => { "__content__" => "Demo Din Kurs", "type" => "PropertyString" },
                     "event_fee" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_fee_tax" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_pub" => { "__content__" => "2014-10-15", "type" => "PropertyDate" },
                     "event_apply" => { "__content__" => "2015-12-31", "type" => "PropertyDate" },
                     "event_start" => { "__content__" => "2040-01-01", "type" => "PropertyDate" },
                     "event_stop" => { "__content__" => "2040-01-01", "type" => "PropertyDate" },
                     "event_participant_number" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participant_reserve" =>
                         { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participants" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_occasions" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_group" => { "__content__" => "10", "type" => "PropertyNumber" },
                     "event_position" => { "__content__" => "3", "type" => "PropertyNumber" },
                     "event_instructor_1" => nil,
                     "event_instructor_2" => nil,
                     "event_instructor_3" => nil,
                     "event_parking" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_commenttext" => nil,
                     "event_ticket_info" => nil,
                     "event_key" => { "__content__" => "LGbRBLplIUHsNJHF", "type" => "PropertyString" },
                     "event_currency_id" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_default_client_numbers" => nil,
                     "event_url_id" =>
                         { "__content__" => "https://dinkurs.se/appliance/?event_id=26230",
                           "type" => "PropertyString" },
                     "event_url_key" =>
                         { "__content__" =>
                               "https://dinkurs.se/appliance/?event_key=LGbRBLplIUHsNJHF",
                           "type" => "PropertyString" },
                     "event_infotext" => nil,
                     "event_completion_text" => nil,
                     "event_aftertext" => nil,
                     "event_event_dates" => nil },
                   { "event_id" => ["41988", { "__content__" => "41988", "type" => "PropertyNumber" }],
                     "event_name" => { "__content__" => "stav", "type" => "PropertyString" },
                     "event_place" => { "__content__" => "Stavsnäs", "type" => "PropertyString" },
                     "event_place_geometry_location" =>
                         { "__content__" => "(59.2911887, 18.690457000000038)",
                           "type" => "PropertyString" },
                     "event_host" => { "__content__" => "Demo", "type" => "PropertyString" },
                     "event_fee" => { "__content__" => "300", "type" => "PropertyNumber" },
                     "event_fee_tax" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_pub" => { "__content__" => "2016-11-14", "type" => "PropertyDate" },
                     "event_apply" => { "__content__" => "2016-11-24", "type" => "PropertyDate" },
                     "event_start" => { "__content__" => "2040-01-01", "type" => "PropertyDate" },
                     "event_stop" => { "__content__" => "2040-01-01", "type" => "PropertyDate" },
                     "event_participant_number" =>
                         { "__content__" => "12", "type" => "PropertyNumber" },
                     "event_participant_reserve" =>
                         { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_participants" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_occasions" => { "__content__" => "0", "type" => "PropertyNumber" },
                     "event_group" => { "__content__" => "10", "type" => "PropertyNumber" },
                     "event_position" => { "__content__" => "3", "type" => "PropertyNumber" },
                     "event_instructor_1" => nil,
                     "event_instructor_2" => nil,
                     "event_instructor_3" => nil,
                     "event_parking" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_commenttext" => nil,
                     "event_ticket_info" => nil,
                     "event_key" => { "__content__" => "BLQHndUsZcZHrJhR", "type" => "PropertyString" },
                     "event_currency_id" => { "__content__" => "1", "type" => "PropertyNumber" },
                     "event_default_client_numbers" => nil,
                     "event_url_id" =>
                         { "__content__" => "https://dinkurs.se/appliance/?event_id=41988",
                           "type" => "PropertyString" },
                     "event_url_key" =>
                         { "__content__" =>
                               "https://dinkurs.se/appliance/?event_key=BLQHndUsZcZHrJhR",
                           "type" => "PropertyString" },
                     "event_infotext" =>
                         { "__content__" =>
                               "Informationstext innan anmälningsformuläret\n" +
                                   "\n" +
                                   "Lämna denna ruta tom för att låta deltagaren komma direkt till anmälningsformuläret",
                           "type" => "PropertyString" },
                     "event_completion_text" => nil,
                     "event_aftertext" => nil,
                     "event_event_dates" => nil }] }
      }
    }


    it 'valid company and events' do

      allow(described_class).to receive(:get_dikurs_event_xml).with(VALID_COMPANY_ID) { valid_co_response }

      dks_events = described_class.get_events(VALID_COMPANY_ID)

      expect(dks_events).to be_a Array
      expect(dks_events.count).to eq 10

    end


    describe 'invalid company' do

      it '0 events' do
        allow(described_class).to receive(:get_dikurs_event_xml).with('blorf') { { 'events': nil } }

        dks_events = described_class.get_events('blorf')

        expect(dks_events).to be_a Array
        expect(dks_events.count).to eq 0
      end
    end

  end


  describe '.get_dikurs_event_xml', vcr: { record: :none } do

    let(:valid_fetched_event) do
      described_class.get_dikurs_event_xml(VALID_COMPANY_ID)
    end


    let(:invalid_company_fetch) do
      described_class.get_dikurs_event_xml('blorf')
    end


    describe 'valid company and events', :vcr do

      it_behaves_like 'a successful company events fetch' do
        let(:fetched_response) { valid_fetched_event }
      end

      it '10 events' do
        expect(valid_fetched_event['events']['event'].count).to eq 10
      end


      describe 'last event is valid', :vcr do

        it 'has the minimum info we need (blank is ok)' do
          # name
          # place?
          # start date? event_start
          # event_key ? event_key
          # dinkurs.se URL event_url_id
          # dinkurs.se URL key event_url_key

          last_event = valid_fetched_event['events']['event'].last

          expect(last_event['event_id'].first).to eq '41988'
          expect(last_event['event_name']['__content__']).to be
          expect(last_event['event_name']['__content__']).to eq 'stav'
          expect(last_event['event_place']['__content__']).to be
          expect(last_event['event_place']['__content__']).to eq 'Stavsnäs'
          expect(last_event['event_start']['__content__']).to be
          expect(last_event['event_start']['__content__']).to eq '2040-01-01'
          expect(last_event['event_key']['__content__']).to be
          expect(last_event['event_key']['__content__']).to eq 'BLQHndUsZcZHrJhR'
          expect(last_event['event_url_id']['__content__']).to be
          expect(last_event['event_url_id']['__content__']).to eq "https://dinkurs.se/appliance/?event_id=41988"
          expect(last_event['event_url_key']['__content__']).to be
          expect(last_event['event_url_key']['__content__']).to eq "https://dinkurs.se/appliance/?event_key=BLQHndUsZcZHrJhR"

        end

      end

    end


    describe 'invalid company' do

      it_behaves_like 'a successful company events fetch' do
        let(:fetched_response) { invalid_company_fetch }
      end

      it 'returns no events if company id is not known' do
        expect(invalid_company_fetch['events']).to be_nil
      end

    end


    it 'raises exception if unsuccessful' do

      expect { invalid_company_fetch }.to raise_exception(RuntimeError,
                                                          'HTTP Status: 401, Unauthorized')
    end
  end



end
