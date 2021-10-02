-- Скрипт by Vadyao https://www.blast.hk/members/187779/
local sampev = require "lib.samp.events"
local imgui = require "imgui"
local encoding = require "encoding"
encoding.default = "CP1251" 
u8 = encoding.UTF8

local page = 1
local selectedTune = imgui.ImInt(0)
local selectedObject = imgui.ImInt(0)
local selectedObject2 = imgui.ImInt(0)
local selectedCar = imgui.ImInt(0)
local textBuffer = imgui.ImBuffer("", 256)
local textBuffer2 = imgui.ImBuffer("", 256)
local textBuffer3 = imgui.ImBuffer("", 256)
local autoPutButton = imgui.ImBool(false)

local state = imgui.ImBool(false)
local state2 = imgui.ImBool(false)

local sliders = {
    pos = {
        x = {coord = imgui.ImFloat(0), name = "Перемещение X", addres = nil},
        y = {coord = imgui.ImFloat(0), name = "Перемещение Y", addres = nil},
        z = {coord = imgui.ImFloat(0), name = "Перемещение Z", addres = nil}},
    rot = {
        x = {coord = imgui.ImFloat(0), name = "Вращение по оси X", addres = nil},
        y = {coord = imgui.ImFloat(0), name = "Вращение по оси Y", addres = nil},
        z = {coord = imgui.ImFloat(0), name = "Вращение по оси Z", addres = nil}}
}

local settings = {
    collision = imgui.ImBool(false),
    saving = imgui.ImBool(true),
    autoPutting = imgui.ImBool(true),
}
local carTunes = {}

local config = getWorkingDirectory().."//config//VisualCarTune.json"

if not doesFileExist(config) then
    createDirectory(getWorkingDirectory().."//config")
    local file = io.open(config, "w")
    file:close()
else
    local file = io.open(config, "r")
    local table_ = decodeJson(file:read())
    file:close()
    carTunes = table_[1]
    settings.collision.v = table_[2].collision
    settings.saving.v = table_[2].saving
    settings.autoPutting.v = table_[2].autoPutting
end

function saveConfig()
    local file = io.open(config, "w")
    file:write(encodeJson({carTunes, {collision = settings.collision.v, saving = settings.saving.v, autoPutting = settings.autoPutting.v}}))
    file:close()
end

local timeTunes = {}
local visualTimeTunes = {}

local vehicle_names = {
    [400] = "Landstalker",
    [401] = "Bravura",
    [402] = "Buffalo",
    [403] = "Linerunner",
    [404] = "Perennial",
    [405] = "Sentinel",
    [406] = "Dumper",
    [407] = "Firetruck",
    [408] = "Trashmaster",
    [409] = "Stretch",
    [410] = "Manana",
    [411] = "Infernus",
    [412] = "Voodoo",
    [413] = "Pony",
    [414] = "Mule",
    [415] = "Cheetah",
    [416] = "Ambulance",
    [417] = "Leviathan",
    [418] = "Moonbeam",
    [419] = "Esperanto",
    [420] = "Taxi",
    [421] = "Washington",
    [422] = "Bobcat",
    [423] = "Mr. Whoopee",
    [424] = "BF Injection",
    [425] = "Hunter",
    [426] = "Premier",
    [427] = "Enforcer",
    [428] = "Securicar",
    [429] = "Banshee",
    [430] = "Predator",
    [431] = "Bus",
    [432] = "Rhino",
    [433] = "Barracks",
    [434] = "Hotknife",
    [435] = "Article Trailer",
    [436] = "Previon",
    [437] = "Coach",
    [438] = "Cabbie",
    [439] = "Stallion",
    [440] = "Rumpo",
    [441] = "RC Bandit",
    [442] = "Romero",
    [443] = "Packer",
    [444] = "Monster",
    [445] = "Admiral",
    [446] = "Squallo",
    [447] = "Seaspamrow",
    [448] = "Pizzaboy",
    [449] = "Tram",
    [450] = "Article Trailer 2",
    [451] = "Turismo",
    [452] = "Speeder",
    [453] = "Reefer",
    [454] = "Tropic",
    [455] = "Flatbed",
    [456] = "Yankee",
    [457] = "Caddy",
    [458] = "Solair",
    [459] = "Topfun Van",
    [460] = "Skimmer",
    [461] = "PCJ-600",
    [462] = "Faggio",
    [463] = "Freeway",
    [464] = "RC Baron",
    [465] = "RC Raider",
    [466] = "Glendale",
    [467] = "Oceanic",
    [468] = "Sanchez",
    [469] = "Spamrow",
    [470] = "Patriot",
    [471] = "Quad",
    [472] = "Coastguard",
    [473] = "Dinghy",
    [474] = "Hermes",
    [475] = "Sabre",
    [476] = "Rustler",
    [477] = "ZR-350",
    [478] = "Walton",
    [479] = "Regina",
    [480] = "Comet",
    [481] = "BMX",
    [482] = "Burrito",
    [483] = "Camper",
    [484] = "Marquis",
    [485] = "Baggage",
    [486] = "Dozer",
    [487] = "Maverick",
    [488] = "News Maverick",
    [489] = "Rancher",
    [490] = "FBI Rancher",
    [491] = "Virgo",
    [492] = "Greenwood",
    [493] = "Jetmax",
    [494] = "Hotring Racer",
    [495] = "Sandking",
    [496] = "Blista Compact",
    [497] = "Police Maverick",
    [498] = "Boxville",
    [499] = "Benson",
    [500] = "Mesa",
    [501] = "RC Goblin",
    [502] = "Hotring Racer A",
    [503] = "Hotring Racer B",
    [504] = "Bloodring Banger",
    [505] = "Rancher",
    [506] = "Super GT",
    [507] = "Elegant",
    [508] = "Journey",
    [509] = "Bike",
    [510] = "Mountain Bike",
    [511] = "Beagle",
    [512] = "Cropduster",
    [513] = "Stuntplane",
    [514] = "Tanker",
    [515] = "Roadtrain",
    [516] = "Nebula",
    [517] = "Majestic",
    [518] = "Buccaneer",
    [519] = "Shamal",
    [520] = "Hydra",
    [521] = "FCR-900",
    [522] = "NRG-500",
    [523] = "HPV1000",
    [524] = "Cement Truck",
    [525] = "Towtruck",
    [526] = "Fortune",
    [527] = "Cadrona",
    [528] = "FBI Truck",
    [529] = "Willard",
    [530] = "Forklift",
    [531] = "Tractor",
    [532] = "Combine",
    [533] = "Feltzer",
    [534] = "Remington",
    [535] = "Slamvan",
    [536] = "Blade",
    [537] = "Train",
    [538] = "Train",
    [539] = "Vortex",
    [540] = "Vincent",
    [541] = "Bullet",
    [542] = "Clover",
    [543] = "Sadler",
    [544] = "Firetruck",
    [545] = "Hustler",
    [546] = "Intruder",
    [547] = "Primo",
    [548] = "Cargobob",
    [549] = "Tampa",
    [550] = "Sunrise",
    [551] = "Merit",
    [552] = "Utility Van",
    [553] = "Nevada",
    [554] = "Yosemite",
    [555] = "Windsor",
    [556] = "Monster A",
    [557] = "Monster B",
    [558] = "Uranus",
    [559] = "Jester",
    [560] = "Sultan",
    [561] = "Stratum",
    [562] = "Elegy",
    [563] = "Raindance",
    [564] = "RC Tiger",
    [565] = "Flash",
    [566] = "Tahoma",
    [567] = "Savanna",
    [568] = "Bandito",
    [569] = "Train",
    [570] = "Train",
    [571] = "Kart",
    [572] = "Mower",
    [573] = "Dune",
    [574] = "Sweeper",
    [575] = "Broadway",
    [576] = "Tornado",
    [577] = "AT400",
    [578] = "DFT-30",
    [579] = "Huntley",
    [580] = "Stafford",
    [581] = "BF-400",
    [582] = "Newsvan",
    [583] = "Tug",
    [584] = "Petrol Trailer",
    [585] = "Emperor",
    [586] = "Wayfarer",
    [587] = "Euros",
    [588] = "Hotdog",
    [589] = "Club",
    [590] = "Train",
    [591] = "Article Trailer 3",
    [592] = "Andromada",
    [593] = "Dodo",
    [594] = "RC Cam",
    [595] = "Launch",
    [596] = "Police Car LS",
    [597] = "Police Car SF",
    [598] = "Police Car LV",
    [599] = "Police Ranger",
    [600] = "Picador",
    [601] = "S.W.A.T.",
    [602] = "Alpha",
    [603] = "Phoenix",
    [604] = "Glendale",
    [605] = "Sadler",
    [606] = "Baggage Trailer",
    [607] = "Baggage Trailer",
    [608] = "Tug Stairs Trailer",
    [609] = "Boxville",
    [610] = "Farm Trailer",
    [611] = "Utility Trailer"
}
function aplly_theme()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	style.WindowRounding = 2.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
	style.ChildWindowRounding = 2.0
	style.FrameRounding = 2.0
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.GrabMinSize = 8.0
	style.GrabRounding = 1.0
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
aplly_theme()

local entered = false
function isPlayerEnteredIntoVehicle()
    if isCharInAnyCar(PLAYER_PED) and getDriverOfCar(storeCarCharIsInNoSave(PLAYER_PED)) == PLAYER_PED and not entered then
        entered = true
        return true
    elseif not isCharInAnyCar(PLAYER_PED) and entered then
        entered = false
    end
    return false
end

local td_id = 1101
local rotate = 0
local last_id = -1
function createRemoveTXD(x, y)
    local tune = carTunes[selectedTune.v]

    if not tune or not tune.objects[selectedObject.v] or not state.v or page ~= 1 then
        if sampTextdrawIsExists(td_id) then
            sampTextdrawDelete(td_id)
        end
        return
    end
    local id = carTunes[selectedTune.v].objects[selectedObject.v].id
    if not sampTextdrawIsExists(td_id) then
        sampTextdrawCreate(td_id, "", x, y)
        sampTextdrawSetStyle(td_id, 5)
        sampTextdrawSetBoxColorAndSize(td_id, 0, 0, 100, 100)
        sampTextdrawSetShadow(td_id, 0, 0)
        sampTextdrawSetModelRotationZoomVehColor(td_id, id, -40, 0, rotate, 1.5, 1, 1)
    end
    if id ~= last_id then
        last_id = id
        sampTextdrawSetModelRotationZoomVehColor(td_id, id, -40, 0, rotate, 1.5, 1, 1)
    end
    sampTextdrawSetPos(td_id, x, y)
end

function openImgui()
    state.v = not state.v
    saveConfig()
end

local script_ = {
    date = "02.10.2021",
    version = "1.1"
}

function autoupdate(json_url)
    local dlstatus = require("moonloader").download_status
    local json = thisScript().path.."--update.json"
    if doesFileExist(json) then os.remove(json) end
    downloadUrlToFile(json_url, json, function(id, status, p1, p2)
        if status == dlstatus.STATUSEX_ENDDOWNLOAD and doesFileExist(json) then
            local file = io.open(json, "r")
            if file then
                local info = decodeJson(file:read("*a"))
                file:close()
                os.remove(json)
                local updateLink = info.updateurl
                local updateDate = info.latest
                local updateVersion = info.version
                local updateNews = info.news
                if updateDate ~= script_.date and updateLink ~= "" then
                    sampAddChatMessage("[VisualTunning] Обнаружена новая версия! Обновляюсь с "..script_.version.." на "..updateVersion..".",-1)
                    sampAddChatMessage("[VisualTunning] Что нового: "..u8:decode(updateNews),-1)
                    lua_thread.create(function(dlstatus)
                        downloadUrlToFile(updateLink, thisScript().path, function(id2, status1, p3, p4)
                            if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                                goUpdate = true
                            end
                            if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                                if goUpdate then
                                    sampAddChatMessage("[VisualTunning] Загрузка завершена, обновляюсь!",-1)
                                    thisScript():reload()
                                else
                                    noUpdate = true
                                    sampAddChatMessage("[VisualTunning] Ошибка обновления.",-1)
                                end
                            end
                        end)
                    end, dlstatus)
                else
                    noUpdate = true
                    sampAddChatMessage("[VisualTunning] Обновлений не найдено, у вас стоит "..script_.version.." версия.", -1)
                end
            else
                noUpdate = true
                sampAddChatMessage("[VisualTunning] Не удалось прочитать файл обновления.", -1)
            end
        end
    end)
    while not noUpdate do wait(0) end
end

function main()
    while not isSampAvailable() or not sampIsLocalPlayerSpawned() do wait(0) end
    autoupdate("https://raw.githubusercontent.com/TheVegasPro/123345/main/update.json")


	sampRegisterChatCommand("tune", openImgui)
	while true do wait(0)
        imgui.Process = state.v

        if testCheat("XB") then
            openImgui()
        end

        if x_ or y_ then
            createRemoveTXD(x_, y_)
        end
        if state.v and isKeyDown(32) and isCharInAnyCar(PLAYER_PED) then showCursor(false) end

        for _, vehicle in pairs(visualTimeTunes) do
            for _, object in pairs(vehicle.objects) do
                setObjectCollision(object, settings.collision.v)
            end
        end

        if isPlayerEnteredIntoVehicle() and settings.autoPutting.v then
            local vHandle = storeCarCharIsInNoSave(PLAYER_PED)
            local vars = {}
            local vModelId = getCarModel(vHandle)
            for i, tune in pairs(carTunes) do
                if tune.modelId == vModelId and tune.autoPut then
                    table.insert(vars, i)
                end
            end
            if #vars > 0 then
                removeObjects(vHandle)
                createObjects(vars[math.random(#vars)], vHandle)
            end
        end
	end
end

function getHandleAndServerId(some)
    local some2 = nil
    local bool, _, some2 = pcall(sampGetVehicleIdByCarHandle, some)
    if not bool then
        some2 = some
        _, some = sampGetCarHandleBySampVehicleId(some2)
    end
    return some, some2
end

function createObjects(id, veh)
    local vHandle, vId = getHandleAndServerId(veh)

    for i, object in pairs(carTunes[id].objects) do
        if not visualTimeTunes[vId] then
            visualTimeTunes[vId] = {id = 0, modelId = getCarModel(vHandle), objects = {}}
        end
        visualTimeTunes[vId].id = id
        local object_handle = createObject(object.id, 0, 0, 0)
        table.insert(visualTimeTunes[vId].objects, object_handle)
        setObjectCollision(object_handle, settings.collision.v)
        attachObjectToCar(object_handle, vHandle, object.pos.x, object.pos.y, object.pos.z, object.rot.x, object.rot.y, object.rot.z)
    end
end

function removeObjects(veh)
    local vHandle, vId = getHandleAndServerId(veh)
    if visualTimeTunes[vId] then
        removeVisualObjects(vId)
        visualTimeTunes[vId] = nil
    end
    for i, veh in pairs(timeTunes) do
        if vId == i then
            for _, object in pairs(veh.objects) do
                local bs = raknetNewBitStream()
                raknetBitStreamWriteInt16(bs, object.objectId) 
                raknetEmulRpcReceiveBitStream(47, bs)
                raknetDeleteBitStream(bs)
            end
            break
        end
    end
end

function removeVisualObjects(vId)
    for _ = 1, #visualTimeTunes[vId].objects do
        deleteObject(visualTimeTunes[vId].objects[1])
        table.remove(visualTimeTunes[vId].objects, 1)
    end
end

function removeAllObjects()
    for i, _ in pairs(visualTimeTunes) do
        removeVisualObjects(i)
    end
end

function getVehicleName(id)
    if not id then id = "nil" end
    local model = "Unknown["..id.."]"
    if vehicle_names[id] then model = vehicle_names[id].."["..id.."]" end
    return model
end

function createNewTune()
    table.insert(carTunes, {name = "New Tune", modelId = 0, autoPut = false, objects = {}})
    if isCharInAnyCar(PLAYER_PED) then
        carTunes[#carTunes].modelId = getCarModel(storeCarCharIsInNoSave(PLAYER_PED))
    end
end

function sampev.onCreateObject(id, data)
    if data.attachToVehicleId ~= 65535 then
        local vehId = tonumber(data.attachToVehicleId)

        if not timeTunes[vehId] then timeTunes[vehId] = {modelId = -1, objects = {}} end
        local veh = timeTunes[vehId]

        lua_thread.create(function()
            local wait_ = os.clock()+2
            repeat wait(0)
                local bool, vehHandle = sampGetCarHandleBySampVehicleId(vehId)
                if bool then veh.modelId = getCarModel(vehHandle) end
            until bool or os.clock() > wait_
        end)

        local pos = data.attachOffsets
        local rot = data.attachRotation
        table.insert(veh.objects, {objectId = id, id = data.modelId, pos = {x = pos.x, y = pos.y, z = pos.z}, rot = {x = rot.x, y = rot.y, z = rot.z}})

        if settings.saving.v then
            for i, vehicle in pairs(visualTimeTunes) do
                if i == vehId then return false end
            end
        end
    end
end

function sampev.onDestroyObject(id)
    for vehId, veh in pairs(timeTunes) do
        for i, object in pairs(veh.objects) do
            if object.objectId == id then
                table.remove(veh.objects, i)
                if #veh.objects == 0 then timeTunes[vehId] = nil end
                return
            end
        end
    end
end

function sampev.onVehicleStreamIn(id, data)
    if settings.saving.v then
        lua_thread.create(function()
            for i, vehicle in pairs(visualTimeTunes) do
                if i == id then
                    local wait_ = os.clock()+2
                    repeat wait(0)
                        visualTimeTunes[i] = nil
                        local bool, handle = sampGetCarHandleBySampVehicleId(id)
                        if bool and getCarModel(handle) == vehicle.modelId then
                            createObjects(vehicle.id, handle)
                        end
                    until bool or os.clock() > wait_
                    break
                end
            end
        end)
    end
end

function sampev.onVehicleStreamOut(id)
    if visualTimeTunes[id] then
        removeVisualObjects(id)
    end

    for i, _ in pairs(timeTunes) do
        if i == id then
            timeTunes[id] = nil
            break
        end
    end
end

function imgui.TextQuestion(text)
    imgui.TextDisabled("(?)")
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.OnDrawFrame()
    if state.v then

        local w,h = getScreenResolution()
        imgui.SetNextWindowSize(imgui.ImVec2(475,570), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(w/2,h/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Визуальные объекты на авто", state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)

        if imgui.Button(u8"Весь тюнинг", imgui.ImVec2(150,20)) then page = 1 end
        if imgui.Button(u8"Отдельный транспорт", imgui.ImVec2(150,20), imgui.SameLine()) then page = 2 end
        if imgui.Button(u8"Настройки", imgui.ImVec2(150,20), imgui.SameLine()) then page = 3 end
        if imgui.Button(u8"Зона стрима", imgui.ImVec2(150,20)) then page = 4 end
        imgui.Separator()
        if page == 1 then
            imgui.BeginChild("##1", imgui.ImVec2(460, 200), true)
            for i, tune in pairs(carTunes) do
                local text = " "..getVehicleName(tune.modelId)
                if tune.autoPut then text = text.."[АвтоУстановка]" end
                text = tune.name..u8(text)

                if imgui.RadioButton(text.."##a"..i, selectedTune, i) then
                    textBuffer.v = tune.name
                    textBuffer2.v = tostring(tune.modelId)
                    selectedObject.v = 0
                    autoPutButton.v = tune.autoPut
                end
            end
            imgui.EndChild()
            if imgui.Button(u8"Новый тюнинг", imgui.ImVec2(150,20)) then createNewTune() end
            if imgui.Button(u8"Снять тюнинг", imgui.ImVec2(150,20), imgui.SameLine()) and isCharInAnyCar(PLAYER_PED) then
                removeObjects(storeCarCharIsInNoSave(PLAYER_PED))
            end
            if carTunes[selectedTune.v] then
                local tune = carTunes[selectedTune.v]

                if imgui.Button(u8"Установить тюнинг", imgui.ImVec2(150,20), imgui.SameLine()) and isCharInAnyCar(PLAYER_PED) then
                    createObjects(selectedTune.v, storeCarCharIsInNoSave(PLAYER_PED))
                end
                if imgui.Button(u8"Удалить тюнинг", imgui.ImVec2(150,20)) then
                    table.remove(carTunes, selectedTune.v)
                    selectedTune.v = 0
                    state2.v = false
                end
                if imgui.Checkbox(u8"Авто Установка", autoPutButton, imgui.SameLine()) then tune.autoPut = autoPutButton.v end
                if imgui.InputText(u8"Название", textBuffer) then tune.name = textBuffer.v end
                if imgui.InputText(u8"Модель##1", textBuffer2) then tune.modelId = tonumber(textBuffer2.v) end

                imgui.BeginChild("##2", imgui.ImVec2(460, 100), true)
                for i, object in pairs(tune.objects) do
                    local text = "Объект: "..i
                    if object.id then text = text.." Модель: "..object.id end
                    if imgui.RadioButton(u8(text), selectedObject, i) then
                        textBuffer3.v = tostring(object.id)

                        sliders.pos.x.coord.v = object.pos.x
                        sliders.pos.y.coord.v = object.pos.y
                        sliders.pos.z.coord.v = object.pos.z

                        sliders.rot.x.coord.v = object.rot.x
                        sliders.rot.y.coord.v = object.rot.y
                        sliders.rot.z.coord.v = object.rot.z

                        for i, what in pairs(sliders) do
                            for i2, slider in pairs(what) do
                                slider.addres = {selectedTune.v, selectedObject.v}
                            end
                        end
                    end
                end
                imgui.EndChild()
                if imgui.Button(u8"Новая деталь", imgui.ImVec2(150,20)) then table.insert(tune.objects, {id = 0, pos = {x = 0, y = 0, z = 0}, rot = {x = 0, y = 0, z = 0}}) end
                if tune.objects[selectedObject.v] then
                    local object = tune.objects[selectedObject.v]

                    local pos = imgui.GetWindowPos()
                    x_, y_ = convertWindowScreenCoordsToGameScreenCoords(pos.x-250, pos.y+300)

                    if imgui.Button(u8"Редактировать деталь", imgui.ImVec2(150,20), imgui.SameLine()) then state2.v = not state2.v end
                    if imgui.Button(u8"Удалить деталь", imgui.ImVec2(150,20), imgui.SameLine()) then
                        table.remove(tune.objects, selectedObject.v)
                        selectedObject.v = 0
                        state2.v = false
                    end
                    if imgui.Button(u8"Повернуть 30°", imgui.ImVec2(95,20)) then
                        rotate = rotate + 30
                        last_id = -1
                        if rotate > 360 then
                            rotate = 0
                        end
                    end
                    if imgui.InputText(u8"Модель##2", textBuffer3, imgui.SameLine()) then object.id = tonumber(textBuffer3.v) end
                    imgui.Text(u8(string.format("Позиция x: %s y: %s z: %s\nПоворот x: %s y: %s z: %s", object.pos.x, object.pos.y, object.pos.z, object.rot.x, object.rot.y, object.rot.z)))
                end
            end
        elseif page == 2 then
            imgui.Text(u8"Быстрый поиск набора тюнинга для отдельной машины")
            imgui.BeginChild("##1", imgui.ImVec2(460, 200), true)
            for i, veh in pairs(vehicle_names) do
                local all, active = 0, 0
                for _, tune in pairs(carTunes) do
                    if i == tune.modelId then
                        all = all + 1
                        if tune.autoPut then active = active + 1 end
                    end
                end
                if all > 0 then
                    if imgui.RadioButton(u8(veh.."["..i.."] Наборов "..all.." Активных "..active), selectedCar, i) then selectedObject2.v = 0 end
                end
            end
            imgui.EndChild()
            if vehicle_names[selectedCar.v] then
                imgui.Text(u8("Наборы тюнинга для "..vehicle_names[selectedCar.v]))
                imgui.BeginChild("##2", imgui.ImVec2(460, 100), true)
                for i2, tune in pairs(carTunes) do
                    if tune.modelId == selectedCar.v then
                        local text = tune.name
                        if tune.autoPut then text = text..u8" [АвтоУстановка]" end
                        if imgui.RadioButton(text, selectedObject2, i2) then autoPutButton.v = tune.autoPut end
                    end
                end
                imgui.EndChild()
                if carTunes[selectedObject2.v] then
                    if imgui.Checkbox(u8"Авто Установка", autoPutButton) then carTunes[selectedObject2.v].autoPut = autoPutButton.v end
                end
            end
        elseif page == 3 then
            imgui.Checkbox(u8"Коллизия объектов", settings.collision, imgui.TextQuestion(u8"Включает/отключает коллизию у визуальных объектов"), imgui.SameLine())
            imgui.Checkbox(u8"Авто Установка тюнинга", settings.autoPutting, imgui.TextQuestion(u8"Все наборы тюнинга в которых включена [АвтоУстановка] и подходящие по модели машины будут случайно применяться к машине при посадке в авто"), imgui.SameLine())
            imgui.Checkbox(u8"Сохранение тюнинга", settings.saving, imgui.TextQuestion(u8"Когда машина пропадает из зоны стрима на которой был некий набор тюнинга и появляется заново имея ту же модель то к ней применится последний набор тюнинга а так-же все серверные объекты не будут на ней появлятся"), imgui.SameLine())
            imgui.Text(u8"Зажимание пробела отключает курсор чтобы можно было вращать камерой\nОткрытие/закрытие меню:\n    Команда /tune\n    Чит-Код XB")
            imgui.Separator()
            if imgui.Button(u8"Удалить все визуальные объекты", imgui.ImVec2(250,20)) then
                removeAllObjects()
                visualTimeTunes = {}
            end
            local exitValue = 0
            for _, vehicle in pairs(visualTimeTunes) do
                exitValue = exitValue + #vehicle.objects
            end
            imgui.Text(u8("Всего визуального тюнинга создано: "..exitValue))

        elseif page == 4 then
            imgui.Text(u8("Скопированный набор объектов переходит в основной список тюнинга"))
            imgui.BeginChild("", imgui.ImVec2(460, 450), true)
            for i, veh in pairs(timeTunes) do
                if imgui.Button(u8"Скопировать тюнинг##"..i) then
                    createNewTune()
                    local tune = carTunes[#carTunes]
                    tune.modelId = veh.modelId
                    tune.name = "Copied car "..i
                    for _, object in pairs(veh.objects) do
                        table.insert(tune.objects, {id = object.id, pos = {x = object.pos.x, y = object.pos.y, z = object.pos.z}, rot = {x = object.rot.x, y = object.rot.y, z = object.rot.z}})
                    end
                end
                local model = getVehicleName(veh.modelId)
                imgui.Text(u8("Ид: "..i.." Модель: "..model.." Объектов: "..#veh.objects), imgui.SameLine())
            end
            imgui.EndChild()
        end
        if state2.v then
            imgui.SetNextWindowSize(imgui.ImVec2(400,180), imgui.Cond.FirstUseEver)
            imgui.Begin(u8"Редактор", state2, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)

            for i, what in pairs(sliders) do
                for i2, slider in pairs(what) do
                    local slideMax = {-5, 5}
                    if tostring(i) == "rot" then slideMax = {-360, 360} end
                    if imgui.SliderFloat(u8(slider.name), slider.coord, slideMax[1], slideMax[2]) then
                        carTunes[slider.addres[1]].objects[slider.addres[2]][i][i2] = slider.coord.v
                        if isCharInAnyCar(PLAYER_PED) then
                            removeObjects(storeCarCharIsInNoSave(PLAYER_PED))
                            createObjects(slider.addres[1], storeCarCharIsInNoSave(PLAYER_PED))
                        end
                    end
                end
            end
            imgui.End()
        end
        imgui.End()
    end
end

function onScriptTerminate(script)
	if script == thisScript() then
        saveConfig()
        sampTextdrawDelete(td_id)
        removeAllObjects()
	end
end

function sampev.onSendClientJoin()
    removeAllObjects()
end