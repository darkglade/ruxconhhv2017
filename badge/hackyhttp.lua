--[[ This is an EXTREMELY shitty HTTP server, don't use it. 
If you want an HTTP server for NodeMCU use this one;
https://github.com/marcoskirsch/nodemcu-httpserver ]]--

local s = net.createServer(net.TCP, 30)

--[[ The guts, basically gets called on connection and blats some vaguely
HTTP-ish data at the user, like I say DON'T USE THIS CODE ]]-- 
local function httpReceive(sock, data)
  local response = {}
  local badgeId = string.format("%06X", node.chipid())
  local hexColour = crypto.toHex(crypto.hash("sha1", string.format("%06X", node.chipid()))):sub(27, 32):upper()
  
  response[#response + 1] = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"
  response[#response + 1] = "<!DOCTYPE HTML>\r\n<html><head><title>RuxBadge-"..badgeId.."</title></head>\r\n"
  response[#response + 1] = "<body>\r\n<h1>RuxBadge-"..badgeId.."</h1>\r\n"
  response[#response + 1] = "<p>Welcome to your Ruxcon HHV 2017 badge</p>\r\n"
  if badgeMode == 99 then
    response[#response + 1] = "<p>Current badge mode: DISCO</p>\r\n"
  else
    response[#response + 1] = "<p>Current badge mode: "..badgeMode.."</p>\r\n"
  end
  response[#response + 1] = "<p style=\"color:#"..hexColour..";\">Your node colour is: #"..hexColour.." colours on screen probably won't accurately reflect colours on LEDs, meh</p>\r\n"
  response[#response + 1] = "</body>\r\n</html>"

  local function send(localSock)
    if #response > 0 then
      localSock:send(table.remove(response, 1))
    else
      localSock:close()
      response = nil
    end
  end

  sock:on("sent", send)
  send(sock)
end

print("Starting hacky HTTP...")
s:listen(80, function(conn)
  conn:on("receive", httpReceive)
end)