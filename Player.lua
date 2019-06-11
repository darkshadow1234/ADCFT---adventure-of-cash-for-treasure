local bumpWorld = require("BumpWorld") -- global collision world refernce
local Camera = require("Camera")
local MiddleState = require("MiddleState") -- MiddleState Refernce
local BulletScript = require("Bullet") -- bullet script
local BulletObject = require("BulletObject") -- Bullet gameobject script

local Player ={}
local camera = {}

rect = {
    x = love.graphics.getWidth() /2 - 100,
    y = love.graphics.getHeight() /2,
    w = 1000,
    h= 50
}

gun = {
    img,
    x,
    y,
    w,
    h ,
    r = 0 ,
}

Player = {
        --- position and size stuff -- 
        x = love.graphics.getWidth() /2,
        y = 0 , --love.graphics.getHeight() /2 ,
        w = 30,
        h = 64,

        ----- animation and stuff --
        sizeX = 72,
        sizeY = 142,
        activeFrame = 1,
        frames = {},
        img = {},
        currentFrame = 1,
        time = 0,
        forTime = 0.1,

        ---- movement mechanics ---
        runSpeed = 500,
        gravity = 1700,
        xVelocity = 0,
        yVelocity = 0,
        terminalVelocity = 1500,
        onGround = false ,
        jumpVelocity = 900,

        --------------- faceLeft or faceRight --- face = 1 for right || face = -1 for left
        face = 1,
}


    function Player:Load()
        camera = Camera()
        camera:setFollowStyle('PLATFORMER')
        camera.scale = 0.4

        self.img = love.graphics.newImage("assets/playerA.png")

        self.activeFrame = 1
        for i=1,3,1
        do
            print(i)
            self.frames[i] = love.graphics.newQuad((i-1) * 72 , 0, 72, 142, self.img:getDimensions())
        end
        self.activeFrame = self.frames[self.currentFrame]

        ----------- gun
        gun.img = love.graphics.newImage("assets/gun.png")
        gun.x = self.x + self.sizeX/2
        gun.y = self.y + self.sizeY/2
        gun.w , gun.h = gun.img:getDimensions()
        -----------

        bumpWorld:add(Player , self.x , self.y , self.sizeX , self.sizeY)
        bumpWorld:add(rect , rect.x , rect.y , rect.w , rect.h)
    end
    -----------------

    function Player:Update(dt)
        --print(Player.x,"--" , Player.y)
        --print(camera.x , "--" ,camera.y)
        --print(love.mouse.getX() * camera.scale + camera.x , "--" ,love.mouse.getY() *camera.scale + camera.y)
        gun:GunHandler()
        self.time = self.time + dt
        self:Move(dt)
        self:ApplyGravity(dt)
        self:Collide(dt)
        camera:update(dt)
        camera:follow(self.x , self.y)
    end

    ----------------------------------------------------------------------- Draw
    function Player:Draw()
        camera:attach()
        if self.face == 1 then
            love.graphics.draw(self.img, self.activeFrame , self.x , self.y , 0 , self.face , 1 , 0, 0)
        else
            love.graphics.draw(self.img, self.activeFrame , self.x , self.y , 0 , self.face , 1 , self.sizeX, 0)
        end

        love.graphics.draw(gun.img , gun.x , gun.y , gun.r , 1,1 , 0, gun.h/2)
        love.graphics.rectangle("line" ,rect.x , rect.y , rect.w , rect.h)
        camera:detach()
    end

---------------------------------------------------------------------------- gun handler
function gun:GunHandler(dt)
    -------------- gun
    gun.x = Player.x + Player.sizeX/2
    gun.y = Player.y + Player.sizeY/2
    --------------
    local angle = math.atan2(love.mouse.getY() - love.graphics.getHeight() / 2 , love.mouse.getX() - love.graphics.getWidth() / 2)
    self.r = angle

end
-------------------------------------------------------------------------- Move
function Player:Move(dt)
    if love.keyboard.isDown("a") then

        ------------------ for animation
        if self.time > self.forTime then
            self.currentFrame = self.currentFrame + 1
            if self.currentFrame > 3 then
                self.currentFrame = 2
            end
            self.activeFrame = self.frames[self.currentFrame]
            self.time = 0
        end
        ------------------------------
        if(camera.scale <0.48) then
            camera.scale = camera.scale + dt * 0.3
        end
        if self.xVelocity > 0 then
            self.xVelocity = self.xVelocity - self.runSpeed *dt *3
        else
            self.xVelocity = self.xVelocity - self.runSpeed *dt
        end
        self.face = -1
    elseif love.keyboard.isDown("d") then
        ------------------ for animation
        if self.time > self.forTime then
            self.currentFrame = self.currentFrame + 1
            if self.currentFrame > 3 then
                self.currentFrame = 2
            end
            self.activeFrame = self.frames[self.currentFrame]
            self.time = 0
        end
        ------------------------------
        if(camera.scale <0.48) then
            camera.scale = camera.scale + dt * 0.3
        end
        if self.xVelocity < 0 then
            self.xVelocity = self.xVelocity + self.runSpeed *dt * 3
        else 
            self.xVelocity = self.xVelocity + self.runSpeed *dt
        end
        self.face = 1
    else
        self.currentFrame = 1
        self.activeFrame = self.frames[self.currentFrame]
        if(camera.scale > 0.4) then
            camera.scale = camera.scale - dt * 0.3
        end

        if self.onGround == true then
            if self.xVelocity > 5 then
                self.xVelocity = self.xVelocity - self.runSpeed *dt *3
            elseif self.xVelocity < -5 then
                    self.xVelocity = self.xVelocity + self.runSpeed *dt * 3
            else 
                self.xVelocity = 0
            end
        else
            if self.xVelocity > 0 then
                self.xVelocity = self.xVelocity - self.runSpeed *dt *0.8
            elseif self.xVelocity < 0 then
                    self.xVelocity = self.xVelocity + self.runSpeed *dt * 0.8
            end
        end
    end
end
---------------------------------------------------------------------------- gravity
function Player:ApplyGravity(dt)
    if self.yVelocity < self.terminalVelocity then
        self.yVelocity = self.yVelocity +  self.gravity * dt
    else 
        self.yVelocity = self.terminalVelocity
    end
    
end
-------------------------------------------------------------------------- jump
function love.keypressed(key)
    if key == "w"  and Player.onGround == true then
        Player.yVelocity = -Player.jumpVelocity
    end
end
-------------------------------------------------------------------------------------------------------bulllet shooooooot
function love.mousepressed(x, y, button, isTouch)
    if button == 1 then
        ---------- make bullets
        --local bulletObj = BulletObject.new()
        local bulletScript = BulletScript.new()
        
        local mx,my = love.mouse.getPosition() --- local mouse poisiton

        local angle = math.atan2( my - love.graphics.getHeight() /2 , mx - love.graphics.getWidth() /2 )
        
        local posx = (math.cos(angle) ) + love.graphics.getWidth() /2 - (Player.x - camera.x)  * camera.scale
        local posy = (math.sin(angle) ) + love.graphics.getHeight() /2 - (camera.y - Player.y) * camera.scale

        print(camera.x , "---" , Player.x)

        bulletScript.x , bulletScript.y = posx , posy -------- assign the transform location
        local vx , vy = math.cos(angle) * 150 , math.sin(angle) * 150
        bulletScript.r = angle
        bulletScript.vx , bulletScript.vy = vx , vy

        --print(vx , "---" , vy)
        --bulletObj:AddComponent(bulletScript , "Bullet")
        --bulletObj:Load()  ----- this line here .. Oh yeah I understand know ... he he he..
        bulletScript:Load()
        MiddleState.playState:AddGameObject(bulletScript)
        ----------
        ----------shake
        camera:shake(8 , 0.2 , 60)
    end
end
-------------------------------------------------------------------------- Collide
function Player:Collide(dt)


    local futureY = self.y + self.yVelocity * dt
    local futureX = self.x + self.xVelocity * dt

    local nextX , nextY , col , len = bumpWorld:move(Player , futureX , futureY)
    self.onGround = false
    for i =1, len do
        if col[i].other == rect and col[i].normal.y == -1 then
            self.onGround = true
            self.yVelocity = 0
        end
    end

    self.x = nextX
    self.y = nextY

end

MiddleState.playState:AddGameObject(Player)

return Player