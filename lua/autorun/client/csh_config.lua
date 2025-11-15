if SERVER then return end

CONFIG = CONFIG or {}
CONFIG.Config = CONFIG.Config or {}

local configData  = { -- default config

    boxesColor    = {r=30, g=30, b=40},
    iconsColor    = {r=255, g=255, b=255},
    textsColor    = {r=255, g=255, b=255},

    RGBalpha      = {bg=250, icons=255, texts=255},
    boxesCorner   = 5,
    enabled       = true,
    lowhp_color   = true,

}

local json         = util.TableToJSON(configData, true)
local configFolder = "customhud"
local configPath   = "customhud/config.json"

function CONFIG.createConfig()
    file.CreateDir(configFolder)
    file.Write(configPath, util.TableToJSON(configData, true))
    print("[csh_config]: created new config: data/"..configPath)
    CONFIG.Config = table.Copy(configData)
end

function CONFIG.createConfig()
    file.CreateDir(configFolder)
    file.Write(configPath, util.TableToJSON(configData, true))
    print("[csh_config]: created new config: data/"..configPath)

    CONFIG.Config = table.Copy(configData)
end

function CONFIG.loadConfig()
    if file.Exists(configPath, "DATA") then
        local content = file.Read(configPath, "DATA")
        if not content or content == "" then
            CONFIG.createConfig()
            return
        end

        local success, config = pcall(util.JSONToTable, content)
        if not success or not config then
            CONFIG.createConfig()
            return
        end

        CONFIG.Config = table.Merge(table.Copy(configData), config)
        --print("[csh_config]: config loaded")
        --PrintTable(CONFIG.Config)
    else
        CONFIG.createConfig()
    end
end

function CONFIG.saveConfig()
    file.CreateDir(configFolder)
    local json = util.TableToJSON(CONFIG.Config, true)
    file.Write(configPath, json)
end 

function CONFIG.editConfig(key, value)
    if not CONFIG.Config then CONFIG.loadConfig() end

    if not CONFIG.Config then
        return default
    end

    if not string.find(key, ".", 1, true) then
        CONFIG.Config[key] = value
    else
        local keys = string.Explode(".", key)
        local tbl = CONFIG.Config

        for i = 1, #keys - 1 do
            local k = keys[i]
            tbl[k] = tbl[k] or {} 
            tbl = tbl[k]
        end
        tbl[keys[#keys]] = value
    end

    CONFIG.saveConfig()
    --print("[csh_config]: edit " .. key .. " = " .. tostring(value))
end

function CONFIG.getValue(key, default)
    if not CONFIG.Config then
        CONFIG.loadConfig()
        return default
    end

    if not string.find(key, ".", 1, true) then
        if CONFIG.Config[key] == nil then
            return default
        else
            return CONFIG.Config[key]
        end
    end

    local keys = string.Explode(".", key)
    local tbl = CONFIG.Config

    for i = 1, #keys do
        local k = keys[i]
        if tbl[k] == nil then
            return default
        end
        tbl = tbl[k]
    end

    return tbl
end