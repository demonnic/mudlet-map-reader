MapExporter = MapExporter or {
  areas = {},
  dir = getMudletHomeDir() .. "/@PKGNAME@/"
}
local fileLocation = MapExporter.dir .. "index.html"
local fileURL = "file:///" .. fileLocation
MapExporter.fileLocation = fileLocation
MapExporter.fileURL = fileURL

function MapExporter:echoUrl()
  cecho("<blue>(<white>Map Explorer<blue>) ")
  echoLink(fileLocation, string.format([[openUrl("%s")]], fileURL), "Open in browser", false)
  echo(" \n")
end

function MapExporter:openUrl()
  openUrl(fileURL)
end

function MapExporter:getRoomInfo(roomId)
  local x,y,z = getRoomCoordinates(roomId)
  local userDataKeys = getRoomUserDataKeys(roomId)
  local userData = {}
  for _,key in ipairs(userDataKeys) do
    userData[key] = getRoomUserData(roomId,key)
  end
  userData.hash = getRoomHashByID(roomId)
  local roomInfo = {
    id = roomId,
    x = x,
    y = y,
    z = z,
    name = getRoomName(roomId),
    exits = getRoomExits(roomId),
    env = getRoomEnv(roomId),
    roomChar = getRoomChar(roomId),
    doors = getDoors(roomId),
    customLines = self:fixCustomLines(getCustomLines(roomId)),
    specialExits = getSpecialExitsSwap(roomId),
    stubs = getExitStubs1(roomId),
    userData = table.size(userData) > 0 and userData or nil
  }
  return roomInfo
end

function MapExporter:getAreaRooms(areaId)
  areaId = tonumber(areaId)
  local rooms = getAreaRooms(areaId)
  local labelIds = getMapLabels(areaId)

  local labels = {}
  if type(labelIds) == "table" then
    for k,v in pairs(labelIds) do
      local label = getMapLabel(areaId, k)
      label.id = k
      table.insert(labels, label)
    end
  end

  local areaRooms = {
    areaId = areaId,
    areaName =  getRoomAreaName(areaId),
    rooms = {},
    labels = labels
  }
  for _, roomId in pairs(rooms) do
    local roomInfo = self:getRoomInfo(roomId)
    table.insert(areaRooms.rooms, roomInfo)
  end
  return areaRooms
end

function MapExporter:exportColors()
  local colors = {}
  local adjustedColors = {}
  for i=0,255 do
    if i ~= 16 then -- ansi 016 is ignored.
      local key = string.format("ansi_%03d",i)
      local envID
      if i == 0 or i == 8 then -- ansi 000 is set to envID 8, and ansi 008 is set to envID 16, due to envID starting at 1 and ansi colors at 0
        envID = i + 8
      else
        envID = i
      end
      colors[envID] = color_table[key]
    end
  end
  for k,v in pairs(getCustomEnvColorTable()) do
    colors[k] = v
  end
  for envID,color in pairs(colors) do
    table.insert(adjustedColors, {
      envId = envID,
      colors = color
    })
  end
  colors = adjustedColors

  local colorsFileName = self.dir .. "data/colors.js"
  local colorsFile = io.open (colorsFileName, "w+")
  colorsFile:write("colors = ")
  colorsFile:write(yajl.to_string(colors))
  colorsFile:close()
end

function MapExporter:exportCurrentLocation()
  local position = {
    area = getRoomArea(getPlayerRoom()),
    room = getPlayerRoom()
  }
  local currentPosition = self.dir .. "/data/current.js"
  currentPosition = io.open (currentPosition, "w+")
  currentPosition:write("position = ")
  currentPosition:write(yajl.to_string(position))
  currentPosition:close()
end

function MapExporter:export()
  local areas = {}
  for areaName, areaId in pairs(getAreaTable()) do
    if areaId > 0 then
      local areaRooms = self:getAreaRooms(areaId)
      table.insert(areas, areaRooms)
    end
  end

  local fileName = self.dir .. "data/mapExport.js"
  local file = io.open (fileName, "w+")
  file:write("mapData = ")
  file:write(yajl.to_string(areas))
  file:close()

  self:exportColors()

  if getPlayerRoom() then
    self:exportCurrentLocation()
  end
end

function MapExporter:fixCustomLines(lineObj)
  for k,v in pairs(lineObj) do
    local tempPoints = {}
    local index = 1
    for i,j in pairs(v.points) do
      table.insert(tempPoints, math.max(1, tonumber(i)), j)
    end

    v.points = tempPoints
  end
  return lineObj
end

MapExporter.colorFixers = MapExporter.colorFixers or {}

function MapExporter.colorFixers.Imperian()
  setCustomEnvColor(1, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(2, Geyser.Color.parse("#808080"))
  setCustomEnvColor(3, Geyser.Color.parse("#808080"))
  setCustomEnvColor(4, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(5, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(6, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(7, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(8, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(9, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(10, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(11, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(12, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(13, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(14, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(15, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(16, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(17, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(18, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(19, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(20, Geyser.Color.parse("#0000A0"))
  setCustomEnvColor(21, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(22, Geyser.Color.parse("#0000A0"))
  setCustomEnvColor(23, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(24, Geyser.Color.parse("#0000A0"))
  setCustomEnvColor(25, Geyser.Color.parse("#0000A0"))
  setCustomEnvColor(26, Geyser.Color.parse("#0000A0"))
  setCustomEnvColor(27, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(28, Geyser.Color.parse("#808080"))
  setCustomEnvColor(30, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(31, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(32, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(33, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(35, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(36, Geyser.Color.parse("#808080"))
  setCustomEnvColor(37, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(38, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(39, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(41, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(42, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(44, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(45, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(46, Geyser.Color.parse("#808080"))
  setCustomEnvColor(47, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(48, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(49, Geyser.Color.parse("#0000A0"))
  setCustomEnvColor(50, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(51, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(52, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(53, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(54, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(56, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(57, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(58, Geyser.Color.parse("#808080"))
  setCustomEnvColor(59, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(60, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(61, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(62, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(63, Geyser.Color.parse("#808080"))
  setCustomEnvColor(64, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(65, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(67, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(68, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(69, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(70, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(71, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(72, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(73, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(74, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(75, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(76, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(77, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(78, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(79, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(81, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(82, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(83, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(84, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(85, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(86, Geyser.Color.parse("#FFFF00"))
end

function MapExporter.colorFixers.Aetolia()
  setCustomEnvColor(1, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(2, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(3, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(4, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(5, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(6, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(7, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(8, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(9, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(10, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(11, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(12, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(13, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(14, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(15, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(16, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(17, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(19, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(20, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(21, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(22, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(23, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(24, Geyser.Color.parse("#0000A0"))
  setCustomEnvColor(25, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(26, Geyser.Color.parse("#808080"))
  setCustomEnvColor(27, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(28, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(29, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(30, Geyser.Color.parse("#00FFFF"))
  setCustomEnvColor(31, Geyser.Color.parse("#808080"))
  setCustomEnvColor(32, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(33, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(34, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(35, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(36, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(37, Geyser.Color.parse("#808080"))
  setCustomEnvColor(38, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(39, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(40, Geyser.Color.parse("#0000A0"))
  setCustomEnvColor(41, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(42, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(43, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(44, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(45, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(46, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(48, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(49, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(50, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(52, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(53, Geyser.Color.parse("#00FFFF"))
  setCustomEnvColor(54, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(55, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(56, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(57, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(58, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(59, Geyser.Color.parse("#808080"))
  setCustomEnvColor(60, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(61, Geyser.Color.parse("#808080"))
  setCustomEnvColor(62, Geyser.Color.parse("#808080"))
  setCustomEnvColor(63, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(65, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(66, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(67, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(68, Geyser.Color.parse("#808080"))
  setCustomEnvColor(69, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(70, Geyser.Color.parse("#00FFFF"))
  setCustomEnvColor(71, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(72, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(73, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(75, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(76, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(77, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(78, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(79, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(80, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(81, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(82, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(83, Geyser.Color.parse("#808080"))
  setCustomEnvColor(84, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(85, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(87, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(88, Geyser.Color.parse("#00FFFF"))
  setCustomEnvColor(89, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(90, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(91, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(92, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(93, Geyser.Color.parse("#C8C8C8"))
  setCustomEnvColor(94, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(96, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(98, Geyser.Color.parse("#808080"))
  setCustomEnvColor(99, Geyser.Color.parse("#808080"))
  setCustomEnvColor(100, Geyser.Color.parse("#808080"))
  setCustomEnvColor(101, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(102, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(103, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(104, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(105, Geyser.Color.parse("#808080"))
  setCustomEnvColor(106, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(107, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(108, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(109, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(110, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(113, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(114, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(116, Geyser.Color.parse("#808080"))
  setCustomEnvColor(117, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(118, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(120, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(121, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(122, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(123, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(124, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(125, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(126, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(127, Geyser.Color.parse("#808080"))
  setCustomEnvColor(128, Geyser.Color.parse("#FF00FF"))
  setCustomEnvColor(129, Geyser.Color.parse("#B1B1B1"))
  setCustomEnvColor(130, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(131, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(132, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(133, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(134, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(136, Geyser.Color.parse("#663300"))
  setCustomEnvColor(137, Geyser.Color.parse("#333300"))
  setCustomEnvColor(138, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(140, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(142, Geyser.Color.parse("#6633FF"))
  setCustomEnvColor(143, Geyser.Color.parse("#CC6600"))
  setCustomEnvColor(144, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(145, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(146, Geyser.Color.parse("#0066FF"))
  setCustomEnvColor(147, Geyser.Color.parse("#3333FF"))
  setCustomEnvColor(148, Geyser.Color.parse("#0099FF"))
  setCustomEnvColor(149, Geyser.Color.parse("#FF00FF"))
  setCustomEnvColor(150, Geyser.Color.parse("#99FF00"))
  setCustomEnvColor(151, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(152, Geyser.Color.parse("#FF9900"))
  setCustomEnvColor(153, Geyser.Color.parse("#FF3300"))
  setCustomEnvColor(154, Geyser.Color.parse("#6633CC"))
  setCustomEnvColor(155, Geyser.Color.parse("#00FF66"))
  setCustomEnvColor(156, Geyser.Color.parse("#434343"))
  setCustomEnvColor(157, Geyser.Color.parse("#FF0099"))
end

function MapExporter.colorFixers.Lusternia()
  setCustomEnvColor(1, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(2, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(3, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(4, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(5, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(6, Geyser.Color.parse("#FFFF00"))
  setCustomEnvColor(7, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(8, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(9, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(10, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(11, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(12, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(13, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(14, Geyser.Color.parse("#A0A000"))
  setCustomEnvColor(15, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(16, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(17, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(18, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(19, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(20, Geyser.Color.parse("#0000FF"))
  setCustomEnvColor(21, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(22, Geyser.Color.parse("#0000A0"))
  setCustomEnvColor(23, Geyser.Color.parse("#00A0A0"))
  setCustomEnvColor(24, Geyser.Color.parse("#0000A0"))
  setCustomEnvColor(25, Geyser.Color.parse("#00FFFF"))
  setCustomEnvColor(27, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(28, Geyser.Color.parse("#00FF00"))
  setCustomEnvColor(29, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(30, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(31, Geyser.Color.parse("#00B300"))
  setCustomEnvColor(32, Geyser.Color.parse("#FF0000"))
  setCustomEnvColor(33, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(34, Geyser.Color.parse("#A00000"))
  setCustomEnvColor(35, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(36, Geyser.Color.parse("#A000A0"))
  setCustomEnvColor(37, Geyser.Color.parse("#FFFFFF"))
  setCustomEnvColor(38, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(39, Geyser.Color.parse("#FF00FF"))
  setCustomEnvColor(40, Geyser.Color.parse("#C0C0C0"))
end

function MapExporter.colorFixers.Achaea()
  setCustomEnvColor(2, Geyser.Color.parse("#80735f"))
  setCustomEnvColor(3, Geyser.Color.parse("#765116"))
  setCustomEnvColor(4, Geyser.Color.parse("#36662e"))
  setCustomEnvColor(5, Geyser.Color.parse("#ffffcc"))
  setCustomEnvColor(6, Geyser.Color.parse("#f9fd00"))
  setCustomEnvColor(7, Geyser.Color.parse("#1dc713"))
  setCustomEnvColor(8, Geyser.Color.parse("#bda0cb"))
  setCustomEnvColor(9, Geyser.Color.parse("#2d7720"))
  setCustomEnvColor(10, Geyser.Color.parse("#00ddff"))
  setCustomEnvColor(11, Geyser.Color.parse("#837766"))
  setCustomEnvColor(12, Geyser.Color.parse("#7c7c7c"))
  setCustomEnvColor(13, Geyser.Color.parse("#41ab2f"))
  setCustomEnvColor(14, Geyser.Color.parse("#584a34"))
  setCustomEnvColor(15, Geyser.Color.parse("#76843c"))
  setCustomEnvColor(16, Geyser.Color.parse("#c5fcff"))
  setCustomEnvColor(17, Geyser.Color.parse("#89e14b"))
  setCustomEnvColor(18, Geyser.Color.parse("#ab9e6d"))
  setCustomEnvColor(19, Geyser.Color.parse("#56a574"))
  setCustomEnvColor(20, Geyser.Color.parse("#0000ff"))
  setCustomEnvColor(21, Geyser.Color.parse("#94e45d"))
  setCustomEnvColor(22, Geyser.Color.parse("#5ff0f0"))
  setCustomEnvColor(23, Geyser.Color.parse("#918010"))
  setCustomEnvColor(24, Geyser.Color.parse("#003366"))
  setCustomEnvColor(25, Geyser.Color.parse("#f98167"))
  setCustomEnvColor(27, Geyser.Color.parse("#ffffff"))
  setCustomEnvColor(28, Geyser.Color.parse("#00e342"))
  setCustomEnvColor(29, Geyser.Color.parse("#990000"))
  setCustomEnvColor(30, Geyser.Color.parse("#4d42d4"))
  setCustomEnvColor(31, Geyser.Color.parse("#dd4400"))
  setCustomEnvColor(32, Geyser.Color.parse("#ddba82"))
  setCustomEnvColor(33, Geyser.Color.parse("#837766"))
  setCustomEnvColor(34, Geyser.Color.parse("#0000ff"))
  setCustomEnvColor(35, Geyser.Color.parse("#ffffff"))
  setCustomEnvColor(36, Geyser.Color.parse("#918010"))
  setCustomEnvColor(39, Geyser.Color.parse("#918010"))
  setCustomEnvColor(40, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(41, Geyser.Color.parse("#C0C0C0"))
  setCustomEnvColor(42, Geyser.Color.parse("#cf1020"))
  setCustomEnvColor(43, Geyser.Color.parse("#00701f"))
  setCustomEnvColor(48, Geyser.Color.parse("#f98167"))
end

function MapExporter.colorFixers.Starmourn()
  setCustomEnvColor(1  , Geyser.Color.parse("#d7875f"))
  setCustomEnvColor(2  , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(3  , Geyser.Color.parse("#ff875f"))
  setCustomEnvColor(4  , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(5  , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(6  , Geyser.Color.parse("#0000ff"))
  setCustomEnvColor(7  , Geyser.Color.parse("#ffd700"))
  setCustomEnvColor(8  , Geyser.Color.parse("#008000"))
  setCustomEnvColor(9  , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(10 , Geyser.Color.parse("#afffff"))
  setCustomEnvColor(11 , Geyser.Color.parse("#5f00ff"))
  setCustomEnvColor(12 , Geyser.Color.parse("#005f00"))
  setCustomEnvColor(13 , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(14 , Geyser.Color.parse("#00afff"))
  setCustomEnvColor(15 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(16 , Geyser.Color.parse("#8787ff"))
  setCustomEnvColor(17 , Geyser.Color.parse("#eeeeee"))
  setCustomEnvColor(18 , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(19 , Geyser.Color.parse("#008700"))
  setCustomEnvColor(20 , Geyser.Color.parse("#87af00"))
  setCustomEnvColor(21 , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(22 , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(23 , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(26 , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(27 , Geyser.Color.parse("#eeeeee"))
  setCustomEnvColor(28 , Geyser.Color.parse("#5faf00"))
  setCustomEnvColor(29 , Geyser.Color.parse("#949494"))
  setCustomEnvColor(30 , Geyser.Color.parse("#00ff00"))
  setCustomEnvColor(31 , Geyser.Color.parse("#d78700"))
  setCustomEnvColor(32 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(34 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(35 , Geyser.Color.parse("#005fff"))
  setCustomEnvColor(36 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(37 , Geyser.Color.parse("#d75f00"))
  setCustomEnvColor(38 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(39 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(40 , Geyser.Color.parse("#878700"))
  setCustomEnvColor(42 , Geyser.Color.parse("#875f00"))
  setCustomEnvColor(43 , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(44 , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(45 , Geyser.Color.parse("#ff5f5f"))
  setCustomEnvColor(46 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(47 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(48 , Geyser.Color.parse("#875f00"))
  setCustomEnvColor(49 , Geyser.Color.parse("#00afff"))
  setCustomEnvColor(50 , Geyser.Color.parse("#00afff"))
  setCustomEnvColor(51 , Geyser.Color.parse("#af8700"))
  setCustomEnvColor(52 , Geyser.Color.parse("#008787"))
  setCustomEnvColor(53 , Geyser.Color.parse("#008000"))
  setCustomEnvColor(54 , Geyser.Color.parse("#870000"))
  setCustomEnvColor(55 , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(56 , Geyser.Color.parse("#800000"))
  setCustomEnvColor(57 , Geyser.Color.parse("#ff0000"))
  setCustomEnvColor(58 , Geyser.Color.parse("#c6c6c6"))
  setCustomEnvColor(59 , Geyser.Color.parse("#5f5f00"))
  setCustomEnvColor(60 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(61 , Geyser.Color.parse("#87d700"))
  setCustomEnvColor(62 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(63 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(64 , Geyser.Color.parse("#00afff"))
  setCustomEnvColor(65 , Geyser.Color.parse("#87ffaf"))
  setCustomEnvColor(66 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(67 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(69 , Geyser.Color.parse("#878700"))
  setCustomEnvColor(70 , Geyser.Color.parse("#5f5f00"))
  setCustomEnvColor(71 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(72 , Geyser.Color.parse("#878700"))
  setCustomEnvColor(73 , Geyser.Color.parse("#878700"))
  setCustomEnvColor(75 , Geyser.Color.parse("#00875f"))
  setCustomEnvColor(76 , Geyser.Color.parse("#87af5f"))
  setCustomEnvColor(77 , Geyser.Color.parse("#87af5f"))
  setCustomEnvColor(78 , Geyser.Color.parse("#87af5f"))
  setCustomEnvColor(79 , Geyser.Color.parse("#87af5f"))
  setCustomEnvColor(80 , Geyser.Color.parse("#87af5f"))
  setCustomEnvColor(81 , Geyser.Color.parse("#87af5f"))
  setCustomEnvColor(82 , Geyser.Color.parse("#87af5f"))
  setCustomEnvColor(83 , Geyser.Color.parse("#87af5f"))
  setCustomEnvColor(84 , Geyser.Color.parse("#87af5f"))
  setCustomEnvColor(85 , Geyser.Color.parse("#00afff"))
  setCustomEnvColor(86 , Geyser.Color.parse("#d75f00"))
  setCustomEnvColor(87 , Geyser.Color.parse("#0000ff"))
  setCustomEnvColor(88 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(89 , Geyser.Color.parse("#87d7d7"))
  setCustomEnvColor(92 , Geyser.Color.parse("#af0087"))
  setCustomEnvColor(93 , Geyser.Color.parse("#808000"))
end
