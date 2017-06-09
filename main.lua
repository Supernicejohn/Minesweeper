-- Minesweeper
local function draw(img,x,y)
   love.graphics.setCanvas(canvas)
   love.graphics.setColor(255,255,255,255)
   local ok,err = pcall(love.graphics.draw,img,x,y)
   if not ok then
      error(err)
   end
end
local function loadImage(img)
   if img and love.filesystem.exists("resources/"..img) then
      return love.graphics.newImage(love.image.newImageData("resources/"..img))
   end
end
local function setup(n,d)

   rotation = 0.1
   settings = {
      squareSize = 20, -- don't touch
      boardSize = n,
      bombPercentage = d
   }
   settings.scale = (select(2,love.window.getDesktopDimensions())/1.1)/(settings.squareSize*settings.boardSize)
   love.window.setTitle("Minesweeper - Beta 1")
   math.randomseed(os.time())
   win = false
   love.window.setMode(settings.boardSize*20*settings.scale,settings.boardSize*20*settings.scale,{resizable = true} )
   canvas = love.graphics.newCanvas(settings.boardSize*20,settings.boardSize*20)
   love.graphics.setCanvas(canvas)
   love.graphics.clear()
   love.graphics.setBlendMode("alpha")
   images = {
      tile = loadImage("tile.png"),
      tile_clicked = loadImage("tile_clicked.png"),
      flag = loadImage("flag.png"),
      bomb = loadImage("bomb.png"),
      [1] = loadImage("one.png"),
      [2] = loadImage("two.png"),
      [3] = loadImage("three.png"),
      [4] = loadImage("four.png"),
      [5] = loadImage("five.png"),
      [6] = loadImage("six.png"),
      [7] = loadImage("seven.png"),
      [8] = loadImage("eight.png")
   }
   grid = {}
   for i=0,settings.boardSize-1 do
      grid[i] = {}
      for j=0,settings.boardSize-1 do
         grid[i][j] = {isBomb = (math.random(0,100)<(settings.bombPercentage)), clicked = false, flag = false}
         draw(images.tile,i*settings.squareSize,j*settings.squareSize)
      end
   end
   for x=0, settings.boardSize-1 do
      for y=0, settings.boardSize-1 do
         local count = 0
         for i=-1,1 do
            for j=-1,1 do
               if x+i>=0 and y+j>=0 and x+i<settings.boardSize and y+j<settings.boardSize then
                  if grid[x+i][y+j].isBomb then
                     count = count + 1
                  end
               end
            end
         end
         grid[x][y].count = count
      end
   end
   love.graphics.setCanvas()
end
function love.load()
   boardSize = 10
   bombPercentage = 10
   setup(boardSize,bombPercentage)
end
function love.resize(w,h)
   settings.scale = h/(settings.boardSize*settings.squareSize)
end

local function flood(x,y)
   for i=-1,1 do
      for j=-1,1 do
         if grid[x+i] then
            if grid[x+i][y+j] then
               if grid[x+i][y+j].count == 0 and grid[x+i][y+j].clicked == false then
                  grid[x+i][y+j].clicked = true
                  draw(images.tile_clicked,(x+i)*settings.squareSize,(y+j)*settings.squareSize)
                  pcall(flood,x+i,y+j)
               elseif grid[x+i][y+j].count ~= 0 then
                  grid[x+i][y+j].clicked = true
                  draw(images.tile_clicked,(x+i)*settings.squareSize,(y+j)*settings.squareSize)
                  draw(images[grid[x+i][y+j].count],(x+i)*settings.squareSize,(y+j)*settings.squareSize)
               end
            end
         end
      end
   end
end
function love.update()
   if love.keyboard.isDown("r") then
      setup(boardSize,bombPercentage)
   end
   if love.keyboard.isDown("up") then
      boardSize = boardSize + 1
      setup(boardSize,bombPercentage)
   end
   if love.keyboard.isDown("down") then
      boardSize = math.max(boardSize-1,1)
      setup(boardSize,bombPercentage)
   end
   if love.keyboard.isDown("left") then
      bombPercentage = math.max(bombPercentage-1,0)
      setup(boardSize,bombPercentage)
   end
   if love.keyboard.isDown("right") then
      bombPercentage = math.min(bombPercentage+1,99)
      setup(boardSize,bombPercentage)
   end
end
function love.mousepressed(x,y,button)
   x = x/settings.scale
   y = y/settings.scale
   love.graphics.setCanvas(canvas)
   local gX,gY = math.floor(x/settings.squareSize),math.floor(y/settings.squareSize)
   if grid[gX] then
      if grid[gX][gY] then
         if button ~= 1 and grid[gX][gY].clicked == false then
            grid[gX][gY].flag = not grid[gX][gY].flag
            if grid[gX][gY].flag then
               draw(images.flag,gX*settings.squareSize,gY*settings.squareSize)
            else
               draw(images.tile,gX*settings.squareSize,gY*settings.squareSize)
            end
         elseif grid[gX][gY].flag == false then
            grid[gX][gY].clicked = true
            draw(images.tile_clicked,gX*settings.squareSize,gY*settings.squareSize)
            if grid[gX][gY].isBomb then
               draw(images.bomb,gX*settings.squareSize,gY*settings.squareSize)
               for i=0,settings.boardSize-1 do
                  for j=0,settings.boardSize-1 do
                     if (i~=gX or j~=gY) and grid[i][j].isBomb then
                        draw(images.bomb,i*settings.squareSize,j*settings.squareSize)
                     end
                  end
               end
            else
               if grid[gX][gY].count > 0 then
                  draw(images[grid[gX][gY].count],gX*settings.squareSize,gY*settings.squareSize)
               else
                  flood(gX,gY)
               end
            end
         end
      end
   end
   win = true
   for i=0,settings.boardSize-1 do
      for j=0,settings.boardSize-1 do
         if grid[i][j].clicked == false and grid[i][j].isBomb == false then
            win = false
         end
      end
   end
   love.graphics.setCanvas()
end
function love.draw()
   love.graphics.setCanvas()
   love.graphics.setBlendMode("alpha","premultiplied")
   if win then
      rotation = rotation * 1.02
      love.graphics.setColor(math.random(170,255),math.random(170,255),math.random(170,255),math.random(170,255))
      love.graphics.draw(canvas,settings.boardSize*10*settings.scale,settings.boardSize*10*settings.scale,rotation,rotation%10,rotation%10,settings.boardSize*10,settings.boardSize*10)
   else
      love.graphics.setColor(255,255,255,255)
      love.graphics.draw(canvas,0,0,0,settings.scale,settings.scale,0,0)
   end
end