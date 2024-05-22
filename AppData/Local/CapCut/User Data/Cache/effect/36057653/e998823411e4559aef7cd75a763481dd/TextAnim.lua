local exports = exports or {}
local TextAnim = TextAnim or {}
---@class TextAnim:ScriptComponent
---@field effectMaterial Material
---@field effectMaterial1 Material
---@field quad Mesh
---@field alphaStart number
---@field alphaEnd number
---@field alphaOffset number
---@field duration number
---@field progress number [UI(Range={0, 1}, Slider)]
---@field autoPlay boolean
---@field sharedMaterial1 Material
---@field sharedMaterial2 Material
---@field sharedMaterial3 Material
---@field sharedMaterial4 Material
---@field sharedMaterial5 Material
---@field sharedMaterial6 Material
---@field sharedMaterial7 Material
---@field sharedMaterial8 Material
---@field sharedMaterial9 Material
---@field sharedMaterial10 Material
---@field renderToRT boolean
TextAnim.__index = TextAnim


local util = nil      ---@type Util
local isEditor = Amaz.Macros and Amaz.Macros.EditorSDK

local AETools = AETools or {}
AETools.__index = AETools

function AETools:new(attrs)
    local self = setmetatable({}, AETools)
    self.attrs = attrs

    local max_frame = 0
    local min_frame = 100000
    for _,v in pairs(attrs) do
        for i = 1, #v do
            local content = v[i]
            local cur_frame_min = content[2][1]
            local cur_frame_max = content[2][2]
            max_frame = math.max(cur_frame_max, max_frame)
            min_frame = math.min(cur_frame_min, min_frame)
        end
    end

    self.all_frame = max_frame - min_frame
    self.min_frame = min_frame


    return self
end

function AETools._remap01(a,b,x)
    if x < a then return 0 end
    if x > b then return 1 end
    return (x-a)/(b-a)
end

function AETools._cubicBezier(p1, p2, p3, p4, t)
    return {
        p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
        p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
    }
end

function AETools:_cubicBezier01(_bezier_val, p)
    local x = self:_getBezier01X(_bezier_val, p)
    return self._cubicBezier(
        {0,0},
        {_bezier_val[1], _bezier_val[2]},
        {_bezier_val[3], _bezier_val[4]},
        {1,1},
        x
    )[2]
end

function AETools:_getBezier01X(_bezier_val, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts+te)*0.5
        local value = self._cubicBezier(
            {0,0},
            {_bezier_val[1], _bezier_val[2]},
            {_bezier_val[3], _bezier_val[4]},
            {1,1},
            tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
    until(te-ts < 0.0001)

    return (te+ts)*0.5
end

function AETools._mix(a, b, x)
    return a * (1-x) + b * x
end

function AETools:GetVal(_name, _progress)
    local content = self.attrs[_name]
    if content == nil then
        return nil
    end

    local cur_frame = _progress * self.all_frame + self.min_frame
    for i = 1, #content do
        local info = content[i]
        local start_frame = info[2][1]
        local end_frame = info[2][2]
        if cur_frame >= start_frame and cur_frame < end_frame then
            local cur_progress = self._remap01(start_frame, end_frame, cur_frame)
            local bezier = info[1]
            local value_range = info[3]

            if #bezier > 4 then
                -- currently scale attrs contains more than 4 bezier values
                local res = {}
                for k = 1, 3 do
                    local cur_bezier = {bezier[k], bezier[k+3], bezier[k+3*2], bezier[k+3*3]}
                    local p = self:_cubicBezier01(cur_bezier, cur_progress)
                    res[k] = self._mix(value_range[1][k], value_range[2][k], p)
                end
                return res

            else
                local p = self:_cubicBezier01(bezier, cur_progress)
 
                if type(value_range[1]) == "table" then
                    local res = {}
                    for j = 1, #value_range[1] do
                        res[j] = self._mix(value_range[1][j], value_range[2][j], p)
                    end
                    return res
                end
                return self._mix(value_range[1], value_range[2], p)
            end

        end
    end

    local first_info = content[1]
    local start_frame = first_info[2][1]
    if cur_frame<start_frame then
        return first_info[3][1]
    end

    local last_info = content[#content]
    local end_frame = last_info[2][2]
    if cur_frame>=end_frame then
        return last_info[3][2]
    end

    return nil
end

function AETools:test()
    Amaz.LOGI("lrc "..tostring(self.key_frame_info), tostring(#self.key_frame_info))
end


local util = {}     ---@class Util
local json = cjson.new()
local rootDir = nil
local record_t = {}

local function getBezierValue(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-t)*t+3*xc2*(1-t)*t*t+t*t*t
    ret[2] = 3*yc1*(1-t)*(1-t)*t+3*yc2*(1-t)*t*t+t*t*t
    return ret
end

local function getBezierDerivative(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-3*t)+3*xc2*(2-3*t)*t+3*t*t
    ret[2] = 3*yc1*(1-t)*(1-3*t)+3*yc2*(2-3*t)*t+3*t*t
    return ret
end

local function getBezierTfromX(controls, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts+te)/2
        local value = getBezierValue(controls, tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
    until(te-ts < 0.0001)

    return (te+ts)/2
end

local function changeVec2ToTable(val)
    return {val.x, val.y}
end

local function changeVec3ToTable(val)
    return {val.x, val.y, val.z}
end

local function changeVec4ToTable(val)
    return {val.x, val.y, val.z, val.w}
end

local function changeCol3ToTable(val)
    return {val.r, val.g, val.b}
end

local function changeCol4ToTable(val)
    return {val.r, val.g, val.b, val.a}
end

local function changeTable2Vec4(t)
    return Amaz.Vector4f(t[1], t[2], t[3], t[4])
end

local function changeTable2Vec3(t)
    return Amaz.Vector3f(t[1], t[2], t[3])
end

local function changeTable2Vec2(t)
    return Amaz.Vector2f(t[1], t[2])
end

local function changeTable2Col3(t)
    return Amaz.Color(t[1], t[2], t[3])
end

local function changeTable2Col4(t)
    return Amaz.Color(t[1], t[2], t[3], t[4])
end

local _typeSwitch = {
    ["vec4"] = function(v)
        return changeVec4ToTable(v)
    end,
    ["vec3"] = function(v)
        return changeVec3ToTable(v)
    end,
    ["vec2"] = function(v)
        return changeVec2ToTable(v)
    end,
    ["float"] = function(v)
        return tonumber(v)
    end,
    ["string"] = function(v)
        return tostring(v)
    end,
    ["col3"] = function(v)
        return changeCol3ToTable(v)
    end,
    ["col4"] = function(v)
        return changeCol4ToTable(v)
    end,

    -- change table to userdata
    ["_vec4"] = function(v)
        return changeTable2Vec4(v)
    end,
    ["_vec3"] = function(v)
        return changeTable2Vec3(v)
    end,
    ["_vec2"] = function(v)
        return changeTable2Vec2(v)
    end,
    ["_float"] = function(v)
        return tonumber(v)
    end,
    ["_string"] = function(v)
        return tostring(v)
    end,
    ["_col3"] = function(v)
        return changeTable2Col3(v)
    end,
    ["_col4"] = function(v)
        return changeTable2Col4(v)
    end,
}

local function typeSwitch()
    return _typeSwitch
end

local function createTableContent()
    -- Amaz.LOGI("lrc", "createTableContent")
    local t = {}
    for k,v in pairs(record_t) do
        t[k] = {}
        t[k]["type"] = v["type"]
        t[k]["val"] = v["func"](v["val"])
    end
    return t
end

function util.registerParams(_name, _data, _type)
    record_t[_name] = {
        ["type"] = _type,
        ["val"] = _data,
        ["func"] = _typeSwitch[_type]
    }
end

function util.getRegistedParams()
    return record_t
end

function util.setRegistedVal(_name, _data)
    record_t[_name]["val"] = _data
end

function util.getRootDir()
    if rootDir == nil then
        local str = debug.getinfo(2, "S").source
        rootDir = str:match("@?(.*/)")
    end
    Amaz.LOGI("lrc getRootDir 123", tostring(rootDir))
    return rootDir
end

function util.registerRootDir(path)
    Amaz.LOGI("lrc registerRootDir", tostring(path))
    rootDir = path
end

function util.bezier(controls)
    local control = controls
    if type(control) ~= "table" then
        control = changeVec4ToTable(controls)
    end
    return function (t, b, c, d)
        t = t/d
        local tvalue = getBezierTfromX(control, t)
        local value =  getBezierValue(control, tvalue)
        return b + c * value[2]
    end
end

function util.remap01(a,b,x)
    if x < a then return 0 end
    if x > b then return 1 end
    return (x-a)/(b-a)
end

function util.mix(a, b, x)
    return a * (1-x) + b * x
end

function util.CreateJsonFile(file_path)
    local t = createTableContent()
    local content = json.encode(t)
    local file = io.open(util.getRootDir()..file_path, "w+b")
    if file then
      file:write(tostring(content))
      io.close(file)
    end
end

function util.ReadFromJson(file_path, jsonData)
    local file = io.input(util.getRootDir() .. file_path)
    local text = io.read("*a")
    if jsonData ~= "" then
        text = jsonData
    end
    local json_data = json.decode(text)
    return json_data
end

function util.bezierWithParams(input_val_4, min_val, max_val, in_val, reverse)
    if type(input_val_4) == "tabke" then
        if reverse == nil then
            return util.bezier(input_val_4)(util.remap01(min_val, max_val, in_val), 0, 1, 1)
        else
            return util.bezier(input_val_4)(1-util.remap01(min_val, max_val, in_val), 0, 1, 1)
        end
    else
        if reverse == nil then
            return util.bezier(util.changeVec4ToTable(input_val_4))(util.remap01(min_val, max_val, in_val), 0, 1, 1)
        else
            return util.bezier(util.changeVec4ToTable(input_val_4))(1-util.remap01(min_val, max_val, in_val), 0, 1, 1)
        end
    end
end


function util.clamp(min, max, value)
	return math.min(math.max(value, min), max)
end

function util.test()
    Amaz.LOGI("lrc", "test123")
end

-- local ae_attribute = {
-- 	["ADBE_Gaussian_Blur_2_0001_0_0"]={
-- 		{{0.33333333, 0, 0.1, 1, }, {0, 4, }, {{40, }, {0, }, }, }, 
-- 	}, 
-- 	["ADBE_Scale_0_1"]={
-- 		{{0.166666667,0.166666667,0.166666667, 0,0,0.166666667, 0.833333333,0.833333333,0.833333333, 1,1,0.833333333, }, {0, 4, }, {{0, 0, 100, }, {50, 50, 100, }, }, }, 
-- 		{{0.03,0.03,0.03, 0,0,0.03, 0.2,0.2,0.2, 1,1,0.2, }, {4, 21, }, {{50, 50, 100, }, {100, 100, 100, }, }, }, 
-- 	}, 
-- 	["ADBE_Scale_1_2"]={
-- 		{{0.03,0.03,0.03, 0,0,0.03, 0.2,0.2,0.2, 1,1,0.2, }, {5, 34, }, {{50, 50, 100, }, {100, 100, 100, }, }, }, 
-- 	}, 
-- }



-- ["ADBE_Position_1_1_1"]={
--     {{0.027272727, 0.821506779, 0.66666667, 1, }, {0, 11, }, {{-144, }, {20, }, }, }, 
-- }, 
-- ["ADBE_Opacity_1_2"]={
--     {{0.027272727, 0.278942261, 0.66666667, 1, }, {0, 11, }, {{0, }, {100, }, }, }, 
-- }, 

-- ["ADBE_Position_1_1_1"]={
--     {{0.027272727, 0.944107149, 0.66666667, 1, }, {2, 13, }, {{184, }, {20, }, }, }, 
-- }, 
-- ["ADBE_Opacity_1_2"]={
--     {{0.027272727, 0.278942261, 0.66666667, 1, }, {2, 13, }, {{0, }, {100, }, }, }, 
-- }, 

-- ["ADBE_Position_1_1_1"]={
--     {{0.027272727, 0.821506779, 0.66666667, 1, }, {4, 15, }, {{-144, }, {20, }, }, }, 
-- }, 
-- ["ADBE_Opacity_1_2"]={
--     {{0.027272727, 0.278942261, 0.66666667, 1, }, {4, 15, }, {{0, }, {100, }, }, }, 
-- }, 

-- ["ADBE_Position_1_1_1"]={
--     {{0.027272727, 0.944107149, 0.66666667, 1, }, {6, 17, }, {{184, }, {20, }, }, }, 
-- }, 
-- ["ADBE_Opacity_1_2"]={
--     {{0.027272727, 0.278942261, 0.66666667, 1, }, {6, 17, }, {{0, }, {100, }, }, }, 
-- }, 

-- ["ADBE_Position_1_1_1"]={
--     {{0.027272727, 0.821506779, 0.66666667, 1, }, {8, 19, }, {{-144, }, {20, }, }, }, 
-- }, 
-- ["ADBE_Opacity_1_2"]={
--     {{0.027272727, 0.278942261, 0.66666667, 1, }, {8, 19, }, {{0, }, {100, }, }, }, 
-- }, 



local ae_attribute = {
	["ADBE_Scale_0_0"]={
		{{0.603584998,0.603584998,0.33333333, 0.001345646,0.001345646,0.33333333, 0,0,0.66666667, 0.988988442,0.988988442,0.66666667, }, {25, 44, }, {{82, 82, 100, }, {100, 100, 100, }, }, }, 
	}, 

	["ADBE_Position_1_1_2"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {13, 24, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_1_3"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {13, 24, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_2_5"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {12, 23, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_2_6"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {12, 23, }, {{0, }, {100, }, }, }, 
	}, 



	["ADBE_Position_1_3_8"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {11, 22, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_3_9"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {11, 22, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_4_11"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {10, 21, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_4_12"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {10, 21, }, {{0, }, {100, }, }, }, 
	}, 



	["ADBE_Position_1_5_14"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {9, 20, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_5_15"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {9, 20, }, {{0, }, {100, }, }, }, 
	}, 



	["ADBE_Position_1_6_17"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {8, 19, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_6_18"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {8, 19, }, {{0, }, {100, }, }, }, 
	}, 

    

	["ADBE_Position_1_8_20"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {11, 22, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_8_21"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {11, 22, }, {{0, }, {100, }, }, }, 
	}, 



	["ADBE_Position_1_9_23"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {10, 21, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_9_24"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {10, 21, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_10_26"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {9, 20, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_10_27"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {9, 20, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_11_29"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {8, 19, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_11_30"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {8, 19, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_12_32"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {7, 18, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_12_33"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {7, 18, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_13_35"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {6, 17, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_13_36"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {6, 17, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_15_38"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {9, 20, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_15_39"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {9, 20, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_16_41"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {8, 19, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_16_42"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {8, 19, }, {{0, }, {100, }, }, }, 
	}, 



	["ADBE_Position_1_17_44"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {7, 18, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_17_45"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {7, 18, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_18_47"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {6, 17, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_18_48"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {6, 17, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_19_50"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {5, 16, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_19_51"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {5, 16, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_20_53"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {4, 15, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_20_54"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {4, 15, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_22_56"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {7, 18, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_22_57"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {7, 18, }, {{0, }, {100, }, }, }, 
	}, 

	["ADBE_Position_23_58"]={
		{{0.166667, 0.166667, 0.833333, 0.833333, }, {6, 17, }, {{-237, 184, 0, }, {-237, 20, 0, }, }, }, 
	}, 
	["ADBE_Position_1_23_59"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {6, 17, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_23_60"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {6, 17, }, {{0, }, {100, }, }, }, 
	}, 
	["ADBE_Position_24_61"]={
		{{0.166667, 0.166667, 0.833333, 0.833333, }, {5, 16, }, {{-237, 184, 0, }, {-237, 20, 0, }, }, }, 
	}, 
	["ADBE_Position_1_24_62"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {5, 16, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_24_63"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {5, 16, }, {{0, }, {100, }, }, }, 
	}, 
	["ADBE_Position_25_64"]={
		{{0.166667, 0.166667, 0.833333, 0.833333, }, {4, 15, }, {{-237, 184, 0, }, {-237, 20, 0, }, }, }, 
	}, 
	["ADBE_Position_1_25_65"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {4, 15, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_25_66"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {4, 15, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_26_68"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {3, 14, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_26_69"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {3, 14, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_27_71"]={
		{{0.027272727, 0.944107149, 0.66666667, 1, }, {2, 13, }, {{184, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_27_72"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {2, 13, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_29_74"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {5, 16, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_29_75"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {5, 16, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_30_77"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {4, 15, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_30_78"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {4, 15, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_31_80"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {3, 14, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_31_81"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {3, 14, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_32_83"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {2, 13, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_32_84"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {2, 13, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_33_86"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {1, 12, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_33_87"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {1, 12, }, {{0, }, {100, }, }, }, 
	}, 


	["ADBE_Position_1_34_89"]={
		{{0.027272727, 0.821506779, 0.66666667, 1, }, {0, 11, }, {{-144, }, {20, }, }, }, 
	}, 
	["ADBE_Opacity_34_90"]={
		{{0.027272727, 0.278942261, 0.66666667, 1, }, {0, 11, }, {{0, }, {100, }, }, }, 
	}, 
}


function TextAnim.new(construct, ...)
    local self = setmetatable({}, TextAnim)
    self.effectMaterial = nil
    self.curTime = 0
    self.progress = 0
    self.autoPlay = false
    self.duration = 1.0
    self.quad = nil
    self.offset = 220.6380781101
    self.alphaStart = 0
    self.alphaEnd = 0.2
    self.lastTime = self.lastTime or 0.0
    self.alphaOffset = -0.15
    self.x1 = 0
    self.y1 = 0
    self.x2 = 0
    self.y2 = 0
    self.lastGap = 0.0
    self.renderToRT = true
    self.intensity = 0.5
    self.lastIntensity = 0.5

    self.cloneEntity = {}
	self.cloneEntityRenderer = {}
    self.ctrans = {}
    self.cloneMaterial={}
    self.cloneText = {}
    self.cloneEffectLayers = {}
    self.cloneEffectParams = {}


    if construct and TextAnim.constructor then TextAnim.constructor(self, ...) end
    return self
end

function TextAnim:constructor()
    self.name = "scriptComp"
end

local function getRootDir()
    local rootDir = nil
    if rootDir == nil then
        local str = debug.getinfo(2, "S").source
        rootDir = str:match("@?(.*/)")
    end
    return rootDir
end

function TextAnim:onSetProperty(key, value)
    if key == "caption_duration_info" and value ~= "" then
        self:ReadFromJson(value)
        -- self:initAnim()
    end
end

function TextAnim:onStart(comp)
    self.comp = comp
    util.registerRootDir(getRootDir())
    self.cloneSharedMaterial={self.sharedMaterial1,self.sharedMaterial2}

    self.text = comp.entity:getComponent('SDFText')
    if self.text == nil then
        local text = comp.entity:getComponent('Text')
        if text ~= nil then
            self.text = comp.entity:addComponent('SDFText')
            self.text:setTextWrapper(text)
        end
    end
    self.rich_text = comp.entity:getComponent('Text')
    self.renderer = true
	if self.text ~= nil then
		self.renderer = comp.entity:getComponent("MeshRenderer")
	else
		self.renderer = comp.entity:getComponent("Sprite2DRenderer")
	end
    self.textEntity=comp.entity
    
    self.clone_richText = {}
    self.first = true
    self.trans = comp.entity:getComponent("Transform")
    self.parentTrans = self.trans.parent
    self.parentEntity = self.parentTrans.entity
    self.text:forceTypeSetting()
    self:transInitial(self.trans)
    self.first = true
    self.attrs = AETools:new(ae_attribute)
    self.user_set_font_size = nil
    local chars = self.text.chars
	local charCount = chars:size()
    self.need_clone_num  = 1
    self.clone_num = 1
    self.maxClone_num = 2
    self:getWordInfo()
    -- self.need_clone_num = #self.wordIndexInfo
    local max_clone_num = 1
    for index, value in ipairs(self.wordIndexInfo) do
        if self.wordIndexInfo[index] then
            local cur_num = #self.wordIndexInfo[index]
            max_clone_num = max_clone_num < cur_num and cur_num or max_clone_num
        end
    end
    self.clone_num = max_clone_num >= 2 and 2 or 1 

end

function TextAnim:ReadFromJson(jsondata)
    local jsonData = util.ReadFromJson("data_val.json", jsondata)
    self.textTimeData = jsonData
end

function TextAnim:transInitial(trans)
    trans.localScale = Amaz.Vector3f(1.,1.,1.)
    trans.localPosition = Amaz.Vector3f(0.,0.,0.)
    trans.localEulerAngle = Amaz.Vector3f(0.,0.,0.)
end

function TextAnim:initMaterial()

    self.text.renderToRT = true
    local materials = Amaz.Vector()
    local InsMaterials = nil
    if self.effectMaterial1 then
        InsMaterials = self.effectMaterial1:instantiate()
    else
        InsMaterials = self.renderer.material
    end
    materials:pushBack(InsMaterials)
    self.materials = materials
    self.renderer.materials = self.materials

    self.material = self.renderer.material
end



function TextAnim:setMatToSDFText(i,text, rendermaterial)

    text.renderToRT = true
    local materials = Amaz.Vector()
    local InsMaterials = nil
    if self.cloneSharedMaterial[i] then
        InsMaterials = self.cloneSharedMaterial[i]:instantiate()
    -- else
    --     InsMaterials = self.effectMaterial:instantiate()
    end
    materials:pushBack(InsMaterials)
    self.cloneMaterial[i] = materials
    rendermaterial.materials = materials

    return rendermaterial.material
end


function TextAnim:updatematerial()
    self:showChar()
    -- self:updatePosition()
end

function TextAnim:initAnimConfig()
    self.text:forceTypeSetting()
	self.count = self.text.chars:size()
    self.size = {}
    for i = 0, self.text.chars:size() - 1 do
        local char = self.text.chars:get(i)
        if char.utf8code ~= "\n" then
            self.size[char.rowth] = char.idInRow
        end
    end
end

function TextAnim:addEffectLayers(i)
	if self.text.effectTextParam ~= nil then
    	self.effectLayers = self.text.effectTextParam.effectLayers
	else
		return 
	end
	self.cloneEffectParams[i] = self.cloneEntity[i]:getComponent("SDFText").effectTextParam
	if self.cloneEffectParams[i] ~= nil and self.effectLayers ~= nil then
		self.cloneEffectLayers[i] = self.cloneEffectParams[i].effectLayers
		for j = 0, self.cloneEffectLayers[i]:size() - 1 do 
			if j < self.effectLayers:size() then
				self.cloneEffectLayers[i]:get(j).mat = self.effectLayers:get(j).mat
				self.cloneEffectLayers[i]:get(j).texture = self.effectLayers:get(j).texture
			end
		end
	end
end

function TextAnim:addEntity(i)
	if self.cloneEntity[i]==nil then
		self.cloneEntity[i] = self.textEntity.scene:createEntity("sdf"..i)
		self.cloneEntity[i]:addComponent("Transform")
		self.ctrans[i] = self.cloneEntity[i]:getComponent("Transform")
		self.ctrans[i].localPosition = Amaz.Vector3f(0.0, 0.0, -10.0)
        self.ctrans[i].localScale = Amaz.Vector3f(1, 1, 1.0)
        		
		if self.rich_text then
            self.clone_richText[i] = self.cloneEntity[i]:cloneComponentOf(self.rich_text)
		end
		self.cloneEntity[i]:cloneComponentOf(self.text)
		self.cloneEntity[i]:cloneComponentOf(self.renderer)
        self.cloneText[i]=self.cloneEntity[i]:cloneComponentOf(self.text)
        if self.clone_richText[i] then
            self.clone_richText[i].letters = self.clone_richText[i].letters
			self.cloneText[i]:setTextWrapper(self.clone_richText[i])
		end
		-- self.cloneText[i].str=self.originText 
		self.cloneText[i].backgroundColor = Amaz.Vector4f(0,0,0,0)
		self.cloneText[i]:forceTypeSetting()
		self.ctrans[i].parent = self.parentTrans
		if self.parentTrans then
			self.parentTrans.children:pushBack(self.ctrans[i])
		end
		self:addEffectLayers(i)
	end
end

function TextAnim:getLayer()
    self.entities = self.text.entity.scene.entities
    for i = 0, self.entities:size() - 1 do
        local e = self.entities:get(i)
        local trans = self.trans
        local entityname = ""
        while trans ~= nil  do
            if trans.entity.name ~= "" then
                entityname = trans.entity.name
                break
            end
            trans = trans.parent
        end
        if entityname == e.name then
            self.layer = i
            break
        end
    end
end



function TextAnim:onUpdate(comp, time)
    if isEditor then
        self.curTime = self.curTime + time
        self:seek(self.curTime)
    end
end

local clamp = function(a, b, x)
    return math.max(math.min(x, b), a)
end

--
function TextAnim:getTextColor()
    local text = self.text.entity:getComponent("Text")
    local textColor = Amaz.Vector3f(1.0,1.0,1.0)
    if text then --
        -- if text.forceFlushCommandQueue then
        --     text:forceFlushCommandQueue()
        -- end
        local letters = text.letters
        if letters:size() > 0 then
            local letter0 = letters:get(0)
            textColor = letter0 and letter0.letterStyle and letter0.letterStyle.letterColor
        end
    else
        textColor = self.text.textColor
    end
    return textColor
end

function TextAnim:getTextFontSize()
    local text = self.rich_text
    -- local textColor = Amaz.Vector3f(1.0,1.0,1.0)
    local fontSize = 24
    if text then
        -- if text.forceFlushCommandQueue then
        --     text:forceFlushCommandQueue()
        -- end
        local letters = text.letters
        if letters:size() > 0 then
            local letter0 = letters:get(0)
            fontSize = letter0 and letter0.letterStyle and letter0.letterStyle.fontSize
        end
    else
        fontSize = self.text.fontSize
    end
    return fontSize
end


function TextAnim:updateScale(scale)
    local trans = self.comp.entity:getComponent("Transform")
    trans.localScale = Amaz.Vector3f(scale,scale,scale)
    if self.clone_num >= 1 then
        for index = 1, self.clone_num do
            local trans1 = self.cloneEntity[index]:getComponent("Transform")
            trans1.localScale = Amaz.Vector3f(scale,scale,scale)
        end
    end
end

function TextAnim:getWordInfo()
	self.count = self.text.chars:size()
	self.wordIndexInfo = {}
    self.wordList = {}
    self.wordTab = {}
    local count = 1
    local count1 = 1
    local prerowth = 1
    for i = 1, self.count do
        local char = self.text.chars:get(i - 1)
        -- Amaz.LOGE("===>>wordInfo",tostring(char))
        local index = char.rowth + 1
        self.wordIndexInfo[index] =  self.wordIndexInfo[index] or {}
        self.wordIndexInfo[index][count] = i

        self.wordList[count1] = self.wordList[count1] or {}
        table.insert(self.wordList[count1],char)
        if char and char.utf8code == " " then
            count = count + 1
            count1 = count1 + 1
        end

        if prerowth ~= index then
            count = 1
            prerowth = index
        end


        local wordType = count%2 == 0 and 2 or 1
        self.wordTab[wordType] = self.wordTab[wordType] or {}
        table.insert(self.wordTab[wordType],char)
    end
end

function TextAnim:getWordIndex(char)
    for key, charT in pairs(self.wordTab) do
        for index, value in pairs(charT) do
            -- Amaz.LOGE("=====>>tt",key.."=="..index.."=="..tostring(value))
            if value == char then
                return key
            end
        end
    end
    return -1
end

function TextAnim:showChar()
    for i = 1, self.count do
        local char = self.text.chars:get(i - 1)
        -- Amaz.LOGE("=====>>dd:",i.."=="..tostring(char))
        -- if self:getWordIndex(char) == 1 then
        --     char.scale = Amaz.Vector3f(0, 0, 0)
        -- else
        --     char.scale = Amaz.Vector3f(0, 0, 0)
        -- end
    end
    -- Amaz.LOGI("dkdkkdkd",self.clone_num)
    for index = 1, self.clone_num do

        for i = 1, self.count do
            local char = self.text.chars:get(i - 1)
            local cloneChar = self.cloneText[index].chars:get(i-1)
            if self:getWordIndex(char) == index then
                cloneChar.scale = Amaz.Vector3f(1, 1, 1)
            else
                cloneChar.scale = Amaz.Vector3f(0, 0, 0)
            end
        end

    end
    
end



function TextAnim:seek(time)
    if self.first == true then
        self.ori_str = self.text.str
        math.randomseed(114514)
        self.lastTime = self.progress
        self:initAnimConfig()
        if Amaz.Macros and Amaz.Macros.EditorSDK then
            self.wordGap = 0.0
        else
        end
	    self.text.renderToRT = self.renderToRT
        if self.renderToRT then
            self:initMaterial()
        end
        self.first = false
        local fs = self.rich_text.letters:get(0).letterStyle.fontSize
        self.ori_fs = fs
        self:getLayer()

        local w = Amaz.BuiltinObject:getOutputTextureWidth()
        local h = Amaz.BuiltinObject:getOutputTextureHeight()

        self.text.targetRTExtraSize = Amaz.Vector2f(0.0,0.0)

        local text = self.rich_text
        if text then 
            if text.BloomPath then
                self.pre_bloom_path = text.BloomPath
                text.BloomPath = ""
    
            elseif text.bloomPath then
                self.pre_bloom_path = text.bloomPath
                text.bloomPath = ""
    
            end
        end
        for key, richText in pairs(self.clone_richText) do
            if text.BloomPath then
                richText.BloomPath = ""
            elseif text.bloomPath then
                richText.bloomPath = ""
            end
        end


        self.text:forceTypeSetting()

        local order_index =1 
        if #self.cloneEntity < 1 and self.clone_num >= 1 then
            for i = 1, self.clone_num do
                self:addEntity(i)
                self.cloneEntityRenderer[i] = self.cloneEntity[i]:getComponent("MeshRenderer")
                self:setMatToSDFText(i,self.cloneEntity[i]:getComponent("SDFText"), self.cloneEntity[i]:getComponent("MeshRenderer"))
                if self.trans.parent then
                    order_index = order_index*10
                    local parent_idx=self.layer*order_index
                    self.cloneEntityRenderer[i].autoSortingOrder=false

                    -- self.cloneEntityRenderer[i].autoSortingOrder=false
                    -- self.renderer.autoSortingOrder = false
                    self.cloneEntityRenderer[i].sortingOrder=self.renderer.sortingOrder+i

                    -- self.cloneEntityRenderer[i].sortingOrder=parent_idx+i
                else
                    self.cloneEntityRenderer[i].autoSortingOrder=true
                end
                self.cloneText[i].renderToRT=true
            end
        end

    end
    -- Amaz.LOGI("====>>:",self.clone_num)
    -- self.originText = self.text.str
    -- if self.clone_num >= 1 then
    --     for i = 1, self.clone_num do
    --         if self.cloneText[i] then
    --             self.cloneText[i].str=self.originText 
    --             self.cloneText[i]:forceTypeSetting()
    --         end
    --     end
    -- end


    if isEditor then
        if self.autoPlay then
            self.progress = time % self.duration / self.duration
        end
    else
        self.progress =time % (self.duration+0.00001) / (self.duration+0.00001)
    end

    local use_fs = self.ori_fs < 30 and 30 or self.ori_fs
    self.trans_scale = 1
    local s = self.trans_scale
    self.trans.localScale = Amaz.Vector3f(s,s,s)
    self.multiscale = s
    -- trans.localPosition = Amaz.Vector3f(0, 0.1, 0)
    for index = 1, self.clone_num do
        local trans1 = self.cloneEntity[index]:getComponent("Transform")
        trans1.localScale = Amaz.Vector3f(s,s,s)
    end
    -- Amaz.LOGE("======kk:",self.progress)
    self:updateAnim(self.progress)

    local u_TextFontSize = self:getTextFontSize() / 26 * self.parentTrans.localScale.x

    local expandSize = self.text:getRectExpanded() 
    -- self.material:setFloat("u_TextFontSize", u_TextFontSize)
    -- self.material:setVec2("expandSize", Amaz.Vector2f(expandSize.width+self.text.targetRTExtraSize.x, expandSize.height+self.text.targetRTExtraSize.y))
    -- self.material:setVec4("u_TextColor", Amaz.Vector4f(textColor.x, textColor.y, textColor.z, 1.0))

    self:getWordInfo()

    self:updatematerial()
end

function TextAnim:updateAnim(_p)
    local p = _p*2.0
    local alpha_p = util.remap01(0.67, 1.0, _p)
    local scale_p = util.remap01(0.5, 1.0, _p)

    local scale_p1 = (25 + scale_p*(44-25))/44
    local s0 = self.attrs:GetVal("ADBE_Scale_0_0", scale_p1)[1]/100

    -- Amaz.LOGE("dkdkkdkd===",s0.."=="..alpha_p)
    scale_p = s0
    local offsety = 0.25
    local w = Amaz.BuiltinObject:getOutputTextureWidth()
    local h = Amaz.BuiltinObject:getOutputTextureHeight()
    if h > w then
        offsety = 0.15
    end
    local num = 1 + self.clone_num
    -- self.material:setFloat("u_Strength", 0.0)
     
    local multi_frame1 = 3
    local multi_frame = 2

    local setting_thetha = 0
    if self.text.typeSettingKind == Amaz.TypeSettingKind.VERTICAL then
        setting_thetha = 90
    end

    -- for i = 1, 6 do
    --     local pp = util.remap01((i-1)*multi_frame1, (10+i*multi_frame1), p*(10+6*multi_frame1+self.clone_num*multi_frame))
    --     local ss = util.bezier({0.027272727, 0.821506779, 0.66666667, 1,})(pp, 0, 1, 1)
    --     local dir_lenth = offsety*(1.0-ss)
    --     local thetha = 3.1415926*(self.parentTrans.localEulerAngle.z + setting_thetha)/180
    --     self.material:setVec2("s"..i, Amaz.Vector2f(dir_lenth*math.sin(thetha),-dir_lenth*math.cos(thetha)))
    --     local opt_pt = util.bezier({0.027272727, 0.278942261, 0.66666667, 1, })(pp, 0, 1, 1)
    --     self.material:setFloat("a"..i, opt_pt)
    --     pp = alpha_p > 0.001 and 1 or 0
    --     self.material:setFloat("a0", 1)
    --     self.material:setFloat("scale",scale_p)
    -- end

        -- Amaz.LOGE("=======>>:",self.clone_num)
    self.material:setFloat("scale",scale_p)
    local textColor = self:getTextColor()
    for index = 1, self.clone_num do
        local material = self.cloneMaterial[index]:get(0)
        local dir = index%2 == 0 and 1 or -1

        for i = 1, 6 do
            local pp = util.remap01((i-1)*multi_frame+index*multi_frame, (10+i*multi_frame1+index*multi_frame), p*(10+6*multi_frame1+self.clone_num*multi_frame))
            local ss = util.bezier({0.027272727, 0.821506779, 0.66666667, 1,})(pp, 0, 1, 1)
            local dir_lenth = offsety*(1.0-ss)
            local thetha = 3.1415926*(self.parentTrans.localEulerAngle.z + setting_thetha)/180
            -- Amaz.LOGI("dkdkkdkd22",thetha)

            material:setVec2("s"..i,Amaz.Vector2f(dir*dir_lenth*math.sin(thetha),-dir*dir_lenth*math.cos(thetha)))
            local opt_pt = util.bezier({0.027272727, 0.278942261, 0.66666667, 1, })(pp, 0, 1, 1)
            material:setFloat("a"..i, opt_pt)
        end

        material:setFloat("a0", pp)
        material:setFloat("scale",scale_p)
        material:setVec4("u_TextColor", Amaz.Vector4f(textColor.x, textColor.y, textColor.z, 1.0))

    end
    self:updateAplha(alpha_p)
    self:updateScale(self.multiscale)
end

function TextAnim:updateAplha(alpha_p)
    local totallen = #self.wordList
    if totallen > 0 then
        for index, value in ipairs(self.wordList) do
            for i, char in ipairs(value) do
                if alpha_p >= index/(totallen+0.1) then
                    char.color = Amaz.Vector4f(char.color.x,char.color.y,char.color.z,1.0)
                else
                    char.color = Amaz.Vector4f(char.color.x,char.color.y,char.color.z,0.0)
                end
            end
        end
    end
    
    for index = 1, self.clone_num do
        for i = 1, self.count do
            local char = self.text.chars:get(i - 1)
            local cloneChar = self.cloneText[index].chars:get(i-1)
            if char.color.w > 0.2 then
                cloneChar.color = Amaz.Vector4f(char.color.x,char.color.y,char.color.z,0.0)
            else
                cloneChar.color = Amaz.Vector4f(char.color.x,char.color.y,char.color.z,1.0)
            end
        end

    end
-- wordList
end

function TextAnim:onEnter()
	self.first = true
	
end
function TextAnim:resetData( ... )
	if self.text ~= nil then
        self.text:forceTypeSetting()
    	local chars = self.text.chars 
		for i = 1, self.text.chars:size() do
			local char = chars:get(i - 1)
			if char.rowth ~= -1 then
				char.position = char.initialPosition
				char.rotate = Amaz.Vector3f(0, 0, 0)
				char.scale = Amaz.Vector3f(1, 1, 1)
				char.color = Amaz.Vector4f(1, 1, 1, 1)
			end
		end
        self.text.renderToRT = false
        self.text.chars = chars
	end

    self.text:forceTypeSetting()
	self.trans.localPosition = Amaz.Vector3f(0, 0, 0)
	self.trans.localEulerAngle = Amaz.Vector3f(0, 0, 0)
	self.trans.localScale = Amaz.Vector3f(1, 1, 1)
    self.text.targetRTExtraSize = Amaz.Vector2f(0.0, 0.0)

    self.trans_scale = 1

    for i, value in pairs(self.cloneEntity) do
        self.textEntity.scene:removeEntity(self.cloneEntity[i])
        if self.parentTrans.children:size() > 1 and self.cloneEntity[i] then
            self.parentTrans.children:erase(self.cloneEntity[i])
        end
        self.cloneEntity[i] = nil
    end
    self.cloneEntity = {}
    local text = self.rich_text
    if text then
        if text.BloomPath then
            text.BloomPath = self.pre_bloom_path
        elseif text.bloomPath then
            text.bloomPath = self.pre_bloom_path
        end
    end
end

function TextAnim:setDuration(duration)
   self.duration = duration
end
function TextAnim:onLeave()
    self:resetData()
	self.first = true
end
function TextAnim:clear()

	self:resetData()
end

exports.TextAnim = TextAnim
return exports
