Logger = Logger or {
  activeLoggers = {},
  path = getMudletHomeDir() .. "/log/",
};

-- Default path behavior - you're on your own if you change Logger.path.
if (path == getMudletHomeDir() .. "/log/") then
  local originalDirectory = lfs.currentdir();
  lfs.chdir(getMudletHomeDir());
  local success, err, code = lfs.mkdir("log");
  lfs.chdir(originalDirectory);
  
  if (not (success or (err and code == 17))) then
    cecho("<red>WARNING: Failed to create log directory. Logger will not function as anticipated.");
  end
end

Logger.htmlHeader = [[
<head>
  <style type='text/css'>
    <!--
      body {
        font-family: 'Bitstream Vera Sans Mono', 'Courier New', 'Monospace', 'Courier';
        font-size: 100%;
        line-height: 1.125em;
        white-space: nowrap;
        color:rgb(255,255,255);
        background-color:rgb(0,0,0);
      }
      span {
        white-space: pre-wrap;
      }
    -->
  </style>
</head>
]];