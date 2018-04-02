local function flag()
    local key = crypto.toHex(crypto.hash("md5", string.format("RuxHHV2017%06X", node.chipid()))):sub(1, 16)
    local flag = "\62\58\53\62\35\96\17\111\109\20\102\31\104\99\101\29\97\18\102\26\110\20\18\29\30\99\98\109\29\99\22\24\28\111\108\105\111\43"
    local crypt = crypto.encrypt("AES-CBC", key, crypto.mask(flag, "\88\86\84\89"))
    print("flag: "..crypto.toHex(crypt))
end

--[[ Embedded specifically for the Ruxcon HHV 2017 badge. If you 
break something in here you will likely brick your badge. Unbricking
requires re-flashing NodeMCU ]]--
local function resetWS2812s()
  ws2812.init()
  local buf = ws2812.newBuffer(5, 3)
  buf:fill(0, 0, 0)
  ws2812.write(buf)
end

--[[ For some reason if we don't do this at startup pulling GPIO14
low during the autoboot delay causes NodeMCU to crash ]]--
local function setGPIO()
  gpio.mode(6, gpio.INPUT) -- IO Index 6 maps to GPIO12
  gpio.mode(7, gpio.INPUT) -- IO Index 7 maps to GPIO13
  gpio.mode(5, gpio.INPUT) -- IO Index 5 maps to GPIO14
  --[[ IO Index 4 maps to GPIO2 this is the blue LED on the module
  this code turns the LED off until the firmware actually launches ]]--  
  gpio.mode(4, gpio.OUTPUT)
  gpio.write(4, gpio.HIGH) 
end

resetWS2812s()
setGPIO()

flag()
-- cleanup
resetWS2812s = nil
setGPIO = nil
collectgarbage()
