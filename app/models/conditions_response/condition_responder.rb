#!/usr/bin/ruby


#--------------------------
#
# @class ConditionResponder
#
# @desc Responsibility: Take a condition and some configuration information
# and _responds_ (handles) the condition.
#
# This might mean looking thru members and sending them emails if
# some particular condition is met, for example.
#
# Although this class is nearly empty right now, it is here to clarify
# the overall design.
#
# TODO: ? rename to ConditionHandler - because it _handles_ conditions, it
# doesn't respond _to_ them or _with_ them.
#
# @date   2018-12-13
#
# @file condition_responder.rb
#
#--------------------------


class ConditionResponder


  # All subclasses must implement this class. This is how they respond to/
  #  handle a condition.
  #
  def self.condition_response(condition, config, log)
    raise NoMethodError, "Subclass must define the #{__method__} method", caller
  end


  end # ConditionResponder

