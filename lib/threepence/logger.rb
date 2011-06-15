module ThreePence
  module Logger
    def severe(message, error=nil)
      log_internal(java.util.logging.Level::SEVERE, message, error)
    end

    def warning(message, error=nil)
      log_internal(java.util.logging.Level::WARNING, message, error)
    end

    def info(message, error=nil)
      log_internal(java.util.logging.Level::INFO, message, error)
    end

    def config(message, error=nil)
      log_internal(java.util.logging.Level::CONFIG, message, error)
    end
    
    def fine(message, error=nil)
      log_internal(java.util.logging.Level::FINE, message, error)
    end

    def finer(message, error=nil)
      log_internal(java.util.logging.Level::FINER, message, error)
    end

    def finest(message, error=nil)
      log_internal(java.util.logging.Level::FINEST, message, error)
    end

    def log_internal(level, message, error=nil)
      if error
	file, line = divine_backtrace_error_location(error)
	java.util.logging.Logger.global.logp(level, file, line, 
					     message + ': ' + error.message)
      else
	file, line = divine_caller_location(caller)
	java.util.logging.Logger.global.logp(level, file, line, message)
      end
    end
    private :log_internal

    def divine_backtrace_error_location(error)
      return $1, $2 if error.backtrace[0] =~ /(.*):(\d+):in\s/o
      return 'unknown', -1
    end
    private :divine_backtrace_error_location

    # JRuby stack traces can also show Java frames which might appear
    # for intermediate generated Java classes.  This will get the 
    # second ruby stack frame down (0 log_internal, 1 specific logger (e.g. 
    # finer), 2 actual caller of specific logger).
    def divine_caller_location(callstack)
      i = 0
      callstack.each do |element|
	if element =~ /(.*\.rb):(\d+):in\s/o
	  i += 1
	  return $1, $2 if i == 2
	end
      end
      return 'unknown', -1
    end

  end
end
