# Procedural world generation client
This is an example resource for MTA:SA displaying procedural world generation.

The generation of the .dff and .col files is done by an API.
The server then caches the result for the terrain generation in `terrain.cache.json`. 
Deleting this file and restarting the resource will result in a new world being generated. Do note that if no settings were changed the newly generated world will be identical.

`configuration.lua` contains a Lua table with configuration sent to the API.  
This file contains several sections of values, for specific parts of the terrain.
- Root level  
  The root level contains values specifying the size and detail of individual chunks.
- Terrain  
  This section of the configuration specifies the input variables to the noise function used to generate the height map for the terrain.
- Texture  
  The texture section contains the materials (in base 64 substrings), material scales, and the configuration for what materials to place at which height in the terrain.  
  This also support smooth transitions between multiple materials.
- Vegetation  
  The vegetation section specifies where to place objects on the terrain.  
  This section contains similar values to the terrain section, because this also uses a noise map to decide where to place the objects.

The resource comes with a pre-configured, and pre-cached world.
  
