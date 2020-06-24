local game = matches[2]
local func = MapExporter.colorFixers[game]
if func then
  func()
end
