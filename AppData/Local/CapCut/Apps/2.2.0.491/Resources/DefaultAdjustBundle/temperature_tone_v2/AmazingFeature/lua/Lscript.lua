local exports = exports or {}
local Lscript = Lscript or {}
---@class Lscript:ScriptComponent 
---@field ColorTemperature number [UI(Range={2500, 10500}, Slider)]
---@field ColorTones number [UI(Range={-100, 100}, Slider)]

Lscript.__index = Lscript

function Lscript.new(construct, ...)
    local self = setmetatable({}, Lscript)
    self.ColorTemperature = 6500
    self.ColorTones = 0.0
    self.lastColorTemp = 6500
    self.lastColorTones = 0.0
    if construct and Lscript.constructor then Lscript.constructor(self, ...) end
    return self
end

local mix = function(a, b, x)
    return a * (1. - x) + b * x
end

local clamp = function(a, b, x)
    return math.min(math.max(x, a), b)
end

local extraDataFunc = function()
    local data = {
        0, 0.18006, 0.26352, -0.24341,
        10, 0.18066, 0.26589, -0.25479,
        20, 0.18133, 0.26846, -0.26876,
        30, 0.18208, 0.27119, -0.28539,
        40, 0.18293, 0.27407, -0.30470,
        50, 0.18388, 0.27709, -0.32675,
        60, 0.18494, 0.28021, -0.35156,
        70, 0.18611, 0.28342, -0.37915,
        80, 0.18740, 0.28668, -0.40955,
        90, 0.18880, 0.28997, -0.44278,
        100, 0.19032, 0.29326, -0.47888,
        125, 0.19462, 0.30141, -0.58204,
        150, 0.19962, 0.30921, -0.70471,
        175, 0.20525, 0.31647, -0.84901,
        200, 0.21142, 0.32312, -1.0182,
        225, 0.21807, 0.32909, -1.2168,
        250, 0.22511, 0.33439, -1.4512,
        275, 0.23247, 0.33904, -1.7298,
        300, 0.24010, 0.34308, -2.0637,
        325, 0.24792, 0.34655, -2.4681,
        350, 0.25591, 0.34951, -2.9641,
        375, 0.26400, 0.35200, -3.5814,
        400, 0.27218, 0.35407, -4.3633,
        425, 0.28039, 0.35577, -5.3762,
        450, 0.28863, 0.35714, -6.7262,
        475, 0.29685, 0.35823, -8.5955,
        500, 0.30505, 0.35907, -11.324,
        525, 0.31320, 0.35968, -15.628,
        550, 0.32129, 0.36011, -23.325,
        575, 0.32931, 0.36038, -40.770,
        600, 0.33724, 0.36051, -116.45,
    }
    local A = {{0.8951, 0.2664, -0.1614}, {-0.7502, 1.7135, 0.0367}, {0.0389, -0.0685, 1.0296}}
    local B = {{0.987, -0.1471, 0.16}, {0.4323, 0.5184, 0.0493}, {-0.0085, 0.04, 0.9685}}
    local P = {
        {0.4123907992659595, 0.357584339383878, 0.1804807884018343},
        {0.21263900587151036, 0.715168678767756, 0.07219231536073371},
        {0.019330818715591832, 0.11919477979462598, 0.9505321522496607}}
    local Q = {
        {3.2409699419045213, -1.5373831775700935, -0.4986107602930033},
        {-0.9692436362808796, 1.8759675015077208, 0.04155505740717562},
        {0.05563007969699364, -0.20397695888897655, 1.0569715142428784}}
    
    local Mat3xVec3 = function(mat3, vec3)
        return {mat3[1][1] * vec3[1] + mat3[1][2] * vec3[2] + mat3[1][3] * vec3[3],
                mat3[2][1] * vec3[1] + mat3[2][2] * vec3[2] + mat3[2][3] * vec3[3],
                mat3[3][1] * vec3[1] + mat3[3][2] * vec3[2] + mat3[3][3] * vec3[3]}
    end
    
    local Vec3xMat3 = function(vec3, mat3)
        return {mat3[1][1] * vec3[1] + mat3[2][1] * vec3[2] + mat3[3][1] * vec3[3],
                mat3[1][2] * vec3[1] + mat3[2][2] * vec3[2] + mat3[3][2] * vec3[3],
                mat3[1][3] * vec3[1] + mat3[2][3] * vec3[2] + mat3[3][3] * vec3[3]}
    end
    
    local Mat3xMat3 = function(mat3_1, mat3_2)
        return {Vec3xMat3(mat3_1[1], mat3_2),
                Vec3xMat3(mat3_1[2], mat3_2),
                Vec3xMat3(mat3_1[3], mat3_2)}
    end
    
    local diag = function(vec3)
        return {
            {vec3[1], 0.0, 0.0},
            {0.0, vec3[2], 0.0},
            {0.0, 0.0, vec3[3]}
        }
    end
    
    return {data, A, B, P, Q, ["Mat3xVec3"] = Mat3xVec3, ["Mat3xMat3"] = Mat3xMat3, ["diag"] = diag}
end

function Lscript:vec3Compute(x, y)
    x = 1000000.0 / x
    y = y * 0.0001
    local index = 5
    local data = self.extraData[index]
    index = index + 4
    while (data <= x and index < #self.extraData + 1) do
        data = self.extraData[index]
        index = index + 4
    end
    local factor = (data - x) / (data - self.extraData[index - 2 * 4])
    local temp_1 = {
        mix(self.extraData[index - 3], self.extraData[index - 7], factor),
        mix(self.extraData[index - 2], self.extraData[index - 6], factor),
    }
    local a = self.extraData[index - 5]
    local b = self.extraData[index - 1]
    local sqA = math.sqrt(a * a + 1.0)
    local sqB = math.sqrt(b * b + 1.0)
    local temp_2 = {
        mix(1. / sqB, 1. / sqA, factor),
        mix(b / sqB, a / sqA, factor)
    }
    factor = math.sqrt(temp_2[1] * temp_2[1] + temp_2[2] * temp_2[2])
    temp_1 = {
        y * temp_2[1] / factor + temp_1[1],
        y * temp_2[2] / factor + temp_1[2],
    }
    temp_2 = -4.0 * temp_1[2] + temp_1[1] + 2.0
    a = temp_1[1] * 1.5 / temp_2
    b = temp_1[2] / temp_2
    a = clamp(0.000001, 0.999999, a)
    b = clamp(0.000001, 0.999999, b)
    if (a + b > 0.999999) then
        local t = 0.999999 / (a + b)
        a = a / t
        b = b / t
    end
    return {a / b, 1.0, (1. - a - b) / b}
end

function Lscript:constructor()
    self.name = "scriptComp"
end

function Lscript:onStart(comp)
    self.ColorTemperature = 6500
    self.ColorTones = 0.0
    self.lastColorTemp = 6500
    self.lastColorTones = 0.0
    self.data = extraDataFunc()
    self.extraData = self.data[1]
    self.A = self.data[2]
    self.B = self.data[3]
    self.P = self.data[4]
    self.Q = self.data[5]
    self.Mat3xVec3 = self.data["Mat3xVec3"]
    self.Mat3xMat3 = self.data["Mat3xMat3"]
    self.diag = self.data["diag"]
    self.trans = comp.entity:getComponent("Transform")
    self.material = comp.entity:getComponent("MeshRenderer").material

end

function Lscript:onUpdate(comp, deltaTime)
    if self.ColorTemperature ~= 6500 or self.ColorTones ~= 0 then 
        if self.ColorTemperature == self.lastColorTemp and self.ColorTones == self.lastColorTones then
            return 
        end
        local vec3_1 = self:vec3Compute(self.ColorTemperature, self.ColorTones)
        self.lastColorTemp = self.ColorTemperature
        self.lastColorTones = self.ColorTones
        local vec3_2 = self:vec3Compute(6500, 0)
        local x_1 = self.Mat3xVec3(self.A, vec3_1)
        local x_2 = self.Mat3xVec3(self.A, vec3_2)
        local D = self.diag({x_1[1] / x_2[1], x_1[2] / x_2[2], x_1[3] / x_2[3]})
        local tmp = self.Mat3xMat3(D, self.A)
        tmp = self.Mat3xMat3(self.B, tmp)
        tmp = self.Mat3xMat3(tmp, self.P)
        tmp = self.Mat3xMat3(self.Q, tmp)
        self.material:setVec3("u_RVec3", Amaz.Vector3f(tmp[1][1], tmp[1][2], tmp[1][3]))
        self.material:setVec3("u_GVec3", Amaz.Vector3f(tmp[2][1], tmp[2][2], tmp[2][3]))
        self.material:setVec3("u_BVec3", Amaz.Vector3f(tmp[3][1], tmp[3][2], tmp[3][3]))
    else
        self.material:setVec3("u_RVec3", Amaz.Vector3f(1, 0, 0))
        self.material:setVec3("u_GVec3", Amaz.Vector3f(0, 1, 0))
        self.material:setVec3("u_BVec3", Amaz.Vector3f(0, 0, 1))
    end
    
end

function Lscript:onEvent(sys, event)
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        if event.args:get(0) == "temperature_intensity" then
            local intensity = event.args:get(1) * 0.5 + 0.5
            if intensity > 0.5 then
                intensity = intensity * 0.96 + 0.02
                self.ColorTemperature = (math.pow((1. - intensity)*2, 0.3437250257)*0.5) * 4000 + 4500
            elseif intensity < 0.5 then
                self.ColorTemperature = (math.pow((1. - intensity)*2-1, 1.5)*0.5+0.5) * 8000 + 2500
            elseif intensity == 0.5 then
                self.ColorTemperature = 6500
            end
        end
        if event.args:get(0) == "tone_intensity" then
            local intensity = event.args:get(1) * 0.5 + 0.5
            self.ColorTones = intensity * 200 - 100
        end
        if event.args:size() == 2 and event.args:get(0) == "reset_params" and event.args:get(1) == 1 then
            self.ColorTones = 0.0
            self.ColorTemperature = 6500
            self.lastColorTemp = 6500
            self.lastColorTones = 0.0
            self.material:setVec3("u_RVec3", Amaz.Vector3f(1, 0, 0))
            self.material:setVec3("u_GVec3", Amaz.Vector3f(0, 1, 0))
            self.material:setVec3("u_BVec3", Amaz.Vector3f(0, 0, 1))
        end
    end
end

exports.Lscript = Lscript
return exports
