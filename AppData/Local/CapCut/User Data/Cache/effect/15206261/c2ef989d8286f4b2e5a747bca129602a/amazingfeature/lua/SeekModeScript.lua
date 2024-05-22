--@input float curTime = 0.0{"widget":"slider","min":0,"max":3.0}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript

local fps = 30
local frameTime = 1000/fps
local sumFrames = 10

local curTime = 0.0

local xscale_init = 0.15    --0.0
local yscale_init = 0.15    --0.0
local timeCount_init = 0.0
local xscale = 0.0
local yscale = 0.0
local timeCount = 0.0
local A_init = 0.0
local maxA = 180.0

  
local effects_adjust_horizontal_chromatic = 1.0
local effects_adjust_vertical_chromatic = 1.0

function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    self.width = 0
    self.height = 0
    return self
end

function SeekModeScript:constructor()

end

function SeekModeScript:onUpdate(comp, detalTime)
    ---6406838584582466119-62869694993587325397941091116234047831
    --local props = comp.entity:getComponent("ScriptComponent").properties
    --if props:has("curTime") then
        --self:seekToTime(comp, props:get("curTime") - self.startTime)
    --end
    --406017906769327848616982245513113966117941091116234047831
    --self.curTime = self.curTime + detalTime
    self:seekToTime(comp, self.curTime - self.startTime)
end

function SeekModeScript:onStart(comp)
    self.EASpeed = 1.0
    self.animSeqCom = comp.entity.scene:findEntityBy("Pass3"):getComponent("AnimSeqComponent")
    self.pass0Material = comp.entity:getComponent("MeshRenderer").material
    self.pass1Material = comp.entity.scene:findEntityBy("Pass1"):getComponent("MeshRenderer").material
    self.pass2Material = comp.entity.scene:findEntityBy("Pass2"):getComponent("MeshRenderer").material
    self.pass3Material = comp.entity.scene:findEntityBy("Pass3"):getComponent("MeshRenderer").material
end

function SeekModeScript:seekToTime(comp, time)

    --self.animSeqCom:seekToTime(time)

    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
        self.pass2Material:setInt("baseTexWidth", self.width)
        self.pass2Material:setInt("baseTexHeight", self.height)
        self.pass3Material:setInt("baseTexWidth", self.width)
        self.pass3Material:setInt("baseTexHeight", self.height)
    end
    self.pass0Material:setFloat("u_iwidthoffset", 1.0/self.width)

    local index = math.floor(time*fps*self.EASpeed)
    local indexLimit = math.floor(200/frameTime)
    local period = math.floor(1200/frameTime)
    index = index%period

    -- if delta<200 then
    if index < indexLimit then
        xscale = math.max(0.0,xscale_init-0.03*index)
        yscale = math.max(0.0, xscale - 0.0005*index)
        timeCount = (timeCount_init+1.0*index)%999

        self.pass1Material:setFloat("u_xscale", math.random(1,10)/100)
        self.pass1Material:setFloat("u_yscale", math.random(100,400)/6000)
        self.pass1Material:setFloat("u_time", timeCount/1000.0)
        self.pass1Material:setInt("u_black", 0)

        local A = (A_init + 1*index)%8
        self.pass0Material:setFloat("u_texeloffset", math.floor(A/4) * maxA)

        -- -1541401642112372366-77069173637411359049104074914236207125-1406838606176867155-5557910313100208320-1659571960295634515752081865891644703035850328528591690129223222407376247995343230584830622186-42485567168954769576923580715680738175-8546663177100261454-8146798020216647427
        self.animSeqCom:seek(9)

        self.pass0Material:setFloat("u_iwidthoffset", effects_adjust_horizontal_chromatic/self.width)
        self.pass0Material:setFloat("u_iheightoffset", effects_adjust_vertical_chromatic/self.height)


    else
        self.pass1Material:setInt("u_black", 1)

        -- 5011837069088525894-1541401642112372366-7698945321087592421-19649067976878576-6434556475241203928-4924352801153475203
        local id = index-indexLimit
        local currFrame = math.min(id+3,sumFrames-1)
        self.animSeqCom:seek(currFrame)

        -- -54922483363313667856966583850552745755-3436143413482147469-2022553554713492258，-30142439166795682022270519720238116080-7555744510787585797-3202883359101062988-60880239784330195877563828917837076465
        timeCount_init = 0.0
        xscale_init = 0.15
        yscale_init = 0.15
        A_init = 0.0
    end
end

function SeekModeScript:onEvent(sys, event)
    if "effects_adjust_speed" == event.args:get(0) then
        local intensity = event.args:get(1)
        self.EASpeed = 1.5*intensity+0.5
    end
    if "effects_adjust_horizontal_chromatic" == event.args:get(0) then
        local intensity = event.args:get(1)
        effects_adjust_horizontal_chromatic = 12*intensity-6
    end
    if "effects_adjust_vertical_chromatic" == event.args:get(0) then
        local intensity = event.args:get(1)
        effects_adjust_vertical_chromatic = 12*intensity-6
    end
end


exports.SeekModeScript = SeekModeScript
return exports
