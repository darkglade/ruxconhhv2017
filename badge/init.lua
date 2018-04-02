abort = false

--[[ This function is called by a timer to give a 5 second lag
before starting the code, this is basically to avoid bricking your 
badge. When the eLua interpreter panics it's generally too quick for 
you to be able to fix the problem (without this you have to be REALLY
quick with a file.move('init.lua', 'init.old') or similar at startup 
to stop it crashing out on you because it doesn't like your code 
either that or reflash NodeMCU ]]--
local function startup()
    if not abort then
        print("Launching")
        dofile("buttons.lc")
        dofile("wsdrv.lc")
        dofile("wifi.lc")
        dofile("hackyhttp.lc")
        collectgarbage()
    end
end

-- Run the compilation script at startup if it's present
if file.exists("compile.lua") then
    dofile("compile.lua")
elseif file.exists("compile.lc") then
    dofile("compile.lc")
end

dofile("ruxinit.lc") -- Run the badge specific initialisation stuff
print("Boot Wait: set abort=true to cancel launch")
tmr.create():alarm(5000, tmr.ALARM_SINGLE, startup)

