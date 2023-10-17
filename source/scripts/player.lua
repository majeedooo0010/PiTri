local pd  <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(AnimatedSprite)

function Player:init(x,y)
    local PlayerImageTable = gfx.imagetable.new("images/player-table-16-16")
    Player.super.init(self, PlayerImageTable)

    self:addState("idle",1,1)
    self:addState("walk",1,3,{tickStep = 4})
    self:addState("jump",4,4)
    self:playAnimation()

    --sprite propreties
    self:moveTo(x,y)
    self:setZIndex(Z_INDEXES.Player)
    self:setTag(TAGS.Player)
    self:setCollideRect(3,3,10,13)

    --physics properties
    self.dx =0          --X velocity
    self.dy =0          --Y velocity
    self.g  =0.2        --gravity
    self.acc=0.3        --acceleration
    self.frc=0.85       --friction
    self.jmp=(3.8*1.2)       --jump height
    self.drg=0.1        --drag
    self.mas=0.5        --minimum air speed

    --player state
    self.touchingFloor=false
    self.touchingWalls=false
    self.touchingRoofs=false
end

function Player:collisionResponse()
    return gfx.sprite.kCollisionTypeSlide
end

function Player:update()
    self:updateAnimation()

    self:handleState()
    self:handleMovementAndCollision()
end

function Player:handleState()
    if     self.currentState == "idle" then
        self:applyGravity()
        self:handleGroundInput()
    elseif self.currentState == "walk" then
        self:applyGravity()
        self:handleGroundInput()
    elseif self.currentState == "jump" then
        if self.touchingFloor then
            self:changeToIdleState()
        end
        self:applyGravity()
        self:applyDrag(self.drg)
        self:handleAirInput()
    end
end

function Player:handleMovementAndCollision()
    local _, _, collisions, length = self:moveWithCollisions(self.x+self.dx,self.y+self.dy)

    self.touchingFloor=false
    self.touchingWalls=false
    self.touchingRoofs=false

    for i=1,length do
        local collision =collisions[i]
        if collision.normal.y==-1 then
            self.touchingFloor=true
        elseif collision.normal.y==1 then
            self.touchingRoofs=true
        end
        if collision.normal.x~=0 then
            self.touchingWalls=false
        end
    end

    if     self.dx<0 then
        self.globalFlip=1
    elseif self.dx>0 then
        self.globalFlip=0
    end
end

-- Input Helper Functions
function Player:handleGroundInput()
    if     pd.buttonJustPressed(pd.kButtonA) and self.dy<1.4 then
        self:changeToJumpState()
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:changeToWalkState("left")
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self:changeToWalkState("right")
    else
        self:changeToIdleState()
    end
end

function Player:handleAirInput()
    self.dx*=self.frc
    if     pd.buttonIsPressed(pd.kButtonLeft) then
        self.dx-=self.acc
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.dx+=self.acc
    end
end

--State Transition
function Player:changeToIdleState()
    self.dx*=self.frc
    if math.abs(self.dx)<0.1 then
        self.dx=0
    end
    self:changeState("idle")
end
function Player:changeToJumpState()
    self.dy-=self.jmp
    self:changeState("jump")
end
function Player:changeToWalkState(dir)
    self.dx*=self.frc
    if     dir=="left" then
        self.dx-=self.acc
        self.globalFlip=1
    elseif dir=="right" then
        self.dx+=self.acc
        self.globalFlip=0
    end
    self:changeState("walk")
end

--Physics Helper Functions
function Player:applyGravity()
    self.dy+=self.g
    if self.touchingFloor or self.touchingRoofs then
        self.dy=0
    end
end
function Player:applyDrag(amount)
    if self.touchingWalls then
        self.dx=0
    end
end

--https://youtu.be/7GbUxjE9rRM?si=GJi9JTvz5dsRIMS_&t=2342