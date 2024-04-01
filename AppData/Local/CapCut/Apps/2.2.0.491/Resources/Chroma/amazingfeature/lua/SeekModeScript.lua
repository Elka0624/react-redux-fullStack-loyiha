--@input float curTime = 0.0{"widget":"slider","min":0,"max":1}
--@input float RRR = 0.0{"widget":"slider","min":0,"max":1}
--@input float GGG = 0.0{"widget":"slider","min":0,"max":1}
--@input float BBB = 0.0{"widget":"slider","min":0,"max":1}
--@input float INTENSITY = 0.0{"widget":"slider","min":0,"max":1}
--@input float SHADOW = 0.0{"widget":"slider","min":0,"max":1}

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

    self.selectedColour = Amaz.Vector4f(0.0,0.0,0.0,1.0);
    self.intensity = 0.0;
    self.shadow = 0.0;

    self.it = 0.0;
    self.sh = 0.0;

    self.edit_mode = false;
    return self
end

function SeekModeScript:constructor()

end

local function logistic(x0, xOffset, xScale)
    local x = (x0 - xOffset) * xScale;
    return 1.0 / (1.0 + math.exp(-x));
end

function SeekModeScript:onUpdate(comp, detalTime)
    if (self.edit_mode) then
    --测试用
        local props = comp.entity:getComponent("ScriptComponent").properties
        if props:has("curTime") then
            self:seekToTime(comp, props:get("curTime"))
        end
    else
    --实际用
        self:seekToTime(comp, self.curTime - self.startTime)
    end
end

function SeekModeScript:onStart(comp)
    self.material = comp.entity:getComponent("MeshRenderer").material

    self.material:setVec4("selectedColour", self.selectedColour);
    self.material:setFloat("inputIntensity", self.intensity);
    self.material:setFloat("inputShadow", self.shadow);
    
    self.material:setFloat("it", self.it);
    self.material:setFloat("sh", self.sh);
end

function SeekModeScript:getParamsFromEditor(comp)
    local props = comp.entity:getComponent("ScriptComponent").properties
    self.selectedColour.x = props:get("RRR");
    self.selectedColour.y = props:get("GGG");
    self.selectedColour.z = props:get("BBB");
    self.intensity = props:get("INTENSITY");
    self.shadow = props:get("SHADOW");
end


function SeekModeScript:seekToTime(comp, time)
    -- if self.first == nil then
    --     self.first = true
    --     self:start(comp)
    -- end

    if (self.edit_mode) then
        self:getParamsFromEditor(comp);
        self.material:setVec4("selectedColour", self.selectedColour);
        self.material:setFloat("inputIntensity", self.intensity);
        self.material:setFloat("inputShadow", self.shadow);

        self.it = math.pow(self.intensity, 0.25); 
        self.material:setFloat("it", self.it);

        self.sh = logistic(self.shadow, 0.3, 4.0);
        self.material:setFloat("sh", self.sh);
    end
end

function SeekModeScript:onEvent(comp, event)
    Amaz.LOGE("AE_TEXT_TAG", "ONEVENT");
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "color" then
            local color = event.args:get(1);
            if (color ~= nil) then
                self.selectedColour.x = color:get(0);
                self.selectedColour.y = color:get(1);
                self.selectedColour.z = color:get(2);
                self.selectedColour.w = color:get(3);
                self.material:setVec4("selectedColour", self.selectedColour);
            end
        elseif event.args:get(0) == "intensity" then
            local intensity = event.args:get(1);
            if (intensity ~= nil) then
                self.intensity = intensity;
                self.material:setFloat("inputIntensity", self.intensity);

                self.it = math.pow(self.intensity, 0.25); 
                self.material:setFloat("it", self.it);
                
                -- Amaz.LOGE("AE_TEXT_TAG", "get intensity from client : "..self.intensity);
                -- Amaz.LOGE("AE_TEXT_TAG", "calculate it from intensity : "..self.it);
            end
        elseif event.args:get(0) == "shadow" then
            local shadow = event.args:get(1);
            if (shadow ~= nil) then
                self.shadow = shadow;
                self.material:setFloat("inputShadow", self.shadow);

                self.sh = logistic(self.shadow, 0.3, 4.0);
                self.material:setFloat("sh", self.sh);
            end
        elseif event.args:get(0) == "reset_params" then
            self.intensity = 0;
            self.material:setFloat("inputIntensity", self.intensity);
            self.it = math.pow(self.intensity, 0.25); 
            self.material:setFloat("it", self.it);
            self.shadow = 0;
            self.material:setFloat("inputShadow", self.shadow);
            self.sh = logistic(self.shadow, 0.3, 4.0);
            self.material:setFloat("sh", self.sh);
        end
    end
end

exports.SeekModeScript = SeekModeScript
return exports

