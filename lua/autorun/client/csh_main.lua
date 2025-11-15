if SERVER then return end

mainf = mainf or {}

local CONSTANTS = {
    baseX = 5,h = 55,gap = 5,padL = 15,padR = 15,iconW = 25,iconH = 25
}

local screenH = ScrH()
local baseY = screenH - 60
local iconY = baseY + (CONSTANTS.h - CONSTANTS.iconH) / 2
local hpTextColor, hpIconColor
local COLORS = {box  = Color(30, 30, 40, 250),
    text = Color(255, 255, 255, 255),
    icon = Color(255, 255, 255, 255)}

local COMP = {
    lowhp = true,
    hud = true,
    corner = 5,
    lowcolor = Color(255, 82, 82, 255),
    lowcolor_2 = Color(255, 82, 82, 255),
}

surface.CreateFont("CustomHUDFont", {
    font = "Montserrat Medium",
    size = 24,
    weight = 500,
    antialias = true,
    shadow = false
})

local icons = {
    healthIcon = Material("customhud/healthicon.png"),
    armorIcon = Material("customhud/armoricon.png"),
    ammoIcon = Material("customhud/ammoicon.png"),
}

function mainf.updateConfig()
    if not CONFIG or not CONFIG.Config then
        print("[DEBUG] CONFIG не загружен!")
        return
    end

    local a_bg     = CONFIG.getValue("RGBalpha.bg", 250)
    local a_texts  = CONFIG.getValue("RGBalpha.texts", 255)
    local a_icons  = CONFIG.getValue("RGBalpha.icons", 255)

    COLORS.text  = Color(
        CONFIG.getValue("textsColor.r", 255),
        CONFIG.getValue("textsColor.g", 255),
        CONFIG.getValue("textsColor.b", 255),
        a_texts
    )

    COLORS.icon  = Color(
        CONFIG.getValue("iconsColor.r", 255),
        CONFIG.getValue("iconsColor.g", 255),
        CONFIG.getValue("iconsColor.b", 255),
        a_icons
    )

    COLORS.box   = Color(
        CONFIG.getValue("boxesColor.r", 30),
        CONFIG.getValue("boxesColor.g", 30),
        CONFIG.getValue("boxesColor.b", 40),
        a_bg
    )

    COLORS.alpha = { bg = a_bg, texts = a_texts, icons = a_icons }

    COMP.lowhp   = CONFIG.getValue("lowhp_color", true)
    COMP.hud     = CONFIG.getValue("enabled", true)
    COMP.corner  = CONFIG.getValue("boxesCorner", 5)
    COMP.lowcolor   = Color(255, 82, 82, a_texts)
    COMP.lowcolor_2 = Color(255, 82, 82, a_icons)
end

local function draw_h(text, mat, textCol, iconCol, x)
    --print(string.format("box: %s; icon: %s; text: %s", COLORS.box, COLORS.icon, COLORS.text))

    surface.SetFont("CustomHUDFont")

    local w = CONSTANTS.padL + CONSTANTS.iconW + 10 + surface.GetTextSize(text) + CONSTANTS.padR
    w = math.max(w, 100)
    draw.RoundedBox(COMP.corner, x, iconY - 15, w, CONSTANTS.h, COLORS.box)
    if mat and not mat:IsError() then
        surface.SetDrawColor(iconCol)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(x + CONSTANTS.padL, iconY, CONSTANTS.iconW, CONSTANTS.iconH)
    end
    draw.SimpleText(text, "CustomHUDFont", x + w * 0.5 + CONSTANTS.iconW * 0.5 + 5, iconY, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    return x + w + CONSTANTS.gap
end

local function main()
    local plr = LocalPlayer()

    if IsValid(plr) then

        --
        local newScreenH = ScrH()

        if newScreenH ~= screenH then
            screenH = newScreenH
            baseY = screenH - 60
            iconY = baseY + (CONSTANTS.h - CONSTANTS.iconH) / 2
        end
        --

        local hp = math.max(plr:Health(), 0)
        local armor = math.max(plr:Armor(), 0)
        local wep = plr:GetActiveWeapon()
        --

        local x = CONSTANTS.baseX

        if hp > 50 then
            x = draw_h(tostring(hp), icons.healthIcon, COLORS.text, COLORS.icon, x)
        else
            if COMP.lowhp then
                x = draw_h(tostring(hp), icons.healthIcon, COMP.lowcolor, COMP.lowcolor_2, x)
            else
                x = draw_h(tostring(hp), icons.healthIcon, COLORS.text, COLORS.icon, x)
            end
        end

        x = draw_h(tostring(armor), icons.armorIcon, COLORS.text, COLORS.icon, x)
        --

        if IsValid(wep) and wep:GetPrimaryAmmoType() > 0 then
            local clip = wep:Clip1()
            local ammo = plr:GetAmmoCount(wep:GetPrimaryAmmoType())
            local ammoText = clip >= 0 and (clip .. " / " .. ammo) or tostring(ammo)
            draw_h(ammoText, icons.ammoIcon, COLORS.text, COLORS.icon, x)
        end
    end
end

--hooks
hook.Add("InitPostEntity", "CustomHUD_InitConfig", function()
    CONFIG.loadConfig()
    mainf.updateConfig()
end)

hook.Add("HUDShouldDraw", "HideDefaultHUD", function(name)
    if COMP.hud then
        local hideElements = {
            CHudHealth = true,
            CHudBattery = true,
            CHudAmmo = true,
            CHudSecondaryAmmo = true
        }
        return not hideElements[name]
    end
end)

hook.Add("HUDPaint", "CSH_CustomHUD", function()
    if not COMP.hud then return end
    main()
end)