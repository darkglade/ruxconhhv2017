--[[ Compiling the Lua to bytecode saves heap at runtime but IME it
frequently results in larger code in Flash (at least when the Lua
source has been minified), theoretically the compiled bytecode should
also run faster but I've not benchmarked it.

This code basically iterates a list of Lua source files, compiles each
(including itself) and deletes the original ]]--

-- Compile code and remove original .lua files.
local compileAndRemoveIfNeeded = function(f)
   if file.open(f) then
      file.close()
      print('Compiling:', f)
      node.compile(f)
      file.remove(f)
      collectgarbage()
   end
end

-- If you wanted to re-use this all you really need to do is update this list
local luaFiles = {
   'wsdrv.lua',
   'wifi.lua',
   'buttons.lua',
   'ruxinit.lua',
   'hackyhttp.lua',
   'compile.lua',
}
for i, f in ipairs(luaFiles) do compileAndRemoveIfNeeded(f) end

-- Tidy up, we don't need this stuff lying around after it's done
compileAndRemoveIfNeeded = nil
luaFiles = nil
collectgarbage()
