function love.load()
  -- Increase window size
  love.window.setMode(1400, 900)
  font = love.graphics.newFont(20)
  smallFont = love.graphics.newFont(16)
  love.graphics.setFont(font)

  -- States
  states = {PLAYING = "playing", GAME_OVER = "game_over", LEVEL_COMPLETE = "level_complete"}
  currentState = states.PLAYING

  -- Camera settings
  camera = {x = 0, y = 0, scale = 1, targetX = 0, targetY = 0}

  cellSize = 35
  levels = {
      {width = 15, height = 15, timeLimit = 20},
      {width = 20, height = 20, timeLimit = 25},
      {width = 25, height = 25, timeLimit = 30},
      {width = 30, height = 30, timeLimit = 35},
      {width = 35, height = 35, timeLimit = 40}
  }

  currentLevel = 1
  timeLeft = levels[1].timeLimit
  lastMove = love.timer.getTime()
  moveDelay = 0.1

  -- Player visual
  playerVisual = {
      x = 2, y = 2,
      targetX = 2, targetY = 2,
      speed = 25,
      trail = {}
  }

  -- Load sounds
  moveSound = love.audio.newSource("assets/move.wav", "static")
  levelCompleteSound = love.audio.newSource("assets/level_complete.wav", "static")
  gameOverSound = love.audio.newSource("assets/game_over.wav", "static")

  resetLevel()
  updateCameraScale()
end

function updateCameraScale()
  local level = levels[currentLevel]
  local windowWidth, windowHeight = love.graphics.getDimensions()
  local mazeWidth = level.width * cellSize
  local mazeHeight = level.height * cellSize
  local scaleX = (windowWidth - 100) / mazeWidth
  local scaleY = (windowHeight - 100) / mazeHeight
  camera.scale = math.min(scaleX, scaleY, 1)
end

function resetLevel()
  local level = levels[currentLevel]
  gridWidth = level.width
  gridHeight = level.height
  timeLeft = level.timeLimit

  maze = {}
  for y = 1, gridHeight do
      maze[y] = {}
      for x = 1, gridWidth do
          maze[y][x] = 1
      end
  end

  player = {x = 2, y = 2}
  playerVisual.x = 2
  playerVisual.y = 2
  playerVisual.targetX = 2
  playerVisual.targetY = 2
  playerVisual.trail = {}
  goal = {x = gridWidth - 1, y = gridHeight - 1}

  generateMaze(2, 2)
  complexifyMaze()
  maze[2][2] = 0
  maze[goal.y][goal.x] = 0
end

function complexifyMaze()
  for i = 1, gridWidth * gridHeight / 8 do
      local x = love.math.random(2, gridWidth - 1)
      local y = love.math.random(2, gridHeight - 1)
      if maze[y][x] == 1 then
          local paths = 0
          for _, dir in ipairs({{0, 1}, {0, -1}, {1, 0}, {-1, 0}}) do
              if maze[y + dir[2]][x + dir[1]] == 0 then
                  paths = paths + 1
              end
          end
          if paths <= 1 then
              maze[y][x] = 0
          end
      end
  end
end

function love.update(dt)
  if currentState == states.PLAYING then
      timeLeft = timeLeft - dt
      if timeLeft <= 0 then
          currentState = states.GAME_OVER
          love.audio.play(gameOverSound)
          return
      end

      -- Smooth camera movement
      camera.x = camera.x + (camera.targetX - camera.x) * 4 * dt
      camera.y = camera.y + (camera.targetY - camera.y) * 4 * dt

      -- Follow player
      local targetX = (playerVisual.x - 1) * cellSize * camera.scale
      local targetY = (playerVisual.y - 1) * cellSize * camera.scale
      camera.targetX = love.graphics.getWidth() / 2 - targetX - cellSize * camera.scale / 2
      camera.targetY = love.graphics.getHeight() / 2 - targetY - cellSize * camera.scale / 2

      local dx = playerVisual.targetX - playerVisual.x
      local dy = playerVisual.targetY - playerVisual.y
      playerVisual.x = playerVisual.x + dx * dt * playerVisual.speed
      playerVisual.y = playerVisual.y + dy * dt * playerVisual.speed

      if love.timer.getTime() - lastMove >= moveDelay then
          local isMoving = math.abs(dx) > 0.01 or math.abs(dy) > 0.01
          if not isMoving then
              local moved = false
              if love.keyboard.isDown("up") and player.y > 1 and maze[player.y - 1][player.x] == 0 then
                  player.y = player.y - 1
                  moved = true
              elseif love.keyboard.isDown("down") and player.y < gridHeight and maze[player.y + 1][player.x] == 0 then
                  player.y = player.y + 1
                  moved = true
              elseif love.keyboard.isDown("left") and player.x > 1 and maze[player.y][player.x - 1] == 0 then
                  player.x = player.x - 1
                  moved = true
              elseif love.keyboard.isDown("right") and player.x < gridWidth and maze[player.y][player.x + 1] == 0 then
                  player.x = player.x + 1
                  moved = true
              end

              if moved then
                  lastMove = love.timer.getTime()
                  playerVisual.targetX = player.x
                  playerVisual.targetY = player.y
                  table.insert(playerVisual.trail, {x = playerVisual.x, y = playerVisual.y, life = 0.3})
                  love.audio.play(moveSound)
              end
          end
      end

      for i = #playerVisual.trail, 1, -1 do
          local trail = playerVisual.trail[i]
          trail.life = trail.life - dt
          if trail.life <= 0 then
              table.remove(playerVisual.trail, i)
          end
      end

      if math.abs(playerVisual.x - playerVisual.targetX) + math.abs(playerVisual.y - playerVisual.targetY) < 0.1 and player.x == goal.x and player.y == goal.y then
          if currentLevel == #levels then
              currentState = states.GAME_OVER
          else
              currentState = states.LEVEL_COMPLETE
              love.audio.play(levelCompleteSound)
          end
      end
  elseif currentState == states.LEVEL_COMPLETE then
      -- Increment level and reset
      currentLevel = currentLevel + 1
      if currentLevel > #levels then
          currentState = states.GAME_OVER
      else
          resetLevel()
          updateCameraScale()
          currentState = states.PLAYING
      end
  end
end

function love.draw()
  love.graphics.push()
  love.graphics.scale(camera.scale)
  love.graphics.translate(camera.x, camera.y)

  -- Draw maze
  for y = 1, gridHeight do
      for x = 1, gridWidth do
          local color = maze[y][x] == 1 and {0.2, 0.2, 0.2} or {0.8, 0.8, 0.8}
          love.graphics.setColor(color)
          love.graphics.rectangle("fill", (x - 1) * cellSize, (y - 1) * cellSize, cellSize, cellSize)
      end
  end

  -- Draw goal
  love.graphics.setColor(0, 1, 0)
  love.graphics.rectangle("fill", (goal.x - 1) * cellSize, (goal.y - 1) * cellSize, cellSize, cellSize)

  -- Draw player
  love.graphics.setColor(1, 0, 0)
  love.graphics.circle("fill", (playerVisual.x - 0.5) * cellSize, (playerVisual.y - 0.5) * cellSize, cellSize / 3)

  -- Draw player trail
  love.graphics.setColor(1, 0.5, 0.5, 0.5)
  for _, trail in ipairs(playerVisual.trail) do
      love.graphics.circle("fill", (trail.x - 0.5) * cellSize, (trail.y - 0.5) * cellSize, cellSize / 4)
  end

  love.graphics.pop()

  -- Draw UI
  drawUI()
end

function drawUI()
  local windowWidth, windowHeight = love.graphics.getDimensions()
  love.graphics.setFont(font)

  -- Draw level and time left
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("Level: " .. currentLevel, 10, 10, windowWidth, "left")
  love.graphics.printf("Time Left: " .. math.ceil(timeLeft), 10, 40, windowWidth, "left")

  -- Draw game state
  if currentState == states.GAME_OVER then
      love.graphics.setFont(font)
      love.graphics.setColor(1, 0, 0)
      love.graphics.printf("GAME OVER", 0, windowHeight / 2 - 50, windowWidth, "center")
  elseif currentState == states.LEVEL_COMPLETE then
      love.graphics.setFont(font)
      love.graphics.setColor(0, 1, 0)
      love.graphics.printf("LEVEL COMPLETE", 0, windowHeight / 2 - 50, windowWidth, "center")
  end
end


function generateMaze(x, y)
  local directions = {{0, 2}, {2, 0}, {0, -2}, {-2, 0}}
  for i = #directions, 2, -1 do
      local j = love.math.random(i)
      directions[i], directions[j] = directions[j], directions[i]
  end

  for _, dir in ipairs(directions) do
      local nextX, nextY = x + dir[1], y + dir[2]
      if nextX > 0 and nextX <= gridWidth and nextY > 0 and nextY <= gridHeight and maze[nextY][nextX] == 1 then
          maze[nextY][nextX] = 0
          maze[y + dir[2] / 2][x + dir[1] / 2] = 0
          generateMaze(nextX, nextY)
      end
  end
end