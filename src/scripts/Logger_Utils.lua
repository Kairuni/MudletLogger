local TOOLTIP_SPAN = [[<span class="displayText">%s<span class="tooltip" id="%s">%s</span></span>]]

function Logger:buildTooltip(displayText, tooltipText, location)
  return string.format(TOOLTIP_SPAN, displayText, location or "bottom", tooltipText);
end