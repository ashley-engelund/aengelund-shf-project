class ActivityLogger

  # This supports simple logging of activity, such as loading data into the
  # the DB with a rake task.
  #
  # This allows for output to $stdout of logged messages.
  #
  # This will write to $stdout *instead of a file* if:
  #   ENV['RAILS_LOG_TO_STDOUT'] exists (the value doesn't matter)
  # or
  #   if the directory for the log is not writeable or cannot be created
  #
  #
  # The format of the logged messages are:
  #
  # [facility] [activity] [severity] <message>
  # Example log contents:
  # [SHF_TASK] [Load Kommuns] [info] Started at 2017-05-20 17:25:39 -0400
  # [SHF_TASK] [Load Kommuns] [info] 290 Kommuns created.
  # [SHF_TASK] [Load Kommuns] [info] Finished at 2017-05-20 17:25:39 -0400.
  # [SHF_TASK] [Load Kommuns] [info] Duration: 0.67 seconds.
  #
  # Here, the facility is an SHF task, the activity is loading Kommuns
  # into the DB, and the messages are all of INFO severity.
  #
  # Usage:
  # 1) call ActivityLogger.open(logfile, facility, activity)
  #    -- assign the logger instance value to a local var (e.g., "log = ..."), OR
  #    -- pass a block which takes an argument (which is the logger instance)
  # 2) for each logged message during the activity,
  #    call log.record(severity, message), (log == logger instance)
  #    where severity is one of 'debug', 'info, 'warn', 'error', 'fatal', 'unknown'
  # 3) when the activity is complete,
  #    -- the log file will be closed automatically if opened with a block, OR
  #    -- call log.close
  #
  # NOTE: this requires ActiveSupport.  It can only be run with Rails

  def self.open(filename, facility, activity, show=true)

    log = new(filename, facility, activity, show)

    if block_given?
      begin
        yield log
      ensure
        log.close unless @is_system_outstream
      end
    else
      log
    end
  end

  private def initialize(filename, facility, activity, show)
    @filename = filename
    @facility = facility
    @activity = activity
    @facility_and_action = "[#{facility}] [#{activity}] "
    @show = show
    @start_time = Time.zone.now
    @is_system_outstream = false # true if we use $stdout or $stderr

    verified_output_stream = ActivityLogger.verified_output_stream(filename)

    @log = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(verified_output_stream))

    record('info', "Started at #{@start_time}")
  end

  def record(log_level, message)
    raise 'invalid log severity level' unless
      ActiveSupport::Logger::Severity.constants.include?(log_level.upcase.to_sym)

    @log.tagged(@facility, @activity, log_level) do
      @log.send(log_level, message)
    end

    puts @facility_and_action + "[#{log_level}] " + message if @show
  end

  def close(duration: true)
    finish_time = Time.zone.now
    record('info', "Finished at #{finish_time}.")
    record('info',
      "Duration: #{(finish_time - @start_time).round(2)} seconds.\n") if duration
    @log.close if @log.respond_to?(:close) && !@is_system_outstream
    logged_to if @show
  end

  def logged_to
    puts @facility_and_action + '[info] ' + "Information was logged to: #{@filename}"
  end


  # Return a stream to use that we have verified is writeable.
  #
  # Given a full filename path, ensure that we can write to the directory.
  # If not, use $stdout instead.
  # If the directory for _filename_ does not exist, try to create it.
  # If we cannot create the directory, then use $stdout for the output.
  # If the directory is not writeable, then use $stdout for the output.
  #
  # @param unverified_filename [String] - the full path of the unverified filename; we
  #   try to verify that the directory for it exists and is writeable
  #
  # @return the full filename + path to use for output.
  #      This might be changed to $stdout if we could not use or create the directory
  #      for filename
  def self.verified_output_stream(unverified_filename)

    @is_system_outstream = true

    # always log to stdout no matter what unverified_filename is
    if ENV.has_key?('RAILS_LOG_TO_STDOUT')
      return $stdout
    end

    # quick gating conditions:
    return unverified_filename if unverified_filename == $stdout
    return unverified_filename if unverified_filename == $stderr
    return unverified_filename if unverified_filename.class.name == 'IO'
      # sometimes a stdout will not have the same address as $stdout depending on
      # how it was created

    # if we're here, we didn't explicitly use a system output stream
    @is_system_outstream = false

    verified_output = $stdout # fallback to this unless we can verify the directory

    unverified_dir = File.dirname unverified_filename

    # if it exists and we can write to it, it's fine to use.
    if File.exists?(unverified_dir) && File.writable?(unverified_dir)
      verified_output = unverified_filename

    else  # try to verify it
      begin
        Dir.mkdir(unverified_dir) unless File.exists? unverified_dir
        raise IOError unless File.writable? unverified_dir
        verified_output = unverified_filename # if we got this far it's fine
      rescue => _error
        # Swallow this error; don't raise it.
        # If we can't create or write to the directory, then this
        # directory is not verified.  Use the fallback output ($stdout)
      end
    end

    verified_output
  end


end
