Item = class("Item", function(spriteFile)
    return cc.Sprite:create(spriteFile or "items/item1.png")
end)

function Item:ctor() 

    --Initialize physics body
    self:setupPhysics()

    --Set tag
    self:setTag(ITEM_TAG)

end

function Item:setupPhysics()
    --Create physics body
    local body = cc.PhysicsBody:createBox(
        cc.size(self:getContentSize().width, self:getContentSize().height),
        cc.PhysicsMaterial(0.1, 0.0, 0.5)
    )

    --Set properties
    body:setDynamic(true)
    body:setGravityEnable(true)
    body:setCategoryBitmask(ITEM_CATEGORY)
    body:setContactTestBitmask(PLAYER_CATEGORY + GROUND_CATEGORY)
    body:setCollisionBitmask(GROUND_CATEGORY)

    --Set physics body
    self:setPhysicsBody(body)
end 

function Item:onCollected() 
    --Play collected animation
    local scale = cc.ScaleTo:create(0.2, 1.5)
    local fade = cc.FadeOut:create(0.2)
    local spawn = cc.Spawn:create(scale, fade)
    local sequence = cc.Sequence:create(spawn, cc.CallFunc:create(function() 
        self:removeFromParent() 
    end))

    self:runAction(sequence)
end

