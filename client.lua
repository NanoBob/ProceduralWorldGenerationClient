local models = {}
local modelStart = 2059

local seed = 1
local width = 400
local height = 400
local size = 8

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
    createObject(model, x, y, 500)

    local json = toJSON({
        seed = seed,
        x = x,
        y = y,
        width = width,
        height = height,
        size = size
    })
    json = json:sub(2, json:len() - 1)
    
    outputChatBox("Downloading .col & .dff")


    fetchRemote(baseUrl .. "getCol", {
        postData = json
    }, function(data, info)
        if (info.success) then
            engineSetModelLODDistance(model, 300)
            local col = engineLoadCOL(data)
            engineReplaceCOL(col, model)

            outputChatBox("Downloaded .col")           
            
            fetchRemote(baseUrl .. "getDff", {
                postData = json
            }, function(data, info)
                if (info.success) then
                    local txd = engineLoadTXD("landscape.txd")
                    engineImportTXD(txd, model)
                    local dff = engineLoadDFF(data)
                    engineReplaceModel(dff, model)

                    outputChatBox("Downloaded .dff")
                else
                    iprint(info)
                end
            end)
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

    attemptGeneration(roundedX - width, roundedY - height)
    attemptGeneration(roundedX, roundedY - height)
    attemptGeneration(roundedX + width, roundedY - height)

    attemptGeneration(roundedX - width, roundedY)
    attemptGeneration(roundedX, roundedY)
    attemptGeneration(roundedX + width, roundedY)

    attemptGeneration(roundedX - width, roundedY + height)
    attemptGeneration(roundedX, roundedY + height)
    attemptGeneration(roundedX + width, roundedY + height)
end

function startGenerating()
    engineSetAsynchronousLoading(false, true)
    generationTimer = setTimer(checkGeneration, 1000, 0)
end
addCommandHandler("generate", startGenerating)
