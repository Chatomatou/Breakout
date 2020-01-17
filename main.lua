io.stdout:setvbuf('no')

-- CONSTANT 
local WINDOW_SCREEN_WIDTH = 800 
local WINDOW_SCREEN_HEIGHT = 600
local ENTITY_MARGIN = 20
local ENTITY_PADDING = 5
local PLAYER_UNIFORM_RECTILINEAR_MOVEMENT_PHYSICS = 300
local BALL_UNIFORM_RECTILINEAR_MOVEMENT_PHYSICS = 1000 * 150

-- Entité de la scène 2D 
local ball = {}
ball.x = 0
ball.y = 0
ball.vx = 0
ball.vy = 0
ball.RADIUS = 10
ball.directionX = 1
ball.directionY = -1
ball.angle = 30

local player = {}
player.x = 0
player.y = 0
player.w = 200
player.h = 20
player.vx = 0
player.vy = 0
player.centralX = 0
player.centralY = 0

local wall = {}
wall.w = 50
wall.h = 25
 

local grid = {} 
grid.column = WINDOW_SCREEN_WIDTH / wall.w - 3
grid.row = 10

local gStart = false 

function love.load()
  love.window.setTitle("Lua Breakout")
  love.window.setMode(WINDOW_SCREEN_WIDTH, WINDOW_SCREEN_HEIGHT)
  
  
  -- Initialisation des information a pré-calculer avant la game loop
  player.x = (WINDOW_SCREEN_WIDTH / 2) - (player.w / 2) 
  player.y = WINDOW_SCREEN_HEIGHT - player.h - ENTITY_MARGIN 
 
  
  for i = 1, grid.row do 
    grid[i] = {}
    for j = 1, grid.column do 
      grid[i][j] = {}
      grid[i][j].status = true 
      grid[i][j].x = j * wall.w + (j * ENTITY_PADDING)
      grid[i][j].y = i * wall.h + (i * ENTITY_PADDING) 
    end
  end

end


function love.update(dt)
  if love.keyboard.isDown("left") and player.x > 0 then 
    player.x = player.x - PLAYER_UNIFORM_RECTILINEAR_MOVEMENT_PHYSICS * dt 
  end
  
  if love.keyboard.isDown("right") and player.x + player.w < WINDOW_SCREEN_WIDTH then 
    player.x = player.x + PLAYER_UNIFORM_RECTILINEAR_MOVEMENT_PHYSICS * dt
  end
  
  if love.keyboard.isDown("space") then 
    gStart = true 
  end
  
  -- calculer le point central 
  
  player.centralX = player.x + (player.w / 2)
  player.centralY = player.y
 
  if not gStart then 
    ball.x = player.x + player.w / 2
    ball.y = player.y - ENTITY_MARGIN
  else
    -- v = a * t 
    ball.vx = ball.directionX  * math.cos(math.rad(ball.angle)) * BALL_UNIFORM_RECTILINEAR_MOVEMENT_PHYSICS * dt 
    ball.vy = ball.directionY  * math.sin(math.rad(ball.angle)) * BALL_UNIFORM_RECTILINEAR_MOVEMENT_PHYSICS * dt  
    
    -- d = v * t 
    ball.x = ball.x + ball.vx * dt 
    ball.y = ball.y + ball.vy * dt 
  end
  
   
  if ball.x < 0 or  ball.x + ball.RADIUS > WINDOW_SCREEN_WIDTH then 
    if ball.directionX == -1 then 
      ball.directionX = 1
    else 
      ball.directionX = -1
    end
  end
  
 
  if ball.y < 0 then 
    ball.directionY = 1 
  end
 
  -- Collission cercle et triangle 
  if ball.x >= player.x and ball.x + ball.RADIUS <= player.x + player.w and ball.y >= player.y then 
    -- todo : calculer l'angle incident, et l'angle réfléchie ne plus utiliser la réflexion total 
    ball.directionY = -1 -- reflexion total
  end
  
  
  -- collision AABB classique 
  -- todo: Modifier le système de collision pour cercle rectangle et non AABB classique rect rect
  for i = 1, grid.row do 
    for j = 1, grid.column do 
       if ball.x >= grid[i][j].x and ball.x + ball.RADIUS <= grid[i][j].x + wall.w and ball.y >= grid[i][j].y and ball.y + ball.RADIUS <= grid[i][j].y + wall.h then 
        grid[i][j].status = false
        if ball.directionY == 1 then
            ball.directionY = -1
        else
            ball.directionY = 1
        end
      end
    end
  end
 
  
end


function love.draw()
  love.graphics.setColor(1, 1, 1)
  
  love.graphics.circle("fill", ball.x, ball.y, ball.RADIUS)
  love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
  
  for i = 1, grid.row do 
    for j = 1, grid.column do 
      if grid[i][j].status then 
        love.graphics.rectangle("fill", grid[i][j].x, grid[i][j].y, wall.w, wall.h)
      end
    end
  end
 
  love.graphics.setColor(1, 0, 0)
  love.graphics.circle("fill", player.centralX, player.centralY, 2)

end
