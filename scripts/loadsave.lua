---Tallennustiedosto
local saveFile = {}

local json = require("json")
--local defaultLocation = "assets.save"
function saveFile.save(data, filename)
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local file, errorString = io.open(path, "w")
    if not file then
        print("File error:" .. errorString)
        return false
    else
        file:write(json.prettify(json.encode(data)))
        io.close(file)
        return true
    end
end

function saveFile.load(filename)

    local path = system.pathForFile(filename, system.DocumentsDirectory)

    local file, errorString = io.open(path, "r")

    if not file then
        print("File error:" .. errorString)
    else
        local contents = file:read("*a")
        local data = json.decode(contents)
        io.close(file)
        return data
    end
end

return saveFile
