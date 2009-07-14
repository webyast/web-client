# = ExceptionLogger module
# Provides unified way to log exception in application.
# == Usage
# Just add log_exception method with Exception as argument and it write informations
# to log
# 
#   rescue Exception => e
#     ExceptionLogger.log_exception e


class ExceptionLogger
  def ExceptionLogger.log_exception e
    Rails.logger.warn e.message
    Rails.logger.info e.backtrace.join("\n")
  end
end
