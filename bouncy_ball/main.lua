-- Load libraries
local lg = love.graphics
local lp = love.physics

-- Define game world variables
local world
local ball
local platforms = {}
local goal
local level = 1
local maxLevels = 30
local bestScore = 0

-- Game state variables
local gameOver = false

-- Level configurations
local levelConfigs = {}
for i = 1, 30 do
    local gravity = math.min(500 + i * 50, 2000) -- Cap gravity at 2000
    local numPlatforms = 3 + math.floor(i / 3)
    local platforms = {}
    for j = 1, numPlatforms do
        local x = math.random(100, 700)
        local y = 600 - j * 50
        local width = math.random(100, 200)
        local height = 20
        table.insert(platforms, {x, y, width, height})
    end
    local goal = {math.random(600, 750), math.random(50, 150), 50, 50}
    levelConfigs[i] = {gravity = gravity, platforms = platforms, goal = goal}
end

-- Load resources and initialize the physics world
function love.load()
    love.window.setTitle("Bounce World")
    love.window.setMode(800, 600)
    loadLevel(level)
end

-- Load a specific level
function loadLevel(level)
    -- Reset the world to avoid physics artifacts
    if world then
        world:destroy()
    end

    local config = levelConfigs[level]

    -- Create physics world
    world = lp.newWorld(0, config.gravity, true)

    -- Create the ball
    ball = {
        body = lp.newBody(world, 400, 100, "dynamic"), -- Start safely in the center
        shape = lp.newCircleShape(15),
        fixture = nil
    }
    ball.fixture = lp.newFixture(ball.body, ball.shape, 1) -- Density = 1
    ball.fixture:setRestitution(0.7) -- Bounciness

    -- Create platforms
    platforms = {}
    for _, p in ipairs(config.platforms) do
        table.insert(platforms, createPlatform(p[1], p[2], p[3], p[4]))
    end

    -- Create the goal
    goal = {
        x = config.goal[1],
        y = config.goal[2],
        width = config.goal[3],
        height = config.goal[4]
    }
end

-- Update the physics world
function love.update(dt)
    if gameOver then
        return -- Stop updating the game when it's over
    end

    world:update(dt)

    -- Restart if the ball falls off the screen
    if ball.body:getY() > 600 or ball.body:getX() < 0 or ball.body:getX() > 800 then
        if level > bestScore then
            bestScore = level
        end
        showGameOverScreen()
        return -- Ensure no further updates are processed after game-over
    end

    -- Check if the ball reaches the goal
    if checkGoalCollision() then
        if level < maxLevels then
            level = level + 1
            loadLevel(level)
        else
            love.window.setTitle("You Win the Game!")
        end
    end
end

-- Draw game elements
function love.draw()
    if gameOver then
        drawGameOverScreen()
        return -- Skip drawing the rest of the game elements
    end

    -- Draw platforms
    lg.setColor(0.5, 0.5, 0.5)
    for _, platform in ipairs(platforms) do
        lg.polygon("fill", platform.body:getWorldPoints(platform.shape:getPoints()))
    end

    -- Draw ball
    lg.setColor(1, 1, 1)
    lg.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())

    -- Draw goal
    lg.setColor(0, 1, 0)
    lg.rectangle("fill", goal.x, goal.y, goal.width, goal.height)

    -- Draw level indicator
    lg.setColor(1, 1, 1)
    lg.print("Level: " .. level, 10, 10)
    lg.print("Best Score: " .. bestScore, 10, 30)
end

-- Handle key presses for ball movement
function love.keypressed(key)
    if gameOver then
        return -- Prevent keypresses during game-over state
    end

    if key == "space" then
        ball.body:applyLinearImpulse(0, -200) -- Jump
    elseif key == "left" then
        ball.body:applyLinearImpulse(-50, 0) -- Move left
    elseif key == "right" then
        ball.body:applyLinearImpulse(50, 0) -- Move right
    end
end

-- Handle mouse clicks for Play Again button
function love.mousepressed(x, y, button)
    if gameOver and button == 1 then -- Left mouse button
        if x >= 300 and x <= 500 and y >= 250 and y <= 300 then
            restartGame()
        end
    end
end

-- Helper function to create a platform
function createPlatform(x, y, width, height)
    local platform = {
        body = lp.newBody(world, x, y, "static"),
        shape = lp.newRectangleShape(width, height)
    }
    platform.fixture = lp.newFixture(platform.body, platform.shape)
    return platform
end

-- Helper function to check if the ball collides with the goal
function checkGoalCollision()
    local bx, by = ball.body:getX(), ball.body:getY()
    return bx > goal.x and bx < goal.x + goal.width and by > goal.y and by < goal.y + goal.height
end

-- Game over logic
function showGameOverScreen()
    gameOver = true
    ball.body:setLinearVelocity(0, 0) -- Stop the ball's movement
end

function drawGameOverScreen()
    -- Background overlay
    lg.setColor(0, 0, 0, 0.75)
    lg.rectangle("fill", 0, 0, 800, 600)

    -- Game over text
    lg.setColor(1, 1, 1)
    lg.printf("Game Over!", 0, 150, 800, "center")
    lg.printf("Best Score: " .. bestScore, 0, 200, 800, "center")

    -- Draw "Play Again" button
    lg.setColor(0.2, 0.8, 0.2)
    lg.rectangle("fill", 300, 250, 200, 50)
    lg.setColor(1, 1, 1)
    lg.printf("Play Again", 300, 265, 200, "center")
end

-- Restart the game
function restartGame()
    gameOver = false
    level = 1
    bestScore = math.max(bestScore, level - 1) -- Update best score
    loadLevel(level)
end