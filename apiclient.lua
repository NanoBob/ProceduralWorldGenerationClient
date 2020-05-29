local storageBaseUrl = "https://renderwaremodelgenerator.blob.core.windows.net/output/"
-- local storageBaseUrl = "http://127.0.0.1:10000/devstoreaccount1/output/"

local apiBaseUrl = "http://renderwaremodelgenerator.azurewebsites.net/api/"
-- local apiBaseUrl = "http://renderwaremodelgenerator-development.azurewebsites.net/api/"
-- local apiBaseUrl = "http://localhost:7071/api/" 

if (triggerServerEvent) then
    function requestDomains()
        requestBrowserDomains({ apiBaseUrl, storageBaseUrl }, true)
    end
    requestDomains()
end

function requestTerrain(options, callback, failureCallback)
    local json = toJSON(options)
    json = json:sub(2, json:len() - 1)

    fetchRemote(apiBaseUrl .. "generateTerrain", {
        postData = json,
    }, function(data, info)
        if (info.success) then
            local result = fromJSON("[" .. data .. "]")
            callback(result.id)
        else 
            failureCallback(data)
        end
    end)
end

function requestChunk(id, x, y, callback, failureCallback)
    local json = toJSON({ id = id, x = x, y = y })
    json = json:sub(2, json:len() - 1)

    fetchRemote(apiBaseUrl .. "generateChunk", {
        postData = json,
    }, function(data, info)
        if (info.success) then
            local result = fromJSON("[" .. data .. "]")
            callback(result.id)
        else 
            failureCallback(data)
        end
    end)
end

function requestChunks(id, positions, callback, failureCallback)
    local json = toJSON({
        id = id,
        chunks = positions
    })
    json = json:sub(2, json:len() - 1)

    fetchRemote(apiBaseUrl .. "generateChunks", {
        postData = json,
    }, function(data, info)
        if (info.success) then
            local result = fromJSON("[" .. data .. "]")
            callback(result.ids)
        else 
            failureCallback(data)
        end
    end)
end

function getDffIfExists(id, callback, failureCallback, retryCount)
    requestIfExists(storageBaseUrl .. id .. ".dff", callback, failureCallback, retryCount or 0)
end

function getTxdIfExists(id, callback, failureCallback, retryCount)
    requestIfExists(storageBaseUrl .. id .. ".txd", callback, failureCallback, retryCount or 0)
end

function getColIfExists(id, callback, failureCallback, retryCount)
    requestIfExists(storageBaseUrl .. id .. ".col", callback, failureCallback, retryCount or 0)
end

function getVegetationIfExists(id, callback, failureCallback, retryCount)
    requestIfExists(storageBaseUrl .. id .. ".vegetation.json", function(data)
        callback(fromJSON("[" .. data .. "]"))
    end, failureCallback, retryCount or 0)
end

function requestIfExists(url, callback, failureCallback, retryCount, retryTimer)
    local retryTimer = retryTimer or 1000
    fetchRemote(url, {
        method = "GET"
    }, function (data, info)
        if (info.success) then
            callback(data, info)
        else
            if (retryCount > 0) then
                setTimer(function() requestIfExists(url, callback, failureCallback, retryCount - 1, retryTimer * 2) end, retryTimer, 1)
            else
                failureCallback(data)
            end
        end
    end) 
end