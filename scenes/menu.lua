-- Menu Scene
local composer = require("composer")
local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view

    -- Screen dimensions
    local screenW = display.contentWidth
    local screenH = display.contentHeight

    -- Background
    local backGround = display.newImageRect("assets/images/backgrounds/pvdr.png", screenW, screenH)
    backGround.x = display.contentCenterX
    backGround.y = display.contentCenterY
    sceneGroup:insert(backGround)

    -- Start button
    local startButton = display.newImageRect("assets/images/muutkuvat/Start.png", 200, 60)
    startButton.x = display.contentCenterX
    startButton.y = 300
    sceneGroup:insert(startButton)

    -- Quit button
    local quitButton = display.newImageRect("assets/images/muutkuvat/Quit.png", 200, 60)
    quitButton.x = display.contentCenterX
    quitButton.y = 400
    sceneGroup:insert(quitButton)

    -- Sound icon
    local soundIcon = display.newRect(screenW - 50, 50, 60, 60)
    soundIcon:setFillColor(0.3, 0.3, 0.3)
    sceneGroup:insert(soundIcon)

    local soundText = display.newText("🔊", screenW - 50, 50, native.systemFont, 36)
    soundText:setFillColor(1, 1, 1)
    sceneGroup:insert(soundText)

    -- Event handlers
    local function onStartButtonPress(event)
        if event.phase == "ended" then
            composer.gotoScene("scenes.main", {effect = "slideLeft", time = 300})
        end
        return true
    end

    local function onQuitButtonPress(event)
        if event.phase == "ended" then
            native.requestExit()
        end
        return true
    end

    local function onSoundIconPress(event)
        if event.phase == "ended" then
            print("Sound settings (coming soon)")
        end
        return true
    end

    -- Add listeners
    startButton:addEventListener("touch", onStartButtonPress)
    quitButton:addEventListener("touch", onQuitButtonPress)
    soundIcon:addEventListener("touch", onSoundIconPress)
end

scene:addEventListener("create", scene)

return scene