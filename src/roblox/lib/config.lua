local HttpService = game:GetService("HttpService")

local Config = {}
Config._folder = "Chiyo"
Config._file = "config.json"

local hasFS = (typeof(isfile) == "function") and (typeof(writefile) == "function") and (typeof(readfile) == "function")
local hasFolder = (typeof(isfolder) == "function") and (typeof(makefolder) == "function")

local function safeMakeFolder(path)
    if hasFolder then
        if not isfolder(path) then
            pcall(makefolder, path)
        end
    end
end

function Config:Setup(folder, file)
    if folder then self._folder = folder end
    if file then self._file = file end
end

function Config:Load()
    if not hasFS then return {} end
    local path = string.format("%s/%s", self._folder, self._file)
    if not isfile(path) then return {} end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    return ok and decoded or {}
end

function Config:Save(tbl)
    if not hasFS then return false end
    safeMakeFolder(self._folder)
    local path = string.format("%s/%s", self._folder, self._file)
    local ok = pcall(function()
        writefile(path, HttpService:JSONEncode(tbl or {}))
    end)
    return ok
end

return Config

