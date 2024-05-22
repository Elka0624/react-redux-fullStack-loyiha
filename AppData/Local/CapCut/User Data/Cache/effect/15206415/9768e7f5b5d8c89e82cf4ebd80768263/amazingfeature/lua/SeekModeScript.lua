--@input float curTime = 0.0{"widget":"slider","min":0,"max":3.0}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
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

    self:seekToTime(comp, self.curTime - self.startTime)
end

function SeekModeScript:onStart(comp)
    -- self.animSeqCom = comp.entity:getComponent("AnimSeqComponent")
    self.pass0Material = comp.entity.scene:findEntityBy("Pass0"):getComponent("MeshRenderer").material
    self.pass1Material = comp.entity.scene:findEntityBy("Pass1"):getComponent("MeshRenderer").material
    self.pass2Material = comp.entity.scene:findEntityBy("Pass2"):getComponent("MeshRenderer").material
    self.pass3Material = comp.entity:getComponent("MeshRenderer").material
    self.pass4Material = comp.entity.scene:findEntityBy("Pass4"):getComponent("MeshRenderer").material
    self.camera0 = comp.entity.scene:findEntityBy("CameraPass0"):getComponent("Camera")
    self.camera1 = comp.entity.scene:findEntityBy("CameraPass1"):getComponent("Camera")
    self.camera3 = comp.entity.scene:findEntityBy("CameraPass3"):getComponent("Camera")
    self.camera4 = comp.entity.scene:findEntityBy("CameraPass4"):getComponent("Camera")

end

function SeekModeScript:seekToTime(comp, time)

    -- self.animSeqCom:seekToTime(time)

    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
        local mW = self.width*0.5
        local mH = self.height*0.5
        self.pass0Material:setInt("imageWidth", mW)
        self.pass0Material:setInt("imageHeight", mH)
        self.pass1Material:setInt("imageWidth", mW)
        self.pass1Material:setInt("imageHeight", mH)
        self.camera0.renderTexture.width = mW
        self.camera0.renderTexture.height = mH
        self.camera1.renderTexture.width = mW
        self.camera1.renderTexture.height = mH
        mW = self.width*0.35
        mH = self.height*0.35
        self.pass3Material:setInt("imageWidth", mW)
        self.pass3Material:setInt("imageHeight", mH)
        self.pass4Material:setInt("imageWidth", mW)
        self.pass4Material:setInt("imageHeight", mH)
        self.camera3.renderTexture.width = mW
        self.camera3.renderTexture.height = mH
        self.camera4.renderTexture.width = mW
        self.camera4.renderTexture.height = mH
    end

    -- self.pass3Material:setFloat("timer", time)
end

function SeekModeScript:onEvent(sys, event)
    if "effects_adjust_luminance" == event.args:get(0) then
        local intensity = event.args:get(1)
        self.pass2Material:setFloat("intensity",2.0*intensity+0.5)
    end
end
exports.SeekModeScript = SeekModeScript
return exports
