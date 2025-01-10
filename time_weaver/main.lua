local Player = {}
local TimeClone = {}
local recording = {}
local isRecording = false
local isReplaying = false
local recordingDuration = 5
local recordingTimer = 0
local energy = 100
local energyDrainRate = 20

function love.load()
    Player = {
        x = 100,
        y = 100,
        width = 32,
        height = 32,
        speed = 200,
        color = {1, 1, 1, 1},
        records = {},
        currentFrame = 1
    }

    -- Initialize time clone
    TimeClone = {
        x = 0,
        y = 0,
        width = 32,
        height = 32,
        color = {0.5, 0.8, 1, 0.7},
        active = false
    }
    
    -- Platform data
    platforms = {
        {x = 100, y = 400, width = 200, height = 20},
        {x = 400, y = 300, width = 200, height = 20},
        {x = 700, y = 200, width = 200, height = 20}
    }
end

function love.update(dt)
    -- Handle player movement
    local dx, dy = 0, 0
    
    if love.keyboard.isDown('left') then
        dx = dx - Player.speed * dt
    end
    if love.keyboard.isDown('right') then
        dx = dx + Player.speed * dt
    end
    if love.keyboard.isDown('up') then
        dy = dy - Player.speed * dt
    end
    if love.keyboard.isDown('down') then
        dy = dy + Player.speed * dt
    end
    
    -- Update player position
    Player.x = Player.x + dx
    Player.y = Player.y + dy
    
    -- Handle recording
    if isRecording then
        recordingTimer = recordingTimer + dt
        energy = math.max(0, energy - energyDrainRate * dt)
        
        -- Store current frame
        table.insert(recording, {
            x = Player.x,
            y = Player.y,
            time = love.timer.getTime()
        })
        
        -- Stop recording if time limit reached or energy depleted
        if recordingTimer >= recordingDuration or energy <= 0 then
            stopRecording()
        end
    end
    
    -- Handle replay
    if isReplaying and #recording > 0 then
        TimeClone.active = true
        local frame = recording[Player.currentFrame]
        if frame then
            TimeClone.x = frame.x
            TimeClone.y = frame.y
            Player.currentFrame = Player.currentFrame + 1
            
            if Player.currentFrame > #recording then
                Player.currentFrame = 1
                isReplaying = false
            end
        end
    end
end

function love.draw()
    -- Draw platforms
    love.graphics.setColor(0.5, 0.5, 0.5)
    for _, platform in ipairs(platforms) do
        love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
    end
    
    -- Draw player
    love.graphics.setColor(Player.color)
    love.graphics.rectangle('fill', Player.x, Player.y, Player.width, Player.height)
    
    -- Draw time clone if active
    if TimeClone.active then
        love.graphics.setColor(TimeClone.color)
        love.graphics.rectangle('fill', TimeClone.x, TimeClone.y, TimeClone.width, TimeClone.height)
    end
    
    -- Draw UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Energy: " .. math.floor(energy), 10, 10)
    love.graphics.print("Recording: " .. (isRecording and "Yes" or "No"), 10, 30)
    if isRecording then
        love.graphics.print("Time Left: " .. string.format("%.1f", recordingDuration - recordingTimer), 10, 50)
    end
end

function love.keypressed(key)
    if key == 'r' and not isRecording and energy > 0 then
        startRecording()
    elseif key == 't' and not isRecording and #recording > 0 then
        startReplay()
    end
end

function startRecording()
    isRecording = true
    recording = {}
    recordingTimer = 0
    TimeClone.active = false
end

function stopRecording()
    isRecording = false
end

function startReplay()
    isReplaying = true
    Player.currentFrame = 1
end