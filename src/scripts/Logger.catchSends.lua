function Logger.catchSends(_, input)
  Logger:handleSendCapture("INPUT: " .. input)
end