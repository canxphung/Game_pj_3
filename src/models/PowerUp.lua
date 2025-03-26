PowerUp = class("PowerUp", function()
    return cc.Sprite:create("items/powerup.png")
end)

function PowerUp:ctor()
    -- Initialize properties
    self.type = "star"  -- star, mushroom, etc.
    self.duration = 10.0  -- for temporary power-ups
    
    -- Initialize physics body
    self:setupPhysics()
    
    -- Initialize animations
    self:setupAnimations()
    
    -- Set tag
    self:setTag(POWER_UP_TAG)
    
    -- Start moving
    self:startMoving()
end

function PowerUp:setupPhysics()
    -- Create physics body
    local body = cc.PhysicsBody:createBox(
        cc.size(self:getContentSize().width, self:getContentSize().height),
        cc.PhysicsMaterial(0.1, 0.0, 0.5)
    )
    
    -- Set properties
    body:setDynamic(true)
    body:setGravityEnable(true)
    body:setCategoryBitmask(ITEM_CATEGORY)
    body:setContactTestBitmask(PLAYER_CATEGORY + GROUND_CATEGORY)
    body:setCollisionBitmask(GROUND_CATEGORY)
    
    -- Set physics body
    self:setPhysicsBody(body)
end

function PowerUp:setupAnimations()
    -- Flashing animation for star
    if self.type == "star" then
        local fadeIn = cc.FadeTo:create(0.3, 255)
        local fadeOut = cc.FadeTo:create(0.3, 180)
        local sequence = cc.Sequence:create(fadeIn, fadeOut)
        local repeat_ = cc.RepeatForever:create(sequence)
        
        self:runAction(repeat_)
    end
end

function PowerUp:startMoving()
    -- Apply initial velocity
    local direction = math.random(0, 1) == 0 and -1 or 1
    self:getPhysicsBody():setVelocity(cc.p(100 * direction, 0))
    
    -- Schedule direction changes
    self:schedule(function()
        local velocity = self:getPhysicsBody():getVelocity()
        velocity.x = -velocity.x
        self:getPhysicsBody():setVelocity(velocity)
    end, 2.0)
end

function PowerUp:onCollected(player)
    -- Apply power-up effect to player
    player:applyPowerUp(self.duration)
    
    -- Play collection animation
    local scale = cc.ScaleTo:create(0.2, 1.5)
    local fade = cc.FadeOut:create(0.2)
    local spawn = cc.Spawn:create(scale, fade)
    local sequence = cc.Sequence:create(spawn, cc.CallFunc:create(function()
        self:removeFromParent()
    end))
    
    self:runAction(sequence)
end