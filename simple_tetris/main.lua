local grid = {}
local gridWidth, gridHeight = 10, 20
local cellSize = 30
local gameOver = false
local paused = false
local score = 0
local level = 1
local linesCleared = 0
local highScore = 0
local ghostPieceEnabled = true
local holdPiece = nil
local canHold = true
local comboCount = 0

-- Color schemes for different tetrominos
local colors = {
    I = {0, 0.9, 0.9},    -- Cyan
    O = {0.9, 0.9, 0},    -- Yellow
    T = {0.9, 0, 0.9},    -- Purple
    S = {0, 0.9, 0},      -- Green
    Z = {0.9, 0, 0},      -- Red
    J = {0, 0, 0.9},      -- Blue
    L = {0.9, 0.45, 0}    -- Orange
}

-- Tetromino shapes and rotations with wall kick data
local tetrominoes = {
    I = {shape = {{1, 1, 1, 1}}, color = colors.I},
    O = {shape = {{1, 1}, {1, 1}}, color = colors.O},
    T = {shape = {{0, 1, 0}, {1, 1, 1}}, color = colors.T},
    S = {shape = {{0, 1, 1}, {1, 1, 0}}, color = colors.S},
    Z = {shape = {{1, 1, 0}, {0, 1, 1}}, color = colors.Z},
    J = {shape = {{1, 0, 0}, {1, 1, 1}}, color = colors.J},
    L = {shape = {{0, 0, 1}, {1, 1, 1}}, color = colors.L}
}

local currentTetromino = {shape = nil, type = nil, color = nil}
local tetrominoX, tetrominoY
local dropTimer = 0
local dropSpeed = 0.5
local nextTetromino = nil
local particles = {}
local shake = {amount = 0, duration = 0}

-- Particle system for effects
local function createParticleSystem()
  local function createPixelImage()
    local imageData = love.image.newImageData(1, 1)
    imageData:setPixel(0, 0, 1, 1, 1, 1)
    return love.graphics.newImage(imageData)
  end

  local pixelImage = createPixelImage()
  local ps = love.graphics.newParticleSystem(pixelImage, 1000)
  ps:setParticleLifetime(0.5, 1)
  ps:setLinearAcceleration(-100, -100, 100, 100)
  ps:setColors(1, 1, 1, 1, 1, 1, 1, 0)
  ps:setSizes(2, 1, 0)  -- Start bigger, end smaller
  return ps
end

-- grid creation
function createGrid()
    for y = 1, gridHeight do
        grid[y] = {}
        for x = 1, gridWidth do
            grid[y][x] = {value = 0, color = nil}
        end
    end
end

-- Generate next piece with bag system
local bag = {}
function getNextPiece()
    if #bag == 0 then
        -- Fill the bag with one of each piece
        for type in pairs(tetrominoes) do
            table.insert(bag, type)
        end

        for i = #bag, 2, -1 do
            local j = math.random(i)
            bag[i], bag[j] = bag[j], bag[i]
        end
    end
    return table.remove(bag)
end

-- Spawn a new Tetromino with preview
function spawnTetromino()
  if not nextTetromino then
      nextTetromino = getNextPiece()
  end

  currentTetromino.type = nextTetromino
  currentTetromino.shape = tetrominoes[nextTetromino].shape
  currentTetromino.color = tetrominoes[nextTetromino].color

  nextTetromino = getNextPiece()

  -- Fix initial position calculation
  tetrominoX = math.floor((gridWidth - #currentTetromino.shape[1]) / 2) + 1
  tetrominoY = 1

  canHold = true
end

-- Hold piece functionality
function holdCurrentPiece()
    if not canHold then return end

    local temp = currentTetromino.type
    if holdPiece then
        currentTetromino.type = holdPiece
        currentTetromino.shape = tetrominoes[holdPiece].shape
        currentTetromino.color = tetrominoes[holdPiece].color
    else
        spawnTetromino()
    end
    holdPiece = temp
    canHold = false

    -- Reset position
    tetrominoX = math.floor(gridWidth / 2) - math.floor(#currentTetromino.shape[1] / 2)
    tetrominoY = 1
end

-- rotation with wall kicks
function rotateTetromino()
    local rotated = {}
    for x = 1, #currentTetromino.shape[1] do
        rotated[x] = {}
        for y = 1, #currentTetromino.shape do
            rotated[x][#currentTetromino.shape - y + 1] = currentTetromino.shape[y][x]
        end
    end

    -- Wall kick data
    local kicks = {
        {0, 0}, {-1, 0}, {1, 0}, {0, -1}, {-1, -1}, {1, -1}
    }

    local originalShape = currentTetromino.shape
    currentTetromino.shape = rotated

    -- Try wall kicks
    for _, kick in ipairs(kicks) do
        local oldX, oldY = tetrominoX, tetrominoY
        tetrominoX = tetrominoX + kick[1]
        tetrominoY = tetrominoY + kick[2]

        if not checkCollision() then
            return true
        end

        tetrominoX, tetrominoY = oldX, oldY
    end

    -- If no kicks work, revert
    currentTetromino.shape = originalShape
    return false
end

-- drawing with ghost piece and effects
function drawGrid()
    -- Draw background gradient
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, gridWidth * cellSize, gridHeight * cellSize)

    -- Draw grid cells
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            if grid[y][x].value == 1 then
                love.graphics.setColor(grid[y][x].color)
                love.graphics.rectangle("fill", (x - 1) * cellSize + 2, (y - 1) * cellSize + 2, cellSize - 4, cellSize - 4)
            else
                love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
                love.graphics.rectangle("line", (x - 1) * cellSize, (y - 1) * cellSize, cellSize, cellSize)
            end
        end
    end
end

-- Draw ghost piece
function drawGhostPiece()
  if not ghostPieceEnabled or not currentTetromino.shape then return end

  local ghostY = tetrominoY
  while not checkCollision(tetrominoX, ghostY + 1) do
      ghostY = ghostY + 1
  end

  love.graphics.setColor(currentTetromino.color[1], currentTetromino.color[2], currentTetromino.color[3], 0.3)
  for y = 1, #currentTetromino.shape do
      for x = 1, #currentTetromino.shape[y] do
          if currentTetromino.shape[y][x] == 1 then
              local drawX = (tetrominoX + x - 2) * cellSize
              local drawY = (ghostY + y - 2) * cellSize
              love.graphics.rectangle("fill", drawX + 2, drawY + 2, cellSize - 4, cellSize - 4)
          end
      end
  end
end

-- tetromino drawing with smooth animations
function drawTetromino()
  if currentTetromino.shape then
      love.graphics.setColor(currentTetromino.color)
      for y = 1, #currentTetromino.shape do
          for x = 1, #currentTetromino.shape[y] do
              if currentTetromino.shape[y][x] == 1 then
                  local drawX = (tetrominoX + x - 2) * cellSize + shake.amount * (math.random() - 0.5)
                  local drawY = (tetrominoY + y - 2) * cellSize + shake.amount * (math.random() - 0.5)
                  love.graphics.rectangle("fill", drawX + 2, drawY + 2, cellSize - 4, cellSize - 4)
              end
          end
      end
  end
end

-- UI with preview and hold piece
function drawUI()
    -- Draw score and level
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.print("Score: " .. score, gridWidth * cellSize + 20, 20)
    love.graphics.print("Level: " .. level, gridWidth * cellSize + 20, 50)
    love.graphics.print("Lines: " .. linesCleared, gridWidth * cellSize + 20, 80)
    love.graphics.print("High Score: " .. highScore, gridWidth * cellSize + 20, 110)

    -- Draw next piece preview
    love.graphics.print("Next:", gridWidth * cellSize + 20, 150)
    if nextTetromino then
        love.graphics.setColor(tetrominoes[nextTetromino].color)
        local shape = tetrominoes[nextTetromino].shape
        for y = 1, #shape do
            for x = 1, #shape[y] do
                if shape[y][x] == 1 then
                    love.graphics.rectangle("fill", 
                        gridWidth * cellSize + 20 + (x - 1) * cellSize/2,
                        200 + (y - 1) * cellSize/2,
                        cellSize/2 - 2, cellSize/2 - 2)
                end
            end
        end
    end

    -- Draw hold piece
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Hold:", gridWidth * cellSize + 20, 300)
    if holdPiece then
        love.graphics.setColor(tetrominoes[holdPiece].color)
        local shape = tetrominoes[holdPiece].shape
        for y = 1, #shape do
            for x = 1, #shape[y] do
                if shape[y][x] == 1 then
                    love.graphics.rectangle("fill", 
                        gridWidth * cellSize + 20 + (x - 1) * cellSize/2,
                        350 + (y - 1) * cellSize/2,
                        cellSize/2 - 2, cellSize/2 - 2)
                end
            end
        end
    end

    -- Draw combo counter
    if comboCount > 1 then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("Combo x" .. comboCount, gridWidth * cellSize + 20, 450)
    end
end

-- collision checking
function checkCollision(checkX, checkY)
  checkX = checkX or tetrominoX
  checkY = checkY or tetrominoY

  for y = 1, #currentTetromino.shape do
      for x = 1, #currentTetromino.shape[y] do
          if currentTetromino.shape[y][x] == 1 then
              local newX = checkX + x - 1
              local newY = checkY + y - 1

              -- Check boundaries and existing blocks
              if newX < 1 or newX > gridWidth or newY > gridHeight then
                  return true
              end

              -- Only check grid collision if we're within the grid
              if newY > 0 then
                  if grid[newY][newX].value == 1 then
                      return true
                  end
              end
          end
      end
  end
  return false
end

-- piece placement with effects
function placeTetromino()
  for y = 1, #currentTetromino.shape do
      for x = 1, #currentTetromino.shape[y] do
          if currentTetromino.shape[y][x] == 1 then
              local newX = tetrominoX + x - 1
              local newY = tetrominoY + y - 1
              if newY >= 1 then
                  grid[newY][newX] = {value = 1, color = currentTetromino.color}
              end
          end
      end
  end

  shake.amount = 3
  shake.duration = 0.1
end

-- row clearing with effects
function clearRows()
    local clearedRows = 0
    for y = gridHeight, 1, -1 do
        local isFull = true
        for x = 1, gridWidth do
            if grid[y][x].value == 0 then
                isFull = false
                break
            end
        end

        if isFull then
            -- Create particle effect
            local ps = createParticleSystem()
            ps:setPosition(gridWidth * cellSize / 2, y * cellSize)
            ps:emit(50)
            table.insert(particles, {system = ps, timeLeft = 1})

            -- Shift rows down
            for yy = y, 2, -1 do
                for x = 1, gridWidth do
                    grid[yy][x] = grid[yy - 1][x]
                end
            end
            for x = 1, gridWidth do
                grid[1][x] = {value = 0, color = nil}
            end

            clearedRows = clearedRows + 1
            y = y + 1
        end
    end

    -- Update score and level
    if clearedRows > 0 then
        local basePoints = {100, 300, 500, 800}
        score = score + basePoints[clearedRows] * level * (comboCount + 1)
        linesCleared = linesCleared + clearedRows
        comboCount = comboCount + 1

        if score > highScore then
            highScore = score
        end

        if linesCleared >= level * 10 then
            level = level + 1
            dropSpeed = dropSpeed * 0.8  -- Faster drop speed
        end

        -- Add screen shake
        shake.amount = clearedRows * 2
        shake.duration = 0.2
    else
        comboCount = 0
    end
end

-- input handling with hard drop and hold functionality
function love.keypressed(key)
  if key == "escape" then
      paused = not paused
      return
  end

  if key == "r" then
      -- Reset game
      createGrid()
      score = 0
      level = 1
      linesCleared = 0
      comboCount = 0
      dropSpeed = 0.5
      gameOver = false
      holdPiece = nil
      spawnTetromino()
      return
  end

  if gameOver or paused then return end

  if key == "left" then
      tetrominoX = tetrominoX - 1
      if checkCollision() then
          tetrominoX = tetrominoX + 1
      end
  elseif key == "right" then
      tetrominoX = tetrominoX + 1
      if checkCollision() then
          tetrominoX = tetrominoX - 1
      end
  elseif key == "down" then
      tetrominoY = tetrominoY + 1
      if checkCollision() then
          tetrominoY = tetrominoY - 1
          placeTetromino()
          clearRows()
          spawnTetromino()
          if checkCollision() then
              gameOver = true
          end
      end
  elseif key == "up" or key == "x" then
      rotateTetromino()
  elseif key == "z" then
      -- Counter-clockwise rotation
      for _ = 1, 3 do
          rotateTetromino()
      end
  elseif key == "space" then
      -- Hard drop
      local dropDistance = 0
      while not checkCollision() do
          tetrominoY = tetrominoY + 1
          dropDistance = dropDistance + 1
      end
      tetrominoY = tetrominoY - 1
      score = score + dropDistance  -- Bonus points for hard drop
      placeTetromino()
      clearRows()
      spawnTetromino()
      if checkCollision() then
          gameOver = true
      end
  elseif key == "c" or key == "lshift" then
      -- Hold piece
      holdCurrentPiece()
  elseif key == "g" then
      -- Toggle ghost piece
      ghostPieceEnabled = not ghostPieceEnabled
  end
end

-- update function
function love.update(dt)
  -- Update screen shake
  if shake.duration > 0 then
      shake.duration = shake.duration - dt
      if shake.duration <= 0 then
          shake.amount = 0
      end
  end

  -- Update particle systems
  for i = #particles, 1, -1 do
      local particle = particles[i]
      particle.system:update(dt)
      particle.timeLeft = particle.timeLeft - dt
      if particle.timeLeft <= 0 then
          table.remove(particles, i)
      end
  end

  if gameOver or paused then return end

  -- Handle continuous key press for smooth movement
  if love.keyboard.isDown('left') then
      local moveTimer = (moveTimer or 0) + dt
      if moveTimer >= 0.1 then  -- Adjust for movement speed
          tetrominoX = tetrominoX - 1
          if checkCollision() then
              tetrominoX = tetrominoX + 1
          end
          moveTimer = 0
      end
  end

  if love.keyboard.isDown('right') then
      local moveTimer = (moveTimer or 0) + dt
      if moveTimer >= 0.1 then
          tetrominoX = tetrominoX + 1
          if checkCollision() then
              tetrominoX = tetrominoX - 1
          end
          moveTimer = 0
      end
  end

  -- Soft drop (faster drop while holding down)
  local currentDropSpeed = love.keyboard.isDown('down') and dropSpeed / 4 or dropSpeed

  dropTimer = dropTimer + dt
  if dropTimer >= currentDropSpeed then
      tetrominoY = tetrominoY + 1
      if checkCollision() then
          tetrominoY = tetrominoY - 1
          placeTetromino()
          clearRows()
          spawnTetromino()
          if checkCollision() then
              gameOver = true
          end
      end
      dropTimer = 0
  end
end

-- main drawing function
function love.draw()
  -- Apply screen shake
  if shake.amount > 0 then
      love.graphics.push()
      love.graphics.translate(
          shake.amount * (math.random() - 0.5),
          shake.amount * (math.random() - 0.5)
      )
  end

  drawGrid()
  drawGhostPiece()
  drawTetromino()
  drawUI()

  -- Draw particle systems
  for _, particle in ipairs(particles) do
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(particle.system)
  end

  if shake.amount > 0 then
      love.graphics.pop()
  end

  if gameOver then
      -- Draw semi-transparent overlay
      love.graphics.setColor(0, 0, 0, 0.7)
      love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

      -- Draw game over text with glow effect
      love.graphics.setColor(1, 0, 0)
      love.graphics.setFont(love.graphics.newFont(40))
      local gameOverText = "GAME OVER"
      local textW = love.graphics.getFont():getWidth(gameOverText)
      local textH = love.graphics.getFont():getHeight()
      local centerX = gridWidth * cellSize / 2
      local centerY = gridHeight * cellSize / 2

      -- Draw glow
      for i = 5, 1, -1 do
          love.graphics.setColor(1, 0, 0, 0.2)
          love.graphics.printf(gameOverText, centerX - textW/2 - i, centerY - textH/2, textW * 2, "center")
      end

      -- Draw main text
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(gameOverText, centerX - textW/2, centerY - textH/2, textW * 2, "center")

      -- Draw restart instruction
      love.graphics.setFont(love.graphics.newFont(20))
      love.graphics.printf("Press 'R' to restart", centerX - textW/2, centerY + textH, textW * 2, "center")
  end

  if paused then
      -- Draw semi-transparent overlay
      love.graphics.setColor(0, 0, 0, 0.7)
      love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

      -- Draw pause text
      love.graphics.setColor(1, 1, 1)
      love.graphics.setFont(love.graphics.newFont(40))
      love.graphics.printf("PAUSED", 0, gridHeight * cellSize / 2, gridWidth * cellSize, "center")
  end
end

-- Initialize the game
function love.load()
  -- Set up window
  love.window.setMode(gridWidth * cellSize + 200, gridHeight * cellSize)
  love.window.setTitle("Tetris")

  -- Initialize random seed
  math.randomseed(os.time())

  -- Create initial game state
  createGrid()
  spawnTetromino()
end