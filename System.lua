local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SprintSys = {}
SprintSys.__index = SprintSys

SprintSys.__newindex = function(t, k, v)
	if (k == "Correndo") then
		if v then
			t:Correr()
		else
			t:Caminhar()
		end
	else rawset(t, k, v) end
end

function SprintSys.new(...)
	return setmetatable({
		CONFIG = ({...})[1],
		
		Connections = {},
		
		FieldOfView_def = Camera.FieldOfView
	}, SprintSys)
end

function SprintSys:Correr()
	self:Caminhar() -- isso é pra evitar duplicidades no sprint, uma precaução
	
	local Character = Player.Character
	if (not Character) or (not Character.Parent) then return end

	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if (not Humanoid) or (Humanoid:GetState() == Enum.HumanoidStateType.Dead) then return end
	
	local Animator = Humanoid:FindFirstChildWhichIsA("Animator") or Humanoid
	
	if (Humanoid.MoveDirection.Magnitude > 0) and (Humanoid.FloorMaterial ~= Enum.Material.Air) then
		Humanoid.WalkSpeed = self.CONFIG.Propriedades.Velocidade.Correr
		
		local Animation = self.CONFIG.Propriedades["Animação Personalizada"]
		if (Animation) and (typeof(Animation) == "Instance") and Animation:IsA("Animation") then
			self.AnimationTrack = Animator:LoadAnimation(Animation)
			self.AnimationTrack:Play()
		end

		if self.CONFIG.Efeitos["Distanciamento de câmera"] then
			TweenService:Create(Camera, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {FieldOfView = self.FieldOfView_def * (1 + math.clamp(self.CONFIG.Efeitos["Distanciamento de câmera"].Intensidade, 0, 10)/14)}):Play()
		end
	end
	
	--> Checagens
	-- tira o efeito de correr caso esteja parado
	local ultimo_MoveDirection = math.round(Humanoid.MoveDirection.Magnitude)
	self.Connections.MoveDirection = Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()	
		if (ultimo_MoveDirection == math.round(Humanoid.MoveDirection.Magnitude)) then return end
		
		if (Humanoid.MoveDirection.Magnitude == 0) then
			self:Caminhar(true)
		else
			if (self.Estado == "Correndo") then
				self:Correr()
			end
		end
		
		ultimo_MoveDirection = math.round(Humanoid.MoveDirection.Magnitude)
	end)
	
	-- tira o efeito de correr caso esteja no ar (pulando/caindo)
	local no_ar = (Humanoid.FloorMaterial == Enum.Material.Air)
	self.Connections.FloorMaterial = Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		if (no_ar == (Humanoid.FloorMaterial == Enum.Material.Air)) then return end
		no_ar = (Humanoid.FloorMaterial == Enum.Material.Air)
		
		if no_ar then
			self:Caminhar(true)
		else
			if (self.Estado == "Correndo") then
				self:Correr()
			end
		end
	end)
	--<
	
	self.Estado = "Correndo"
end

function SprintSys:Caminhar(temp)
	local Character = Player.Character
	if (not Character) or (not Character.Parent) then return end

	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if (Humanoid) then
		Humanoid.WalkSpeed = self.CONFIG.Propriedades.Velocidade.Caminhar
	end
	
	if (self.AnimationTrack) then
		self.AnimationTrack:Stop()
		self.AnimationTrack = nil
	end
	
	TweenService:Create(Camera, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {FieldOfView = self.FieldOfView_def}):Play()
	
	if (not temp) then
		for _,Connection in pairs(self.Connections) do
			if typeof(Connection) == "RBXScriptConnection" then
				Connection:Disconnect()
			end
		end
		self.Connections = {}
		
		self.Estado = "Caminhando"
	end
end

----------------------------------------------------------------------

return function(CONFIG)
	local Sprint = SprintSys.new(CONFIG)
	
	local last_w
	ContextActionService:BindAction("Sprint", function(_, UserInputState: Enum.UserInputState, Input: InputObject)
		if UserInputState == Enum.UserInputState.Begin then
			if CONFIG.Controles.Tipo == "Segurar" then
				if (Input.KeyCode == Enum.KeyCode.W) then
					if (not last_w) or (tick() - last_w > 1) then
						last_w = tick()
						
						return Enum.ContextActionResult.Pass
					end
				end
				Sprint.Correndo = true
			elseif CONFIG.Controles.Tipo == "Pressionar" then
				Sprint.Correndo = (Sprint.Estado ~= "Correndo")
			end
		else
			if CONFIG.Controles.Tipo == "Segurar" then
				Sprint.Correndo = false
			end
		end
		
		return Enum.ContextActionResult.Pass
	end, (Sprint.CONFIG.Controles.Celular and Sprint.CONFIG.Controles.Celular.Habilitar), table.unpack(Sprint.CONFIG.Controles.Teclas))
end
