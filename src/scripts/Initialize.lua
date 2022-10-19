Logger = Logger or {
  activeLoggers = {},
  path = getMudletHomeDir() .. "/log/",
  bufferDeletionSize = 1000,
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

      .displayText {
        position: relative;
        border-style: dotted;
        padding: 1px 1px 1px 1px;
        border-width: thin;
      }

      .displayText:hover .tooltip {
        visibility: visible;
        opacity: 1;
      }

      .displayText .tooltip {
        visibility: hidden;
        position: absolute;
        z-index: 1;
        width: 60em;
        color: white;
        background-color: #0f1d33;
        word-wrap: break-word;
        border-style: dotted;
        padding: 5px 5px 5px 5px;
      }

      #right {
        left: 100%;
        top: -8px;
      }

      #left {
        right: 0%;
        top: -8px;
      }

      #bottom {
        top: 100%;
        left: 0%;
      }

      #top {
        bottom: 100%;
        left: 0%;
      }
    -->
  </style>
</head>
]];