# = ExceptionLogger module
# Provides unified way to log exception in controller.
# == requirements
# Should be used only in controller. (TODO make it more universal)
# == Usage
# Just add log_exception method with Exception as argument and it write informations
# to log
# 
#   rescue Exception => e
#     log_exception e


module ExceptionLogger
  def log_exception e
    logger.warn e.message
    logger.info e.backtrace.join("\n")
  end
end
