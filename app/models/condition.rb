# class:          Condition
#
# Responsibility: Provides the information needed so that a specific
#                 class can be instantiated and :process_condition
#                 can run on those instances.
#
#                 This class is  _descriptive._  (= the configration pattern)
#
#                 Ex:  A nightly rake/rails task will go thru all of the
#                 Condition record in the db and, using the information in each,
#                 instantiate the class in _class_name_.
#                 The task will send each instance the :process_condition method,
#                 passing it the name, timing, and config data.
#
#                 Each instance will then do 'whatever needs to be done' when
#                 it is sent :process_condition with the information.
#                 Ex: this will send out emails to all users that are past due
#                 with their Membership fee, etc.
#
#
# Attributes: These are all essentially *class variables* as they apply
#   to every instance of a class.
#
#   class_name - the name of the class to instantiate
#   name - the name of the method to call for the condition TODO - is this really needed?
#
#   timing - this can be mostly descriptive so that the code
#             reads much more naturally.  Some classes may need to use
#             this when running :process_condition
#   config - whatever configuration information is required for a
#         particular Condition class
#
#  @author:  Patrick Bolger
#
class Condition < ApplicationRecord
  serialize :config

  validates :class_name, presence: true
end
