local StarterPlayer = game:GetService("StarterPlayer")

local _CONFIG = {}
_CONFIG.Controles = {
	Tipo = "Segurar",
	-- Segurar: correr segurando o botão, e parar de correr ao solta-lo
	-- Pressionar: correr ao pressionar o botão, e parar de correr ao pressiona-lo novamente
	---> Caso queira correr apertando "2 vezes o W", use o Tipo "Segurar", e defina a Tecla "W" no campo a baixo, usando "Enum.KeyCode.W"
	
	Teclas = { -- teclas/botões para correr
		Enum.KeyCode.LeftControl, -- Teclado
		Enum.KeyCode.ButtonX -- Controle de XBOX
	},
	
	--[[--> Essa opção ficará disponível na próxima atualização!
	Mobile = {
		Habilitar = false -- Se habilitado, irá gerar um botão para correr no celular
	}
	--]]
}

_CONFIG.Propriedades = {
	Velocidade = { -- em WalkSpeed
		Caminhar = StarterPlayer.CharacterWalkSpeed, -- Você pode alterar isso para o WalkSpeed de "andar" do seu personagem, caso não seja esse
		Correr = 30
	},
	
	-- Caso tenha uma animação personalizada para usar, remova os "--" do inicio da linha a baixo
	--["Animação Personalizada"] = script.Animation -- Insira aqui o diretório da sua Animation
}

_CONFIG.Efeitos = {
	["Distanciamento de câmera"] = {
		Habilitar = true,

		Intensidade = 3 -- (Min: 0; Max: 10)
	},
}

require(script:FindFirstChildWhichIsA("ModuleScript"))(_CONFIG)
