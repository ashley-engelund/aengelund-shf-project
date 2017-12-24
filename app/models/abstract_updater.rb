#--------------------------
#
# @file abstract_updater.rb
#
# @desc Abstracts the behavior and information common to the Updaters
#       This is mainly used to abstract out the idea that 'updaters' are singletons.
#
#       It is currently also used to abstract out some logging just for
#       demonstration purposes during the spike/exploration.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/22/17
#
#
#--------------------------

require 'singleton'

class AbstractUpdater

  include Singleton


  LOG_DIR = File.join(__dir__, '..', '..', 'log')


  def log_filename
    File.join(LOG_DIR, "#{Rails.env}_#{self.class}.log")
  end


end # AbstractUpdater

