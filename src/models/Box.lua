Box = class("Box", function()
    return cc.Sprite:create("items/box.png")
end)

function Box:ctor()
    --Initialize properties
    self.state = BOX_STATE.NORMAL
    self.containsItem = false
    self.itemType = nil

    --Initialize physics body
    self:setupPhysics()
    --Set tag
    self:setTag(BOX_TAG)
end 

function Box:setupPhysics()
    --Create physics body
    local body = cc.PhysicsBody:createBox(
        cc.size(self:getContentSize().width, self:getContentSize().height),
        cc.PhysicsMaterial(0.1, 0.0, 0.5)
    )

    --Set properties
    body:setDynamic(true)
    body:setGravityEnable(false)
    body:setCategoryBitmask(BOX_CATEGORY)
    body:setContactTestBitmask(PLAYER_CATEGORY)
    body:setCollisionBitmask(PLAYER_CATEGORY)

    --Set physics body
    self:setPhysicsBody(body)
end

function Box:setState(state)
    self.state = state

    if state == BOX_STATE.HIT then
        --Play hit animation
        local jump = cc.JumpBy:create(0.2, cc.p(0, 0), 5, 1)
        self:runAction(jump)

        --Change sprite
        self:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("items/box_hit.png"))
    elseif state == BOX_STATE.BROKEN then
        --Change sprite
        self:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("items/box_broken.png"))
    
    end

end

function Box:getState()
    return self.state
end

function Box:setItem(itemType)
    self.containsItem = true
    self.itemType = itemType
end

function Box:hit()
    --Can only hit normal boxes
    if self.state ~= BOX_STATE.NORMAL then
        return
    end
    --Update state
    self:setState(BOX_STATE.HIT)

    --Play break sound
    SoundManager:playEffect("sfx/break.wav")

    --Spawn item if box contains one
    if self.containsItem then
        self:spawnItem()
    end

    --Set broken state
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function() 
            self:setState(BOX_STATE.BROKEN) 
        end)
    ))
end

function Box:spawnItem()

    local item

    if self.itemType == "coin" then
        item = Coin:new()
    elseif self.itemType == "powerup" then
        item = PowerUp:new()
    else
        --Default to coin
        item = Coin:new()
    end

    --Position item above box
    item:setPosition(cc.p(
        self:getPositionX(),
        self:getPositionY() + self:getContentSize().height + item:getContentSize().height / 2))
    
    --Add item to parent
    self:getParent():addChild(item)

    --Apply initial velocity
    if item:getPhysicsBody() then 
        item:getPhysicsBody():setVelocity(cc.p(0, 200))
    end

end