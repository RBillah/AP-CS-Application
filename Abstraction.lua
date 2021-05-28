--> RaycastService (Provides necessary functionality and abstraction)
--> Credits: @Raiden
--> Date: 5/16/21

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Debris = require(script.Debris)
local Signal = require(ReplicatedStorage.Util.Signal)
local Settings = require(script.Settings)
local Util = require(script.Util)

local Debugging = Settings.Debugging
local Cooldown = os.clock() + Settings.Cooldown

local Iterators = {}
for _, Module in ipairs(script.Iterators:GetChildren()) do
	Iterators[Module.Name] = require(Module)
end

local Rendered = {}
local function CastRay(self, Current, Next) --> Void
	local Params = self._Params
	local RayInfo = workspace:Raycast(Current, Next - Current, Params)
	
	if self._CanVisualize and Debugging then
		Util.Visualize(self, Current, Next)
	end
	if RayInfo then
		self._OnHit:Invoke(RayInfo)	
	end
	return nil
end
local function RefreshPoints(self) --> Void
	local Points = self._Points
	local Iterator = Iterators[self._Type]
	
	for Current, Next in Iterator(Points) do		
		CastRay(self, Current, Next)
	end
	self._CanVisualize = false
	return nil
end
local function DebugVisuals(self) --> Void
	local Parts = self._Parts
	for _, Item in ipairs(Parts:GetChildren()) do
		Debris:AddItem(Item, Settings.DebugClearTime)
	end
	return nil
end
local Metatable = {}
Metatable.__index = Metatable

function Metatable:Start() --> Void
	self._Parts = ( Debugging and Util.GetFolder() ) or nil
	table.insert(Rendered, self)
	return nil
end
function Metatable:Disable() --> Void
	local Parts = self._Parts
	local Index = table.find(Rendered, self)
	
	Parts:Destroy()
	table.remove(Rendered, Index)
	return nil
end

local RaycastAPI = {}
function RaycastAPI.new(Type, Config) --> Dictionary
	local self = setmetatable({
		_OnHit = Signal.new(),
		_Update = Config.Update,
		_Params = Config.Params,
		_CanVisualize = Debugging or nil,
		_Type = Type,
		_Points = Util.Serialize(Config.Points), 
	}, Metatable)
	return self
end
function RaycastAPI.DisableCasts() --> Void
	for _, Object in ipairs(Rendered) do
		Object:Disable()
	end
	return nil
end
function RaycastAPI.GetReflect(Vector, Normal) --> Vector3
	return -2 * Vector:Dot(Normal) * Normal + Vector
end

local function SwitchVisuals(self) --> Void
	if not Debugging then return end
	
	local Points = self._Points
	for _, Point in ipairs(Points) do
		if type(Point) ~= 'table' then continue end                 
		
		local CurrentPos = Point.Raw[Point.Property]
		if CurrentPos ~= Point.LastPos then
			DebugVisuals(self)
			self._CanVisualize = true
		end
		Point.LastPos = CurrentPos
	end
	return nil
end
local function Update() --> Void
	if os.clock() - Cooldown < Settings.Cooldown then return end
	
	Cooldown = os.clock()
	for _, Object in ipairs(Rendered) do
		SwitchVisuals(Object)
		RefreshPoints(Object)
		if not Object._Update then
			Object:Disable()
		end
	end
	return nil
end
RunService.Heartbeat:Connect(Update)
return RaycastAPI
