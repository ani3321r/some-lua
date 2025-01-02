-- Constants
local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600
local PADDLE_WIDTH = 10
local PADDLE_HEIGHT = 100
local BALL_SIZE = 10
local PADDLE_SPEED = 300

-- Score variables
local player1Score = 0
local player2Score = 0

-- Fonts
local font

-- Game state
local player1Y = 0
local player2Y = 0
local ballX = 0
local ballY = 0
local ballDX = 200
local ballDY = 200
local gameMode = nil

-- Load resources and initialize game state
function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = false,
        vsync = true,
        fullscreen = false
    })
    love.window.setTitle("Pong")

    -- Set font
    font = love.graphics.newFont(32)
    love.graphics.setFont(font)

    -- Initialize positions
    resetGame()
end

-- Reset ball and paddle positions
function resetGame()
    player1Y = (WINDOW_HEIGHT - PADDLE_HEIGHT) / 2
    player2Y = (WINDOW_HEIGHT - PADDLE_HEIGHT) / 2
    ballX = (WINDOW_WIDTH - BALL_SIZE) / 2
    ballY = (WINDOW_HEIGHT - BALL_SIZE) / 2

    -- Randomize ball direction
    ballDX = 200 * (love.math.random(2) == 1 and 1 or -1)
    ballDY = 200 * (love.math.random(2) == 1 and 1 or -1)
end

-- Update game state
function love.update(dt)
    if gameMode == nil then return end

    -- Player 1 controls (W and S keys)
    if love.keyboard.isDown("w") then
        player1Y = math.max(0, player1Y - PADDLE_SPEED * dt)
    elseif love.keyboard.isDown("s") then
        player1Y = math.min(WINDOW_HEIGHT - PADDLE_HEIGHT, player1Y + PADDLE_SPEED * dt)
    end

    if gameMode == "2p" then
        -- Player 2 controls (Up and Down arrow keys)
        if love.keyboard.isDown("up") then
            player2Y = math.max(0, player2Y - PADDLE_SPEED * dt)
        elseif love.keyboard.isDown("down") then
            player2Y = math.min(WINDOW_HEIGHT - PADDLE_HEIGHT, player2Y + PADDLE_SPEED * dt)
        end
    elseif gameMode == "1p" then
        if ballY < player2Y + PADDLE_HEIGHT / 2 then
            player2Y = math.max(0, player2Y - PADDLE_SPEED * dt)
        elseif ballY > player2Y + PADDLE_HEIGHT / 2 then
            player2Y = math.min(WINDOW_HEIGHT - PADDLE_HEIGHT, player2Y + PADDLE_SPEED * dt)
        end
    end

    -- Ball movement
    ballX = ballX + ballDX * dt
    ballY = ballY + ballDY * dt

    -- Ball collision with top and bottom walls
    if ballY <= 0 or ballY >= WINDOW_HEIGHT - BALL_SIZE then
        ballDY = -ballDY
    end

    -- Ball collision with paddles
    if (ballX <= PADDLE_WIDTH and ballY + BALL_SIZE > player1Y and ballY < player1Y + PADDLE_HEIGHT) or
       (ballX + BALL_SIZE >= WINDOW_WIDTH - PADDLE_WIDTH and ballY + BALL_SIZE > player2Y and ballY < player2Y + PADDLE_HEIGHT) then
        ballDX = -ballDX * 1.1
        ballDY = ballDY * 1.1
    end

    -- Ball reset and scoring
    if ballX < 0 then
        player2Score = player2Score + 1
        resetGame()
    elseif ballX > WINDOW_WIDTH then
        player1Score = player1Score + 1
        resetGame()
    end
end

-- Draw game objects
function love.draw()
    if gameMode == nil then
        -- Draw menu
        love.graphics.printf("Pong", 0, 100, WINDOW_WIDTH, "center")
        love.graphics.printf("Press 1 for Single Player", 0, 200, WINDOW_WIDTH, "center")
        love.graphics.printf("Press 2 for Two Players", 0, 300, WINDOW_WIDTH, "center")
        return
    end

    -- Draw paddles
    love.graphics.rectangle("fill", 0, player1Y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle("fill", WINDOW_WIDTH - PADDLE_WIDTH, player2Y, PADDLE_WIDTH, PADDLE_HEIGHT)

    -- Draw ball
    love.graphics.rectangle("fill", ballX, ballY, BALL_SIZE, BALL_SIZE)

    -- Draw middle line
    love.graphics.line(WINDOW_WIDTH / 2, 0, WINDOW_WIDTH / 2, WINDOW_HEIGHT)

    -- Draw scores
    love.graphics.printf(player1Score, 0, 20, WINDOW_WIDTH / 2, "center")
    love.graphics.printf(player2Score, WINDOW_WIDTH / 2, 20, WINDOW_WIDTH / 2, "center")
end

-- Handle key presses
function love.keypressed(key)
    if gameMode == nil then
        if key == "1" then
            gameMode = "1p"
        elseif key == "2" then
            gameMode = "2p"
        end
    elseif key == "escape" then
        love.event.quit()
    end
end