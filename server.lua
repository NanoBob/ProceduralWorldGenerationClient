
function startGenerating(player)
    local vehicle = createVehicle(495, 0, 0, 520)
    setVehicleDamageProof(vehicle, true)
    warpPedIntoVehicle(player, vehicle)
end
addCommandHandler("warpgenerate", startGenerating)
