local modelStart = 2059
local modelDistanceCache = {}

function loadChunk(x, y, dff, col, txd, vegetation)
    if (dff and col and txd and vegetation) then
        print("Loading chunk at " .. x .. ", " .. y)
        local objectModel = modelStart
        modelStart = modelStart + 1

        local col = engineLoadCOL(col)
        local txd = engineLoadTXD(txd)
        local dff = engineLoadDFF(dff)

        engineReplaceCOL(col, objectModel)  
        engineImportTXD(txd, objectModel)
        engineReplaceModel(dff, objectModel)

        engineSetModelLODDistance(objectModel, 3000)
        local object = createObject(objectModel, x, y, heightOffset)
        local lod = createObject(objectModel, x, y, heightOffset, 0, 0, 0, true)
        setLowLODElement(object, lod)

        for key, model in pairs(vegetation) do
            setTimer(function()
                engineSetModelLODDistance(model.Model, 100)
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
    end
end

function requestChunk(id, x, y)
    local dff
    local col
    local txd
    local vegetation

    getDffIfExists(id, function(result)
        dff = result
        loadChunk(x, y, dff, col, txd, vegetation)
    end, function()
        outputDebugString("Failed to get chunk " .. id .. " dff")
    end, 16)

    getTxdIfExists(id, function(result)
        txd = result
        loadChunk(x, y, dff, col, txd, vegetation)
    end, function()
        outputDebugString("Failed to get chunk " .. id .. " txd")
    end, 16)

    getColIfExists(id, function(result)
        col = result
        loadChunk(x, y, dff, col, txd, vegetation)
    end, function()
        outputDebugString("Failed to get chunk " .. id .. " col")
    end, 16)

    getVegetationIfExists(id, function(result)
        vegetation = result
        loadChunk(x, y, dff, col, txd, vegetation)
    end, function()
        outputDebugString("Failed to get chunk " .. id .. " vegetation")
    end, 16)
end
addEvent("generation.loadChunk", true)
addEventHandler("generation.loadChunk", getRootElement(), requestChunk)