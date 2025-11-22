if SERVER then return end

mainf = mainf or {}

local BASE = {
    gap      = 5,
    padL     = 15,
    padR     = 15,
    height   = 55,
    icon     = 25,
    text     = 24,
    minW     = 100,
}

local scale      = 1
local iconSize   = 25
local tileH      = 55
local padL, padR, gap = 15,15,5
local corner     = 5

local baseY = ScrH() - 60
local posY  = 60
local iconY = 0

local COLORS = { box = Color(30,30,40,250), text = Color(255,255,255), icon = Color(255,255,255) }
local COMP   = { lowhp = true, hud = true }

local icons = {
    health = Material("customhud/healthicon.png"),
    armor  = Material("customhud/armoricon.png"),
    ammo   = Material("customhud/ammoicon.png"),
}

local function CreateFont(size)
    surface.CreateFont("CustomHUDFont", {
        font      = "Montserrat Medium",
        size      = math.Round(size),
        weight    = 500,
        antialias = true,
    })
end

function mainf.updateConfig()
    if not CONFIG.Config then return end

    scale = math.Clamp(CONFIG.getValue("size.all",100)/100, 0.3, 3)

    local ib = CONFIG.getValue("size.icons",25)
    local tb = CONFIG.getValue("size.texts",24)

    iconSize = math.Round(BASE.icon * scale * (ib/BASE.icon))
    local textSize = math.Round(BASE.text * scale * (tb/BASE.text))

    tileH   = math.Round(BASE.height * scale)
    padL    = math.Round(BASE.padL * scale)
    padR    = math.Round(BASE.padR * scale)
    gap     = math.Round(BASE.gap * scale)
    corner  = math.Round(CONFIG.getValue("boxesCorner",5) * scale)

    local a = CONFIG.getValue("RGBalpha.bg",250)
    COLORS.box = Color(CONFIG.getValue("boxesColor.r",30), CONFIG.getValue("boxesColor.g",30), CONFIG.getValue("boxesColor.b",40), a)
    COLORS.text = Color(CONFIG.getValue("textsColor.r",255), CONFIG.getValue("textsColor.g",255), CONFIG.getValue("textsColor.b",255), CONFIG.getValue("RGBalpha.texts",255))
    COLORS.icon = Color(CONFIG.getValue("iconsColor.r",255), CONFIG.getValue("iconsColor.g",255), CONFIG.getValue("iconsColor.b",255), CONFIG.getValue("RGBalpha.icons",255))

    COMP.lowhp = CONFIG.getValue("lowhp_color", true)
    COMP.hud   = CONFIG.getValue("enabled", true)

    posY = CONFIG.getValue("position.y", 60)
    baseY = ScrH() - posY
    iconY = baseY + (tileH - iconSize) / 2

    CreateFont(textSize)
end

local function DrawTile(text, mat, colText, colIcon, x)
    surface.SetFont("CustomHUDFont")
    local tw, th = surface.GetTextSize(text)

    local refW = surface.GetTextSize("100")
    local textZoneW = math.max(tw, refW)

    local totalW = padL + iconSize + 10 + textZoneW + padR
    local w = math.max(totalW, BASE.minW * scale)

    draw.RoundedBox(corner, x, baseY, w, tileH, COLORS.box)

    if mat and not mat:IsError() then
        surface.SetDrawColor(colIcon or COLORS.icon)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(x + padL, iconY, iconSize, iconSize)
    end

    local textStartX = x + w - padR - textZoneW
    local textX = textStartX + textZoneW / 2
    local textY = baseY + (tileH - th) / 2

    local offsetX = 0
    local offsetY = -1

    draw.SimpleText(text, "CustomHUDFont", textX + offsetX, textY + offsetY, colText or COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

    return x + w + gap
end

hook.Add("HUDPaint", "CustomHUD_Draw", function()
    if not COMP.hud then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if not CONFIG then return end

    if ScrH() ~= baseY + posY then
        baseY = ScrH() - posY
        iconY = baseY + (tileH - iconSize) / 2
    end

    local x = CONFIG.getValue("position.x", 5)

    local hp = ply:Health()
    local armor = ply:Armor()

    -- HP
    local hpCol = (hp <= 50 and COMP.lowhp) and Color(255,82,82) or COLORS.text
    local hpIconCol = (hp <= 50 and COMP.lowhp) and Color(255,82,82) or COLORS.icon
    x = DrawTile(tostring(hp), icons.health, hpCol, hpIconCol, x)

    -- Armor
    x = DrawTile(tostring(armor), icons.armor, COLORS.text, COLORS.icon, x)

    -- Ammo
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep:GetPrimaryAmmoType() > 0 then
        local clip = wep:Clip1()
        local reserve = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
        local str = clip >= 0 and (clip.." / "..reserve) or tostring(reserve)
        DrawTile(str, icons.ammo, COLORS.text, COLORS.icon, x)
    end
end)



hook.Add("InitPostEntity", "CustomHUD_InitConfig", function()
    if not CONFIG then return end
    CONFIG.loadConfig()
    mainf.updateConfig()
end)

hook.Add("HUDShouldDraw", "CustomHUD_HideDefault", function(name)
    if not COMP.hud then return end
    local hide = { CHudHealth=true, CHudBattery=true, CHudAmmo=true, CHudSecondaryAmmo=true }
    return not hide[name]
end)
