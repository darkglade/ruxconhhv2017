--[[ Unfortunately in their infinite wisdom the designers of the
NodeMCU dev kit which NodeMCU was written around chose not to
map the IO pins on their board based on their actual designations 
on the ESP8266. Instead they chose a largely arbitrary mapping, 
which is fine if you're using an actual NodeMCU devkit but for 
anybody else requires some irritating mapping work, details can 
be found here;
https://nodemcu.readthedocs.io/en/master/en/modules/gpio/ 
]]--

gpio.mode(6, gpio.INT) -- IO Index 6 maps to GPIO12
gpio.mode(7, gpio.INT) -- IO Index 7 maps to GPIO13
gpio.mode(5, gpio.INT) -- IO Index 5 maps to GPIO14
--[[ IO Index 0 maps to GPIO16, but this pin does NOT support 
interrupt mode so you have to poll it if you want to use it. ]]--

gpio12trig = false
gpio13trig = false
gpio14trig = false

-- Used for soft debounce
gpio12time = 0
gpio13time = 0
gpio14time = 0

-- What it says on the box, called by the GPIO12 interrupt
local function gpio12(level, time)
  --print("GPIO12 "..level)
  if (gpio12time + 20000) < time then -- Soft debounce
    gpio12time = time
    if level == 0 then
      if not gpio12trig == true and not gpio13trig == true and not gpio14trig == true then
        print("step1")
        gpio12trig = true
      elseif gpio12trig == true and gpio13trig == true and gpio14trig == true then
        print("Disco Stu's gonna disco DOWN!")
        badgeMode=99
        gpio12trig = false
        gpio13trig = false
        gpio14trig = false
      else
        gpio12trig = false
        gpio13trig = false
        gpio14trig = false
      end
    end
  end
end
gpio.trig(6, "both", gpio12)

-- What it says on the box, called by the GPIO12 interrupt
local function gpio13(level, time)
  --("GPIO13 "..level)
  if (gpio13time + 20000) < time then -- Soft debounce
    gpio13time = time
    if level == 0 then
      if gpio12trig == true and not gpio13trig == true and gpio14trig == true then
        print("step3")
        gpio13trig = true
      else
        gpio12trig = false
        gpio13trig = false
        gpio14trig = false
      end
      -- NORMAL STUFF
      badgeMode = badgeMode + 1;
      if badgeMode > 1 then 
        badgeMode = 0
      end
      --print("updated badgeMode: "..badgeMode)
      newMode = true
    end
  end
end
gpio.trig(7, "both", gpio13)

-- What it says on the box, called by the GPIO12 interrupt
local function gpio14(level, time)
  --print("GPIO14 "..level)
  if (gpio14time + 20000) < time then -- Soft debounce
    gpio14time = time
    if level == 0 then
      if gpio12trig == true and not gpio13trig == true and not gpio14trig == true then
        print("step2")
        gpio14trig = true
      else
        gpio12trig = false
        gpio13trig = false
        gpio14trig = false
      end
    end
  end
end
gpio.trig(5, "both", gpio14)
