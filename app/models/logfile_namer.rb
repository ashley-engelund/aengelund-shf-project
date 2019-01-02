#!/usr/bin/ruby

#--------------------------
#
# @class LogfileNamer
#
# @desc Responsibility: Given a class, creates a standardized log file name, including the full path.
#
#     If this is production, then the log file name is the name of the class with ".log" as the extension.
#     Else the log file name starts with the Rails.environment.
#       Ex: Given the class 'MembershipStatusUpdater' this will create the filename
#         development_MembershipStatusUpdater.log  if running in the 'development' Rails environment
#         test_MembershipStatusUpdater.log  if running in the 'test' Rails environment
#
#     The full path for the log file is the Rails log directory.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-01-02
#
# @file logfile_namer.rb
#
#--------------------------


class LogfileNamer

  FILE_EXT = 'log'


  def self.for( klass_name )

    env_prefix = Rails.env.production? ? '' : "#{Rails.env}_"
    File.join(Rails.configuration.paths['log'].absolute_current, "#{env_prefix}#{klass_name}.#{FILE_EXT}")
  end


end # LogfileNamer

