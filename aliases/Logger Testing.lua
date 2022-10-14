testLoggers = testLoggers or {};

local loggerTests = {
  {"Command HTML Test", {timestamp = true, keepOpen = true, format = "html", logAllSends = true}},
  {"No Command HTML Test", {timestamp = true, keepOpen = true, format = "html", logAllSends = false}},
  {"Command TXT Test", {timestamp = true, keepOpen = true, format = "txt", logAllSends = true}},
  {"No Command TXT Test", {timestamp = true, keepOpen = true, format = "txt", logAllSends = false}},
  {"Command ANS Test", {timestamp = true, keepOpen = true, format = "ans",logAllSends = true}},
  {"No Command ANS Test", {timestamp = true, keepOpen = true, format = "ans", logAllSends = false}},
  {"Command HTML No Timestamp Test", {timestamp = false, keepOpen = true, format = "html", logAllSends = true}},
  {"No Command HTML No Timestamp Test", {timestamp = false, keepOpen = true, format = "html", logAllSends = false}},
  {"Command HTML Test No Timestamp No Keepopen Small File", {timestamp = true, keepOpen = false, format = "html", maxFilesize = 100, logAllSends = true}},
}

if (#testLoggers == 0) then
  for _,v in ipairs(loggerTests) do
    local logger = NLogger.createLogger(v[1], v[2]);
    table.insert(testLoggers, logger);
    logger:start();
  end
else
  for _,v in ipairs(testLoggers) do
    v:stop();
  end
  testLoggers = {};
end