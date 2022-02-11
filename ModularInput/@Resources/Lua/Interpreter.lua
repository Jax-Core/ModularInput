function Initialize()
    rootConfigName = SKIN:GetVariable('ROOTCONFIG')
    rootConfigPath = SKIN:GetVariable('ROOTCONFIGPATH')
    writeLocation = rootConfigPath..'ModularInput\\Window.ini'
    started = 0
end

function inputStart(handlerMeterName, finishactionIndex, defaultValue, arg1)
    if started == 0 then
        started = 1
        _G["handlerMeterName"] = handlerMeterName
        _G["finishactionIndex"] = finishactionIndex
        _G["defaultValue"] = defaultValue
        local handler = SKIN:GetMeter(handlerMeterName)
        if handler == nil then print('Unable to find meter '..handlerMeterName) return end
        _G["finishAction"] = SELF:GetOption('FinishAction'..finishactionIndex)
        if arg1 ~= nil then _G["finishAction"] = string.gsub(finishAction, '%$MI%.arg1%$', arg1) end
        if _G["defaultValue"] == nil or _G["defaultValue"] == '' then _G["defaultValue"] = SELF:GetOption('DefaultValue') or ' ' end

        local miposX = handler:GetX() + SKIN:GetX()
        local miposY = handler:GetY() + SKIN:GetY()
        local miposaX = '0'
        local miposaY = '0'
        print("MI.XY: ".. miposX ..'|'.. miposY)

        -- ------------------------- writing and activating ------------------------- --
        local function tablelength(T)
            local count = 0
            for _ in pairs(T) do count = count + 1 end
            return count
        end

        local bang = ''
        local optionsList = {'StringAlign', 'FontFace', 'FontSize', 'AntiAlias', 'FontColor'}
        for i = 1, tablelength(optionsList) do
            local optionValue = SELF:GetOption(optionsList[i])
            if optionValue ~= nil and optionValue ~= '' then
                bang = bang .. '[!WriteKeyValue Style '..optionsList[i]..' "'..optionValue..'" "'..writeLocation..'"]'
            end
        end

        bang = bang .. '[!WriteKeyValue Variables Sec.OriginConfigName "'..SKIN:GetVariable('CURRENTCONFIG')..'" "'..writeLocation..'"]'
        bang = bang .. '[!WriteKeyValue Variables Sec.X "'..miposX..'" "'..writeLocation..'"]'
        bang = bang .. '[!WriteKeyValue Variables Sec.Y "'..miposY..'" "'..writeLocation..'"]'
        bang = bang .. '[!WriteKeyValue Variables Sec.W "'..handler:GetW()..'" "'..writeLocation..'"]'
        bang = bang .. '[!WriteKeyValue Variables Sec.H "'..handler:GetH()..'" "'..writeLocation..'"]'
        bang = bang .. '[!WriteKeyValue Variables Sec.Text "'.._G["defaultValue"]..'" "'..writeLocation..'"]'

        bang = bang .. '[!WriteKeyValue Rainmeter OnRefreshAction """[!Delay 100][!SetWindowPosition '..miposX..' '..miposY..' '..miposaX..' '..miposaY..'][!Show][!CommandMeasure InputHandler "Initiate()"]""" "'..writeLocation..'"]'
        bang = bang .. '[!ActivateConfig "'..rootConfigName..'\\ModularInput"][!Delay 100][!HideMeter '.._G["handlerMeterName"]..'][!Redraw]'
        SKIN:Bang(bang)
    end
end

function inputEnd(input, reset)
    if started == 1 then
        started = 0
        local CancelOnUnfocus = SELF:GetOption('CancelOnUnfocus')
        if reset and CancelOnUnfocus == '1' then input = _G["defaultValue"] end
        print(input)
        local bang = ''
        bang = bang .. _G["finishAction"]:gsub('%$MI%.value%$', input)
        bang = bang .. '[!ShowMeter '.._G["handlerMeterName"]..'][!DeactivateConfig "'..rootConfigName..'\\ModularInput"][!Redraw]'
        SKIN:Bang(bang)
    end
end