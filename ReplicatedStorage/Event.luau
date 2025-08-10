local Types = require(script.Types)

export type Event<T> = {
	Fire: (self: Event<T>, data: T) -> (),
	Connect: (self: Event<T>, callback: (data: T) -> ()) -> Types.Connection,
	Once: (self: Event<T>, callback: (data: T) -> ()) -> Types.Connection,
	Wait: (self: Event<T>, timeout: number?, conditionalCallback: ((data: T) -> boolean)?) -> T,
	DisconnectAll: (self: Event<T>) -> (),
	Destroy: (self: Event<T>) -> ()
}

local Event = {}
Event.__index = Event

function Event.register<T>(annotation: T): Event<T>
	local self = setmetatable({}, Event)

	self._connections = {} :: {Types.Connection}
	self._waitingThreads = {} :: {thread}
	self._waitingConditionCallbacks = {} :: {[thread]: (T...) -> boolean}

	return self
end

function Event.Fire(self: Event, ...)
	for _, connection in self._connections do
		if connection and connection.Connected then
			task.defer(connection.Function, ...)
		end
		if connection.Once then
			connection:Disconnect()
		end
	end

	local remaining_threads = {}
	for _, thread in self._waitingThreads do
		local conditionalCallback = self._waitingConditionCallbacks[thread]
		if not conditionalCallback then
			coroutine.resume(thread, ...)
			continue
		end
		
		if conditionalCallback(...) then
			coroutine.resume(thread, ...)
		else
			table.insert(remaining_threads, thread)
		end
	end
	self._waitingThreads = remaining_threads
end

function Event.Connect(self: Event, callback)
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

function Event.Once(self: Event, callback)
	local connection = {
		Function = callback,
		Connected = true,
		Once = true
	}

	function connection:Disconnect()
		self.Connected = false
	end

	table.insert(self._connections, connection)

	return connection
end

function Event.Wait(self: Event, timeout, conditionalCallback)
	local thread = coroutine.running()

	table.insert(self._waitingThreads, thread)

	if timeout then
		task.delay(timeout, function()
			for i, waitingThread in ipairs(self._waitingThreads) do
				if waitingThread == thread then
					table.remove(self._waitingThreads, i)
					coroutine.resume(thread, nil)
					break
				end
			end
		end)
	end
	
	if conditionalCallback then
		self._waitingConditionCallbacks[thread] = conditionalCallback
	end

	return coroutine.yield()
end

function Event.DisconnectAll(self: Event): ()
	for _, connection in self._connections do
		connection.Connected = false
	end
	self._connections = {}
end

function Event.Destroy(self: Event): ()
	self:DisconnectAll()
	self._waitingThreads = {}
	self._connections = nil
	self._waitingThreads = nil
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

return Event
