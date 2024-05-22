local exports = exports or {}
local Transform = Transform or {}
Transform.__index = Transform
function Transform.new(construct, ...)
    local self = setmetatable({}, Transform)
    self.tween1 = nil
    self.tween2 = nil
    self.tween3 = nil
    self.duration = 0
    -- 设置起始点
    self.startPoint = Amaz.Vector3f(0.3, -0.2, 0.0)
    -- 设置起始点旋转方向
    self.startRotate = Amaz.Vector3f(0.0, 0.0, 7.0)
    -- 设置起始点缩放系数
    self.startScale = Amaz.Vector3f(1.0, 1.0, 1.0)
    -- 设置结束点
    self.endPoint = Amaz.Vector3f(0.0, 0.0, 0.0)
    -- 设置结束点旋转方向
    self.endRotate = Amaz.Vector3f(0.0, 0.0, 0.0)
    -- 设置结束点缩放系数
    self.endScale = Amaz.Vector3f(1.0, 1.0, 1.0)
    -- 设置模糊强度
    self.blurIntensity = 2.0
    -- 设置模糊的方向
    self.blurDirection = Amaz.Vector2f(1.0, 1);
    self.distance = Amaz.Vector3f.Distance(self.startPoint, self.endPoint)
    if construct and Transform.constructor then Transform.constructor(self, ...) end
    return self
end

function Transform:constructor()

end

function Transform:onStart(comp)
    self.vfx = comp.entity.scene:findEntityBy("Blur")
    self.canvas = comp.entity.scene:findEntityBy("Root")
    local transform = comp.entity:getComponent("Transform")
    transform.localPosition = Amaz.Vector3f(0.0, 0.0, 0.0)
    self.tweenDirty = true
end

-- 编辑器测试用方法，更新资源包前要注释掉！！！
-- function Transform:onUpdate(comp, deltaTime)
--     if self.tweenDirty then
--         self.time = 0.0
--         -- 测试代码，修改动画时间
--         self.duration = 2.0
--         -- 设置多少秒后重复
--         self.resetDuration = 2.5
--         self.startPoint = Amaz.Vector3f(self.startPoint.x * 0.5625, -self.startPoint.y, self.startPoint.z)
--         self.startScale = Amaz.Vector3f(self.startScale.x * 0.5625, self.startScale.y, self.startScale.z)
--         self.endPoint = Amaz.Vector3f(self.endPoint.x * 0.5625, -self.endPoint.y, self.endPoint.z)
--         self.endScale = Amaz.Vector3f(self.endScale.x * 0.5625, self.endScale.y, self.endScale.z)
--         self.startRotate = Amaz.Vector3f(self.startRotate.x, self.startRotate.y, -self.startRotate.z)
--         self.endRotate = Amaz.Vector3f(self.endRotate.x, self.endRotate.y, -self.endRotate.z)
--     end

--     self.time = self.time + deltaTime
--     -- Amaz.LOGE("TAG", "time: " .. self.time)
--     -- self.time = 0.1
--     if self.time > self.duration then
--         self:seek(self.duration)
--     else
--         self:seek(self.time)
--     end
    
--     if self.time > self.resetDuration then
--         self.time = 0.0
--     end
-- end

local function funcEaseActionMove(t, b, c, d)
    t=t/d
    if t~=0.0 and t~=1.0 then
        t = math.exp(-7.0 * t) * 1.0 * math.sin((t - 0.075) * (2.0*math.pi) / 0.3) + 1.0
    end
    return Amaz.Ease.linearFunc(t,c,b)
end

local function funcEaseActionRotate(t, b, c, d)
    t=t/d
    if t~=0.0 and t~=1.0 then
        t = math.exp(-4.5 * t) * 1.0 * math.sin((t - 0.07) * (2.0*math.pi) / 0.25) + 1.0
    end
    return Amaz.Ease.linearFunc(t,c,b)
end

local function funcEaseBlurAction(t, b, c, d)
    t=t/d
    t = (-7 * math.exp(-7.0 * t) * 1.0 * math.sin((t - 0.075) * (2.0*math.pi) / 0.3) + math.exp(-7.0 * t) * 1.0 * math.cos((t - 0.075) * (2.0*math.pi) / 0.3) * 2.0 * math.pi / 0.3) * 0.1    
    
    return c * t
end

local function checkDirty(self)
    if self.tweenDirty then
        local transform = self.vfx:getComponent("Transform")
        local screenW = Amaz.BuiltinObject:getOutputTextureWidth()
        local screenH = Amaz.BuiltinObject:getOutputTextureHeight()
        
        local ratio = screenW / screenH
        self.startPoint = Amaz.Vector3f(self.startPoint.x * ratio, self.startPoint.y, self.startPoint.z)
        self.endPoint = Amaz.Vector3f(self.endPoint.x * ratio, self.endPoint.y, self.endPoint.z)
        self.tween1 = self.canvas.scene.tween:fromTo(transform, 
                                                {
                                                    ["localPosition"] = self.startPoint,
                                                    ["localScale"] = self.startScale,
                                                },   
                                                {
                                                    ["localPosition"] = self.endPoint,
                                                    ["localScale"] = self.endScale,
                                                }, 
                                                self.duration, 
                                                -- 修改曲线
                                                funcEaseActionMove,
                                                -- Amaz.Ease.ElasticOut,
                                                nil, 
                                                0.0, 
                                                nil, 
                                                false)
        self.tween3 = self.canvas.scene.tween:fromTo(transform, 
                                            {
                                                ["localEulerAngle"] = self.startRotate,
                                            },   
                                            {
                                                ["localEulerAngle"] = self.endRotate,
                                            }, 
                                            self.duration, 
                                            -- 修改曲线
                                            funcEaseActionRotate,
                                            -- Amaz.Ease.ElasticOut,
                                            nil, 
                                            0.0, 
                                            nil, 
                                            false)
        local material = self.vfx:getComponent("Sprite2DRenderer").material
        material["blurDirection"] = self.blurDirection
        self.tween2 = self.canvas.scene.tween:fromTo(material, 
                                                {["blurStep"] = self.blurIntensity/self.duration},
                                                {["blurStep"] = 0.0}, 
                                                self.duration, 
                                                -- Amaz.Ease.quadIn, 
                                                funcEaseBlurAction,
                                                -- funcEaseAction,
                                                nil, 
                                                0.0, 
                                                nil, 
                                                false)
        -- self.tween3 = self.canvas.scene.tween:fromTo(material, 
        --                                         {["blurStep"] = self.distance / self.duration * self.blurIntensity},
        --                                         {["blurStep"] = 0.0}, 
        --                                         self.duration / 2.0, 
        --                                         Amaz.Ease.quadOut, 
        --                                         nil, 
        --                                         0.0, 
        --                                         nil, 
        --                                         false)
                                                
        self.tweenDirty = false

	end
end

local function updateHandle(entity, canvas)
    if entity == nil then 
        return 
    end

    local animTrans = entity:getComponent("Transform")
    local parentTrans = canvas:getComponent("Transform")
    
    local userS = parentTrans.localScale
    local userR = parentTrans.localOrientation
    local userT = parentTrans.localPosition

    local animS = animTrans.localScale
    local animR = animTrans.localOrientation
    local animT = animTrans.localPosition

    local mat = parentTrans.localMatrix

    local matA = animTrans.localMatrix

    local userM = parentTrans.localMatrix
    userM:SetTRS(Amaz.Vector3f(0.0, 0.0, 0.0), userR, userS)

    -- move to (0,0)
    matA:SetTRS(animT, animR, animS)
    matA:AddTranslate(userT)

    animTrans.localMatrix = matA * userM * parentTrans.localMatrix:Invert_Full()
end

function Transform:seek(time)
    checkDirty(self)
    if(time <= self.tween1.duration) then
        self.tween1:set(time)
        self.tween3:set(time)
        self.tween2:set(time)
    end

    -- if time <= self.tween2.duration then
    --     self.tween2:set(time)
    -- else
    --     self.tween3:set(time - self.tween2.duration)
    -- end

    updateHandle(self.vfx, self.canvas)
end

function Transform:setDuration(duration)
    self.duration = duration
    self.tweenDirty = true
end

function Transform:clear()
    self.tweenDirty = true
    if self.tween1 then
        self.tween1:set(0)
        self.tween1:clear()
        self.tween1 = nil
    end

    if self.tween2 then
        self.tween2:set(0)
        self.tween2:clear()
        self.tween2 = nil
    end

    if self.tween3 then
        self.tween3:set(0)
        self.tween3:clear()
        self.tween3 = nil
    end
end
exports.Transform = Transform
return exports
