badgeMode = 0
newMode = false
leds = {}
for i=0,4 do
    leds[i] = {r = 0, g = 0, b = 0}
end
fadeRed, fadeGreen, fadeBlue = 0, 0, 0
fadeDown = true

--[[ Since all the ESPs in the batch are liable to have very similar chipids
(last three octets of the MAC) using those directly for colours wouldn't be
terribly interesting, so instead we hash the value to try to provide variety ]]--
function nodetocolor(id)
    hash = crypto.hash("sha1", id)
    hash = crypto.toHex(hash):sub(27, 32)
    return hextocolor(hash)
end

--[[ converts an arbitrary three-byte hex colour value into something more
appropriate for the WS2812Bs ]]--
function hextocolor(hexVal)
    local red, green, blue

    red = hexVal:sub(1, 2)    -- G
    green = hexVal:sub(3, 4)  -- B
    blue = hexVal:sub(5, 6)   -- R

    --[[ The divisions here are an attempt to keep the brightness of the LEDs
	down to a sensible level and to save battery ]]--
    red = tonumber("0x"..red)/5
    green = tonumber("0x"..green)/5
    blue = tonumber("0x"..blue)/5

    return red, green, blue
end

-- Does what it says on the box, resets the LEDs to off
local function clearleds()
    for i=0,4 do
        leds[i] = {r = 0, g = 0, b = 0}
    end
end

-- "Normal" mode displays proximity to other badges
local function mode0()
  --print("Setting LEDs from WiFi")
  ledtimer:interval(500)
  for i=0,4 do
    leds[i] = wifileds[i]
  end
end

-- "Node colour" mode, displays a fading representation of this node's colour.
local function mode1()
  if newMode then
    --print("enter mode1 newMode")
    ledtimer:interval(200)
    for i=0,4 do
      leds[i] = {r = nodeRed, g = nodeGreen, b = nodeBlue}
      fadeRed, fadeGreen, fadeBlue = nodeRed, nodeGreen, nodeBlue
    end
  else
    if fadeRed >= 5 and fadeDown == true then
        fadeRed = fadeRed - 5
    elseif fadeDown == false then
      fadeRed = fadeRed + 5
      if fadeRed > nodeRed then
        fadeRed = nodeRed
      end
    else
        fadeRed = 0
    end
    
    if fadeGreen >= 5 and fadeDown == true then
        fadeGreen = fadeGreen - 5
    elseif fadeDown == false then
      fadeGreen = fadeGreen + 5
      if fadeGreen > nodeGreen then
        fadeGreen = nodeGreen
      end
    else
        fadeGreen = 0
    end
    
    if fadeBlue >= 5 and fadeDown == true then
        fadeBlue = fadeBlue - 5
    elseif fadeDown == false then
      fadeBlue = fadeBlue + 5
      if fadeBlue > nodeBlue then
        fadeBlue = nodeBlue 
      end   
    else
        fadeBlue = 0
    end
    for i=0,4 do
      leds[i] = {r = fadeRed, g = fadeGreen, b = fadeBlue}
    end
    
    if fadeRed == 0 and fadeGreen == 0 and fadeBlue == 0 then
      fadeDown = false
    elseif fadeRed >= nodeRed and fadeGreen >= nodeGreen and fadeBlue >= nodeBlue then
      fadeDown = true
    end
  end
end

-- DISCO mode, randomly sets the colour of the LEDs
local function disco()
  ledtimer:interval(400)
  for i=0,4 do
    leds[i] = {r = node.random(40), g = node.random(20), b = node.random(20)}
  end
end

-- This drives the LEDs by calling the appropriate mode handler
local function pushleds()
  local led = leds[0]
  if(badgeMode == 0) then
    mode0()
  elseif (badgeMode == 1) then
    mode1()
  elseif (badgeMode == 99) then
    disco()
  else
    clearleds()
    badgeMode = 0
  end
  newMode = false
end

nodeRed, nodeGreen, nodeBlue = nodetocolor(string.format("%06X", node.chipid()))
ws2812.init()
local i, buffer = 0, ws2812.newBuffer(5, 3)
buffer:fill(0, 0, 0); 
ledtimer = tmr.create()
ledtimer:register(200, tmr.ALARM_AUTO, function()
  pushleds()
  for i=0,4 do
    buffer:set(i % buffer:size() + 1, leds[i].g, leds[i].r, leds[i].b)
  end
  ws2812.write(buffer)
end)

print("Node Colour - R: "..nodeRed.." G: "..nodeGreen.." B: "..nodeBlue)

ledtimer:start()
