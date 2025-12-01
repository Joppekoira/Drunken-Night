-- Main Scene (Korjattu: baari, uudet sydämet, tile paikat)
local composer = require("composer")
local scene = composer.newScene()

local physics = require("physics")
physics.start()
physics.setDrawMode( "normal" )
physics.setGravity(0, 0)

-- Forward declarations
local move = require("scripts.move")
local drunkenguy
local currentFrequence = "walkRight"
local speed = 2

-- Coin system
local coinsCollected = 0
local COINS_NEEDED = 5
local coins = {}
local tiles = {}
local infoBox
local infoBoxBg
local closeButton
local hearts = {}

-- Global keys table
if not _G.keysPressed then
    _G.keysPressed = {}
end
local keysPressed = _G.keysPressed

-- Global health tracking
if not _G.playerHealth then
    _G.playerHealth = 100
end

-- Update hearts display (KÄYTTÄÄ UUSIA KUVIA)
local function updateHearts()
    for i = 1, 3 do
        if hearts[i] then
            if i <= _G.playerHealth then
                hearts[i].fill = {type="image", filename="images/muutkuvat/rakennukset/heart_full.png"}
            else
                hearts[i].fill = {type="image", filename="images/muutkuvat/rakennukset/heart_empty.png"}
            end
        end
    end
end

-- Function to show info box
local function showInfoBox(sceneGroup)
    infoBoxBg = display.newRect(display.contentCenterX, display.contentCenterY,
                                 display.contentWidth, display.contentHeight)
    infoBoxBg:setFillColor(0, 0, 0, 0.7)
    sceneGroup:insert(infoBoxBg)

    infoBox = display.newRoundedRect(display.contentCenterX, display.contentCenterY, 400, 350, 12)
    infoBox:setFillColor(0.2, 0.2, 0.3)
    infoBox.strokeWidth = 3
    infoBox:setStrokeColor(1, 0.8, 0)
    sceneGroup:insert(infoBox)

    local title = display.newText("MISSION", display.contentCenterX,
                                  display.contentCenterY - 130, native.systemFontBold, 24)
    title:setFillColor(1, 0.8, 0)
    sceneGroup:insert(title)

    local infoText = display.newText({
    text = "You have to collect " .. COINS_NEEDED .. " coins to unlock the next lvl!\n" ..
           "Movement Keys W-A-S-D, Up, Down, Left, Right, Space\n\n" ..
           "Coins collected:" .. coinsCollected .. "/" .. COINS_NEEDED,
    x = display.contentCenterX,
    y = display.contentCenterY,
    width = 350,
    font = native.systemFont,
    fontSize = 20,
    align = "center"
})
    infoText:setFillColor(1, 1, 1)
    sceneGroup:insert(infoText)

    closeButton = display.newRoundedRect(display.contentCenterX,
                                         display.contentCenterY + 130, 100, 40, 8)
    closeButton:setFillColor(0.8, 0.2, 0.2)
    sceneGroup:insert(closeButton)

    local closeText = display.newText("CLOSE", display.contentCenterX,
                                      display.contentCenterY + 130, native.systemFontBold, 22)
    closeText:setFillColor(1, 1, 1)
    sceneGroup:insert(closeText)

    local function closeInfoBox(event)
        if event.phase == "ended" then
            display.remove(infoBoxBg)
            display.remove(infoBox)
            display.remove(title)
            display.remove(infoText)
            display.remove(closeButton)
            display.remove(closeText)
        end
        return true
    end

    closeButton:addEventListener("touch", closeInfoBox)
end

-- Function to check coin collision
local function checkCoinCollision(player, coin)
    local dx = player.x - coin.x
    local dy = player.y - coin.y
    local distance = math.sqrt(dx*dx + dy*dy)
    return distance < 50
end

function scene:create(event)
    local sceneGroup = self.view

    -- Screen dimensions
    local screenW = 960
    local screenH = 640

    --BGM
    local bgm = audio.loadStream("assets/audio/music/Takeover.mp3")
	audio.setVolume( 0.5, { channel=1 } )
	audio.play( bgm, {
		channel = 1,
		loops = -1,
		fadein = 3000
	})

    -- Load background
    local backGround = display.newImageRect("assets/images/backgrounds/tile_taivas.png", screenW, screenH)
    backGround.x = display.contentCenterX
    backGround.y = display.contentCenterY
    sceneGroup:insert(backGround)

    -- Add lamps (decorative)
    local lampPositions = {
        {x = 50, y = 460}
    }

    for i = 1, #lampPositions do
        local lamp = display.newImageRect("assets/images/objects/lamppu.png", 80, 180)
        lamp.x = lampPositions[i].x
        lamp.y = lampPositions[i].y
        sceneGroup:insert(lamp)
    end

    -- UUSI: Baari oikealla puolella
    --local baari = display.newImageRect("assets/images/objects/baari.png", 360, 400)
    --baari.x = screenW - 175  -- Oikealla reunalla
    --baari.y = screenH - 220
    --sceneGroup:insert(baari)

    -- Info lamp icon (top left)
    local infoLamp = display.newCircle(60, 60, 30)
    infoLamp:setFillColor(1, 0.8, 0)
    sceneGroup:insert(infoLamp)

    local lampText = display.newText("💡", 60, 60, native.systemFont, 40)
    sceneGroup:insert(lampText)

    local function onInfoLampTouch(event)
        if event.phase == "ended" then
            showInfoBox(sceneGroup)
        end
        return true
    end
    infoLamp:addEventListener("touch", onInfoLampTouch)

    -- Coin counter display (top right)
    local coinCounterBg = display.newRoundedRect(screenW - 100, 60, 150, 50, 8)
    coinCounterBg:setFillColor(0.2, 0.2, 0.3)
    sceneGroup:insert(coinCounterBg)

    local coinCounterText = display.newText("Coins: 0/" .. COINS_NEEDED,
                                            screenW - 100, 60, native.systemFontBold, 24)
    coinCounterText:setFillColor(1, 0.8, 0)
    sceneGroup:insert(coinCounterText)

    self.coinCounterText = coinCounterText

    -- Health hearts (UUDET KUVAT - top center)
    for i = 1, 3 do
        local heart = display.newImageRect("assets/images/ui/heart_full.png", 32, 32)
        heart.x = screenW/2 - 50 + (i-1)*40
        heart.y = 40
        sceneGroup:insert(heart)
        hearts[i] = heart
    end

    -- Create tiles (UUDET PAIKAT - eivät osu baariin)
    local tilePositions = {
        {x = 120, y = 500},
        {x = 240, y = 450},
        {x = 360, y = 500},
        {x = 480, y = 400},
        {x = 600, y = 500},
        {x = 720, y = 500},
        {x = 840, y = 500}
    }

    for i = 1, #tilePositions do
        local tile = display.newImageRect("assets/images/tiles/ML.png", 80, 20)
        tile.x = tilePositions[i].x
        tile.y = tilePositions[i].y
        physics.addBody(tile, "static", {density = -1})
        sceneGroup:insert(tile)
        tiles[i] = tile
    end

    self.tiles = tiles
    COINS_NEEDED = #tilePositions
    -- Create coins (on the top of tiles)
    for i = 1, COINS_NEEDED do
        local coin = display.newImageRect("assets/images/objects/coin.png", 40, 40)
        coin.x = tilePositions[i].x
        coin.y = tilePositions[i].y - 40
        sceneGroup:insert(coin)

        coins[i] = {image = coin, collected = false}
    end

    self.coins = coins
    self.hearts = hearts

    -- Load sprite sheet
    local walkOptions = require("assets.images.spritet.sprite-0004")
    local walkSheet = graphics.newImageSheet("assets/images/spritet/Sprite-0004.png", walkOptions)

    -- Create sprite
    drunkenguy = display.newSprite(walkSheet, {
        { name="walkRight", frames={1,2,3,4,5,6,7}, time=1300, loopCount=0 },
        { name="walkLeft", frames={1,2,3,4,5,6,7}, time=1300, loopCount=0 },
        { name="walkUp", frames={1,2,3,4,5,6,7}, time=1300, loopCount=0 },
        { name="walkDown", frames={1,2,3,4,5,6,7}, time=1300, loopCount=0 },
        { name="walkUpRight", frames={1,2,3,4,5,6,7}, time=1300, loopCount=0 },
        { name="walkUpLeft", frames={1,2,3,4,5,6,7}, time=1300, loopCount=0 },
        { name="walkDownRight", frames={1,2,3,4,5,6,7}, time=1300, loopCount=0 },
        { name="walkDownLeft", frames={1,2,3,4,5,6,7}, time=1300, loopCount=0 }
    })
    local drunkenguyShape = { -15,-40, -10,-10, -10,60, -35, 60, -45,-10 }
    physics.addBody( drunkenguy, "dynamic", {shape = drunkenguyShape})

    drunkenguy.x = 820
    drunkenguy.y = 490
    drunkenguy:setSequence("walkLeft")
    drunkenguy.xScale = 0.5
    drunkenguy.yScale = 0.5
    sceneGroup:insert(drunkenguy)

    self.drunkenguy = drunkenguy
end

function scene:show(event)
    local phase = event.phase

    if phase == "will" then
        -- Update health display
        updateHearts()

        if event.params and event.params.fromKiosk then
            drunkenguy.x = 50
        end
    end

    if phase == "did" then
        for k in pairs(_G.keysPressed) do
            _G.keysPressed[k] = nil
        end

        local function onKey(event)
            if event.phase == "down" then
                keysPressed[event.keyName] = true
            elseif event.phase == "up" then
                keysPressed[event.keyName] = false
            end
            return false
        end

        local sceneActive = true
        local function gameLoop()
            if not sceneActive then return end

            currentFrequence = move.update(drunkenguy, keysPressed, currentFrequence, speed, self.tiles)

            -- Check coin collection
            for i = 1, #coins do
                if not coins[i].collected and checkCoinCollision(drunkenguy, coins[i].image) then
                    coins[i].collected = true
                    coins[i].image.isVisible = false
                    coinsCollected = coinsCollected + 1

                    self.coinCounterText.text = "Coins: " .. coinsCollected .. "/" .. COINS_NEEDED

                    print("Coin collected! Total: " .. coinsCollected .. "/" .. COINS_NEEDED)
                end
            end

            -- Check scene transition: left -> kiosk
            if drunkenguy.x < 0 then
                if coinsCollected >= COINS_NEEDED then
                    sceneActive = false
                    Runtime:removeEventListener("key", self.onKey)
                    Runtime:removeEventListener("enterFrame", self.gameLoop)
                    composer.gotoScene("scenes.kiosk", {
                        effect = "slideLeft",
                        time = 300,
                        params = { fromMain = true }
                    })
                else
                    drunkenguy.x = 50
                    print("Need " .. (COINS_NEEDED - coinsCollected) .. " more coins!")
                end
            end
        end

        Runtime:addEventListener("key", onKey)
        Runtime:addEventListener("enterFrame", gameLoop)

        self.onKey = onKey
        self.gameLoop = gameLoop
    end
end

function scene:hide(event)
    local phase = event.phase

    if phase == "will" then
        if self.onKey then
            Runtime:removeEventListener("key", self.onKey)
        end
        if self.gameLoop then
            Runtime:removeEventListener("enterFrame", self.gameLoop)
        end

        for k in pairs(_G.keysPressed) do
            _G.keysPressed[k] = nil
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