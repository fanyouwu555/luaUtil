local Util = { }


-- 增加,分割字符串
function Util.SplitNumberByComma(formatted)
	local k;
	while true do
		formatted, k = string.gsub(formatted, "^([-%d]*%d)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end
	return formatted
end




-- 格式化float数据
-- 小数点后无效的0忽略 ，如 1.10 保留2为小数的话，则为1.1
function Util.FormatFloat(value, N)
	if (not N) then
		N = 2;
	end
	local format = string.format('%%.%df', N + 1);
	local result = string.format(format, value);

	local ret = string.gsub(result, '(%.-0*)(%d)$', function(v1, v2) if (v2 == '0') then return ''; else return v1; end end);
	return Util.SplitNumberByComma(ret);
end



local suffix = { '', 'K', 'M', 'B', 'T', 'q', 'Q', 's', 'S', 'O', 'N', 'd', 'U', 'D' };
-- 格式化cash
-- notRound , true四舍五入,false 或nil不四舍五入
function Util.FormatCashNum(value, notRound)
	if (value < 0) then
		return '-' .. Util.FormatCashNum(- value, notRound);
	end
	if (value < 1000) then
		return tostring(math.floor(value));
	end

	local newValue = nil;
	local length = math.floor(math.log(value, 10) / 3);

	if (notRound) then
		local divValue = 10 ^(length * 3);
		newValue = value / divValue;
	else
		local divValue = 10 ^(length * 3 - 2);
		newValue = math.floor(value / divValue) / 100;
	end

	local ret = string.format('%.2f%s', newValue, suffix[length + 1])
	return ret;
end


local pow10_3 = 10 ^ 3;
local pow10_6 = 10 ^ 6;
local pow10_9 = 10 ^ 9;
local pow10_12 = 10 ^ 12;
local pow10_15 = 10 ^ 15;
local pow10_18 = 10 ^ 18;


-- 格式化数字100M,  !!不四舍五入!!
-- @param point 为true时则不保留小数点
function Util.FormatNum(value, point)
	if (value < 0) then
		return '-' .. Util.FormatNum(- value, point)
	end

	local format = '%d';
	local fixValue = math.floor
	if (not point) then
		format = '%.2f';
		fixValue = function(value) return math.floor(value * 100) / 100; end;
	end

	if (value >= pow10_18) then
		return string.format(format, fixValue(value / pow10_18)) .. suffix[7];
	end
	if (value >= pow10_15) then
		return string.format(format, fixValue(value / pow10_15)) .. suffix[6];
	end
	if (value >= pow10_12) then
		return string.format(format, fixValue(value / pow10_12)) .. suffix[5];
	end
	if (value >= pow10_9) then
		return string.format(format, fixValue(value / pow10_9)) .. suffix[4];
	end
	if (value >= pow10_6) then
		return string.format(format, fixValue(value / pow10_6)) .. suffix[3];
	end
	if (value >= pow10_3) then
		return string.format(format, fixValue(value / pow10_3)) .. suffix[2];
	end
	return string.format('%d', math.floor(fixValue(value)));
end


-- 格式化钻石,小于 1M的 用逗号隔开
function Util.FormatDiamondNum(value)
	if (value >= 1000000) then
		return Util.FormatCashNum(value);
	else
		return Util.SplitNumberByComma(value);
	end
end


-- 分割数字字符串,数字都为整数
-- 1231;123,3343
function Util.SplitToIntegerArray(str)
	local ret = { };
	for d in string.gmatch(str, "(-?%d+)") do
		table.insert(ret, tonumber(d));
	end
	return ret;
end




function Util.clamp(value, min, max)
	if value > max then
		return max;
	elseif value < min then
		return min;
	else
		return value;
	end
end






-- 对象是否销毁判断
function Util.IsNil(uobj)
	return uobj == nil or uobj:Equals(nil)
end


function Util.TableExtensionField(obj, add_field_name, name)
	setmetatable(obj, {
		__index = function(t, k)
			if (add_field_name == k) then
				return rawget(t, name);
			else
				return rawget(t, k);
			end
		end
	} );
end


-- table合并,不覆盖,如果存在则提示错误
function Util.TableMerge(dest, src)
	for k, v in pairs(src) do
		if (dest[k]) then
			traceError('合并失败 ! 不能覆盖 %s', k);
		else
			dest[k] = v
		end
	end
end




-- 格式化时间隔
-- time 秒
function Util.FormatTime(time)
	if (time < 0) then
		time = 0;
	end

	local hour = math.floor(time / 3600)

	local day = math.floor(hour / 24);
	hour = math.fmod(hour, 24);

	local minute = math.fmod(math.floor(time / 60), 60)
	local second = math.fmod(math.floor(time), 60)

	if (day > 0) then
		local strTime = string.format("%02d:%02d:%02d", hour, minute, second);
		return language:getValue('Common1022', day, strTime);
	else
		if (hour > 0) then
			return string.format("%02d:%02d:%02d", hour, minute, second)
		else
			return string.format("%02d:%02d", minute, second)
		end
	end
end








function Util.FormatTimeInToday(time)
	if (time < 0) then
		time = 0;
	end
	time = math.floor(math.fmod(time, 60 * 60 * 24));
	return Util.FormatTime(time);
end





-- 格式化时间戳
-- 显示UTC时间
function Util.FormatServerTimeUTC(t)
	return os.date("!%Y.%m.%d", t)
end



-- 格式化服务器时间戳
-- 参数一般为服务器下发过来的时间戳
-- 转化为本地时间显示本地时间
function Util.FormatServerTime(format, time)
	if (not string.match(format, '^[^!].*')) then
		traceError('format not start ! [%s] , %s', format, tostring(time));
	end
	return os.date(format, time);
end



function Util.FormatBeginEndTime(beginTime, endTime)
	local b = Util.FormatServerTime("%Y.%m.%d", math.floor(beginTime / 1000));
	local e = Util.FormatServerTime("%Y.%m.%d", math.floor(endTime / 1000));
	return string.format('%s - %s', b, e);
end


-- 得到utc的年月日
function Util.getUtcDateTime(t)
	local tm = os.date('!*t', t);
	return tm.year, tm.month, tm.day, tm.hour, tm.min, tm.sec;
end


-- 
function Util.mkUtcTime(tm)
	local offset = os.time(os.date("!*t", os.time())) - os.time();
	return os.time(tm) - offset;
end



-- 字符串时间转换UTC时间戳
-- time = XXXX-XX-XX XX:XX:XX
function Util.GetTimeStamp(time)
	local year, month, day, hour, minute, second = string.match(time, '(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)');
	if (year and month and day and hour and minute and second) then
		local t = Util.mkUtcTime( { day = day, month = month, year = year, hour = hour, min = minute, sec = second })
		return t;
	else
		return nil;
	end
end


-- 得到今日(UTC) 00:00的时间戳.
-- curTime 时间戳(秒)
function Util.GetCurrNight(curTime)
	local d = os.date('!*t', curTime);
	d.hour = 0;
	d.min = 0;
	d.sec = 0;
	return Util.mkUtcTime(d);
end

-- 得到多少天后24点的时间
-- curTime 时间戳(秒)
function Util.GetDayMidnight(curTime, day)
	-- local d = os.date('!*t', curTime);
	-- d.hour = 0;
	-- d.min = 0;
	-- d.sec = 0;
	local oneDay = 24 * 60 * 60;
	return Util.GetCurrNight(curTime) +(oneDay * day);
end

function Util.GetCurrHour(curTime)
	local time = curTime/1000
	local hour = math.fmod(math.floor(time / 3600), 24);
	return hour
end



function Util.GetTime(curTime,time)
	local oneDay = time * 60 * 60;
	return Util.GetCurrNight(curTime) + oneDay;
end

-- 得到今日(UTC) 24:00的时间戳(UTC)
-- curTime 时间戳(秒)
function Util.GetMidnight(curTime)
	-- local d = os.date('!*t', curTime);
	-- d.hour = 0;
	-- d.min = 0;
	-- d.sec = 0;
	local oneDay = 24 * 60 * 60;
	return Util.GetCurrNight(curTime) + oneDay;
end

-- 得到今日(UTC) 12：00的时间戳
-- curTime 时间戳(秒)
function Util.GetHighNoon(curTime)
	local oneDay = 12 * 60 * 60;
	return Util.GetCurrNight(curTime) + oneDay;
end




-- 转换罗马数字1-10
function Util.ConvertRomanNumerals(num)
	local roman = { 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X' }
	if num > 0 and num <= 10 then
		return roman[num]
	end
	return 0;
end



-- USD0.99拆分出 货币符号和价格
function Util.getPriceByPriceString(price)
	if (price) then
		local f = string.gmatch(price, '([^%d]+)([%d.,]+)');
		if (f) then
			local priceCode, priceValue = f();
			local ret = string.gsub(priceValue, ',', '');
			return priceCode, tonumber(ret);
		end
	end
	return nil, nil;
end

function Util.FormatResourceNum(t, value)
	if (ConstValue.ResourceType.Cash == t) then
		return util.FormatCashNum(value);
	else
		return util.FormatNum(value);
	end
end


return Util;
