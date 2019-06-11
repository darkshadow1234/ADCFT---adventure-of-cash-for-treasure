Pause = false
enemyNo = 3
level = 1
levelNo = 1
LevelGenerator = {}
levelG = {}
noOfStars = 0
font = {}
---------------- Buttons
gameoverActive = false
playButton = {}
exitButton = {}
NextButton = {}
---------------
playerHealth = 3
--------------- playerHealth
psx =0 
psy = 0

ColorBackgrounds = {
    {170/255,212/255,0 , 1},
    {1,42/255,42/255,1},
    {1,127/255,42/255,1},
    {167/255 , 172/255,147/255,1},
    {42/255,127/255,255/25,1},
    {127/255 , 42/255,255/255,1},
    {1 , 42/255 , 127/255 , 1},
    {171/255 , 55/255 , 200 / 255 , 1}
}

--------------------------------------------
local particleSystem = {}
w = love.graphics.getWidth()
h = love.graphics.getHeight()
----------- difficulty of enemies ----------
----------- constants here =================
difficulty = 1
bulletPower = 1
----------
Player = {}
------------
Camera = require("Camera")
Bump = require("bump")
BG = {}
--------------
bulletSpeed = 1500
insert = table.insert
ActiveState = {}
bumpWorld = {}
State = {}

shootFire = {shoot = false ,img , time = 0.05 , T = 0.05}
-----------------------------
Particles = {}
ButtonState = {} ------------------- buttons and scores etc
ButtonState.MenuState = {}
ButtonState.PlayState = {}
ButtonActiveState = {}
mouseButtonDown = false
-----------------------------
State.PlayState = {}
State.MenuState = {}

----ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp
function love.load()
    playerHealth = 3

    font = love.graphics.newFont(20)
    love.graphics.setFont(font)
    local forColor = love.math.random(1 , 8)
    love.graphics.setBackgroundColor(ColorBackgrounds[forColor][1] ,ColorBackgrounds[forColor][2] , ColorBackgrounds[forColor][3] , ColorBackgrounds[forColor][4])

    bumpWorld = Bump.newWorld(30)
    camera = Camera()
    camera:setFollowStyle('PLATFORMER')
    camera.scale = 0.4
    ------------ get dimensions of platforms
    local a1 = love.graphics.newImage("assets/platform.png")
    psx , psy = a1:getDimensions()
    psx , psy = psx , psy * camera.scale
    ---------------------------- get level Generator 

    ----------------------------
    shootFire.img = love.graphics.newImage("assets/shootFire.png")
    shootFire.w , shootFire.h = shootFire.img:getDimensions()
    -- in the level generator ----- insert player in the playstate
    
    MenuInitialize() ---------------- initialise menu
    print(playButton)
    playButton.isActive = true

    ActiveState = State.MenuState
    ButtonActiveState = ButtonState.MenuState

    for k,v in ipairs(ButtonState.MenuState) do
        v:Load()
    end
    for k,v in ipairs(ButtonState.PlayState) do
        v:Load()
    end
    for k,v in ipairs(State.PlayState) do
        v:Load()
    end
    for k,v in ipairs(State.MenuState) do
        v:Load()
    end
end
--ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp
function love.draw()
    --love.graphics.print('Memory actually used (in kB) :' .. collectgarbage('count'), 10,10)

    camera:attach()
    for k , v in ipairs(Particles) do
        love.graphics.draw(v , 0, 0)
    end
    --love.graphics.draw(BG , 0 , 0 )
    for k,v in ipairs(ActiveState) do
        v:Draw(dt)
    end
    if shootFire.shoot == true then
        love.graphics.draw(shootFire.img , (math.cos(gun.r) * 80) + gun.x ,(math.sin(gun.r) * 80) + gun.y , 0 , 1 , 1 ,shootFire.w/2 , shootFire.h/2)
    end

    ----- level draw
    camera:detach()
    for k,v in ipairs(ButtonActiveState) do
        v:Draw(dt)
    end
end
------------------pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp
function love.update(dt)

    --print(#State.PlayState)
    for k,v in ipairs(ButtonActiveState) do
        v:Update(dt)
    end

    --particleSystem:update(dt)
    if shootFire.shoot == true then
        shootFire.time = shootFire.time - dt
        if shootFire.time < 0 then
            shootFire.shoot = false
            shootFire.time = shootFire.T
        end
    end
    for k,v in ipairs(ActiveState) do
        v:Update(dt)
        if v.remove == true then
            if bumpWorld:hasItem(v) then
                table.remove(ActiveState , k)
                bumpWorld:remove(v)
            end
        end
    end
    for k,v in ipairs(Particles) do
        v:update(dt)
        if v:getCount() == 0 then
            table.remove(Particles , k)
        end
    end
end
-------------ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp

function PlatformGenerator(x1,y1)
    platform = { img , x = x1 ,y = y1 ,sx , sy , isPlatform = true}
    platform.img = love.graphics.newImage("assets/platform.png")
    platform.sx , platform.sy = platform.img:getDimensions()
    platform.x = platform.x
    platform.y = platform.y - platform.sy/2
    bumpWorld:add(platform , platform.x , platform.y , platform.sx , platform.sy)
    return platform
end

function TreeGenerator(x1,y1)
    platform = { img , x = x1 ,y = y1  ,sx , sy , isPlatform = true}
    platform.img = love.graphics.newImage("assets/tree.png")
    platform.sx , platform.sy = platform.img:getDimensions()
    platform.x = platform.x -platform.sx/2 + 30 + 60 -- 60 for the draw scale of 0.9
    platform.y = platform.y - platform.sy  + 100
    return platform
end
function CloudGenerator(x1,y1)
    platform = { img , x = x1 ,y = y1  ,sx , sy , isPlatform = true}
    platform.img = love.graphics.newImage("assets/cloud.png")
    platform.sx , platform.sy = platform.img:getDimensions()
    platform.x = platform.x -platform.sx/2 + 30
    platform.y = platform.y - platform.sy
    return platform
end

function GrassGenerator(x1,y1)
    grass = { img , x = x1 ,y=y1 ,imx,imy , currentFrame , 
        frames = {},activeFrame ,time= love.math.random(0.2 , 0.4),t,front = true
    }
    grass.img = love.graphics.newImage("assets/grassA.png")
    grass.imx = 52.5
    grass.imy = 51
    grass.currentFrame = love.math.random(1,4)
    grass.t = 0

    for i = 1 , 4 , 1 do
        grass.frames[i] = love.graphics.newQuad( (i-1)*grass.imx , 0, grass.imx , grass.imy , grass.img:getDimensions() )
    end
    grass.activeFrame = grass.frames[grass.currentFrame]
    function grass:Draw()
        love.graphics.draw(self.img , self.activeFrame , self.x , self.y , 0)
    end

    function grass:Update(dt)
        self.t = self.t + dt
        if(self.t >self.time )then
            self.t = 0
            if(self.front) then
                self.currentFrame = self.currentFrame + 1
                if(self.currentFrame > 4) then
                    self.currentFrame = 4
                    self.front = false
                end
            else
                self.currentFrame = self.currentFrame - 1
                if self.currentFrame < 1 then
                    self.currentFrame = 1
                    self.front = true
                end
            end
        end
        self.activeFrame = self.frames[self.currentFrame]
    end
    return grass
end

function JustForTheChill (x1,y1)
    chill = {img , x = x1,y = y1,sx,sy}
    chill.img = love.graphics.newImage("assets/justForTheChill.png")
    return chill
end

function StarGenerator(x1,y1)
    star = {img , x=x1,y=y1,sx,sy,isStar = true , isDraw = true}
    star.img = love.graphics.newImage("assets/Star.png")
    star.sx , star.sy = star.img:getDimensions()
    star.x = star.x
    star.y = star.y + star.sy/2
    bumpWorld:add(star , star.x , star.y , star.sx , star.sy)
    return star 
end

function FlagGenerator(x1,y1)
    flag = {img , x=x1 , y =y1, sx , sy , isFlag = true}
    flag.img = love.graphics.newImage("assets/flag.png")

    flag.sx , flag.sy = flag.img:getDimensions()

    flag.x = flag.x + flag.sx/2
    flag.y = flag.y - flag.sy * 0.9

    flag.sx = flag.sx * 0.9
    flag.sy = flag.sy * 0.9

    bumpWorld:add(flag , flag.x , flag.y , flag.sx , flag.sy)
    return flag
end

function SpikeGenerator(x1,y1)
    local spike = {img , x =x1, y = y1 , sx , sy , isSpike = true }
    spike.img = love.graphics.newImage("assets/spikes.png")
    spike.sx , spike.sy = spike.img:getDimensions()
    bumpWorld:add(spike , spike.x + spike.sx * 0.2, spike.y +spike.sy * 0.2 , spike.sx * 0.8 , spike.sy * 0.8)
    return spike
end


function LevelGenerator:init()
    local L = {
        ohx = w +600,ohy=300,
        ovx = 300,ovy=h + 600,
        sizeX ,
        sizeY  ,
        Elements = {} ,
        DrawOnly = {},
        Grass = {},
        Actors = {},
        prob = 0.5 ,
        scale =  0.4,
        Star = {},
        o1,o2,o3,o4,
        coins = {}
    }
    function L:Unload()
        for k,v in ipairs(self.Elements) do
            bumpWorld:remove(v)
        end
        for k,v in ipairs(self.Actors) do
            bumpWorld:remove(v)
        end

        for k,v in ipairs(self.Star) do
            if bumpWorld:hasItem(v) then
                bumpWorld:remove(v)
            end
        end

        bumpWorld:remove(self.o1)
        bumpWorld:remove(self.o2)
        bumpWorld:remove(self.o3)
        bumpWorld:remove(self.o4)

        bumpWorld:remove(flag)
    end 

    function L:Load()
        NextButton.isActive = false
        Pause = false
        gameoverActive = false
        exitButton.isActive = false

        exitButton.x = 0 ; exitButton.y = 0 -- remove this shit
        local forColor = love.math.random(1 , #ColorBackgrounds)
        love.graphics.setBackgroundColor(ColorBackgrounds[forColor][1] ,ColorBackgrounds[forColor][2] , ColorBackgrounds[forColor][3] , ColorBackgrounds[forColor][4])
    
        self.sizeX = (w/self.scale) * level
        self.sizeY = (h/self.scale) * level
        local nowPosY =0
        local nowPosX = 0
        self.prob = 0.7
        
        local sun = {
            img , x,y,sx,sy
        }
        sun.img = love.graphics.newImage("assets/sun.png")
        sun.x = love.math.random(200 ,self.sizeX-200)
        sun.y = love.math.random(0,100 )
        sun.sx , sun.sy = sun.img:getDimensions()
        sun.x = sun.x 
        sun.y = sun.y 

        insert(self.DrawOnly , sun)

        for i = nowPosY , self.sizeY -300 , 200 do
            for j = nowPosX , self.sizeX , 300  do
                if love.math.random() > 0.95 and i < 1000 then
                    local cloud = CloudGenerator(j , i)
                    insert(self.DrawOnly , cloud)
                end
            end
        end

        if(level == 1) then
            nowPosY = psy * 23
        else
            nowPosY = psy * 35
        end

        for i = nowPosY/1.5 , self.sizeY  , 250 do
            for j = nowPosX  , self.sizeX  , 300  do
                if love.math.random() > 0.85  then
                    local chill = JustForTheChill(j , i)
                    insert(self.DrawOnly , chill)
                end
            end
        end
        local flagExist = false
        for i = nowPosY , self.sizeY  , psy * 10 do
            for j = nowPosX , self.sizeX -300, psx  do
                if love.math.random() > self.prob then

                    if love.math.random() > 0.95 then
                        local tree = TreeGenerator(j , i)
                        insert(self.DrawOnly , tree)
                    end
                    if love.math.random() > 0.92 then
                        local spike = SpikeGenerator(j , i - 80)
                        insert(self.Elements , spike)
                    elseif love.math.random()>0.85 then
                        local star = StarGenerator(j , i - 200)
                        insert(self.Star , star)
                        noOfStars = noOfStars + 1
                    elseif love.math.random() > 0.5 and flagExist == false then
                        local flag = FlagGenerator( j  , i )
                        flagExist = true
                        insert(self.DrawOnly , flag)
                    end
                    if self.prob >0.8 then
                        self.prob = 0.1
                    end
                    local pt = PlatformGenerator(j,i)
                    insert(self.Elements , pt)

                    if(love.math.random() > 0.85) then
                        local grass = GrassGenerator(j,i-85)
                        insert(self.Grass , grass)
                        local grass = GrassGenerator(j + 70,i-85)
                        insert(self.Grass , grass)
                    end

                    self.prob = self.prob * 1.1
                else
                    self.prob = self.prob * 0.8
                end
            end
        end
        self.o1 ={isPlatform = true} ; self.o2 = {isPlatform = true} ; self.o3 = {} ; self.o4 = {}
        bumpWorld:add(self.o1 ,-300,0, (self.ohx / self.scale ) * (level/1.5) , 5 )
        bumpWorld:add(self.o2 , -300 , self.sizeY - 150, (self.ohx / self.scale) * (level/1.5)  , 1 )
        bumpWorld:add( self.o3,0, 0, 5, (self.ovy / self.scale)* (level/1.5) )
        bumpWorld:add( self.o4,self.sizeX, 0, 5, (self.ovy / self.scale)* (level/1.5))

        Player:Load()
        insert(self.Actors , Player)
        Player.win = false

        for i = 0 , enemyNo , 1 do
            local blacke = BlackEnemyNormal.new()
            blacke:Load()
            insert(self.Actors , blacke)
        end
        --local pt = PlatformGenerator(w/2 , h/2)
        --insert(self.Elements,pt)
        
    end

    function L:Update(dt)
        for k , v in ipairs(self.Actors) do
            v:Update(dt)
        end
        for k,v in ipairs(self.Grass) do
            v:Update(dt)
        end
    end

    function L:Draw()
        for k,v in ipairs(self.Grass) do
            v:Draw()
        end


        for k,v in pairs(self.DrawOnly) do
            love.graphics.draw( v.img , v.x , v.y , 0 , 0.8 ,0.80 )
        end
        ----- draw outline
        love.graphics.rectangle("fill", -300, 0, (self.ohx / self.scale) * (level/1.5) , -self.ohy)
        love.graphics.rectangle("fill",-300, self.sizeY - 150, (self.ohx / self.scale) * (level/1.5) , self.ohy)
        love.graphics.rectangle("fill", 0, 0, -self.ovx , (self.ovy / self.scale)* (level/1.5) )
        love.graphics.rectangle("fill", self.sizeX, 0, self.ovx , (self.ovy / self.scale)* (level/1.5))
        -----
        for k,v in pairs(self.Elements) do
            love.graphics.draw(v.img , v.x , v.y ,0,1, 1)
        end
        for k , v in ipairs(self.Actors) do
            v:Draw()
        end

        for k , v in ipairs(self.Star) do
            if (v.isDraw) then
                love.graphics.draw(v.img , v.x , v.y ,0, 0.7 ,0.7 )
            end
        end

    end
    return L

end
-------------------------------------------------ooooooooooooooooooooo
----------------iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
----------------------------------------------------------------------------------------------------------------
------------------------------------------------- Black Enemy ---------------------------------------------
BlackEnemyNormal = {}

function BlackEnemyNormal:new()
    black =  {isActive = true ,isEnemy = true,x ,y ,w,h,img ,face = 1,health,runSpeed = 500,gravity = 2000,xVelocity = 0,yVelocity = 0,
        terminalVelocity = 1500,onGround = false ,jumpVelocity = 1500,enemy = true
    }
    function black:Unload()
        --print("-----------" , self.a)
        bumpWorld:remove(self)
        self.isActive = false
        for k,v in ipairs(ActiveState) do
            if(v == self) then
                table.remove(ActiveState , k)
            end
        end
    end

    function black:Load() 
        self.x = love.math.random(1000 , levelG.sizeX - 300)
        self.y = love.math.random(800 , levelG.sizeY - 500)
        self.runSpeed = love.math.random(200 , 400)
        self.health = difficulty + 1
        self.img = love.graphics.newImage("assets/enemyNormal.png")
        self.w ,self.h = self.img:getDimensions()
        bumpWorld:add(self ,self.x , self.y, self.w, self.h)
    end

    function black:Update(dt)
        if self.health <= 0 then
            self.isActive = false
            for k,v in ipairs(levelG.Actors) do
                if( v == self) then
                    table.remove(levelG.Actors , k)
                end
            end
            if(bumpWorld:hasItem(self)) then
                bumpWorld:remove(self)
            end
            pt = ParticleObjectEnemy()
            pt:setPosition(self.x , self.y)
            pt:emit(3)
            insert(Particles , pt)
        else
            self:collide(dt)
            --print(self.onGround)
            self:move(dt)
            self:apply_gravity(dt)
        end
    end

    function black:Draw()
        if self.face == -1 then
            love.graphics.draw(self.img , self.x , self.y , 0 , self.face , 1 , self.w , 0)
        else
            love.graphics.draw(self.img ,self.x , self.y , 0 , self.face , 1)
        end
    end

    function black:move(dt)
        if Player.x < self.x then
            if self.xVelocity > -400 then
                self.xVelocity = self.xVelocity - self.runSpeed * dt
                self.face = 1
            end
        elseif Player.x >self.x then
           if self.xVelocity <400 then
                self.xVelocity = self.xVelocity + self.runSpeed * dt
                self.face = -1
           end
        end
        --print( self.y + self.h , "-----" , Player.y + Player.sizeY)
        if Player.y+Player.sizeY + 20 < self.y + self.h then
            --print(1)
            self:jump()
        end
    end
    function black:apply_gravity(dt)
        if self.yVelocity < self.terminalVelocity then 
            self.yVelocity = self.yVelocity + self.gravity * dt
        else
            self.yVelocity = self.terminalVelocity
        end
        
    end
    
    function black:collide(dt)
        local fx ,fy = self.x + self.xVelocity *dt, self.y + self.yVelocity*dt
        local ax , ay , col , len = bumpWorld:move(self , fx , fy , EnemyCheck)
        self.x = ax 
        self.y = ay
        self.onGround = false
        for i = 1 , len 
        do
            if col[i].other.isPlatform and col[i].normal.y == -1 then
                self.onGround = true
                self.yVelocity = 0
            elseif col[i].other.isPlatform and col[i].normal.y == 1 then
                self.yVelocity = 0
            end
        end
    end
    function black:jump()
        --print(self.onGround)
        if self.onGround then
            self.yVelocity = -self.jumpVelocity
        end
    end
    return black
end

----------------- Start Making Objects Here --------------------------------------------------------------------
function ParticleObject()
    local i = love.graphics.newImage("assets/shootFireCircle.png")
    local particleSystem = love.graphics.newParticleSystem(i, 10)
    particleSystem:setAreaSpread('uniform' , 10 , 10)
    particleSystem:setParticleLifetime(0.2, 0.5)
    --particleSystem:setEmissionRate(33.33)
    particleSystem:setSpeed(0,0)
    particleSystem:setColors(1,1,1,1)
    particleSystem:setRadialAcceleration(1500, 1500)
    particleSystem:setDirection(0.73)
    particleSystem:setSizes(1.5, 1, 0)
    --print(particleSystem)
    return particleSystem
end
function ParticleObjectEnemy()
    local i = love.graphics.newImage("assets/shootFireCircle.png")
    local particleSystem = love.graphics.newParticleSystem(i, 10)
    particleSystem:setAreaSpread('uniform' , 10 , 10)
    particleSystem:setParticleLifetime(0.4, 0.7)
    --particleSystem:setEmissionRate(33.33)
    particleSystem:setSpeed(0,0)
    particleSystem:setColors(0,0,0,1)
    particleSystem:setRadialAcceleration(1500, 1500)
    particleSystem:setDirection(0.73)
    particleSystem:setSizes(1.5, 1, 0)
    --print(particleSystem)
    return particleSystem
end
----------------------------------------------------------------------------------------------------------------
function EnemyCheck(item , other)
    if other.isPlayer == true or other.isBullet or other.isEnemy or other.isSpike or other.isStar or other.isFlag then
        return 'cross'
    end
    return 'slide'
end

function PlayerCheckIfBullet(item , other)
    if(other.isBullet  ) then
        return 'cross'
    end
    if ( other.isFlag )then
        if noOfStars <= 0 then
            item.win = true
        end
        return 'cross'
    end
    if (other.isEnemy) then
        --print(other.x , item.x)
        if other.health >0 then
            playerHealth = playerHealth -1
        end

        if (other.x < item.x) then
            item.xVelocity = 900
        else
            item.xVelocity = -900
        end
        other.health = 0
        return 'cross'
    end
    if (other.isStar) then
        bumpWorld:remove(other)
        noOfStars = noOfStars - 1
        other.isDraw = false
        return cross
    end
    if (other.isSpike) then
        if item.isSpiked == false then
            item.isSpiked = true
            playerHealth = playerHealth -1
        end
        if other.x < item.x then
            item.xVelocity = 900
        else
            item.xVelocity = -900
        end
        return 'slide'
    else
        item.isSpiked = false
    end
    return 'slide'
end

function BulletCheckIfPlayer(item , other)
    
    if(other.isPlayer == true or other.isBullet ) then
        return 'cross'
    elseif (other.isPlatform == true or other.enemy == true)and item.isDestroyed == false then
        local pt = ParticleObject()
        pt:setPosition(item.x , item.y)
        pt:emit(2)
        insert(Particles , pt)
        item.isDestroyed = true
        if (other.isEnemy) then
            other.health = other.health - item.bulletPower
            if other.health <= 0 then
                playerHealth = playerHealth + 1
            end
        end
        --print(item)
        return 'touch'
    end
    --print(other.isPlatform , other.enemy , other.isPlayer)
end
-----------------------Bullet ---------------------------
--BulletScript = require("Bullet")
BulletScript = {}

function BulletScript:new()
    Bullet = {isActive = true,bulletPower,x,y,r ,w=0,h=0,vx,vy,img , time = 1 , remove = false , isBullet = true , isDestroyed = false}
    
    function Bullet:Unload()
        self.isDestroyed = true
        self.isActive = false
    end
    function Bullet:Load()
        --print(self)
        self.bulletPower = bulletPower
        self.isDestroyed = false
        self.img = love.graphics.newImage("assets/bullet.png")
        self.w,self.h = self.img:getDimensions()
        bumpWorld:add(self, self.x - self.w/2 , self.y - self.h/2 , self.w  , self.h  )
    end
    function Bullet:Update(dt)
        if self.time < 0 then
            self.remove = true
        end
        self.time = self.time - dt

        local fx , fy = self.x + self.vx * dt , self.y + self.vy * dt
        local ax , ay = 0, 0
        --print(self.isDestroyed)
        if self.isDestroyed == false then

            ax , ay = bumpWorld:move(self, fx- self.w/2 , fy - self.h/2, BulletCheckIfPlayer)

        elseif self.isDestroyed == true then

            --print("1")
            for k ,v in ipairs(ActiveState) do
                if v == self then
                    table.remove(ActiveState , k)
                end
                --print(ActiveState[k])
            end
            bumpWorld:remove(self)

        end
        self.x = ax + self.w/2
        self.y = ay + self.h/2
    end
    function Bullet:Draw()
        love.graphics.draw(self.img , self.x , self.y , self.r , 1 , 1 , self.w / 2 , self.h/ 2 )
        --love.graphics.rectangle("line" , self.x , self.y , self.w ,self.h)
        --love.graphics.circle("fill", self.x, self.y, 10 )
    end
    
    return Bullet
end
------------------------Player ---------------------------
----------------------------------------------------------
Player = {}
--[[rect = {
    x = love.graphics.getWidth() /2 - 100,
    y = love.graphics.getHeight() /2,
    w = 5000,
    h= 50,
    platform = true
}
]]--
gun = {
    img,
    x,
    y,
    w,
    h ,
    r = 0 ,
}

Player = {
        isActive = false,
        --- position and size stuff -- 
        x = 200,
        y = 200 , --love.graphics.getHeight() /2 ,
        w = 30,
        h = 64,
        ----- health -- global playerHealth
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
        runSpeed = 600,
        gravity = 2000,
        xVelocity = 0,
        yVelocity = 0,
        terminalVelocity = 1500,
        onGround = false ,
        jumpVelocity = 1400,

        --------------- faceLeft or faceRight --- face = 1 for right || face = -1 for left
        face = 1,
        isPlayer = true,
        isSpiked = false
}

function Player:Unload()
    bumpWorld:remove(self)
    self.isActive = false
end

function Player:Load()
        self.x = 200
        self.y = 200

        self.xVelocity = 0
        self.yVelocity = 0

        self.isActive = true
        self.img = love.graphics.newImage("assets/playerA.png")

        self.activeFrame = 1
        for i=1,3,1
        do
            self.frames[i] = love.graphics.newQuad((i-1) * 72 , 0, 72, 142, self.img:getDimensions())
        end
        self.activeFrame = self.frames[self.currentFrame]

        ----------- gun
        gun.img = love.graphics.newImage("assets/gun.png")
        gun.x = self.x + self.sizeX/2
        gun.y = self.y + self.sizeY/2
        gun.w , gun.h = gun.img:getDimensions()
        -----------
        bumpWorld:add(self , self.x , self.y , self.sizeX , self.sizeY)

end
    -----------------

    function Player:Update(dt)
        --print(Player.x,"--" , Player.y)
        --print(camera.x , "--" ,camera.y)
        --print(love.mouse.getX() * camera.scale + camera.x , "--" ,love.mouse.getY() *camera.scale + camera.y)
        if(playerHealth <= 0 ) then
            return
        end
        if Pause == true then
            return
        end
        if(self.win == true) then
            LevelCompleted()
        end
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
        if( playerHealth <= 0) then
            if gameoverActive == false then
                GameOver()
                gameoverActive = true
            end
            return
        end

        if self.face == 1 then
            love.graphics.draw(self.img, self.activeFrame , self.x , self.y , 0 , self.face , 1 , 0, 0)
        else
            love.graphics.draw(self.img, self.activeFrame , self.x , self.y , 0 , self.face , 1 , self.sizeX, 0)
        end

        love.graphics.draw(gun.img , gun.x , gun.y , gun.r , 1,1 , 0, gun.h/2)
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
        if self.xVelocity > -self.runSpeed then
            if self.xVelocity > 0 then
                self.xVelocity = self.xVelocity - self.runSpeed *dt *3
            else
                self.xVelocity = self.xVelocity - self.runSpeed *dt
            end
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
        if self.xVelocity < self.runSpeed then
            if self.xVelocity < 0 then
                self.xVelocity = self.xVelocity + self.runSpeed *dt * 3
            else 
                self.xVelocity = self.xVelocity + self.runSpeed *dt
            end
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
    if ActiveState == State.PlayState then
        if key == "w"  and Player.onGround == true then
            Player.yVelocity = -Player.jumpVelocity
        end
    end
end
-------------------------------------------------------------------------------------------------------bulllet shooooooot
function love.mousepressed(x, y, button, isTouch)
    if Player.isActive and Player.win == false and playerHealth > 0 then
        if ActiveState == State.PlayState then
            if button == 1 then
                ---------- make bullets
                shootFire.shoot = true
                shootFire.time = shootFire.T
                local bulletScript = BulletScript.new()
                local mx,my = love.mouse.getPosition() --- local mouse poisiton
                local angle = math.atan2( my - love.graphics.getHeight() /2 , mx - love.graphics.getWidth() /2 )
                local posx = (math.cos(angle) * 60) + gun.x
                local posy = (math.sin(angle) * 60) + gun.y
                --print(camera.x , "---" , Player.x)
                bulletScript.x , bulletScript.y = posx , posy -------- assign the transform location
                local vx , vy = math.cos(angle) * bulletSpeed , math.sin(angle) * bulletSpeed
                bulletScript.r = angle
                bulletScript.vx , bulletScript.vy = vx , vy
        
                --print(vx , "---" , vy)
                --bulletObj:AddComponent(bulletScript , "Bullet")
                --bulletObj:Load()  ----- this line here .. Oh yeah I understand know ... he he he..
                bulletScript:Load()
                insert(State.PlayState , bulletScript)
                ----------
                ----------shake
                camera:shake(8 , 0.2 , 60)
            end
        end
    end
end
-------------------------------------------------------------------------- Collide
function Player:Collide(dt)


    local futureY = self.y + self.yVelocity * dt
    local futureX = self.x + self.xVelocity * dt

    local nextX , nextY , col , len = bumpWorld:move(Player , futureX , futureY , PlayerCheckIfBullet)
    self.onGround = false
    for i =1, len do
        if col[i].other.isPlatform and col[i].normal.y == -1 then
            self.onGround = true
            self.yVelocity = 0
        elseif col[i].other.isPlatform and col[i].normal.y == 1 then
            self.yVelocity = 0
        end
    end

    self.x = nextX
    self.y = nextY

end

----------------------------------------------------------------------------
---------------------------------- Menu States -----------------------------
----------------------------------------------------------------------------
--------------------------------- Button Script --------------------
function Button(text ,posx , posy , sizex , sizey  , fx,fy, func )
    button = {pressed = false , func = func , isActive = false}
    function button:Load()
        self.text = text
        self.x = posx or 0
        self.y = posy or 0
        self.w = sizex or 110
        self.h = sizey or 60
        self.fx = fx or 2
        self.fy = fy or 2
        self.x = w/2 - self.w/2
        self.y = h/2 - self.h/2
    end
    function button:Update()
        --print(self.text)
        if self.isActive == true then
            self:isPressed()
        end
    end
    function button:Draw()
        if self.isActive == true then 
            self:TextDraw()
        end
    end
    function button:TextDraw()
        mx , my = love.mouse.getPosition()
        --print(camera.y , self.y , my)
        if (mx > self.x) and (mx < self.x+self.w) and (my >self.y) and (my< self.y+self.h) then
           love.graphics.setColor(1, 0, 0, 1) 
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        love.graphics.setColor(0,0,0,1)
        love.graphics.print(self.text, self.x + 8, self.y, 0, self.fx , self.fy)
        love.graphics.setColor(1 ,1 ,1 ,1)

    end

    function button:isPressed()
        if love.mouse.isDown(1) then
            mx , my = love.mouse.getPosition()
            --print("iampressed")
            if (mx > self.x) and mouseButtonDown == false and (mx < self.x+self.w) and (my >self.y) and (my < self.y+self.h) then
                self:func()
            end
            mouseButtonDown = true
        else
            mouseButtonDown = false
        end
    end
    return button
end

function HealthText()
    text = {}
    function text:Load()
    end
    function text:Update()
    end
    function text:Draw()
        love.graphics.setColor(0,0,0,1)
        love.graphics.print( "Health:"..playerHealth , w/2 -80, 10)
        love.graphics.setColor(1,1,1,1)
    end
    return text
end

function CoinText()
    text = {}
    function text:Load()
    end
    function text:Update()
    end
    function text:Draw()
        love.graphics.setColor(0,0,0,1)
        love.graphics.print( "Stars :"..noOfStars , w/2 + 80, 10)
        love.graphics.setColor(1,1,1,1)
    end
    return text
end

------------------- Adding Buttons to Menu ----------
function MenuInitialize()
    local pb = Button("start")
    playButton = pb
    playButton.func = function ()
        levelG = LevelGenerator.init()
        levelG:Load()
        insert(State.PlayState , levelG)
        ActiveState = State.PlayState
        ButtonActiveState = ButtonState.PlayState
    end
    
    local eb = Button("Exit") 
    exitButton = eb
    exitButton.func = function()
        level = 1
        levelNo = 1
        playerHealth = 3
        enemyNo = 4
        levelG:Unload()
        noOfStars = 0
        for k,v in ipairs(State.PlayState) do
            if v==levelG then
                table.remove(State.PlayState , k)
                break
            end
        end
        levelG = nil
        ActiveState = State.MenuState
        ButtonActiveState = ButtonState.MenuState
    end

    local nb = Button("Next")
    NextButton = nb
    NextButton.func = function()
        levelG:Unload()
        for k,v in ipairs(State.PlayState) do
            if v==levelG then
                table.remove(State.PlayState , k)
                break
            end
        end
        levelG = nil
        ActiveState = State.MenuState
        ButtonActiveState = ButtonState.MenuState
        levelG = LevelGenerator.init()
        levelG:Load()
        Pause = false
        NextButton.isActive = false
        insert(State.PlayState , levelG)
        ActiveState = State.PlayState
        ButtonActiveState = ButtonState.PlayState
    end

    hT = HealthText()
    nS = CoinText()

    insert(ButtonState.MenuState , playButton)

    insert(ButtonState.PlayState , exitButton)

    insert(ButtonState.PlayState , NextButton)

    insert(ButtonState.PlayState , hT)
    insert(ButtonState.PlayState , nS)
end

function LevelCompleted()
    Pause = true
    level = level + 0.2
    if ( levelNo %2 == 0  ) then
        level = level + 0.2
    else
        enemyNo = enemyNo + 3
    end
    levelNo = levelNo + 1
    NextButton.isActive = true
end

function GameOver()
    --levelNo = 0
    --level = 1
    exitButton.isActive = true
end

