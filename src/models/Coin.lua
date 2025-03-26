Coin = class("Coin", function()
    return cc.Sprite:create("items/coin.png")
end)

function Coin:ctor()
    --Initialize physics body
    self:setupPhysics()
    --Initialize animations
    self:setupAnimations()
    --Set tag
    self:setTag(COIN_TAG)
end

function Coin:setupPhysics()
    --Create physics body
    local body = cc.PhysicsBody:createCircle(
        self:getContentSize().width / 2 * 0.8,
        cc.PhysicsMaterial(0.1, 0.0, 0.5)
    )

    --Set properties
    body:setDynamic(true)
    body:setGravityEnable(false)
    body:setCategoryBitmask(ITEM_CATEGORY)
    body:setContactTestBitmask(PLAYER_CATEGORY)
    body:setCollisionBitmask(0)

    --Set physics body
    self:setPhysicsBody(body)
end

function Coin:setupAnimations()
    --Load animations
    local spinFrames = {}
    for i = 1, 4 do
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("coin_spin_%d.png", i))
        if frame then
            table.insert(spinFrames, frame)
        end
    end

    if #spinFrames > 0 then
        --Create animation
        local spinAnimation = cc.Animation:createWithSpriteFrames(spinFrames, 0.15)
        self.spinAction = cc.RepeatForever:create(cc.Animate:create(spinAnimation))

        --Run animation
        self:runAction(self.spinAction)
    end
end

function Coin:onCollected()
    --Play collected animation
    local scale = cc.ScaleTo:create(0.2, 1.5)
    local fade = cc.FadeOut:create(0.2)
    local spawn = cc.Spawn:create(scale, fade)
    local sequence = cc.Sequence:create(spawn, cc.CallFunc:create(function() 
        self:removeFromParent() 
    end))

    self:runAction(sequence)
end