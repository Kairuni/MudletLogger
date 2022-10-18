local defaultOptions = {
  timestamp = true,
  keepOpen = true,
  format = "html",
  logAllSends = false,
}

local optionsMT = {
  __index = function(_, k)
    return defaultOptions[k];
  end
}

local mudletTimestampFormat = "hh:mm:ss.zzz "; 

-- Creates a new logger for a given filename with the given options.
-- Valid options are:
--    timestamp = true | false (default: true) - This uses Mudlet's timestamp, rather than capturing per-line.
--    maxFilesize = 1+ (default: infinite) - This is the max filesize in kilobytes. Please make this a reasonable number, or you will have a million tiny log files before very long.
--    keepOpen = true | false (default: true) - Not sure this is actually necessary.
--    format = html | ans | txt (default: "html") - I don't think this is slow enough to fake an enum vs. just using the string.
--    logAllSends = true | false (default: false) - This can result in double logging of inputs, but will catch send("...", false).
function Logger.createLogger(filename, options)
  local logger = {
    filename = filename,
    options = options or {},
    _bytes = 0,
    _pendingOutOfBoundsLines = {},
  }
  setmetatable(options, optionsMT);

  function logger:path() 
    return Logger.path .. filename .. 
              (self.index and tostring(self.index) or "") ..
              (self.options.format and "." .. self.options.format or ".txt")
  end

  local attr, error, code = lfs.attributes(logger:path());
  if (attr) then
    logger.index = 0;
    while (code ~= 2) do
      logger.index = logger.index + 1;
      attr, error, code = lfs.attributes(logger:path());
    end
    cecho("\n<yellow>File already existed for logger " .. filename .. ", starting with index " .. tostring(logger.index) .. "\n");
  end

  function logger:openFile()
    if (not self._file) then
      self._file = io.open(self:path(), "a+");
    end
  end

  function logger:createFile()
    self:openFile();
    if (self.options.format == "html") then
      self._file:write(Logger.htmlHeader);
    end
  end

  function logger:closeIfRequested()
    if (not self.options.keepOpen and self._file) then
      -- Reference self again here as it may have been re-opened above.
      self._file:close();
      self._file = nil;
    end
  end

  function logger:incrementIndex()
    self._file:close();
    self._file = nil;
    self.index = self.index and self.index + 1 or 0;
    self:createFile();
    self:closeIfRequested();
    self._bytes = 0;
  end

  function logger:_logLine(line, lineNum)
    self:openFile();
    local file = self._file;

    local timestamp = self.options.timestamp
                        and (lineNum and getTimestamp(lineNum) or getTime(true, mudletTimestampFormat))
                        or "";

    -- Not sure if it's faster to :write three times or concat the string, but at least this doesn't reallocate the string.
    file:write(timestamp)
    file:write(line);
    if (self.options.format == "html" and not line:ends("<br>")) then
      file:write("<br>");
    end
    if (not line:ends("\n")) then
      file:write("\n");
    end
    self._bytes = self._bytes + #timestamp + #line;

    -- This won't be 100% accurate, but rough is fine. Can't just use raw filesystem because we're supporting keeping the file open.
    if (self.options.maxFilesize and (self._bytes / 1024) > self.options.maxFilesize) then
      self:incrementIndex();
    end
    self:closeIfRequested();
  end

  -- Log some data out-of-bounds.
  function logger:log(str)
    local lineNumber = getLastLineNumber() - 1;

    self._pendingOutOfBoundsLines[lineNumber] = self._pendingOutOfBoundsLines[lineNumber] or {};
    table.insert(self._pendingOutOfBoundsLines[lineNumber], str);
  end

  function logger:_logPendingLines(lineNumber)
    if (self._pendingOutOfBoundsLines[lineNumber]) then
      for _,v in ipairs(self._pendingOutOfBoundsLines[lineNumber]) do
        self:_logLine(v);
      end
      self._pendingOutOfBoundsLines[lineNumber] = nil;
    end
  end

  function logger:update(lineBuffer, bufferCleaned)
    local format = self.options.format;
    local startLine = self._lastLineLogged;
    local endLine = getLastLineNumber() - 1;

    while (self._lastLineLogged < endLine) do
      local i = self._lastLineLogged;

      if (not lineBuffer[format][i]) then
        moveCursor(0, i);
        lineBuffer[format][i] = lineBuffer[format][i] or Logger.outputFunctionMap[format]();
      end

      self:_logLine(lineBuffer[format][i], i);
      self._lastLineLogged = self._lastLineLogged + 1;

      self:_logPendingLines(i);
      if (bufferCleaned) then
        self:_logPendingLines(i + Logger.bufferDeletionSize)
      end
    end
  end

  function logger:start()
    self._pendingOutOfBoundsLines = {};
    Logger:enableLogger(self);
    self:createFile();
    self._lastLineLogged = getLastLineNumber();
    cecho("\n<yellow>Logger Started: " .. self.filename .. "\n");
  end

  function logger:stop()
    cecho("\n<red>Logger Ended: " .. self.filename .. "\n");
    Logger:disableLogger(self);
    self:update(Logger.buildLineBufferMap());
    if (self._file) then
      self._file:close();
      self._file = nil;
    end 
  end

  return logger;
end