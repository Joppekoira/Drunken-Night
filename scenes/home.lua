-- Home Scene (Cutscene - 5 seconds)
local composer = require("composer")
local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view

    -- Get screen dimensions
    local screenW = display.contentWidth
    local screenH = display.contentHeight

    -- Black background
    local blackBg = display.newRect(screenW/2, screenH/2, screenW, screenH)
    blackBg:setFillColor(0, 0, 0, 1)
    sceneGroup:insert(blackBg)

    -- Full text (for reference)
    local fullText = "Hot dogs...\nmy favourite"

    -- Create text display (starts empty)
    local cutsceneText = display.newText({
        text = "",
        x = screenW/2,
        y = screenH/2,
        width = screenW - 100,
        font = native.systemFont,
        fontSize = 32,
        align = "center"
    })
    cutsceneText:setFillColor(1, 1, 1)  -- White text
    sceneGroup:insert(cutsceneText)

    -- Animate letters appearing one by one
    local charIndex = 1
    local charDelay = 80  -- Milliseconds between each character

    local function addNextChar()
        if charIndex <= #fullText then
            cutsceneText.text = string.sub(fullText, 1, charIndex)
            charIndex = charIndex + 1
            timer.performWithDelay(charDelay, addNextChar)
        else
            -- All text has appeared, wait then fade out
            timer.performWithDelay(2500, function()
                transition.to(cutsceneText, {
                    time = 1000,
                    alpha = 0,
                    onComplete = function()
                        -- Go back to menu after cutscene
                        composer.gotoScene("scenes.menu", {
                            effect = "fade",
                            time = 500
                        })
                    end
                })
            end)
        end
    end

    -- Start animation
    addNextChar()

    self.cutsceneText = cutsceneText
end

function scene:show(event)
    -- Cutscene plays automatically
end

function scene:hide(event)
    local phase = event.phase

    if phase == "will" then
        -- Cancel any transitions
        if self.cutsceneText then
            transition.cancel(self.cutsceneText)
        end
    end
end

function scene:destroy(event)
    -- Cleanup if needed
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
