-- BLOQUEAR PEGAR MOEDAS - MM2
-- CLIENT SIDE

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function bloquearMoeda(coin)
    if coin:IsA("BasePart") then
        for _, v in pairs(coin:GetChildren()) do
            if v:IsA("TouchTransmitter") then
                v:Destroy()
            end
        end
        coin.CanTouch = false
        coin.CanCollide = false
    end
end

for _, obj in pairs(workspace:GetDescendants()) do
    if obj.Name:lower():find("coin") then
        bloquearMoeda(obj)
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if obj.Name:lower():find("coin") then
        task.wait(0.1)
        bloquearMoeda(obj)
    end
end)

print("✅ Moedas bloqueadas (client-side)")
