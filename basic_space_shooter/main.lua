-- Constants
local WINDOW_WIDTH = 1200
local WINDOW_HEIGHT = 800
local PLAYER_WIDTH = 80
local PLAYER_HEIGHT = 40
local BULLET_WIDTH = 10
local BULLET_HEIGHT = 20
local ENEMY_WIDTH = 80
local ENEMY_HEIGHT = 40
local PLAYER_SPEED = 300
local BULLET_SPEED = 500
local ENEMY_SPEED_BASE = 150
local ENEMY_SPAWN_INTERVAL = 1
local HEART_WIDTH = 40
local HEART_HEIGHT = 40

-- Game state
local playerX = 0
local playerY = 0
local bullets = {}
local enemies = {}
local gameOver = false
local score = 0
local highestScore = 0
local enemySpawnTimer = 0
local enemySpeed = ENEMY_SPEED_BASE
local lives = 3
local totalEnemies = 3
local enemySpawnRate = 1.5  -- Interval to spawn new enemies

-- Load resources and initialize game state
function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = false,
        vsync = true,
        fullscreen = false
    })
    love.window.setTitle("Space Shooter")

    -- Load images
    playerImg = love.graphics.newImage("assets/player.png")
    bulletImg = love.graphics.newImage("assets/bullet.png")
    enemyImg = love.graphics.newImage("assets/enemy.png")
    heartImg = love.graphics.newImage("assets/heart.png")

    -- Scale images automatically based on the target dimensions
    playerImg:setFilter("linear", "linear")
    bulletImg:setFilter("linear", "linear")
    enemyImg:setFilter("linear", "linear")
    heartImg:setFilter("linear", "linear")
    
    -- Initialize player position
    playerX = (WINDOW_WIDTH - PLAYER_WIDTH) / 2
    playerY = WINDOW_HEIGHT - PLAYER_HEIGHT - 10

    -- Spawn initial set of enemies
    for i = 1, totalEnemies do
        spawnEnemy()
    end
end

-- Spawn a single enemy at a random position at the top of the screen
function spawnEnemy()
    local enemyX = love.math.random(0, WINDOW_WIDTH - ENEMY_WIDTH)
    table.insert(enemies, {x = enemyX, y = -ENEMY_HEIGHT})
end

-- Update game state
function love.update(dt)
    if gameOver then return end

    -- Player movement
    if love.keyboard.isDown("left") then
        playerX = math.max(0, playerX - PLAYER_SPEED * dt)
    elseif love.keyboard.isDown("right") then
        playerX = math.min(WINDOW_WIDTH - PLAYER_WIDTH, playerX + PLAYER_SPEED * dt)
    end

    -- Update bullets
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.y = bullet.y - BULLET_SPEED * dt
        if bullet.y < 0 then
            table.remove(bullets, i)
        end
    end

    -- Spawn enemies at regular intervals and increase the number over time
    enemySpawnTimer = enemySpawnTimer + dt
    if enemySpawnTimer >= ENEMY_SPAWN_INTERVAL then
        spawnEnemy()
        enemySpawnTimer = 0
        -- Gradually increase the number of enemies
        totalEnemies = totalEnemies + 1
    end

    -- Update enemies
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.y = enemy.y + enemySpeed * dt
        if enemy.y > WINDOW_HEIGHT then
            lives = lives - 1
            table.remove(enemies, i)
            if lives <= 0 then
                gameOver = true
            end
        end
    end

    -- Gradually increase enemy speed over time
    enemySpeed = ENEMY_SPEED_BASE + (score / 100) * 50

    -- Check for collisions
    checkCollisions()
end

-- Check for bullet-enemy collisions
function checkCollisions()
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        for j = #enemies, 1, -1 do
            local enemy = enemies[j]
            if bullet.x < enemy.x + ENEMY_WIDTH and
               bullet.x + BULLET_WIDTH > enemy.x and
               bullet.y < enemy.y + ENEMY_HEIGHT and
               bullet.y + BULLET_HEIGHT > enemy.y then
                table.remove(bullets, i)
                table.remove(enemies, j)
                score = score + 1
                if score > highestScore then
                    highestScore = score
                end
                break
            end
        end
    end
end

-- Draw game objects
function love.draw()
    if gameOver then
        love.graphics.printf("Game Over", 0, WINDOW_HEIGHT / 2 - 30, WINDOW_WIDTH, "center")
        love.graphics.printf("Score: " .. score, 0, WINDOW_HEIGHT / 2, WINDOW_WIDTH, "center")
        love.graphics.printf("Highest Score: " .. highestScore, 0, WINDOW_HEIGHT / 2 + 30, WINDOW_WIDTH, "center")

        -- Draw Play Again Button
        local buttonWidth = 200
        local buttonHeight = 50
        local buttonX = (WINDOW_WIDTH - buttonWidth) / 2
        local buttonY = WINDOW_HEIGHT / 2 + 80
        love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight)
        love.graphics.printf("Play Again", buttonX, buttonY + 15, buttonWidth, "center")
        
        return
    end

    -- Calculate scale factor for the player
    local playerScaleX = PLAYER_WIDTH / playerImg:getWidth()
    local playerScaleY = PLAYER_HEIGHT / playerImg:getHeight()
    love.graphics.draw(playerImg, playerX, playerY, 0, playerScaleX, playerScaleY)

    -- Draw bullets with scaling
    for _, bullet in ipairs(bullets) do
        local bulletScaleX = BULLET_WIDTH / bulletImg:getWidth()
        local bulletScaleY = BULLET_HEIGHT / bulletImg:getHeight()
        love.graphics.draw(bulletImg, bullet.x, bullet.y, 0, bulletScaleX, bulletScaleY)
    end

    -- Draw enemies with scaling
    for _, enemy in ipairs(enemies) do
        local enemyScaleX = ENEMY_WIDTH / enemyImg:getWidth()
        local enemyScaleY = ENEMY_HEIGHT / enemyImg:getHeight()
        love.graphics.draw(enemyImg, enemy.x, enemy.y, 0, enemyScaleX, enemyScaleY)
    end

    -- Draw score
    love.graphics.print("Score: " .. score, 10, 10)

    -- Draw lives as scaled hearts
    for i = 1, lives do
        local heartScaleX = HEART_WIDTH / heartImg:getWidth()
        local heartScaleY = HEART_HEIGHT / heartImg:getHeight()
        love.graphics.draw(heartImg, 10 + (i - 1) * (HEART_WIDTH + 10), 30, 0, heartScaleX, heartScaleY)
    end
end

-- Handle key presses
function love.keypressed(key)
    if key == "space" and not gameOver then
        fireBullet()
    elseif key == "escape" then
        love.event.quit()
    end
end

-- Fire 3 bullets at once from the player
function fireBullet()
    local offset = 25  -- Spacing between bullets
    table.insert(bullets, {x = playerX + PLAYER_WIDTH / 2 - BULLET_WIDTH / 2 - offset, y = playerY})
    table.insert(bullets, {x = playerX + PLAYER_WIDTH / 2 - BULLET_WIDTH / 2, y = playerY})
    table.insert(bullets, {x = playerX + PLAYER_WIDTH / 2 - BULLET_WIDTH / 2 + offset, y = playerY})
end

-- Handle mouse presses for "Play Again" button
function love.mousepressed(x, y, button, istouch, presses)
    if gameOver then
        local buttonWidth = 200
        local buttonHeight = 50
        local buttonX = (WINDOW_WIDTH - buttonWidth) / 2
        local buttonY = WINDOW_HEIGHT / 2 + 80
        
        if x >= buttonX and x <= buttonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
            -- Reset the game
            gameOver = false
            score = 0
            lives = 3
            bullets = {}
            enemies = {}
            totalEnemies = 3
            enemySpeed = ENEMY_SPEED_BASE
            playerX = (WINDOW_WIDTH - PLAYER_WIDTH) / 2
            playerY = WINDOW_HEIGHT - PLAYER_HEIGHT - 10
        end
    end
end