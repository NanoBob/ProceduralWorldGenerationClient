local function getFileBase64(filepath)
    local file = fileOpen(filepath)
    local content = fileRead(file, fileGetSize(file))
    fileClose(file)

    local base64 = base64Encode(content)

    local segments = {}
    while (base64:len() > 65535) do
        segments[#segments + 1] = base64:sub(1, 65535)
        base64 = base64:sub(65535 + 1)
    end
    segments[#segments + 1] = base64
    return segments
end

chunkRange = 2
waterHeight = 0;
heightOffset = 0

terrainConfiguration = {
    ChunkWidth = 400,
    ChunkHeight = 400,
    ChunkDelta = 8.0,
    Terrain = {
        Seed = 5,
        Octaves = 3,
        Lacunarity = 3.0,
        Gain = 0.4,
        Frequency = 0.001,
        HeightMultiplier = 250
    },
    Texture = {
        Width = 1600,
        Height = 1600,
        Materials = {
            getFileBase64("textures/sand.png"),
            getFileBase64("textures/grass.png"),
            getFileBase64("textures/stone.png"),
            getFileBase64("textures/snow.png"),
        },
        MaterialScaleFactors = {
            1,
            1,
            1,
            1
        },
        MaterialOptions = {
            {
                min = -0.5,
                max = 0.00,
                from = 0
            },
            {
                min = 0.00,
                max = 0.050,
                from = 0,
                to = 1
            },
            {
                min = 0.050,
                max = 0.5,
                from = 1
            },
        }
    },
    Vegetation = {
        Delta = 2,
        VegetationSets = {
            {
                Seed = 2,
                Octaves = 3,
                Lacunarity = 2,
                Gain = 0.5,
                Frequency = 0.03,

                objectRanges = {
                    {
                        minNoise =  0.48955,
                        maxNoise =  0.49,
                        minHeight = 0.08,
                        maxHeight = 0.5,
                        models = { 690, 693, 694, 698, 790, 791 }
                    },
                    {
                        minNoise =  0.4095,
                        maxNoise =  0.41,
                        minHeight = 0.08,
                        maxHeight = 0.5,
                        models = { 705, 706, 709 }
                    },
                    {
                        minNoise =  0.3095,
                        maxNoise =  0.31,
                        minHeight = 0.08,
                        maxHeight = 0.5,
                        models = { 615, 617, 764, 766, 768, 773 }
                    },
                    {
                        minNoise =  0.2095,
                        maxNoise =  0.21,
                        minHeight = 0.08,
                        maxHeight = 0.5,
                        models = { 672, 700, 729, 780, 779, 782, 781  }
                    },
                    {
                        minNoise =  0.1085,
                        maxNoise =  0.11,
                        minHeight = 0.08,
                        maxHeight = 0.5,
                        models = { 647, 728, 759, 760, 762, 800, 801, 802, 803, 805, 808, 809, 810, 811, 812, 813, 814, 815, 874}
                    }
                }
            }
        }
    }
}