local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Raycast = require(ReplicatedStorage.Services.RaycastAPI)

local A0 = script.Parent.One.Attachment
local A1 = script.Parent.Two.Attachment
local A2 = script.Parent.Three.Attachment
local A3 = script.Parent.Four.Attachment

local Params = RaycastParams.new()
Params.FilterDescendantsInstances = {script.Parent, workspace.Visuals}
Params.FilterType = Enum.RaycastFilterType.Blacklist

local function ManageHit(Info) --> Void
	local Parent = Info.Instance.Parent
	
	if Parent:FindFirstChild('Humanoid') then
		print(Parent.Name)
		Parent.Humanoid:TakeDamage(0.2)
	end
	return nil
end
local function AddCast(Type) --> Raycast
	local Cast = Raycast.new(Type, {
		Params = Params,
		Update = true,
		Points = {A0, A1, A2, A3}
	})
	Cast._OnHit:Connect(ManageHit)
	return Cast
end

while true do
	local Type = ( math.random() < 0.5 and 'Origin' ) or 'Order'
	local Cast = AddCast(Type)
	Cast:Start()
	wait(10)
	Cast:Disable()
	wait(10)
end
