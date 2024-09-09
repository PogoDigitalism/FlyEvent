local Types = require(script.Types)

----------------
local Event = {}
Event.__index = Event

function Event.register()
	local self = setmetatable({}, Event)
	
	self._connections = {} :: {Types.Connection}
	self._waitingThreads = {} :: {thread}
	
	return self
end
export type CLS = typeof( -- intellisense support
	Event.register(...)
)

function Event.Fire(self: CLS, clean_up: boolean, ...): ()
	for _, connection in self._connections do
		if connection and connection.Connected then
			task.defer(
				connection.Function,
				...
			)
		end
		if connection.Once then
			connection:Disconnect()
		end
	end

	if self._waitingThreads then
		for _, thread in self._waitingThreads do
			coroutine.resume(
				thread, 
				...
			)
		end
		self._waitingThreads = {}
	end
end

function Event.Connect(self: CLS, callback): Types.Connection
	local connection = {
		Function = callback,
		Connected = true,
		Once = false
	}

	function connection:Disconnect()
		self.Connected = false
	end

	table.insert(self._connections, connection)

	return connection
end

function Event.Once(self: CLS, callback): Types.Connection
	local connection = {
		Function = callback,
		Connected = true,
		Once = true
	}

	function connection:Disconnect(): ()
		self.Connected = false
	end

	table.insert(self._connections, connection)

	return connection
end

function Event.Wait(self: CLS): ...any
	local thread = coroutine.running()

	if not self._waitingThreads then
		self._waitingThreads = {}
	end
	table.insert(self._waitingThreads, thread)

	return coroutine.yield()
end

function Event.DisconnectAll(self: CLS): ()
	for _, connection in self._connections do
		connection.Connected = false
	end
	self._connections = {}
end

function Event.Destroy(self: CLS): ()
	self:DisconnectAll()

	self._waitingThreads = {}

	self._connections = nil
	self._waitingThreads = nil

	setmetatable(self, nil)
	
	table.freeze(self)
	table.clear(self)
end

return Event
