# MudletLogger
Loggers for Mudlet, for those times when you also want to log things that you don't explicitly see.

Project built with [muddler](https://github.com/demonnic/muddler) - go show demonnic some love.

## Usage

### Aliases

^LOGGER TESTING$ - Creates several different loggers with different options for testing. This is mostly in for me to validate functionality.

### API

#### Simple Example
Alias : ^startCombatLog$
```
if (not combatLogger) then
    combatLogger = Logger.createLogger("MyPKLog", {
        timestamp = true,
        keepOpen = true,
        format = "html",
        logAllSends = true,
        maxFilesize = 1024
    });
end

combatLogger:start();
```

##### Trigger : On Prompt
```
combatLogger:log(string.format("<b>My current blood: %d</b><i>Am I paralyzed? %s", gmcp.Char.Vitals.blood, myAffs.paralysis and "Yes" or "No"));
```

##### Alias : ^stopCombatLog$
```
combatLogger:stop();
```

#### Logger.createLogger(filename, options)
Creates a new logger for a given filename with the given options.  
Valid options are:
* timestamp = `true | false` (default: true) - This uses Mudlet's timestamp, rather than capturing per-line.
* maxFilesize = `1+` (default: infinite) - This is the max filesize in kilobytes. Please make this a reasonable number (probably > 5000 for 5 mb filesize), or you will have a million tiny log files before very long.
* keepOpen = `true | false` (default: true) - Not sure this is actually necessary.
* format = `"html" | "ans" | "txt"` (default: "html") - I don't think this is slow enough to fake an enum vs. just using the string.
* logAllSends = `true | false` (default: false) - This can result in double logging of inputs, but will catch send("...", false).

#### myLogger:start()
Begins logging from the current point in time. Creates a new log file if necessary, otherwise reopens the existing log file.

#### myLogger:stop()
Stops logging at the current point in time, and closes the log file.

#### myLogger:log(str)
Logs a string to the current logger, separate from game output.

#### Logger:buildTooltip(displayText, tooltipText, location)
Builds a tooltip for HTML logs.

Valid locations are `left | right | top | bottom`

##### Usage
````
myLogger:log(Logger:buildTooltip("This is a test tooltip.", "WEEOOWEEOO", "right"));
````

### TODO:

Log searching.