-- Street Scene --bossfightti
local composer = require("composer")
local scene = composer.newScene()

-- Forward declarations//kävely koodit
local playerMovement = require("scripts.move")
local drunkenguy
local monster
local currentFrequence = "walkRight"
local speed = 2
local hearts = {}
local projectiles = {}
local platforms = {}

-- Global keys table//globaali nappaimiston tila
if not _G.keysPressed then
    _G.keysPressed = {}
end
local keysPressed = _G.keysPressed

-- Global health tracking//pelaajan elämän seuranta
if not _G.playerHealth then
    _G.playerHealth = 3
end

-- Monster AI//hirviö tekoAäly automaattinen liike, oksennus
local monsterSpeed = 3.5
local shootTimer = 3
local shootInterval = 2000 -- Shoot every 2 seconds

-- Update hearts display
local function updateHearts()
    for i = 1, 3 do
        if hearts[i] then
            if i <= _G.playerHealth then
                hearts[i].fill = {type="image", filename="assets/images/ui/heart_full.png"}
            else
                hearts[i].fill = {type="image", filename="assets/images/ui/heart_empty.png"}
            end
        end
    end
end

-- Damage player
local function damagePlayer()
    if _G.playerHealth > 0 then
        _G.playerHealth = _G.playerHealth - 0.5
        updateHearts()
        print("Health: " .. _G.playerHealth)

        if _G.playerHealth <= 0 then
            print("Game Over!")
            _G.playerHealth = 1
            audio.stop()
            composer.gotoScene("scenes.menu", {effect = "fade", time = 500})
        end
    end
end

-- Check collision between two objects
local function checkCollision(obj1, obj2, range)
    local dx = obj1.x - obj2.x
    local dy = obj1.y - obj2.y
    local distance = math.sqrt(dx*dx + dy*dy)
    return distance < range
end

-- Create projectile
local function createProjectile(startX, startY, targetX, targetY, sceneGroup)
    local projectile = display.newImageRect("/assets/images/objects/oksennus_obj.png", 60, 30)
    projectile.x = startX
    projectile.y = startY

    -- Calculate direction
    local dx = targetX - startX
    local dy = targetY - startY
    local distance = math.sqrt(dx*dx + dy*dy)

    projectile.vx = (dx / distance) * 7
    projectile.vy = (dy / distance) * 7 - 3 -- Initial upward arc

    projectile.lifetime = 0
    projectile.hasHit = false
    projectile.onGround = false

    sceneGroup:insert(projectile)
    table.insert(projectiles, projectile)

    return projectile
end

function scene:create(event)
    local sceneGroup = self.view

    -- Get screen dimensions
    local screenW = display.contentWidth
    local screenH = display.contentHeight

    -- Load background image
    local backGround = display.newImageRect("assets/images/backgrounds/pixel_taivas.png", screenW, screenH)
    backGround.x = display.contentCenterX
    backGround.y = display.contentCenterY
    sceneGroup:insert(backGround)

    --change BGM
    bgm = audio.loadStream("assets/audio/music/taistelumusiikki.mp3")
    audio.play( bgm, {
		channel = 1,
		loops = -1,
		fadein = 3000
	})

    -- Create platforms (safe spots for jumping) - UUDET PAIKAT
    local platformData = {
        {x = 150, y = 500, width = 100, height = 20},  -- Low left
        {x = 350, y = 430, width = 120, height = 20},  -- Medium left
        {x = 550, y = 370, width = 100, height = 20},  -- High middle
        {x = 750, y = 430, width = 100, height = 20},  -- Medium right
        {x = 450, y = 300, width = 140, height = 20}   -- Top safe platform
    }

    for i = 1, #platformData do
        local platform = display.newImageRect("assets/images/tiles/ML.png", platformData[i].width, platformData[i].height)
        platform.x = platformData[i].x
        platform.y = platformData[i].y
        sceneGroup:insert(platform)
        table.insert(platforms, platform)
    end

    -- Health hearts (UUDET KUVAT - top center)
    for i = 1, 3 do
        local heart = display.newImageRect("assets/images/ui/heart_full.png", 32, 32)
        heart.x = screenW/2 - 40 + (i-1)*40
        heart.y = 40
        sceneGroup:insert(heart)
        hearts[i] = heart
    end

    -- Load monster sprite sheet (5 frames animation) - 1.5x ISOMPI
    local monsterOptions = {
        width = 120,
        height = 156,
        numFrames = 5,
        sheetContentWidth = 360,
        sheetContentHeight = 312
    }
    local monsterSheet = graphics.newImageSheet("assets/images/spritet/bb.png", monsterOptions)

    -- Create animated monster sprite
    monster = display.newSprite(monsterSheet, {
        name = "walk",
        frames = {1, 2, 3, 4, 5},
        time = 800,
        loopCount = 0
    })
    monster.x = 100  -- Start from LEFT side
    monster.y = 480
    monster.xScale = 1.5
    monster.yScale = 1.5
    monster:setSequence("walk")
    monster:play()
    sceneGroup:insert(monster)

    -- Load WALK sprite sheet
    local walkOptions = require("assets.images.spritet.Sprite-0004")
    local walkSheet = graphics.newImageSheet("assets/images/spritet/Sprite-0004.png", walkOptions)

    -- Create sprite
    drunkenguy = display.newSprite(walkSheet, {
        {
            name = "walkRight",
            frames = {1, 2, 3, 4, 5, 6, 7},
            time = 1300,
            loopCount = 0
        },
        {
            name = "walkLeft",
            frames = {1, 2, 3, 4, 5, 6, 7},
            time = 1300,
            loopCount = 0
        },
        {
            name = "walkUp",
            frames = {1, 2, 3, 4, 5, 6, 7},
            time = 1300,
            loopCount = 0
        },
        {
            name = "walkDown",
            frames = {1, 2, 3, 4, 5, 6, 7},
            time = 1300,
            loopCount = 0
        },
        {
            name = "walkUpRight",
            frames = {1, 2, 3, 4, 5, 6, 7},
            time = 1300,
            loopCount = 0
        },
        {
            name = "walkUpLeft",
            frames = {1, 2, 3, 4, 5, 6, 7},
            time = 1300,
            loopCount = 0
        },
        {
            name = "walkDownRight",
            frames = {1, 2, 3, 4, 5, 6, 7},
            time = 1300,
            loopCount = 0
        },
        {
            name = "walkDownLeft",
            frames = {1, 2, 3, 4, 5, 6, 7},
            time = 1300,
            loopCount = 0
        }
    })

    drunkenguy.x = display.contentCenterX
    drunkenguy.y = 510
    drunkenguy:setSequence("walkRight")
    drunkenguy.xScale = 0.5  -- Takaisin 0.5 (kuten kioskissa toimii)
    drunkenguy.yScale = 0.5
    sceneGroup:insert(drunkenguy)

    -- Save to scene data
    self.drunkenguy = drunkenguy
    self.monster = monster
    self.hearts = hearts
    self.sceneGroup = sceneGroup
    self.platforms = platforms
end

function scene:show(event)
    local phase = event.phase

    if phase == "will" then
        -- Update health display
        updateHearts()

        -- When coming from kiosk scene, place character on right side
        if event.params and event.params.fromKiosk then
            drunkenguy.x = display.contentWidth - 50
        end

        -- Reset monster position
        monster.x = 100
        monster.y = 480

        -- Clear old projectiles
        for i = #projectiles, 1, -1 do
            display.remove(projectiles[i])
            table.remove(projectiles, i)
        end
    end

    if phase == "did" then
        -- Reset keys first
        for k in pairs(_G.keysPressed) do
            _G.keysPressed[k] = nil
        end

        shootTimer = 0

        -- Keyboard listener
        local function onKey(event)
            if event.phase == "down" then
                keysPressed[event.keyName] = true
            elseif event.phase == "up" then
                keysPressed[event.keyName] = false
            end
            return false
        end

        -- Continuous update
        local sceneActive = true
        local lastTime = system.getTimer()

        local function gameLoop()
            if not sceneActive then return end

            local currentTime = system.getTimer()
            local deltaTime = currentTime - lastTime
            lastTime = currentTime

            -- Update player (with platforms for jumping)
            currentFrequence = playerMovement.update(drunkenguy, keysPressed, currentFrequence, speed, self.platforms)

            -- Monster AI - chase player (but can't jump to platforms)
            local dx = drunkenguy.x - monster.x
            local dy = drunkenguy.y - monster.y
            local distance = math.sqrt(dx*dx + dy*dy)

            -- Monster only moves on ground level
            if monster.y > 470 then
                if distance > 10 then
                    monster.x = monster.x + (dx / distance) * monsterSpeed
                end
            end

            -- Monster shoots (KOKO RUUTUUN - tarkista vain etäisyys)
            shootTimer = shootTimer + deltaTime
            if shootTimer > shootInterval and distance < 900 then  -- Laajennettu kantama
                shootTimer = 0
                createProjectile(monster.x, monster.y - 20, drunkenguy.x, drunkenguy.y, self.sceneGroup)
            end

            -- Update projectiles
            for i = #projectiles, 1, -1 do
                local proj = projectiles[i]

                if not proj.onGround then
                    -- Apply gravity
                    proj.vy = proj.vy + 0.6

                    -- Move projectile
                    proj.x = proj.x + proj.vx
                    proj.y = proj.y + proj.vy

                    -- Check if hit ground
                    if proj.y >= display.contentHeight - 50 then
                        proj.y = display.contentHeight - 50
                        proj.onGround = true
                        proj.vx = 0
                        proj.vy = 0
                    end
                end

                proj.lifetime = proj.lifetime + deltaTime

                -- Check collision with player (VAIN KUN EI OLE PLATFORMILLA)
                if not proj.hasHit and checkCollision(drunkenguy, proj, 40) then
                    -- Tarkista onko pelaaja platformilla (safe spot)
                    local onPlatform = false
                    for j = 1, #self.platforms do
                        local plat = self.platforms[j]
                        if drunkenguy.x > plat.x - 60 and drunkenguy.x < plat.x + 60 and
                           math.abs(drunkenguy.y - plat.y) < 30 then
                            onPlatform = true
                            break
                        end
                    end

                    -- Vain vahingoita jos EI ole platformilla
                    if not onPlatform then
                        proj.hasHit = true
                        damagePlayer()
                    end
                end

                -- Remove after 3 seconds on ground
                if proj.onGround and proj.lifetime > 3000 then
                    display.remove(proj)
                    table.remove(projectiles, i)
                elseif proj.y > display.contentHeight + 100 or proj.x < -100 or proj.x > display.contentWidth + 100 then
                    display.remove(proj)
                    table.remove(projectiles, i)
                end
            end

            -- Check collision with monster (only if player is on ground level)
            if drunkenguy.y > 470 and checkCollision(drunkenguy, monster, 50) then
                damagePlayer()
                -- Push player back
                local pushDx = drunkenguy.x - monster.x
                drunkenguy.x = drunkenguy.x + pushDx * 0.3
            end

            -- Check scene transition: right -> kiosk
            if drunkenguy.x > display.contentWidth then
                sceneActive = false
                Runtime:removeEventListener("key", self.onKey)
                Runtime:removeEventListener("enterFrame", self.gameLoop)
                composer.gotoScene("scenes.kiosk", {
                    effect = "slideLeft",
                    time = 300,
                    params = { fromStreet = true }
                })
            end

            -- Check scene transition: left -> home (SAFE!)
            if drunkenguy.x < 0 then
                sceneActive = false
                Runtime:removeEventListener("key", self.onKey)
                Runtime:removeEventListener("enterFrame", self.gameLoop)
                composer.gotoScene("scenes.home", {
                    effect = "fade",
                    time = 500
                })
            end
        end

        Runtime:addEventListener("key", onKey)
        Runtime:addEventListener("enterFrame", gameLoop)

        -- Save listeners for cleanup
        self.onKey = onKey
        self.gameLoop = gameLoop
    end
end

function scene:hide(event)
    local phase = event.phase

    if phase == "will" then
        -- Remove listeners
        if self.onKey then
            Runtime:removeEventListener("key", self.onKey)
        end
        if self.gameLoop then
            Runtime:removeEventListener("enterFrame", self.gameLoop)
        end

        -- Reset all key presses
        for k in pairs(_G.keysPressed) do
            _G.keysPressed[k] = nil
        end
    end
end

function scene:destroy(event)
    -- Cleanup projectiles
    for i = #projectiles, 1, -1 do
        display.remove(projectiles[i])
        table.remove(projectiles, i)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene