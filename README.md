Usage is simple;

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Event = require(ReplicatedStorage.Event)
local my_event = Event.register({
    message = nil :: string -- registering an event with such a table enables type hints support across your whole Roblox project!
})

-- CONNECTION OPTIONS --

local connection = my_event:Connect(function(data)
    print("Message: " .. data.message)
end)
local connection = my_event:Once(function(data)
    print("Message: " .. data.message)
end)

local message = my_event:Wait()
print("Message: " .. message)

-- END --

local data = {message="Hello World!"}
my_event:Fire(data)

-- CLEAN UP --
my_event:DisconnectAll()
-- OR
my_event:Destroy()
```
