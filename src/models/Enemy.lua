Enemy = cladd("Enemy", function(spriteFile)
    return cc.Sprite:create(spriteFile or "enemies/enemy1.png")
end)

function Enemy:ctor() 
    --Initialize properties
    self.state = ENEMY_STATE.IDLE
    self.speed = 100
    self.health = 1
    self.direction = "left" --"left" or "right"

    --Initialize physics body
    self:setupPhysics()

    --Initialize animations
    self:setupAnimations()

    --Set tag
    self:setTag(ENEMY_TAG)

    --Schedule update
    self:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

function Enemy:setupPhysics()
    --Create physics body
    local body = cc.PhysicsBody:createBox(
        cc.size(self:getContentSize().width * 0.8, self:getContentSize().height * 0.8),
        cc.PhysicsMaterial(0.1, 0.0, 0.5)
    )

    --Set properties
    body:setDynamic(true)
    body:setRotationEnable(false)
    body:setGravityEnable(true)
    body:setCategoryBitmask(ENEMY_CATEGORY)
    body:setContactTestBitmask(PLAYER_CATEGORY + GROUND_CATEGORY)
    body:setCollisionBitmask(PLAYER_CATEGORY + GROUND_CATEGORY + ENEMY_CATEGORY)
    

    --Set physics body
    self:setPhysicsBody(body)
end

function Enemy:setupAnimations()
    --Load animations
    local idleFrames = {}
    for i = 1, 2 do
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("enemy_idle_%d.png", i))
        if frame then
            table.insert(idleFrames, frame)
        end
    end
    if #walkFrames > 0 then
        --Create animation
        local walkAnimation = cc.Animation:createWithSpriteFrames(idleFrames, 0.3)
        self.walkAction = cc.RepeatForever:create(cc.Animate:create(idleAnimation))

        --Run animation
        self:runAction(idleAction)
end

function Enemy:setState(state)
    self.state = state
end

function Enemy:getState()
    return self.state
end

function Enemy:startMoving()
    --Set intial state
    self:setState(ENEMY_STATE.WALKING)
    --Start monving
    self:move()
end

function Enemy:move()
    --Get current velocity
    local velocity = self:getPhysicsBody():getVelocity()

    --Move to the right
    if self.direction == "right" then
        velocity.x = self.speed
        self:setFlippedX(true)
        
    --Move to the left
    else
        velocity.x = -self.speed
        self:setFlippedX(false)
        
    end
    --Apply velocity
    self:getPhysicsBody():setVelocity(velocity)

end 

function Enemy:reverseDirection()
    --Change direction
    if self.direction == "right" then
        self.direction = "left"
        self:setFlippedX(false)
    else
        self.direction = "right"
        self:setFlippedX(true)
    end

    --Move
    self:move()
end

functon Enemy:takeDamage()
    self.health = self.health - 1
    if self.health <= 0 then
        self:die()
    end
end

function Enemy:die()
    --Set state
    self:setState(ENEMY_STATE.DEAD)

    --Disable physics
    self:getPhysicsBody():setEnabled(false)

    --Play death animation
    local jump = cc.JumpBy:create(0.5, cc.p(0, -50), 50, 1)
    local fade = cc.FadeOut:create(0.5)
    local sequence = cc.Sequence:create(jump, fade, cc.CallFunc:create(function()
        self:removeFromParent()
    end))
    
    self:runAction(sequence)
end

function Enemy:update(dt)
    -- Don't update if dead
    if self.state == ENEMY_STATE.DEAD then
        return
    end
    
    -- Check for obstacles
    local pos = self:getPosition()
    local checkDistance = self:getContentSize().width * 0.6
    local checkYOffset = self:getContentSize().height * 0.4
    
    local startPoint
    local endPoint
    
    if self.direction == "left" then
        startPoint = cc.p(pos.x - checkDistance, pos.y - checkYOffset)
        endPoint = cc.p(pos.x - checkDistance, pos.y - checkYOffset - 30)
    else
        startPoint = cc.p(pos.x + checkDistance, pos.y - checkYOffset)
        endPoint = cc.p(pos.x + checkDistance, pos.y - checkYOffset - 30)
    end
    
    local ray = cc.PhysicsRayCast:create(startPoint, endPoint, GROUND_CATEGORY)
    
    if #ray == 0 then
        -- No ground ahead, reverse direction
        self:reverseDirection()
    end
    
    -- Check for wall collision
    local wallCheckDistance = self:getContentSize().width * 0.6
    
    if self.direction == "left" then
        startPoint = cc.p(pos.x, pos.y)
        endPoint = cc.p(pos.x - wallCheckDistance, pos.y)
    else
        startPoint = cc.p(pos.x, pos.y)
        endPoint = cc.p(pos.x + wallCheckDistance, pos.y)
    end
    
    ray = cc.PhysicsRayCast:create(startPoint, endPoint, GROUND_CATEGORY)
    
    if #ray > 0 then
        -- Wall collision, reverse direction
        self:reverseDirection()
    end
end