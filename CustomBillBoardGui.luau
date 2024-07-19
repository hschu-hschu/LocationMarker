--!native

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

export type CustomBillBoardGui = {
	Adornee:(BasePart|Model),
	Size:UDim2,
	OutSideSize:UDim2,
	Object:ImageLabel,
	Position:Vector3,
	Enabled:boolean,
	InsideIconID:string,
	OutsideIconID:string,
	Destroy: (CustomBillBoardGui) -> nil,
	_renderConnection:RBXScriptConnection?,
}

export type billboardguiManager = {
	new: () -> (CustomBillBoardGui),
	_ScreenGui:ScreenGui,
	_BillBoardGuis:{CustomBillBoardGui},
	_Init:()-> (),
}

local module:billboardguiManager = {} :: billboardguiManager
module._BillBoardGuis = {}


local NAN_V3 = Vector3.one * 0/0

local Carmera = Workspace.CurrentCamera

local CustomBillBoardGuiGetter = {
	["ClassName"] = "CustomBillBoardGui",
	["Enabled"] = true,
	["Size"] = UDim2.new(0,50,0,50),
	["OutSideSize"] = UDim2.new(0,50,0,50),
	["InsideIconID"] = "rbxasset://textures/ui/GuiImagePlaceholder.png",
	["OutsideIconID"] = "rbxasset://textures/ui/GuiImagePlaceholder.png",
}

local DefualtGetter = function(self,index)
	return rawget(self,index) 
		or rawget(CustomBillBoardGuiGetter,index)
end

local DefualtSetter = function(self, index, value)
	rawset(self,index,value)
end
local ObjectSetter = function(self:CustomBillBoardGui, index, value)
	self["Object"][index] = value
	DefualtSetter(self, index, value)
end

local getters = {
	["Adornee"] = DefualtGetter,
	["Position"] = function(self:CustomBillBoardGui, index)
		if not self.Adornee then
			return NAN_V3
		end
		local Adornee = self.Adornee
		if Adornee:IsA("Model") then
			local model = Adornee
			return model:GetPivot().Position

		elseif Adornee:IsA("BasePart") then
			local part = Adornee
			return part.Position
		end
	end,
	["Enabled"] = DefualtGetter,
	["ClassName"] = DefualtGetter,
	["Size"] = DefualtGetter,
	["OutSideSize"] = DefualtGetter,
	["InsideIconID"] = DefualtGetter,
	["OutsideIconID"] = DefualtGetter,
	["Destroy"] = function(self:CustomBillBoardGui)
		self["_renderConnection"] = nil
		self.Object:Destroy()
		table.remove(module._BillBoardGuis,table.find(module._BillBoardGuis,self))
		if #module._BillBoardGuis == 0 then
			module._ScreenGui:Destroy()
		end
	end,
	["_renderConnection"] = DefualtGetter,
}

local setters = {
	["Adornee"] = function(self:CustomBillBoardGui, k, v)
		self["_renderConnection"] = RunService.PreRender:Connect(function()
			if not self.Enabled then return end

			local Object = self.Object
			local viewportPoint,depth,onScreen do
				local vector:Vector3
				if module._ScreenGui.IgnoreGuiInset then
					vector,onScreen  = Carmera:WorldToViewportPoint(self.Position)
				else
					vector,onScreen  = Carmera:WorldToScreenPoint(self.Position)
				end
				viewportPoint = Vector2.new(vector.X, vector.Y)
				depth = vector.Z
			end
			local viewportX = Carmera.ViewportSize.X
			local viewportY = Carmera.ViewportSize.Y

			local size do
				local targetSize =  self.OutSideSize

				local ScaleOffset = math.sqrt(5)/2 * depth
				size = UDim2.fromOffset(targetSize.Height.Offset + targetSize.Height.Scale/ScaleOffset*viewportY
					,targetSize.Height.Offset + targetSize.Height.Scale/ScaleOffset*viewportY)
			end
			local bufferSize = size.Width.Offset


			local maxBoundsX = viewportX - (bufferSize * 2)
			local maxBoundsY = viewportY - (bufferSize * 2)

			if viewportX <= bufferSize or viewportY<=bufferSize then
				return
			end
			local xPosition = math.clamp(viewportPoint.X, bufferSize, viewportX - bufferSize)
			local yPosition = math.clamp(viewportPoint.Y, bufferSize, viewportY - bufferSize)

			local camCFrame = Carmera.CFrame
			local screenHypotenuse = math.sqrt((maxBoundsX / 2)^2 + (maxBoundsY / 2)^2)
			onScreen = ((xPosition == viewportPoint.X) and (yPosition == viewportPoint.Y) and onScreen)
			local Rotation = 0
			local Image = self.InsideIconID
			if not onScreen then
				local worldDirection = self.Position - camCFrame.Position
				local relativeDirection = camCFrame:VectorToObjectSpace(worldDirection)
				local relativeDirection2D = Vector2.new(relativeDirection.X, relativeDirection.Y).Unit

				local testScreenPoint = relativeDirection2D * screenHypotenuse

				local angle = math.atan2(relativeDirection2D.X, relativeDirection2D.Y)

				local screenPoint
				if math.abs(testScreenPoint.Y) > maxBoundsY / 2 then
					screenPoint = relativeDirection2D * math.abs(maxBoundsY / 2 / relativeDirection2D.Y)
				else
					screenPoint = relativeDirection2D * math.abs(maxBoundsX / 2 / relativeDirection2D.X)
				end

				xPosition = viewportX / 2 + screenPoint.X
				yPosition = viewportY / 2 - screenPoint.Y

				Rotation = math.deg(angle)
				Image = self.OutsideIconID
			end
			local targetSize = 
				onScreen
				and self.Size
				or self.OutSideSize

			local ScaleOffset = math.sqrt(5)/2 * depth
			size = UDim2.fromOffset(targetSize.Height.Offset + targetSize.Height.Scale/ScaleOffset*viewportY
				,targetSize.Height.Offset + targetSize.Height.Scale/ScaleOffset*viewportY)
			Object.Position = UDim2.fromOffset(xPosition, yPosition)
			Object.Size = size
			Object.Image = Image
			Object.Rotation = Rotation
		end)
		DefualtSetter(self, k, v)
	end,
	["Parent"] = ObjectSetter,
	["Enabled"] = function(self:CustomBillBoardGui, k, v)
		self["Object"]["Visible"] = v
		DefualtSetter(self, k, v)
	end,
	["Size"] = DefualtSetter,
	["OutSideSize"] = DefualtSetter,
	["InsideIconID"] = function(self:CustomBillBoardGui, k, v)
		self.Object.Image = v
		DefualtSetter(self, k, v)
	end,
	["OutsideIconID"] = function(self:CustomBillBoardGui, k, v)
		self.Object.Image = v
		DefualtSetter(self, k, v)
	end,
	["_renderConnection"] = function(self:CustomBillBoardGui, k, v)
		local preRenderConnection = self["_renderConnection"]
		if preRenderConnection and preRenderConnection.Connected then
			preRenderConnection:Disconnect()
		end
		DefualtSetter(self, k, v)
	end,
}

function errorf(pattern, ...)
	error(string.format(pattern, ...))
end

function module._Init()
	module._ScreenGui = Instance.new("ScreenGui")
	module._ScreenGui.IgnoreGuiInset = true
	module._ScreenGui.Parent = Players.LocalPlayer.PlayerGui
end

function module.new(): CustomBillBoardGui
	local new = setmetatable({},{
		__newindex = function(t, k, v)
			if setters[k] then
				return setters[k](t, k, v)
			else
				errorf("Tried to set %s of MyModule.", k)
			end
		end,
		__index = function(t, k)
			if getters[k] then
				return getters[k](t, k)
			else
				errorf("Tried to get %s of MyModule.", k)
			end
		end,
	})
	if #module._BillBoardGuis == 0 then
		module._Init()
	end
	local Object do
		Object = Instance.new("ImageLabel")
		Object["AnchorPoint"] = Vector2.one/2
		Object["Visible"] = new.Enabled
		Object["Size"] = new.Size
		Object.BackgroundTransparency = 1
		Object.Parent = module._ScreenGui
	end
	rawset(new,"Object",Object)
	table.insert(module._BillBoardGuis,new)
	return new
end

return module
