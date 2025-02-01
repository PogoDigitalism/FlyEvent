local Event = require(script.Parent)

local Public = {}

-- REGISTER PUBLIC EVENTS HERE (SAME RUN CONTEXT ONLY) --

Public.RoundFinished = Event.register({
	winner = nil :: Player,
	round_time = nil :: number
})
Public.MyPublicEvent2 = Event.register()
Public.MyPublicEvent2 = Event.register()

-- END --

return Public
