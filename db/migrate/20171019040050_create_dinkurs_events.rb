class CreateDinkursEvents < ActiveRecord::Migration[5.1]

  def change
    create_table :dinkurs_events, comment: "Information tracked by the DinKurs.se system about an Event" do |t|

      t.string  :dinkurs_id,                            comment: "unique identifier for the event in the DinKurs system"

      t.string  :event_name,                            comment: "text name of the event"
      t.string  :event_place_geometry_location,         comment: "location "
      t.string  :event_host,                            comment: ""

      t.float  :event_fee,                             comment: "cost of the event (for a ticket)"
      t.float  :event_fee_tax,                         comment: "tax that is in addition to the cost"

      t.datetime  :event_pub,                            comment: "date the event is published?"
      t.datetime  :event_apply,                          comment: "TODO date ? " #TODO what is this field?
      t.datetime  :event_start,                          comment: "start date and time for the event"
      t.datetime  :event_stop,                           comment: "stop date and time for the event"

      t.numeric  :event_participant_number,              comment: "max. number of participants allowed for the event"
      t.numeric  :event_participant_reserve,             comment: "number of participants waiting for a spot to be available for the event"
      t.numeric  :event_participants,                    comment: "number of participants signed up for the event"

      t.string  :event_occasions,                        comment: "" # TODO what is this field?
      t.string  :event_group,                            comment: "" # TODO what is this field?

      t.string  :event_position,                         comment: ""
      t.string  :event_instructor_1,                     comment: "name of instructor 1 for the event"
      t.string  :event_instructor_2,                     comment: "name of instructor 2 for the event"
      t.string  :event_instructor_3,                     comment: "name of instructor 3 for the event"


      t.string  :event_infotext,                         comment: "More text details about the event"
      t.string  :event_commenttext,                      comment: "" # TODO what is this field?


      t.string  :event_ticket_info,                      comment: "" # TODO what is this field?

      t.string  :event_key,                              comment: "unique identifier for DinKurs used to construct the event_url_key"
      t.string  :event_url_id,                           comment: "" # TODO what is this field?
      t.string  :event_url_key,                          comment: "" # TODO what is this field?

      t.string  :event_completion_text,                  comment: "" # TODO what is this field?
      t.string  :event_aftertext,                        comment: "" # TODO what is this field?

      t.string  :event_event_dates,                      comment: "" # TODO what is this field?


      t.timestamps
    end
  end
end
