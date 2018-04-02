wifitimer = tmr.create()

-- Initialisation, basically setting all the LEDs to 0
wifileds = {}
for i=0,4 do
    wifileds[i] = {r = 0, g = 0, b = 0}
end

--[[ This function is passed as a callback to wifi.sta.getap which retrieves
 the current list of seen SSIDs ]]--
local function listap(t) -- (SSID : Authmode, RSSI, BSSID, Channel)
    if t then
        local aps = sortaps(t)
        for i=1,5 do
            if i <= #aps then
                local bssid = aps[i].b
                local v = t[bssid]
                local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
                if(tonumber(rssi) > -20) then rssi = -20 end

				--[[ This code is primarily concerned with changing the brighness 
				of the LEDs based on proximity, well RSSI anyway ]]--
                local r, g, b = nodetocolor(bssid:gsub(":", ""):sub(7))
                local sf = (math.abs(tonumber(rssi))-20)/6
                if(sf <= 0) then sf = 1 end
                print("SSID: "..ssid.." BSSID: "..bssid.." RSSI: "..rssi)

                wifileds[i-1].r = r/sf
                wifileds[i-1].g = g/sf
                wifileds[i-1].b = b/sf
            else
                wifileds[i-1].r = 0
                wifileds[i-1].g = 0
                wifileds[i-1].b = 0
            end                    
        end
    end
    wifitimer:register(500, tmr.ALARM_SINGLE, function() wifi.sta.getap(1, listap) end) -- Re-register timer
    wifitimer:start() -- Re-start timer
end

-- This sorts the returned list of RuxBadge-<BLAH> SSIDs by RSSI
function sortaps(t)
    local tx = {}
    for bssid,v in pairs(t) do -- grab all the rssi values and associated bssid for any RuxBadge-XXXXXX
        local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
        if(string.match(ssid, "RuxBadge-......")) then
            table.insert(tx, { b=bssid, r=rssi })
        end
    end
    table.sort(tx, function(a,b) return a.r < b.r end)
    return tx
end


wifi.setmode(wifi.STATIONAP, true)

cfg={}
cfg.ssid=string.format("RuxBadge-%06X", node.chipid())
cfg.pwd=crypto.toHex(crypto.hash("md5", string.format("RuxHHV2017%06X", node.chipid()))):sub(1, 16)
print("Starting WiFi...")
wifi.setphymode(wifi.PHYMODE_B) -- We set ourselves to 802.11b mode because it's the lowest power option
wifi.ap.config(cfg)
print("SSID: "..cfg.ssid.." PSK: "..cfg.pwd.." IP: "..wifi.ap.getip())

-- This timer drives the listap/LED colour/brighness functionality
wifitimer:register(2000, tmr.ALARM_SINGLE, function() wifi.sta.getap(1, listap) end)
wifitimer:start()
