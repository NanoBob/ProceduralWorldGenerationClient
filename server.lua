local cacheFileName = "terrain.cache.json"
local cache = {
    chunks = {}
}
local generatingChunks = {}
local generatingPlayers = {}

function loadCache()
    if fileExists(cacheFileName) then
        local file = fileOpen(cacheFileName)
        local content = fileRead(file, fileGetSize(file))
        fileClose(file)
        cache = fromJSON(content)
    else
        requestTerrain(terrainConfiguration, function(id)
            cache.id = id
        end, function (data)
            outputDebugString("Unable to generate terrain", 1)
            outputDebugString(data, 1)
        end)
    end
end

function saveCache()
    local file
    if fileExists(cacheFileName) then
        file = fileOpen(cacheFileName)
    else
        file = fileCreate(cacheFileName)
    end
    fileWrite(file, toJSON(cache))
    fileClose(file)
end

function generateChunk(x, y)
    if cache.id == null then
        outputDebugString("Unable to generate chunk, terrain id does not yet exist", 2)
        return
    end
    local identifier = x .. "X" ..  y
    if (generatingChunks[identifier] == nil) then
        generatingChunks[identifier] = true
        outputDebugString("Generating " .. identifier)
        requestChunk(cache.id, x, y, function(id)
            outputDebugString("Chunk generation successful")
            cache.chunks[identifier] = id
            generatingChunks[identifier] = nil
            saveCache()
        end, function()
            outputDebugString("Chunk generation failed " .. identifier, 2)
            generatingChunks[identifier] = nil
        end)
    end
end

function checkGenerationForPlayer(player)
    local x, y, z = getElementPosition(player)

    local width = terrainConfiguration.ChunkWidth
    local height = terrainConfiguration.ChunkHeight

    local roundedX = math.floor(x / width + 0.5) * width
    local roundedY = math.floor(y / height + 0.5) * height

    for generateX = -chunkRange, chunkRange do
        for generateY = -chunkRange, chunkRange do
            local identifier = (roundedX + generateX * width) .. "X" .. (roundedY + generateY * height)
            if (cache.chunks[identifier]) then
                if (generatingPlayers[player][identifier] == nil) then
                    generatingPlayers[player][identifier] = true
                    triggerClientEvent(player, "generation.loadChunk", player, cache.chunks[identifier], roundedX + generateX * width, roundedY + generateY * height)
                end
            else
                generateChunk(roundedX + generateX * width, roundedY + generateY * height)
            end
        end
    end
end

function checkGeneration()
    for player, _ in pairs(generatingPlayers) do
        checkGenerationForPlayer(player)
    end
end

function startGenerating(player)
    setElementPosition(player, 0, 0, 320)
    local vehicle = createVehicle(495, 0, 0, 320)
    setVehicleDamageProof(vehicle, true)
    warpPedIntoVehicle(player, vehicle)
    generatingPlayers[player] = {}
    checkGenerationForPlayer(player)
end
addCommandHandler("generate", startGenerating)

function init()
    for i = 550, 20000 do
        removeWorldModel(i, 10000, 0, 0, 0)
    end
    setOcclusionsEnabled(false)
    
    local heightMultiplier = terrainConfiguration.Terrain.HeightMultiplier
    createWater(
        -2998, -2998, heightOffset + waterHeight * heightMultiplier, 
        2998, -2998, heightOffset + waterHeight * heightMultiplier, 
        -2998, 2998, heightOffset + waterHeight * heightMultiplier, 
        2998, 2998, heightOffset + waterHeight * heightMultiplier
    )

    loadCache()

    setTimer(checkGeneration, 2 * 1000, 0)
end
init()