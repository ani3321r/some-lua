function love.load()
  -- Initialize random seed
  love.math.setRandomSeed(love.timer.getTime())
  
  -- Window settings
  love.window.setMode(800, 600, {
      vsync = true,
      resizable = false
  })
  
  -- Game state
  gameState = "start"
  score = 0
  lives = 3
  comboCount = 0
  comboTimer = 0
  
  -- Colors
  colors = {
      background = {0.1, 0.1, 0.15},
      paddle = {0.9, 0.9, 1},
      ball = {1, 1, 1},
      particles = {1, 1, 1, 0.8}
  }
  
  -- Paddle properties
  paddle = {
      width = 100,
      height = 20,
      x = 0,
      y = 550,
      speed = 600,
      targetX = 0,
      dampening = 0.8,
      originalWidth = 100,
      lasersEnabled = false,
      lasers = {}
  }
  
  -- Ball properties
  ball = {
      x = 0,
      y = 0,
      size = 8,
      baseSpeed = 300,
      speed = 300,
      dx = 0,
      dy = 0,
      trail = {},
      maxTrail = 10,
      stuck = true
  }
  
  -- Particle systems
  particles = {
      brick = love.graphics.newParticleSystem(createDotCanvas(), 100),
      trail = love.graphics.newParticleSystem(createDotCanvas(), 100)
  }
  
  setupParticleSystems()
  
  -- Brick properties
  brickRows = 5
  brickColumns = 8
  bricks = {}
  brickColors = {
      {1, 0.2, 0.2},    -- Red
      {1, 0.6, 0.2},    -- Orange
      {1, 1, 0.2},      -- Yellow
      {0.2, 1, 0.2},    -- Green
      {0.2, 0.6, 1}     -- Blue
  }
  
  -- Screen shake effect
  shake = {
      duration = 0,
      intensity = 0
  }
  
  -- Power-up types
  powerUps = {
      types = {
          {name = "wide", color = {0.4, 1, 0.4}, duration = 10},
          {name = "multiball", color = {1, 0.4, 1}},
          {name = "laser", color = {1, 0.4, 0.4}, duration = 8},
          {name = "slow", color = {0.4, 0.4, 1}, duration = 6}
      },
      active = {},
      falling = {}
  }
  
  -- Special brick types
  brickTypes = {
      normal = {strength = 1},
      metal = {strength = 3, color = {0.7, 0.7, 0.7}},
      explosive = {strength = 1, color = {1, 0.4, 0}, explosive = true},
      power = {strength = 1, color = {1, 1, 1}, powerUp = true}
  }
  
  -- Level system
  currentLevel = 1
  maxLevel = 5
  
  -- High scores
  highScores = loadHighScores()
  
  -- Multiple balls support
  balls = {ball}
  
  -- Initialize the game
  resetGame()
end

function createDotCanvas()
  local canvas = love.graphics.newCanvas(4, 4)
  love.graphics.setCanvas(canvas)
      love.graphics.clear()
      love.graphics.setColor(1, 1, 1)
      love.graphics.circle('fill', 2, 2, 2)
  love.graphics.setCanvas()
  return canvas
end

function setupParticleSystems()
  particles.brick:setParticleLifetime(0.3, 0.6)
  particles.brick:setLinearAcceleration(-100, -100, 100, 100)
  particles.brick:setColors(1, 1, 1, 1, 1, 1, 1, 0)
  particles.brick:setSizes(2, 0.5)
  
  particles.trail:setParticleLifetime(0.1, 0.2)
  particles.trail:setLinearAcceleration(-50, -50, 50, 50)
  particles.trail:setColors(1, 1, 1, 0.6, 1, 1, 1, 0)
  particles.trail:setSizes(1, 0.1)
end

function resetGame()
  paddle.x = love.graphics.getWidth()/2 - paddle.width/2
  paddle.targetX = paddle.x
  
  -- Reset all balls
  balls = {}
  resetBall()
  
  -- Reset power-ups
  powerUps.active = {}
  powerUps.falling = {}
  
  -- Reset paddle properties
  paddle.width = paddle.originalWidth
  paddle.lasersEnabled = false
  paddle.lasers = {}
  
  -- Load current level
  loadLevel(currentLevel)
end

function resetBall()
    local newBall = {
        x = paddle.x + paddle.width/2,
        y = paddle.y - ball.size,
        size = ball.size,
        speed = ball.baseSpeed,
        baseSpeed = ball.baseSpeed,
        dx = 0,
        dy = 0,
        trail = {},
        maxTrail = ball.maxTrail,
        stuck = true
    }
    balls = {newBall}  -- Replace all balls with a single new ball
    
    -- Reset paddle position
    paddle.x = love.graphics.getWidth() / 2 - paddle.width / 2
    paddle.targetX = paddle.x
end

function loadLevel(level)
  bricks = {}
  local brickWidth = (love.graphics.getWidth() - 40) / brickColumns
  local brickHeight = 25
  
  -- Different patterns for each level
  local patterns = {
      -- Level 1: Basic pattern
      function()
          for row = 1, brickRows do
              for col = 1, brickColumns do
                  createBrick(row, col, brickWidth, brickHeight, "normal")
              end
          end
      end,
      -- Level 2: Checker pattern with metal bricks
      function()
          for row = 1, brickRows do
              for col = 1, brickColumns do
                  if (row + col) % 2 == 0 then
                      createBrick(row, col, brickWidth, brickHeight, "metal")
                  else
                      createBrick(row, col, brickWidth, brickHeight, "normal")
                  end
              end
          end
      end,
      -- Level 3: Explosive bricks
      function()
          for row = 1, brickRows do
              for col = 1, brickColumns do
                  local type = love.math.random() < 0.2 and "explosive" or "normal"
                  createBrick(row, col, brickWidth, brickHeight, type)
              end
          end
      end,
      -- Level 4: Power-up focused
      function()
          for row = 1, brickRows do
              for col = 1, brickColumns do
                  local type = love.math.random() < 0.3 and "power" or "normal"
                  createBrick(row, col, brickWidth, brickHeight, type)
              end
          end
      end,
      -- Level 5: Mix of everything
      function()
          for row = 1, brickRows do
              for col = 1, brickColumns do
                  local r = love.math.random()
                  local type = "normal"
                  if r < 0.2 then type = "metal"
                  elseif r < 0.4 then type = "explosive"
                  elseif r < 0.6 then type = "power"
                  end
                  createBrick(row, col, brickWidth, brickHeight, type)
              end
          end
      end
  }
  
  if patterns[level] then
      patterns[level]()
  else
      -- Fallback pattern if level doesn't exist
      patterns[1]()
  end
end

function createBrick(row, col, width, height, type)
  local brickType = brickTypes[type]
  local brick = {
      x = 20 + (col-1) * width,
      y = 50 + row * (height + 5),
      width = width - 4,
      height = height,
      color = brickType.color or brickColors[row],
      alive = true,
      health = brickType.strength,
      type = type,
      scale = 1,
      opacity = 1
  }
  table.insert(bricks, brick)
end

function love.update(dt)
  if gameState == "playing" then
      -- Update particle systems
      particles.brick:update(dt)
      particles.trail:update(dt)
      
      -- Update screen shake
      if shake.duration > 0 then
          shake.duration = shake.duration - dt
      end
      
      updatePaddle(dt)
      updatePowerUps(dt)
      updateLasers(dt)
      
      -- Update all balls
      for i = #balls, 1, -1 do
          updateBall(balls[i], dt)
      end
      
      -- Check if all balls are lost
      if #balls == 0 then
          lives = lives - 1
          if lives <= 0 then
              gameState = "gameover"
              checkHighScore(score)
          else
              resetBall()
          end
      end
      
      updateBricks(dt)
      updateCombo(dt)
      
      -- Check for level completion
      if checkLevelComplete() then
          if currentLevel < maxLevel then
              currentLevel = currentLevel + 1
              loadLevel(currentLevel)
              resetBall()
          else
              gameState = "victory"
              checkHighScore(score)
          end
      end
  end
end

function updatePaddle(dt)
  -- Mouse control for smooth movement
  local mouseX = love.mouse.getX()
  paddle.targetX = mouseX - paddle.width/2
  
  -- Keyboard control
  if love.keyboard.isDown('left') then
      paddle.targetX = paddle.targetX - paddle.speed * dt
  end
  if love.keyboard.isDown('right') then
      paddle.targetX = paddle.targetX + paddle.speed * dt
  end
  
  -- Smooth movement
  local dx = paddle.targetX - paddle.x
  paddle.x = paddle.x + dx * paddle.dampening
  
  -- Clamp paddle position
  paddle.x = math.max(0, math.min(love.graphics.getWidth() - paddle.width, paddle.x))
  
  -- Update stuck balls
  for _, b in ipairs(balls) do
      if b.stuck then
          b.x = paddle.x + paddle.width/2 - b.size/2
          b.y = paddle.y - b.size
      end
  end
end

function updateBall(ball, dt)
    if not ball.stuck then
        -- Update ball position
        local nextX = ball.x + ball.dx * dt
        local nextY = ball.y + ball.dy * dt
        
        -- Store trail
        table.insert(ball.trail, 1, {x = ball.x, y = ball.y})
        if #ball.trail > ball.maxTrail then
            table.remove(ball.trail)
        end
        
        -- Emit trail particles
        particles.trail:setPosition(ball.x, ball.y)
        particles.trail:emit(1)
        
        -- Update position
        ball.x = nextX
        ball.y = nextY
        
        -- Wall collisions
        if ball.x <= 0 then
            ball.x = 0
            ball.dx = math.abs(ball.dx)
            addScreenShake(0.1, 3)
        elseif ball.x + ball.size >= love.graphics.getWidth() then
            ball.x = love.graphics.getWidth() - ball.size
            ball.dx = -math.abs(ball.dx)
            addScreenShake(0.1, 3)
        end
        
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = math.abs(ball.dy)
            addScreenShake(0.1, 3)
        end
        
        -- Paddle collision
        if checkCollision(ball, paddle) then
            ball.y = paddle.y - ball.size
            local hitX = (ball.x + ball.size/2) - (paddle.x + paddle.width/2)
            local normalizedHitX = hitX / (paddle.width/2)
            local angle = normalizedHitX * math.pi/3
            
            ball.dx = math.sin(angle) * ball.speed
            ball.dy = -math.cos(angle) * ball.speed
            
            addScreenShake(0.1, 2)
        end
        
        -- Bottom screen collision (lose ball)
        if ball.y > love.graphics.getHeight() then
            table.remove(balls, 1)  -- Remove the lost ball
            if #balls == 0 then     -- If no balls remain
                lives = lives - 1    -- Decrease lives
                if lives <= 0 then
                    gameState = "gameover"
                    checkHighScore(score)
                else
                    resetBall()
                    ball.stuck = true -- Make sure the new ball starts stuck to paddle
                end
            end
            return true
        end
    end
    return false
end

function updateBricks(dt)
  for _, brick in ipairs(bricks) do
      if brick.alive then
          -- Animate brick scale
          if brick.scale > 1 then
              brick.scale = brick.scale - dt * 5
              if brick.scale < 1 then brick.scale = 1 end
          end
          
          -- Animate brick fade out
          if brick.health <= 0 then
              brick.opacity = brick.opacity - dt * 5
              if brick.opacity <= 0 then
                  brick.alive = false
                  if brick.type == "power" then
                      spawnPowerUp(brick.x + brick.width/2, brick.y + brick.height/2)
                  end
              end
          end
          
          -- Check collision with all balls
          for _, currentBall in ipairs(balls) do
              if brick.opacity > 0 and checkCollision(currentBall, brick) then
                  -- Decrease brick health
                  brick.health = brick.health - 1
                  brick.scale = 1.3
                  
                  -- Bounce the ball
                  local brickCenterX = brick.x + brick.width/2
                  local brickCenterY = brick.y + brick.height/2
                  local ballCenterX = currentBall.x + currentBall.size/2
                  local ballCenterY = currentBall.y + currentBall.size/2
                  
                  local dx = ballCenterX - brickCenterX
                  local dy = ballCenterY - brickCenterY
                  
                  if math.abs(dx) > math.abs(dy) then
                      currentBall.dx = currentBall.dx * -1
                  else
                      currentBall.dy = currentBall.dy * -1
                  end
                  
                  -- Particle effect
                  particles.brick:setPosition(ballCenterX, ballCenterY)
                  particles.brick:setColors(brick.color[1], brick.color[2], brick.color[3], 1,
                                         brick.color[1], brick.color[2], brick.color[3], 0)
                  particles.brick:emit(10)
                  
                  -- Update score and combo
                  updateScore(brick)

                  -- Screen shake
                  addScreenShake(0.1, 3)
                    
                  -- Slightly increase ball speed
                  currentBall.speed = math.min(currentBall.speed * 1.01, currentBall.baseSpeed * 1.5)
                  
                  -- Handle explosive bricks
                  if brick.type == "explosive" then
                      triggerExplosion(brick)
                  end
              end
          end
      end
  end
end

function triggerExplosion(brick)
  local radius = 100  -- Explosion radius
  for _, otherBrick in ipairs(bricks) do
      if otherBrick.alive and otherBrick ~= brick then
          local dx = (otherBrick.x + otherBrick.width/2) - (brick.x + brick.width/2)
          local dy = (otherBrick.y + otherBrick.height/2) - (brick.y + brick.height/2)
          local distance = math.sqrt(dx * dx + dy * dy)
          
          if distance < radius then
              otherBrick.health = otherBrick.health - 1
              otherBrick.scale = 1.3
          end
      end
  end
end

function updateCombo(dt)
  if comboCount > 0 then
      comboTimer = comboTimer - dt
      if comboTimer <= 0 then
          comboCount = 0
      end
  end
end

function updateScore(brick)
  local basePoints = 10
  comboCount = comboCount + 1
  comboTimer = 1.0
  score = score + basePoints * comboCount
end

function updatePowerUps(dt)
  -- Update falling power-ups
  for i = #powerUps.falling, 1, -1 do
      local p = powerUps.falling[i]
      p.y = p.y + 100 * dt  -- Fall speed
      
      -- Check collision with paddle
      if checkCollision(p, paddle) then
          activatePowerUp(p.type)
          table.remove(powerUps.falling, i)
      elseif p.y > love.graphics.getHeight() then
          table.remove(powerUps.falling, i)
      end
  end
  
  -- Update active power-ups
  for i = #powerUps.active, 1, -1 do
      local p = powerUps.active[i]
      if p.duration then
          p.timeLeft = p.timeLeft - dt
          if p.timeLeft <= 0 then
              deactivatePowerUp(p.type)
              table.remove(powerUps.active, i)
          end
      end
  end
end

function updateLasers(dt)
  if paddle.lasersEnabled then
      -- Update existing lasers
      for i = #paddle.lasers, 1, -1 do
          local laser = paddle.lasers[i]
          laser.y = laser.y + laser.dy * dt
          
          -- Check brick collisions
          local hitBrick = false
          for _, brick in ipairs(bricks) do
              if brick.alive and checkCollision(laser, brick) then
                  brick.health = brick.health - 1
                  brick.scale = 1.3
                  hitBrick = true
                  break
              end
          end
          
          -- Remove laser if it hits something or goes off screen
          if hitBrick or laser.y < 0 then
              table.remove(paddle.lasers, i)
          end
      end
      
      -- Shoot new lasers
      if love.keyboard.isDown('space') then
          local laserSpeed = -500  -- Negative because moving upward
          table.insert(paddle.lasers, {
              x = paddle.x,
              y = paddle.y,
              width = 2,
              height = 10,
              dy = laserSpeed
          })
          table.insert(paddle.lasers, {
              x = paddle.x + paddle.width - 2,
              y = paddle.y,
              width = 2,
              height = 10,
              dy = laserSpeed
          })
      end
  end
end

function activatePowerUp(powerType)
  if powerType.name == "wide" then
      paddle.width = paddle.originalWidth * 2
  elseif powerType.name == "multiball" then
      spawnMultipleBalls()
  elseif powerType.name == "laser" then
      paddle.lasersEnabled = true
  elseif powerType.name == "slow" then
      for _, b in ipairs(balls) do
          b.speed = b.baseSpeed * 0.5
      end
  end
  
  if powerType.duration then
      table.insert(powerUps.active, {
          type = powerType,
          timeLeft = powerType.duration
      })
  end
end

function deactivatePowerUp(powerType)
  if powerType.name == "wide" then
      paddle.width = paddle.originalWidth
  elseif powerType.name == "laser" then
      paddle.lasersEnabled = false
      paddle.lasers = {}
  elseif powerType.name == "slow" then
      for _, b in ipairs(balls) do
          b.speed = b.baseSpeed
      end
  end
end

function spawnMultipleBalls()
  local numNewBalls = 2
  local baseBall = balls[1]
  for i = 1, numNewBalls do
      local angle = math.pi * 2 * i / numNewBalls
      local newBall = {
          x = baseBall.x,
          y = baseBall.y,
          size = baseBall.size,
          speed = baseBall.speed,
          baseSpeed = baseBall.baseSpeed, 
          dx = baseBall.speed * math.cos(angle),
          dy = -baseBall.speed * math.sin(angle),
          trail = {},
          maxTrail = baseBall.maxTrail,
          stuck = false
      }
      table.insert(balls, newBall)
  end
end

function checkLevelComplete()
  for _, brick in ipairs(bricks) do
      if brick.alive and brick.type ~= "metal" then
          return false
      end
  end
  return true
end

function addScreenShake(duration, intensity)
  shake.duration = duration
  shake.intensity = intensity
end

function checkCollision(a, b)
  return a.x < b.x + b.width and
         a.x + (a.size or a.width) > b.x and
         a.y < b.y + b.height and
         a.y + (a.size or a.height) > b.y
end

function loadHighScores()
  local scores = {}
  local success, err = pcall(function()
      if love.filesystem.getInfo("highscores.txt") then
          for line in love.filesystem.lines("highscores.txt") do
              table.insert(scores, tonumber(line) or 0)
          end
      end
  end)
  
  if not success then
      print("Error loading high scores: " .. tostring(err))
  end
  
  -- Ensure we always have 5 scores
  while #scores < 5 do
      table.insert(scores, 0)
  end
  table.sort(scores, function(a, b) return a > b end)
  return scores
end

function saveHighScores()
  local success, err = pcall(function()
      local data = ""
      for _, score in ipairs(highScores) do
          data = data .. tostring(score) .. "\n"
      end
      love.filesystem.write("highscores.txt", data)
  end)
  
  if not success then
      print("Error saving high scores: " .. tostring(err))
  end
end

function checkHighScore(score)
  for i, highScore in ipairs(highScores) do
      if score > highScore then
          -- Shift down all lower scores
          for j = #highScores, i + 1, -1 do
              highScores[j] = highScores[j-1]
          end
          highScores[i] = score
          saveHighScores()
          break
      end
  end
end

function love.draw()
    if gameState.isGameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Game Over!", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
        love.graphics.printf("Press R to restart", 0, love.graphics.getHeight() / 2 + 20, love.graphics.getWidth(), "center")
    else
        -- Apply screen shake
        love.graphics.push()
        if shake.duration > 0 then
            local dx = love.math.random(-shake.intensity, shake.intensity)
            local dy = love.math.random(-shake.intensity, shake.intensity)
            love.graphics.translate(dx, dy)
        end
        
        -- Draw background
        love.graphics.setColor(colors.background)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        -- Draw game elements
        drawBricks()
        drawPaddle()
        drawBalls()
        drawPowerUps()
        drawParticles()
        drawUI()
        
        love.graphics.pop()
    end    
end

function drawBricks()
  for _, brick in ipairs(bricks) do
      if brick.alive and brick.opacity > 0 then
          -- Draw brick shadow
          love.graphics.setColor(0, 0, 0, 0.2 * brick.opacity)
          love.graphics.rectangle('fill', 
              brick.x + 2, 
              brick.y + 2, 
              brick.width * brick.scale, 
              brick.height * brick.scale)
          
          -- Draw brick
          love.graphics.setColor(brick.color[1], brick.color[2], brick.color[3], brick.opacity)
          love.graphics.rectangle('fill',
              brick.x + (brick.width * (1 - brick.scale))/2,
              brick.y + (brick.height * (1 - brick.scale))/2,
              brick.width * brick.scale,
              brick.height * brick.scale)
      end
  end
end

function drawPaddle()
  -- Draw paddle shadow
  love.graphics.setColor(0, 0, 0, 0.2)
  love.graphics.rectangle('fill', paddle.x + 2, paddle.y + 2, paddle.width, paddle.height)
  
  -- Draw paddle
  love.graphics.setColor(colors.paddle)
  love.graphics.rectangle('fill', paddle.x, paddle.y, paddle.width, paddle.height)
  
  -- Draw lasers
  if paddle.lasersEnabled then
      love.graphics.setColor(1, 0, 0)
      for _, laser in ipairs(paddle.lasers) do
          love.graphics.rectangle('fill', laser.x, laser.y, laser.width, laser.height)
      end
  end
end

function drawBalls()
  for _, ball in ipairs(balls) do
      -- Draw ball trail
      for i, pos in ipairs(ball.trail) do
          local alpha = (1 - i/ball.maxTrail) * 0.3
          love.graphics.setColor(1, 1, 1, alpha)
          love.graphics.circle('fill', pos.x + ball.size/2, pos.y + ball.size/2, ball.size/2)
      end
      
      -- Draw ball
      love.graphics.setColor(colors.ball)
      love.graphics.circle('fill', ball.x + ball.size/2, ball.y + ball.size/2, ball.size/2)
  end
end

function drawPowerUps()
  -- Draw falling power-ups
  for _, p in ipairs(powerUps.falling) do
      love.graphics.setColor(p.type.color)
      love.graphics.rectangle('fill', p.x, p.y, p.width, p.height)
  end
  
  -- Draw active power-up indicators
  local y = 30
  for _, p in ipairs(powerUps.active) do
      love.graphics.setColor(p.type.color)
      love.graphics.print(p.type.name .. ": " .. string.format("%.1f", p.timeLeft), 10, y)
      y = y + 20
  end
end

function drawParticles()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(particles.brick)
  love.graphics.draw(particles.trail)
end

function drawUI()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Score: " .. score, 10, 10)
  love.graphics.print("Lives: " .. lives, love.graphics.getWidth() - 80, 10)
  love.graphics.print("Level: " .. currentLevel, love.graphics.getWidth() - 80, 30)
  
  if comboCount > 1 then
      love.graphics.setColor(1, 1, 1, comboTimer)
      love.graphics.printf(comboCount .. "x Combo!", 0, 50, love.graphics.getWidth(), 'center')
  end
  
  -- Draw game state messages
  if gameState == "start" then
      love.graphics.printf(
          "Click or press Space to start!",
          0, love.graphics.getHeight()/2, love.graphics.getWidth(), 'center'
      )
  elseif gameState == "gameover" then
      love.graphics.printf(
          "Game Over!\nFinal Score: " .. score .. "\n\nHigh Scores:\n" ..
          table.concat(highScores, "\n") .. "\n\nPress Space to restart",
          0, love.graphics.getHeight()/3, love.graphics.getWidth(), 'center'
      )
  elseif gameState == "victory" then
      love.graphics.printf(
          "Victory!\nFinal Score: " .. score .. "\n\nPress Space to play again",
          0, love.graphics.getHeight()/3, love.graphics.getWidth(), 'center'
      )
  end
end

function love.keypressed(key)
  if key == 'escape' then
      love.event.quit()
  elseif key == 'space' then
      if gameState == "start" then
          gameState = "playing"
          launchBall()
      elseif gameState == "playing" then
          for _, ball in ipairs(balls) do
              if ball.stuck then
                  launchBall()
                  break
              end
          end
      elseif gameState == "gameover" or gameState == "victory" then
          gameState = "start"
          currentLevel = 1
          score = 0
          lives = 3
          resetGame()
      end
  end

  if key == 'r' and gameState.isGameOver then
    -- Reset game state
    gameState.lives = 3
    gameState.isGameOver = false
    resetBall()
    -- Reset bricks and other game elements
    initializeBricks()
    paddle.width = 100 -- Reset paddle size
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
      if gameState == "playing" then
          for _, ball in ipairs(balls) do
              if ball.stuck then
                  launchBall()
                  break
              end
          end
      elseif gameState == "start" then
          gameState = "playing"
          launchBall()
      end
  end
end

function launchBall()
    for _, ball in ipairs(balls) do
        if ball.stuck then
            ball.stuck = false
            local angle = math.rad(love.math.random(-60, 60))
            ball.dx = math.sin(angle) * ball.speed
            ball.dy = -math.cos(angle) * ball.speed
        end
    end
end

function spawnPowerUp(x, y)
  if love.math.random() < 0.2 then  -- 20% chance to spawn
    local powerType = powerUps.types[love.math.random(#powerUps.types)]
    table.insert(powerUps.falling, {
      x = x,
      y = y,
      type = powerType,
      width = 20,
      height = 20,
      speed = 100
    })
  end
end

function updatePowerUps(dt)
    for i = #powerUps.falling, 1, -1 do
        local powerUp = powerUps.falling[i]
        powerUp.y = powerUp.y + powerUp.speed * dt

        -- Check collision with paddle
        if checkCollision(powerUp, paddle) then
            applyPowerUp(powerUp.type)
            table.remove(powerUps.falling, i)
        -- Remove if off screen
        elseif powerUp.y > love.graphics.getHeight() then
            table.remove(powerUps.falling, i)
        end
    end
end

function applyPowerUp(powerType)
    if powerType == "extraBall" then
        spawnExtraBall()
    elseif powerType == "expandPaddle" then
        paddle.width = paddle.width * 1.5
    elseif powerType == "shrinkPaddle" then
        paddle.width = paddle.width * 0.75
    end
end

function drawPowerUps()
    for _, powerUp in ipairs(powerUps.falling) do
        love.graphics.setColor(1, 1, 0) -- Yellow color for power-ups
        love.graphics.rectangle("fill", powerUp.x, powerUp.y, powerUp.width, powerUp.height)
    end
end

function checkBallOffScreen()
    for i = #balls, 1, -1 do
        if balls[i].y > love.graphics.getHeight() then
            table.remove(balls, i)
            if #balls == 0 then
                gameState.lives = gameState.lives - 1
                if gameState.lives > 0 then
                    -- Reset ball and paddle
                    resetBall()
                else
                    gameState.isGameOver = true
                end
            end
        end
    end
end