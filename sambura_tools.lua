script_name("sambura tools")
script_version("1.0.1")
script_author("TG - @samburax")

require('lib.moonloader')

local imgui = require('imgui')
local sampev = require('lib.samp.events')
local memory = require('memory')
local encoding = require('encoding')
local ffi = require('ffi')
local vkeys = require('vkeys')

encoding.default = 'CP1251'
u8 = encoding.UTF8

font = renderCreateFont('Arial', 7, 12)
fonts = renderCreateFont('Arial', 30, 12)

local new, str = imgui.new, ffi.string

local status = false
local KEY = VK_XBUTTON1

GUI =
{
    windowState = imgui.ImBool(false),
    newMenuState = imgui.ImBool(false),

    main =
    {
        Lrend = imgui.ImBool(false),
        Radius = imgui.ImBool(false),
        Drift = imgui.ImBool(false),
        Sbiv = imgui.ImBool(false),
        Crosshair = imgui.ImBool(false),
        Dellall = imgui.ImBool(false),
        Crash = imgui.ImBool(false),
        Catcher = imgui.ImBool(false),
        Trigger = imgui.ImBool(false),
    },
}

local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then printu8(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then printu8('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/samburarixo/sambura_tools/main/version.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/samburarixo/sambura_tools/tree/main"
        end
    end
end

function main()
        if not initialized then
            if not isSampAvailable() then return false end
            lua_thread.create(sambura)
            initialized = true

            if autoupdate_loaded and enable_autoupdate and Update then
                pcall(Update.check, Update.json_url, Update.prefix, Update.url)
            end

        end

        

    if wasKeyPressed(VK_INSERT) then
        GUI.windowState.v = not GUI.windowState.v
    end
    if wasKeyPressed(VK_H) and GUI.windowState.v then
        GUI.newMenuState.v = not GUI.newMenuState.v
    end
    imgui.Process = GUI.windowState.v
    return false
end

function imgui.OnDrawFrame()
    if GUI.windowState.v then
        DrawMainMenu()
    end
    if GUI.windowState.v and GUI.newMenuState.v then
        DrawNewMenu()
    end
end

function DrawMainMenu()
    local screenWidth, screenHeight = getScreenResolution()
    local posX = screenWidth - 1100
    local posY = screenHeight - 700

    imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(300, 110), imgui.Cond.FirstUseEver)
    imgui.Begin('SAMBURA TOOLS V1', GUI.windowState, imgui.WindowFlags.NoResize)
    imgui.Checkbox('Арабский дрифт нахуй (Shift)', GUI.main.Drift)
    imgui.Checkbox('Лавка Радиус', GUI.main.Radius)
    imgui.Separator()
    if imgui.Button('Удаление Игроков', imgui.ImVec2(280, 0)) then
        delplayers()
    end
    
    imgui.End()
end

function DrawNewMenu()
    imgui.SetNextWindowPos(imgui.ImVec2(820, 500), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(300, 200), imgui.Cond.FirstUseEver)
    imgui.Begin('SAMBURA VIP', GUI.newMenuState, imgui.WindowFlags.NoResize)
    imgui.Checkbox('Arz Catcher', GUI.main.Catcher)
    imgui.Checkbox('Лавка Рендер', GUI.main.Lrend)
    imgui.Checkbox('Trigger Bot', GUI.main.Trigger)
    imgui.Checkbox('Сбив (H)', GUI.main.Sbiv)
    imgui.Checkbox('Instant Cross', GUI.main.Crosshair)
    if imgui.Button('Краш Игры', imgui.ImVec2(280, 0)) then
        Crash()
    end
    if imgui.Button('Закрыть Меню', imgui.ImVec2(280, 0)) then
        GUI.newMenuState.v = false
    end

    imgui.End()
end

function sambura()
    if GUI.main.Drift.v then
        if isCharInAnyCar(playerPed) then 
            local car = storeCarCharIsInNoSave(playerPed)
            local speed = getCarSpeed(car)
            
            if isKeyDown(VK_LSHIFT) and isVehicleOnAllWheels(car) and doesVehicleExist(car) and speed > 5.0 then
                setCarCollision(car, false)
                
                if isKeyDown(VK_A) then 
                    addToCarRotationVelocity(car, 0, 0, 0.15)
                elseif isKeyDown(VK_D) then 
                    addToCarRotationVelocity(car, 0, 0, -0.15)
                end
                
                if isCarInAirProper(car) then 
                    setCarCollision(car, true)
                end
            else
                setCarCollision(car, true)
            end
        end
    end
    if GUI.main.Lrend.v then
        for id = 0, 2304 do
            if sampIs3dTextDefined(id) then
                local text, _, posX, posY, posZ, _, _, _, _ = sampGet3dTextInfoById(id)
                if math.floor(posZ) == 17 and text == '' then
                    if isPointOnScreen(posX, posY, posZ, nil) then
                        local pX, pY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                        local lX, lY = convert3DCoordsToScreen(posX, posY, posZ)
                        renderFontDrawText(font, 'Free Lavka', lX - 30, lY - 20, 0xFF16C910, 0x90000000)
                        renderFontDrawText(fonts, 'FREE LAVKA!!!', 820, 200, 0xFFFFFFFF)
                        renderDrawLine(pX, pY, lX, lY, 1, 0xFF52FF4D)
                        renderDrawPolygon(pX, pY, 10, 10, 10, 0, 0xFFFFFFFF)
                        renderDrawPolygon(lX, lY, 10, 10, 10, 0, 0xFFFFFFFF)
                    end
                end
            end
        end
    end
    if GUI.main.Sbiv.v then
        if isKeyJustPressed(VK_H)  and not sampIsDialogActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not isCharInAnyCar(1) and not isCharInAnyHeli(1) and not isCharInAnyPlane(1) and not isCharInAnyBoat(1) and not isCharInAnyPoliceVehicle(1) then
            if text == "" then
                sampAddChatMessage(text, -1)
                freezeCharPosition(PLAYER_PED, true)
                freezeCharPosition(PLAYER_PED, false)
                setPlayerControl(PLAYER_HANDLE, true)
                clearCharTasksImmediately(PLAYER_PED)
            else
                freezeCharPosition(PLAYER_PED, true)
                freezeCharPosition(PLAYER_PED, false)
                setPlayerControl(PLAYER_HANDLE, true)
                clearCharTasksImmediately(PLAYER_PED)
            end
        end    
    end
    if GUI.main.Crosshair.v then
        showCrosshairInstantlyPatch(true)
    else
        showCrosshairInstantlyPatch(false)
    end
    if GUI.main.Catcher.v then
        status = true
    else
        status = false
    end
    if GUI.main.Trigger.v and not isCharOnAnyBike(playerPed) and not isCharDead(playerPed) and isKeyDown(KEY) then
        local int = readMemory(0xB6F3B8, 4, 0)
        int = int + 0x79C
        local intS = readMemory(int, 4, 0)
        if intS > 0 then
            local lol = 0xB73458
            lol = lol + 34
            writeMemory(lol, 4, 255, 0)
            wait(100)
            local int = readMemory(0xB6F3B8, 4, 0)
            int = int + 0x79C
            writeMemory(int, 4, 0, 0)
        end
    end
    if GUI.main.Radius.v then
        for IDTEXT = 0, 2048 do
            if sampIs3dTextDefined(IDTEXT) then
                local text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle = sampGet3dTextInfoById(IDTEXT)
                if text == "Управления товарами." and not isCentralMarket(posX, posY) then
                    local myPos = {getCharCoordinates(1)}
                    drawCircleIn3d(posX, posY, posZ-1.3, 5, 36, 1.5, getDistanceBetweenCoords3d(posX, posY, 0, myPos[1], myPos[2], 0) > 5 and 0xFFFFFFFF or 0xFFFF0000)
                end
            end
        end
    end
    return false
end

drawCircleIn3d = function(x, y, z, radius, polygons, width, color)
    local step = math.floor(360 / (polygons or 36))
    local sX_old, sY_old
    for angle = 0, 360, step do
        local lX = radius * math.cos(math.rad(angle)) + x
        local lY = radius * math.sin(math.rad(angle)) + y
        local lZ = z
        local _, sX, sY, sZ, _, _ = convert3DCoordsToScreenEx(lX, lY, lZ)
        if sZ > 1 then
            if sX_old and sY_old then
                renderDrawLine(sX, sY, sX_old, sY_old, width, color)
            end
            sX_old, sY_old = sX, sY
        end
    end
end

isCentralMarket = function(x, y)
    return (x > 1090 and x < 1180 and y > -1550 and y < -1429)
end

-- Crystal_Castle OR TELEGRAM @samburax BEST MAKER SCRIPTS --

function showCrosshairInstantlyPatch(enable)
    if enable then
        if not patch_showCrosshairInstantly then
            patch_showCrosshairInstantly = memory.read(0x0058E1D9, 1, true)
        end
        memory.write(0x0058E1D9, 0xEB, 1, true)
    elseif patch_showCrosshairInstantly ~= nil then
        memory.write(0x0058E1D9, patch_showCrosshairInstantly, 1, true)
        patch_showCrosshairInstantly = nil
    end
end

function Crash()
    readMemory(0, 1)
end

function delplayers()
    for _, handle in ipairs(getAllChars()) do
        if doesCharExist(handle) then
            local _, id = sampGetPlayerIdByCharHandle(handle)
            if id ~= myid then
                emul_rpc('onPlayerStreamOut', { id })
                sampAddChatMessage("All players deleted", -1)
            end
        end
    end
end

function emul_rpc(hook, parameters)
    local bs_io = require 'samp.events.bitstream_io'
    local handler = require 'samp.events.handlers'
    local extra_types = require 'samp.events.extra_types'
    local hooks = {
        ['onInitGame'] = { 139 },
        ['onPlayerJoin'] = { 'int16', 'int32', 'bool8', 'string8', 137 },
        ['onPlayerQuit'] = { 'int16', 'int8', 138 },
        ['onRequestClassResponse'] = { 'bool8', 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 128 },
        ['onRequestSpawnResponse'] = { 'bool8', 129 },
        ['onSetPlayerName'] = { 'int16', 'string8', 'bool8', 11 },
        ['onSetPlayerPos'] = { 'vector3d', 12 },
        ['onSetPlayerPosFindZ'] = { 'vector3d', 13 },
        ['onSetPlayerHealth'] = { 'float', 14 },
        ['onTogglePlayerControllable'] = { 'bool8', 15 },
        ['onPlaySound'] = { 'int32', 'vector3d', 16 },
        ['onSetWorldBounds'] = { 'float', 'float', 'float', 'float', 17 },
        ['onGivePlayerMoney'] = { 'int32', 18 },
        ['onSetPlayerFacingAngle'] = { 'float', 19 },
        ['onGivePlayerWeapon'] = { 'int32', 'int32', 22 },
        ['onSetPlayerTime'] = { 'int8', 'int8', 29 },
        ['onSetToggleClock'] = { 'bool8', 30 },
        ['onPlayerStreamIn'] = { 'int16', 'int8', 'int32', 'vector3d', 'float', 'int32', 'int8', 32 },
        ['onSetShopName'] = { 'string256', 33 },
        ['onSetPlayerSkillLevel'] = { 'int16', 'int32', 'int16', 34 },
        ['onSetPlayerDrunk'] = { 'int32', 35 },
        ['onCreate3DText'] = { 'int16', 'int32', 'vector3d', 'float', 'bool8', 'int16', 'int16', 'encodedString4096', 36 },
        ['onSetRaceCheckpoint'] = { 'int8', 'vector3d', 'vector3d', 'float', 38 },
        ['onPlayAudioStream'] = { 'string8', 'vector3d', 'float', 'bool8', 41 },
        ['onRemoveBuilding'] = { 'int32', 'vector3d', 'float', 43 },
        ['onCreateObject'] = { 44 },
        ['onSetObjectPosition'] = { 'int16', 'vector3d', 45 },
        ['onSetObjectRotation'] = { 'int16', 'vector3d', 46 },
        ['onDestroyObject'] = { 'int16', 47 },
        ['onPlayerDeathNotification'] = { 'int16', 'int16', 'int8', 55 },
        ['onSetMapIcon'] = { 'int8', 'vector3d', 'int8', 'int32', 'int8', 56 },
        ['onRemoveVehicleComponent'] = { 'int16', 'int16', 57 },
        ['onRemove3DTextLabel'] = { 'int16', 58 },
        ['onPlayerChatBubble'] = { 'int16', 'int32', 'float', 'int32', 'string8', 59 },
        ['onUpdateGlobalTimer'] = { 'int32', 60 },
        ['onShowDialog'] = { 'int16', 'int8', 'string8', 'string8', 'string8', 'encodedString4096', 61 },
        ['onDestroyPickup'] = { 'int32', 63 },
        ['onLinkVehicleToInterior'] = { 'int16', 'int8', 65 },
        ['onSetPlayerArmour'] = { 'float', 66 },
        ['onSetPlayerArmedWeapon'] = { 'int32', 67 },
        ['onSetSpawnInfo'] = { 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 68 },
        ['onSetPlayerTeam'] = { 'int16', 'int8', 69 },
        ['onPutPlayerInVehicle'] = { 'int16', 'int8', 70 },
        ['onSetPlayerColor'] = { 'int16', 'int32', 72 },
        ['onDisplayGameText'] = { 'int32', 'int32', 'string32', 73 },
        ['onAttachObjectToPlayer'] = { 'int16', 'int16', 'vector3d', 'vector3d', 75 },
        ['onInitMenu'] = { 76 },
        ['onShowMenu'] = { 'int8', 77 },
        ['onHideMenu'] = { 'int8', 78 },
        ['onCreateExplosion'] = { 'vector3d', 'int32', 'float', 79 },
        ['onShowPlayerNameTag'] = { 'int16', 'bool8', 80 },
        ['onAttachCameraToObject'] = { 'int16', 81 },
        ['onInterpolateCamera'] = { 'bool', 'vector3d', 'vector3d', 'int32', 'int8', 82 },
        ['onGangZoneStopFlash'] = { 'int16', 85 },
        ['onApplyPlayerAnimation'] = { 'int16', 'string8', 'string8', 'bool', 'bool', 'bool', 'bool', 'int32', 86 },
        ['onClearPlayerAnimation'] = { 'int16', 87 },
        ['onSetPlayerSpecialAction'] = { 'int8', 88 },
        ['onSetPlayerFightingStyle'] = { 'int16', 'int8', 89 },
        ['onSetPlayerVelocity'] = { 'vector3d', 90 },
        ['onSetVehicleVelocity'] = { 'bool8', 'vector3d', 91 },
        ['onServerMessage'] = { 'int32', 'string32', 93 },
        ['onSetWorldTime'] = { 'int8', 94 },
        ['onCreatePickup'] = { 'int32', 'int32', 'int32', 'vector3d', 95 },
        ['onMoveObject'] = { 'int16', 'vector3d', 'vector3d', 'float', 'vector3d', 99 },
        ['onEnableStuntBonus'] = { 'bool', 104 },
        ['onTextDrawSetString'] = { 'int16', 'string16', 105 },
        ['onSetCheckpoint'] = { 'vector3d', 'float', 107 },
        ['onCreateGangZone'] = { 'int16', 'vector2d', 'vector2d', 'int32', 108 },
        ['onPlayCrimeReport'] = { 'int16', 'int32', 'int32', 'int32', 'int32', 'vector3d', 112 },
        ['onGangZoneDestroy'] = { 'int16', 120 },
        ['onGangZoneFlash'] = { 'int16', 'int32', 121 },
        ['onStopObject'] = { 'int16', 122 },
        ['onSetVehicleNumberPlate'] = { 'int16', 'string8', 123 },
        ['onTogglePlayerSpectating'] = { 'bool32', 124 },
        ['onSpectatePlayer'] = { 'int16', 'int8', 126 },
        ['onSpectateVehicle'] = { 'int16', 'int8', 127 },
        ['onShowTextDraw'] = { 134 },
        ['onSetPlayerWantedLevel'] = { 'int8', 133 },
        ['onTextDrawHide'] = { 'int16', 135 },
        ['onRemoveMapIcon'] = { 'int8', 144 },
        ['onSetWeaponAmmo'] = { 'int8', 'int16', 145 },
        ['onSetGravity'] = { 'float', 146 },
        ['onSetVehicleHealth'] = { 'int16', 'float', 147 },
        ['onAttachTrailerToVehicle'] = { 'int16', 'int16', 148 },
        ['onDetachTrailerFromVehicle'] = { 'int16', 149 },
        ['onSetWeather'] = { 'int8', 152 },
        ['onSetPlayerSkin'] = { 'int32', 'int32', 153 },
        ['onSetInterior'] = { 'int8', 156 },
        ['onSetCameraPosition'] = { 'vector3d', 157 },
        ['onSetCameraLookAt'] = { 'vector3d', 'int8', 158 },
        ['onSetVehiclePosition'] = { 'int16', 'vector3d', 159 },
        ['onSetVehicleAngle'] = { 'int16', 'float', 160 },
        ['onSetVehicleParams'] = { 'int16', 'int16', 'bool8', 161 },
        ['onChatMessage'] = { 'int16', 'string8', 101 },
        ['onConnectionRejected'] = { 'int8', 130 },
        ['onPlayerStreamOut'] = { 'int16', 163 },
        ['onVehicleStreamIn'] = { 164 },
        ['onVehicleStreamOut'] = { 'int16', 165 },
        ['onPlayerDeath'] = { 'int16', 166 },
        ['onPlayerEnterVehicle'] = { 'int16', 'int16', 'bool8', 26 },
        ['onUpdateScoresAndPings'] = { 'PlayerScorePingMap', 155 },
        ['onSetObjectMaterial'] = { 84 },
        ['onSetObjectMaterialText'] = { 84 },
        ['onSetVehicleParamsEx'] = { 'int16', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 24 },
        ['onSetPlayerAttachedObject'] = { 'int16', 'int32', 'bool', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 113 }

    }
    local handler_hook = {
        ['onInitGame'] = true,
        ['onCreateObject'] = true,
        ['onInitMenu'] = true,
        ['onShowTextDraw'] = true,
        ['onVehicleStreamIn'] = true,
        ['onSetObjectMaterial'] = true,
        ['onSetObjectMaterialText'] = true
    }
    local extra = {
        ['PlayerScorePingMap'] = true,
        ['Int32Array3'] = true
    }
    local hook_table = hooks[hook]
    if hook_table then
        local bs = raknetNewBitStream()
        if not handler_hook[hook] then
            local max = #hook_table-1
            if max > 0 then
                for i = 1, max do
                    local p = hook_table[i]
                    if extra[p] then extra_types[p]['write'](bs, parameters[i])
                    else bs_io[p]['write'](bs, parameters[i]) end
                end
            end
        else
            if hook == 'onInitGame' then handler.on_init_game_writer(bs, parameters)
            elseif hook == 'onCreateObject' then handler.on_create_object_writer(bs, parameters)
            elseif hook == 'onInitMenu' then handler.on_init_menu_writer(bs, parameters)
            elseif hook == 'onShowTextDraw' then handler.on_show_textdraw_writer(bs, parameters)
            elseif hook == 'onVehicleStreamIn' then handler.on_vehicle_stream_in_writer(bs, parameters)
            elseif hook == 'onSetObjectMaterial' then handler.on_set_object_material_writer(bs, parameters, 1)
            elseif hook == 'onSetObjectMaterialText' then handler.on_set_object_material_writer(bs, parameters, 2) end
        end
        raknetEmulRpcReceiveBitStream(hook_table[#hook_table], bs)
        raknetDeleteBitStream(bs)
    end
end

function sampev.onShowDialog(dialogId)
    if dialogId == 3010 and status then
        sampSendDialogResponse(dialogId, 1, 0, 0)
    end
end

function sampev.onSetObjectMaterialText(ev, data)
    local Object = sampGetObjectHandleBySampId(ev)
    if doesObjectExist(Object) and getObjectModel(Object) == 18663 and string.find(data.text, "(.-) {30A332}Свободная!") then
        if get_distance(Object) and status then
            lua_thread.create(press_key)
        end
    end
end

function press_key()
    setGameKeyState(21, 256)
end

function get_distance(Object)
    local result, posX, posY, posZ = getObjectCoordinates(Object)
    if result then
        if doesObjectExist(Object) then
            local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
            local distance = (math.abs(posX - pPosX)^2 + math.abs(posY - pPosY)^2)^0.5
            local posX, posY = convert3DCoordsToScreen(posX, posY, posZ)
            if round(distance, 2) <= 0.9 then
                return true
            end
        end
    end
    return false
end

function round(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end
