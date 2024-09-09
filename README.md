Usage is simple;

```luau
local Event = require(script.Event)
local my_event = Event.register()

-- CONNECTION OPTIONS --

local connection = my_event:Connect(function(message)
    print("Message: " .. message)
end)
local connection = my_event:Once(function(message)
    print("Message: " .. message)
end)

local message = my_event:Wait()
print("Message: " .. message)

-- END --

my_event:Fire("Hello World!")

-- CLEAN UP --
my_event:DisconnectAll()
-- OR
my_event:Destroy()
```
