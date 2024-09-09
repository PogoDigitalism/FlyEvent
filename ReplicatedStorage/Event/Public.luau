local Event = require(script.Parent)

local Public = {}

-- REGISTER PUBLIC EVENTS HERE (SAME RUN CONTEXT ONLY) --

Public.MyPublicEvent = Event.register()
Public.MyPublicEvent2 = Event.register()
Public.MyPublicEvent2 = Event.register()

-- END --

return Public
