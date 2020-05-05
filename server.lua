
function startGenerating(player)
    local vehicle = createVehicle(495, 0, 0, 320)
    setVehicleDamageProof(vehicle, true)
    warpPedIntoVehicle(player, vehicle)
end
addCommandHandler("warpgenerate", startGenerating)
