-- LocalScript - Simulador de Wi-Fi ruim no MM2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local NetworkSettings = settings():GetService("NetworkSettings")

local player = Players.LocalPlayer

-- CONFIGURAÇÕES
local LAG_DURATION = 1.6 -- segundos de lag
local REPLICATION_LAG = 5.0 -- quanto maior, pior o "wi-fi"

-- Variável para controlar o sistema
local sistemaAtivo = false

-- Criar GUI no canto inferior direito
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false -- não desaparece ao morrer/resetar
screenGui.Parent = player:WaitForChild("PlayerGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 50)
statusLabel.Position = UDim2.new(1, -210, 1, -60) -- canto inferior direito
statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Text = "Sistema OFF ❌"
statusLabel.Active = true
statusLabel.Parent = screenGui

-- Função para atualizar painel
local function atualizarPainel()
    if sistemaAtivo then
        statusLabel.Text = "Sistema ON 📶"
        statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        statusLabel.Text = "Sistema OFF ❌"
        statusLabel.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end

-- Função de simulação de lag
local function simulateLag()
    if not sistemaAtivo then return end

    pcall(function()
        NetworkSettings.IncomingReplicationLag = REPLICATION_LAG
        NetworkSettings.OutgoingReplicationLag = REPLICATION_LAG
    end)

    local start = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if tick() - start < LAG_DURATION then
            task.wait(math.random(0.05, 0.15))
        else
            connection:Disconnect()
        end
    end)

    task.delay(LAG_DURATION, function()
        pcall(function()
            NetworkSettings.IncomingReplicationLag = 0
            NetworkSettings.OutgoingReplicationLag = 0
        end)
    end)
end

-- Detecta mortes importantes
local function monitorCharacter(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    hum.Died:Connect(function()
        simulateLag()
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then
        monitorCharacter(plr.Character)
    end
    plr.CharacterAdded:Connect(monitorCharacter)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(monitorCharacter)
end)

-- Sistema ON/OFF com tecla Y
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Y then
        sistemaAtivo = not sistemaAtivo
        atualizarPainel()
        if not sistemaAtivo then
            pcall(function()
                NetworkSettings.IncomingReplicationLag = 0
                NetworkSettings.OutgoingReplicationLag = 0
            end)
        end
    end
end)

-- Sistema de arrastar (mouse ou toque)
local dragging = false
local dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    statusLabel.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

statusLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = statusLabel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        update(input)
    end
end)
