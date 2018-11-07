#!/usr/bin/ruby


#--------------------------
#
# @class LogFileNamer
#
# @desc Responsibility: Creates log file names so that they're standardized across the app
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   11/7/18
#
# @file log_file_namer.rb
#
#--------------------------


class LogFileNamer


  def self.log_filename(klass_name)
    File.join(Rails.configuration.paths['log'].absolute_current, "#{Rails.env}_#{klass_name}.log")
  end


end # LogFileNamer

