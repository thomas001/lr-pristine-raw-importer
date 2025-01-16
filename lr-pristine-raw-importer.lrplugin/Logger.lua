local LrLogger = import "LrLogger"

local logger = LrLogger("lr-pristine-raw-importer")
logger:enable("logfile")
logger:info("Logger started")

return logger
