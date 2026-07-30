local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local function try(callback)
    pcall(callback)
end

local flags = {
    DFFlagDebugRenderForceTechnologyVoxel = "True",
    DFFlagDebugRenderForceTechnologyCompatibility = "True",
    DFFlagDebugRenderForceTechnologyFuture = "False",
    DFFlagDebugRenderForceTechnologyShadowMap = "False",
    DFFlagDisableDPIScale = "True",
    DFFlagTextureQualityOverrideEnabled = "True",
    DFIntTextureQualityOverride = "0",
    DFIntDebugFRMQualityLevelOverride = "1",
    FFlagDebugGraphicsPreferD3D11 = "True",
    FFlagDebugGraphicsPreferVulkan = "False",
    FFlagDebugGraphicsPreferOpenGL = "False",
    FFlagDebugSkyGray = "True",
    FFlagGlobalWindRendering = "False",
    FFlagRenderGrassDetailStrands = "False",
    FFlagRenderGrassHeightMap = "False",
    FIntRenderGrassDetailStrands = "0",
    FIntRenderGrassHeightMap = "0",
    FIntFRMMinGrassDistance = "0",
    FIntFRMMaxGrassDistance = "0",
    FIntRenderShadowIntensity = "0",
    FIntRenderLocalLightFadeInMs = "0",
    FIntRenderLocalLightFadeOutMs = "0",
    FIntRenderLocalLightUpdatesMax = "1",
    FIntRenderLocalLightUpdatesMin = "1",
    FIntDebugForceMSAASamples = "0",
    FIntDebugTextureManagerSkipMips = "8",
    FIntTerrainArraySliceSize = "4",
    FIntTerrainOTAMaxTextureSize = "4",
    FIntDebugFRMOptionalMSAALevelOverride = "0"
}

if type(setfflag) == "function" then
    for flag, value in pairs(flags) do
        try(function()
            setfflag(flag, value)
        end)
    end
end

try(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

try(function()
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
end)

try(function()
    sethiddenproperty(Workspace.Terrain, "Decoration", false)
end)

try(function()
    sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
end)

Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.Brightness = 1
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.ShadowSoftness = 0

local function optimize(instance)
    if instance:IsA("BasePart") then
        instance.Material = Enum.Material.SmoothPlastic
        instance.MaterialVariant = ""
        instance.Reflectance = 0
        instance.CastShadow = false
    elseif instance:IsA("Decal") or instance:IsA("Texture") then
        instance.Transparency = 1
    elseif instance:IsA("SurfaceAppearance") then
        instance.AlphaMode = Enum.AlphaMode.Overlay
        instance.ColorMap = ""
        instance.MetalnessMap = ""
        instance.NormalMap = ""
        instance.RoughnessMap = ""
    elseif instance:IsA("ParticleEmitter")
        or instance:IsA("Trail")
        or instance:IsA("Beam")
        or instance:IsA("Smoke")
        or instance:IsA("Fire")
        or instance:IsA("Sparkles") then
        instance.Enabled = false
    elseif instance:IsA("PostEffect") then
        instance.Enabled = false
    elseif instance:IsA("Atmosphere") then
        instance.Density = 0
        instance.Haze = 0
        instance.Glare = 0
    elseif instance:IsA("Clouds") then
        instance.Enabled = false
    end
end

for _, instance in ipairs(game:GetDescendants()) do
    try(function()
        optimize(instance)
    end)
end

game.DescendantAdded:Connect(function(instance)
    try(function()
        optimize(instance)
    end)
end)

if game:GetService("CoreGui"):FindFirstChild("RenderBlackout") then
    game:GetService("CoreGui"):FindFirstChild("RenderBlackout"):Destroy()
end

Instance.new("ScreenGui", game:GetService("CoreGui")).Name = "RenderBlackout"
game:GetService("CoreGui").RenderBlackout.IgnoreGuiInset = true
game:GetService("CoreGui").RenderBlackout.ResetOnSpawn = false
game:GetService("CoreGui").RenderBlackout.DisplayOrder = 2147483647
game:GetService("CoreGui").RenderBlackout.ZIndexBehavior = Enum.ZIndexBehavior.Global

Instance.new("Frame", game:GetService("CoreGui").RenderBlackout).Name = "Blackout"
game:GetService("CoreGui").RenderBlackout.Blackout.Size = UDim2.fromScale(1, 1)
game:GetService("CoreGui").RenderBlackout.Blackout.BackgroundColor3 = Color3.new(0, 0, 0)
game:GetService("CoreGui").RenderBlackout.Blackout.BorderSizePixel = 0
game:GetService("CoreGui").RenderBlackout.Blackout.ZIndex = 2147483647

game:GetService("RunService").RenderStepped:Wait()
game:GetService("RunService"):Set3dRenderingEnabled(false)

game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightAlt then
        if game:GetService("CoreGui").RenderBlackout.Enabled then
            game:GetService("RunService"):Set3dRenderingEnabled(true)
            game:GetService("CoreGui").RenderBlackout.Enabled = false
        else
            game:GetService("CoreGui").RenderBlackout.Enabled = true
            game:GetService("RunService").RenderStepped:Wait()
            game:GetService("RunService"):Set3dRenderingEnabled(false)
        end
    end
end)
