Player = class("Player", function() 
    return cc.Sprite:create()
end)

function Player:ctor()
    
    --Initialaize properties
    self.state = PLAYER_STATE.IDLE
    self.isJumping = false
    self.isOnGround = false
    self.isPoweredUp = false
    self.powerUpTime = 0
    self.maxJumpHeight = 150
    self.speed = 200
    self.jumpForce = 400
    self.health = 1
    self.coins = 0

    --Initialize physics body
    self:setupPhysics()

    --Initialize animations
    self:setupAnimations()

    --Set tag
    self:setTag(PLAYER_TAG)

    --Schedule update
    self:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

end

function Player:setupPhysics()
    --Create physics body
    local body = cc.PhysicsBody:createBox(
        cc.size(self:getContentSize().width * 0.8, self:getContentSize().height * 0.8),
        cc.PhysicsMaterial(0.1, 0.0, 0.5)

    )

    --Set properties
    body:setDynamic(true)
    body:setRotationEnable(false)
    body:setGravityEnable(true)
    body:setCategoryBitmask(PLAYER_CATEGORY)
    body:setContactTestBitmask(ENEMY_CATEGORY + GROUND_CATEGORY + ITEM_CATEGORY + BOX_CATEGORY)
    body:setCollisionBitmask(GROUND_CATEGORY + BOX_CATEGORY)
    body:setMass(1.0)

    --Set physics body
    self:setPhysicsBody(body)
end

function Player:setupAnimations()
    --Load animations
    local idleFrames = {}
    for i = 1, 2 do
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("player_idle_%d.png", i))
        if frame then
            table.insert(idleFrames, frame)
        end
    end

    if #idleFrames > 0 then
        local idleAnimation = cc.Animation:createWithSpriteFrames(idleFrames, 0.3)
        self.idleAction = cc.RepeatForever:create(cc.Animate:create(idleAnimation))
        self:runAction(self.idleAction)
        self:idleAction:pause()
    end

    --Walking animation
    local walkFrames = {}
    for i = 1, 4 do
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("player_walk_%d.png", i))
        if frame then
            table.insert(walkFrames, frame)
        end
    end

    if #walkFrames > 0 then
        local walkAnimation = cc.Animation:createWithSpriteFrames(walkFrames, 0.15)
        self.walkAction = cc.RepeatForever:create(cc.Animate:create(walkAnimation))
        self:runAction(self.walkAction)
        self.walkAction:pause()
    end

    --Jump animation
    local jumpFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("player_jump.png")
    if jumpFrame then
        self.jumpAction = cc.RepeatForever:create(cc.Animate:create(cc.Animation:createWithSpriteFrames({jumpFrame}, 1)))
        self:runAction(self.jumpAction)
        self.jumpAction:pause()
    end

    --Power up animation
    local powerUpFrames = {}
    for i = 1, 3 do
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("player_powerup_%d.png", i))
        if frame then
            table.insert(powerUpFrames, frame)
        end
    end

    if #powerUpFrames > 0 then
        local powerUpAnimation = cc.Animation:createWithSpriteFrames(powerUpFrames, 0.15)
        self.powerUpAction = cc.RepeatForever:create(cc.Animate:create(powerUpAnimation))
        self:runAction(self.powerUpAction)
        self.powerUpAction:pause()
    end
end

function Player:setState(state)
    if self.state == state then
        return
    end

    --Stop all animations
    if self.idleAction then
        self.idleAction:pause()
    end
    
    if self.walkAction then
        self.walkAction:pause()
    end

    if self.jumpAction then
        self.jumpAction:pause()
    end

    if self.powerUpAction then
        self.powerUpAction:pause()
    end

    --Set new state
    self.state = state

    --Play animation based on state
    if state == PLAYER_STATE.IDLE then
        if self.idleAction then
            self.idleAction:resume()
        end
    elseif state == PLAYER_STATE.WALKING then
        if self.walkAction then
            self.walkAction:resume()
        end
    elseif state == PLAYER_STATE.JUMPING or state = PLAYER_STATE.FALLING then
        if self.jumpAction then
            self.jumpAction:resume()
        end
    elseif state == PLAYER_STATE.POWER_UP then
        if self.powerUpAction then
            self.powerUpAction:resume()
        end
    end
end

function Player:getState()
    return self.state
end

function Player:move(direction)
    --Get current velocity
    local velocity = self:getPhysicsBody():getVelocity()

    --Set new velocity based on direction
    if direction == "left" then
        velocity.x = -self.speed
        self:setFlippedX(true)
    elseif direction == "right" then
        velocity.x = self.speed
        self:setFlippedX(false)
    else
        velocity.x = 0
    end

    --Apply new velocity
    self:getPhysicsBody():setVelocity(velocity)

    --Set state
    if seft.isOnGround then
        if direction == "left" or direction == "right" then
            self:setState(PLAYER_STATE.WALKING)
        else
            self:setState(PLAYER_STATE.IDLE)
        end
    end
end

function Player:jump()
    if self.isOnGround and not self.isJumping then
        --Apply jump force
        local velocity = self:getPhysicsBody():getVelocity()
        velocity.y = self.jumpForce
        seft:getPhysicsBody():setVelocity(velocity)

        --Set jump flag
        self.idJumping = true
        self.isOnGround = false

        --Play jump sound
        SoundManager:playEffect("sfx/jump.wav")

        --Set state
        self:setState(PLAYER_STATE.JUMPING)
    end
end

function Player:land()
    self.isOnGround = true
    self.isJumping = false

    --Set state based on velocity
    local velocity = self:getPhysicsBody():getVelocity()
    if math.abs(velocity.x) > 0.1 then
        self:setState(PLAYER_STATE.WALKING)
    else
        self:setState(PLAYER_STATE.IDLE)
    end
end

function Player:applePowerUp()
    self.isPoweredUp = true
    self.powerUpTime = duration

    --Set state
    self:setState(PLAYER_STATE.POWER_UP)

    --Make player blink
    local blink = cc.Bilnk:create(duration, duration * 5)
    self:runAction

    --Play power up sound
    SoundManager:playEffect("sfx/powerup.wav")

    --Schedule power up timer
    self:scheduleOnce(function()
    self.isPoweredUp = false
    if self.isOnGround then
        if math.abs(self:getPhysicsBody():getVelocity().x) > 0.1 then
            self:setState(PLAYER_STATE.WALKING)
        else
            self:setState(PLAYER_STATE.IDLE)
        end
    else
        self:setState(PLAYER_STATE.JUMPING)
    end
    end, duration)
end

function Player:takeDamage()
    if self.isPoweredUp then
        self.health = sefl.health - 1
        if self.health <= 0 then
            self:die()
        else
            --Play damage animation
            local blink = cc.Blink:create(1.0, 5)
            self:runAction(blink)
        end
    end
end

function Player:die()
    --Set state
    self:setState(PLAYER_STATE.DEAD)

    --Play death sound
    SoundManager:playEffect("sfx/death.wav")

    --Disable physics
    self:getPhysicsBody():setEnabled(false)

    --Play death animation
    local jump = cc.JumpBy:create(1.0, cc.p(0, -100), 100, 1)
    local fade = cc.FadeOut:create(1.0)
    local sequence = cc.Sequence:create(jump, fade, cc.CallFunc:create(function()
        self:removeFromParent()
    end))
    self:runAction(sequence)
end

function Player:addCoin()
    self.coins = self.coins + 1

    --Play coin sound
    SoundManager:playEffect("sfx/coin.wav")
end

function Player:getCoins()
    return self.coins
end

function Player:update(dt) 
    --Update power up timer
    if self.isPoweredUp then
        self.powerUpTime = self.powerUpTime - dt
        if self.powerUpTime <= 0 then
            self.isPoweredUp = false
        end
    end

    --Update player state
    local velocity = self:getPhysicsBody():getVelocity()

    if not self.isOnGround then
        if velocity.y > 0 then
            self:setState(PLAYER_STATE.JUMPING)
        elseif velocity.y < 0 then
            self:setState(PLAYER_STATE.FALLING)
        end
    end

    --Check if player is on ground
    local pos = self:getPosition()
    local ray = cc.PhysicsRayCast:create(
        cc.p(pos.x, pos.y),
        cc.p(pos.x, pos.y - (self:getContentSize().height / 2 + 1)),
        GROUND_CATEGORY
    )

    if #ray > 0 then 
        if not self.isOnGround then
            self:land()
        end
    else
        self.isOnGround = false
    end
end