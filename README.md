# Procedural world generation client
This is an example resource for MTA:SA displaying procedural world generation.

The generation of the .dff and .col files is done by an API.
client.lua contains some configurable variables, these are:
- local seed = 1  
  Seed for generator, a different seed will generate a different world
- local width = 400  
  Width of an individual .dff / .col 
- local height = 400  
  Height of an individual .dff / .col
- local size = 8  
  Size of the grid used in generating the models

The resource contains two commands:
- /generate  
  Starts procedural generation
- /warpgenerate  
  Warps you into a vehicle on the procedurally generated map
