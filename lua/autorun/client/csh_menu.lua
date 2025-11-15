if SERVER then return end

hook.Add("AddToolMenuTabs", "csh_tab", function()
    spawnmenu.AddToolTab("MinimalisticHUD", "Minimalistic HUD", "icon16/paintcan.png")
end)

hook.Add("PopulateToolMenu", "csh_settings", function()
    spawnmenu.AddToolMenuOption("MinimalisticHUD", "Settings", "HUD_Main", "Main", "", "", function(p)
        p:ClearControls()
        p:Help("Minimalistic HUD settings")

        --
        local toggle = p:CheckBox("Toggle HUD")
        toggle:SetValue(CONFIG.getValue("enabled", true) and 1 or 0)
        toggle.OnChange = function(self)
            local state = self:GetChecked()
            CONFIG.editConfig("enabled", state)
            mainf.updateConfig()
        end

        local toggle2 = p:CheckBox("Low HP color")
        toggle2:SetValue(CONFIG.getValue("lowhp_color", true) and 1 or 0)
        toggle2.OnChange = function(self)
            local state = self:GetChecked()
            CONFIG.editConfig("lowhp_color", state)
            mainf.updateConfig()
        end

        local corner = p:NumSlider("Background Corner", "", 0, 50, 0)
        corner:SetValue(CONFIG.getValue("boxesCorner", 5))

        corner.OnValueChanged = function(self, value)
            local val = math.Round(value)
            CONFIG.editConfig("boxesCorner", val)
            mainf.updateConfig()
        end

        p:Help("Texts Color:")

        local container = p:Add("DPanel")
        container:Dock(TOP)
        container:SetTall(220)
        container.Paint = function() end

        local mixer = vgui.Create("DColorMixer", container)
        mixer:Dock(FILL)
        mixer:SetPalette(true)
        mixer:SetAlpha(255)
        mixer:SetWangs(true)

        mixer:SetColor(Color(
            CONFIG.getValue("textsColor.r", 255),
            CONFIG.getValue("textsColor.g", 255),
            CONFIG.getValue("textsColor.b", 255),
            CONFIG.getValue("RGBalpha.texts", 255)
        ))

        mixer.ValueChanged = function(_, col)
            CONFIG.editConfig("textsColor.r", col.r)
            CONFIG.editConfig("textsColor.g", col.g)
            CONFIG.editConfig("textsColor.b", col.b)
            CONFIG.editConfig("RGBalpha.texts", col.a)
            mainf.updateConfig()
        end

        p:Help("Icons Color:")

        local container2 = p:Add("DPanel")
        container2:Dock(TOP)
        container2:SetTall(220)
        container2.Paint = function() end

        local mixer2 = vgui.Create("DColorMixer", container2)
        mixer2:Dock(FILL)
        mixer2:SetPalette(true)
        mixer2:SetAlpha(255)
        mixer2:SetWangs(true)

        mixer2:SetColor(Color(
            CONFIG.getValue("iconsColor.r", 255),
            CONFIG.getValue("iconsColor.g", 255),
            CONFIG.getValue("iconsColor.b", 255),
            CONFIG.getValue("RGBalpha.icons", 255)
        ))

        mixer2.ValueChanged = function(_, col)
            CONFIG.editConfig("iconsColor.r", col.r)
            CONFIG.editConfig("iconsColor.g", col.g)
            CONFIG.editConfig("iconsColor.b", col.b)
            CONFIG.editConfig("RGBalpha.icons", col.a)
            mainf.updateConfig()
        end

        p:Help("Background Color:")

        local container3 = p:Add("DPanel")
        container3:Dock(TOP)
        container3:SetTall(220)
        container3.Paint = function() end

        local mixer3 = vgui.Create("DColorMixer", container3)
        mixer3:Dock(FILL)
        mixer3:SetPalette(true)
        mixer3:SetAlpha(255)
        mixer3:SetWangs(true)

        mixer3:SetColor(Color(
            CONFIG.getValue("boxesColor.r", 255),
            CONFIG.getValue("boxesColor.g", 255),
            CONFIG.getValue("boxesColor.b", 255),
            CONFIG.getValue("RGBalpha.bg", 255)
        ))

        mixer3.ValueChanged = function(_, col)
            CONFIG.editConfig("boxesColor.r", col.r)
            CONFIG.editConfig("boxesColor.g", col.g)
            CONFIG.editConfig("boxesColor.b", col.b)
            CONFIG.editConfig("RGBalpha.bg", col.a)
            mainf.updateConfig()
        end

        local reset = p:Button("Reset settings")
        reset.DoClick = function()
            CONFIG.createConfig()
            mainf.updateConfig()

            toggle:SetValue(CONFIG.getValue("enabled", true) and 1 or 0)
            toggle2:SetValue(CONFIG.getValue("lowhp_color", true) and 1 or 0)
            corner:SetValue(CONFIG.getValue("boxesCorner", 5))

            mixer:SetColor(Color(
            CONFIG.getValue("textsColor.r", 255),
            CONFIG.getValue("textsColor.g", 255),
            CONFIG.getValue("textsColor.b", 255),
            CONFIG.getValue("RGBalpha.texts", 255)
            ))

            mixer2:SetColor(Color(
            CONFIG.getValue("iconsColor.r", 255),
            CONFIG.getValue("iconsColor.g", 255),
            CONFIG.getValue("iconsColor.b", 255),
            CONFIG.getValue("RGBalpha.icons", 255)
            ))

            mixer3:SetColor(Color(
            CONFIG.getValue("boxesColor.r", 255),
            CONFIG.getValue("boxesColor.g", 255),
            CONFIG.getValue("boxesColor.b", 255),
            CONFIG.getValue("RGBalpha.bg", 255)
            ))
        end
    end)
end)