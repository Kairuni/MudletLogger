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

local outputFunctionMap = {
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

local function logLoop(logger, endLine, linesToLog)
  local format = logger.options.format;
  local startLine = logger._lastLineLogged;

  while (logger._lastLineLogged < endLine) do
    local i = logger._lastLineLogged;
    
    if (not linesToLog[format][i]) then
      moveCursor(0, i);
      
      linesToLog[format][i] = linesToLog[format][i] or outputFunctionMap[format]();
    end

    logger:logLine(linesToLog[format][i], i);
    logger._lastLineLogged = logger._lastLineLogged + 1;
  end
end

local function buildLineBufferMap()
  return {
    html = {},
    ans = {},
    txt = {},
  };
end

function Logger:handleActiveLoggers(commands)
  local lineBuffer = buildLineBufferMap();
  for k,v in pairs(self.activeLoggers) do
    local logSends = commands and v.options.logAllSends;
    -- TODO: This is a bit inefficient with multiple loggers, even though we're only doing the work once. Still multiple iterations. Maybe do this smarter.
    local endLine = logSends and getLastLineNumber() or getLastLineNumber() - 1;
    
    -- Handle the buffer deletion case. In theory, this COULD miss something if we receive more than 1000 lines in one go. I'm assuming that is uncommon.
    -- 1000 lines is the default per the Mudlet source code.
    if (getLastLineNumber() < v._lastLineLogged) then
      v._lastLineLogged = v._lastLineLogged - (Logger.bufferDeletionSize or 1000);
    end

    logLoop(v, endLine, lineBuffer);
    
    if (logSends) then
      v:logLine("INPUT: " .. commands);
    end
  end
end

-- Called to capture a subset of lines. Used for finalizing logs.
function Logger:captureLines(logger, endLine)
  local lineBuffer = buildLineBufferMap(); -- Not really necessary when closing out a single logger, but this is minimal overhead.
  logLoop(logger, endLine or getLastLineNumber(), lineBuffer);
end