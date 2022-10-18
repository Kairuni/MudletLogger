function Logger:enableLogger(logger)
  enableTimer("Logger Catchall");
  self.activeLoggers[logger.filename] = logger;
end

function Logger:disableLogger(logger)
  self.activeLoggers[logger.filename] = nil;
  if (table.size(self.activeLoggers) == 0) then
    cecho("<red>All active loggers disabled.");
    disableTimer("Logger Catchall");
  end  
end

Logger.outputFunctionMap = {
  ans = function()
      local asDecho = copy2decho(); 
      local str = decho2ansi(asDecho);
      return str;
    end,
  html = function()
      local str = copy2html();
      str = str:ends("<br>") and str or str .. "<br>";
      return str;
    end,
  txt = function()
      selectCurrentLine();
      local str, start, finish = getSelection();
      return str;
    end,
}

function Logger.buildLineBufferMap()
  return {
    html = {},
    ans = {},
    txt = {},
  };
end

function Logger:handleSendCapture(command)
  for _,logger in pairs(self.activeLoggers) do
    if (logger.options.logAllSends) then
      logger:log(command);
    end
  end
end

function Logger:handleActiveLoggers()
  local lineBuffer = Logger.buildLineBufferMap();
  for k,v in pairs(self.activeLoggers) do
    local logSends = commands and v.options.logAllSends;
    
    -- Handle the buffer deletion case. In theory, this COULD miss something if we receive more than 1000 lines in one go. I'm assuming that is uncommon.
    -- 1000 lines is the default per the Mudlet source code.
    local bufferCleaned = false;
    if (getLastLineNumber() < v._lastLineLogged) then
      v._lastLineLogged = v._lastLineLogged - Logger.bufferDeletionSize;
      bufferCleaned = true;
    end
    
    v:update(lineBuffer, bufferCleaned);
  end
end

-- Called to capture a subset of lines. Used for finalizing logs.
--function Logger:captureLines(logger, endLine)
--  local lineBuffer = buildLineBufferMap(); -- Not really necessary when closing out a single logger, but this is minimal overhead.
--  logLoop(logger, endLine or getLastLineNumber(), lineBuffer);
--end