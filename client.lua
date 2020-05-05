local models = {}
local modelStart = 2059
local heightOffset = 150

local seed = 1
local width = 400
local height = 400
local size = 8

local octaves = 6
local lacunarity = 2
local gain = 0.4
local heightMultiplier = 500
local frequency = 0.001
local waterHeight = -0.3;

local modelDistanceCache = {}

local materialOptions = {
    {
        min = -0.5,
        max = -0.25,
        materialName = "sand",
        maskName = "mask",
        red = 255,
        green = 255,
        blue = 255,
        alpha = 255,
    },
    {
        min = -0.25,
        max = 0,
        materialName = "grass",
        maskName = "mask",
        red = 255,
        green = 255,
        blue = 255,
        alpha = 255,
    },
    {
        min = 0,
        max = 0.25,
        materialName = "stone",
        maskName = "mask",
        red = 255,
        green = 255,
        blue = 255,
        alpha = 255,
    },
    {
        min = 0.25,
        max = 0.5,
        materialName = "snow",
        maskName = "mask",
        red = 255,
        green = 255,
        blue = 255,
        alpha = 255,
    },
}

local vegetationDelta = 2

local vegetationOptions = {
    {
        seed =  2,
        min =  0.4895,
        max =  0.49,
        minHeightNoise = -0.25,
        maxHeightNoise = 0,
        octaves =  3,
        lacunarity =  2,
        gain =  0.5,
        frequency =  0.03,
        models =  { 690, 693, 694, 698, 790, 791 }
    },
    {
        seed =  2,
        min =  0.409,
        max =  0.41,
        minHeightNoise = -0.25,
        maxHeightNoise = 0,
        octaves =  3,
        lacunarity =  2,
        gain =  0.5,
        frequency =  0.03,
        models =  { 705, 706, 709 }
    },
    {
        seed =  2,
        min =  0.309,
        max =  0.31,
        minHeightNoise = -0.25,
        maxHeightNoise = 0,
        octaves =  3,
        lacunarity =  2,
        gain =  0.5,
        frequency =  0.03,
        models =  { 615, 617, 764, 766, 768, 773 }
    },
    {
        seed =  2,
        min =  0.209,
        max =  0.21,
        minHeightNoise = -0.25,
        maxHeightNoise = 0,
        octaves =  3,
        lacunarity =  2,
        gain =  0.5,
        frequency =  0.03,
        models =  { 672, 700, 729, 780, 779, 782, 781  }
    },
    {
        seed =  2,
        min =  0.108,
        max =  0.11,
        minHeightNoise = -0.25,
        maxHeightNoise = 0,
        octaves =  3,
        lacunarity =  2,
        gain =  0.5,
        frequency =  0.03,
        models =  { 647, 728, 759, 760, 762, 800, 801, 802, 803, 805, 808, 809, 810, 811, 812, 813, 814, 815, 874 }
    }
}



local baseUrl = "http://renderwaremodelgenerator.azurewebsites.net/api/"

local generationTimer

function requestDomains()
    requestBrowserDomains({ "renderwaremodelgenerator.azurewebsites.net" })
end
requestDomains()

function placeModel(x, y)
    local fileName = x .. "x" .. y
    models[fileName] = true
    local model = modelStart
    modelStart = modelStart + 1

    local options = {
        seed = seed,
        x = x,
        y = y,
        width = width,
        height = height,
        size = size,

        octaves = octaves,
        lacunarity = lacunarity,
        gain = gain,
        heightMultiplier = heightMultiplier,
        frequency = frequency,

        materialOptions = materialOptions,
    }
    local json = toJSON(options)
    json = json:sub(2, json:len() - 1)


    fetchRemote(baseUrl .. "getCol", {
        postData = json
    }, function(data, info)
        if (info.success) then
            local col = engineLoadCOL(data)
            engineReplaceCOL(col, model)      
            
            fetchRemote(baseUrl .. "getDff", {
                postData = json
            }, function(data, info)
                if (info.success) then
                    local txd = engineLoadTXD("landscape.txd")
                    engineImportTXD(txd, model)
                    local dff = engineLoadDFF(data)
                    engineReplaceModel(dff, model)

                    engineSetModelLODDistance(model, 3000)
                    local object = createObject(model, x, y, heightOffset)
                    local lod = createObject(model, x, y, heightOffset, 0, 0, 0, true)
                    setLowLODElement(object, lod)

                    placeVegetation(x, y, options)
                else
                    iprint(info)
                end
            end)
        else
            iprint(info)
        end
    end)
end

function placeVegetation(x, y, terrainOptions)
    local options = {
        terrain = terrainOptions,
        delta = vegetationDelta,
        vegetationOptions = vegetationOptions,
    }
    local json = toJSON(options)   
    json = json:sub(2, json:len() - 1)

    fetchRemote(baseUrl .. "getVegetation", {
        postData = json
    }, function(data, info)
        if (info.success) then
            local models = fromJSON("[" .. data .. "]")
            for key, model in pairs(models) do
                setTimer(function()
                    engineSetModelLODDistance(model.Model, 300)
                    local main = createObject(model.Model, x + model.Position.X, y + model.Position.Y, model.Position.Z + heightOffset, model.Rotation.X, model.Rotation.Y, model.Rotation.Z)
                    local lod = createObject(model.Model, x + model.Position.X, y + model.Position.Y, model.Position.Z + heightOffset, model.Rotation.X, model.Rotation.Y, model.Rotation.Z, true)
                    setLowLODElement(main, lod)
    
                    local mainX, mainY, mainZ = getElementPosition(main)
                    if (modelDistanceCache[model.Model] == nil) then
                        modelDistanceCache[model.Model] = getElementDistanceFromCentreOfMassToBaseOfModel(main)
                    end
                    local offset = modelDistanceCache[model.Model]
                    setElementPosition(main, mainX, mainY, mainZ + offset)
                    setElementPosition(lod, mainX, mainY, mainZ + offset)
                end, key * 50, 1)
            end
        else
            iprint(info)
        end
    end)
end

function attemptGeneration(roundedX, roundedY)
    local fileName = roundedX .. "x" .. roundedY
    if not models[fileName] then
        placeModel(roundedX, roundedY)
    end
end

function checkGeneration()
    local x, y, z = getElementPosition(getLocalPlayer())
    local roundedX = math.floor(x / width + 0.5) * width
    local roundedY = math.floor(y / height + 0.5) * height

    for generateX = -2, 2 do
        for generateY = -2, 2 do
            attemptGeneration(roundedX + generateX * width, roundedY + generateY * height)
        end
    end
end

function startGenerating()
    engineSetAsynchronousLoading(false, true)
    generationTimer = setTimer(checkGeneration, 1000, 0)

    for i=550,20000 do
        removeWorldModel(i,10000,0,0,0)
    end
    setOcclusionsEnabled(false)  -- Also disable occlusions when removing certain models
    
    createWater(
        -2998, -2998, heightOffset + waterHeight * heightMultiplier, 
        2998, -2998, heightOffset + waterHeight * heightMultiplier, 
        -2998, 2998, heightOffset + waterHeight * heightMultiplier, 
        2998, 2998, heightOffset + waterHeight * heightMultiplier
    )

    setCloudsEnabled(false)
    -- setFogDistance(1000)
    -- setFarClipDistance(1000)
end
addCommandHandler("generate", startGenerating)
