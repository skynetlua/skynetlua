local Timer = {}

-- brief : 获取下N个小时的时间点
-- param : interval,若干小时
-- param : timepoint,起始时间点,为nil时则为当前时间
-- return : 小时点Hour,unix时间戳
function Timer.get_next_hour( interval,timepoint )
	local tt = timepoint or this.time()

	tt = tt + 3600 * interval

	local time = os.date('*t',tt)

	return time.hour,tt
end

-- brief : 获取下N个半小时的时间点
-- param : interval,若干小时
-- param : timepoint, 起始时间点,为nil时则为当前时间
-- return : unix时间戳
function Timer.get_next_half_hour( interval, timepoint )
    local tt = timepoint or this.time()
	local time = os.date("*t",tt + (1800 * interval))
	time.sec = 0

	if time.min < 30 then
		time.min = 0
	else
		time.min = 30
	end

	return os.time(time)
end

-- brief : 获取下N个时刻的时间点
-- param : interval, 若干小时
-- return : unix时间戳
function Timer.get_next_hour_point( interval )
	interval = interval or 1
	local ti = this.time() + 3600 * interval --获取下一时刻

	ti = os.date("*t",ti)

	ti.min = 0
	ti.sec = 0

	return os.time(ti)
end

-- 获取下一个cron时间
-- @param minute 从0开始的间隔分钟 如10 - [0 10 20 30 40 50]  20 - [0 20 40] 9 - [0 9 18 27 36 45 54]
-- @param 时间起点 
function Timer.get_next_cron_min_point(minute,timepoint)
    local tt = timepoint or this.time()
    local time = os.date("*t", tt) 
    time.sec = 0 
    local n = math.modf(time.min / minute) + 1 
    local x = n * minute
    if x >= 60 then
        time.hour = time.hour + 1 
        time.min = 0 
    else
        time.min = x 
    end 
    return os.time(time)
end

-- brief: HMS时间格式的 >= 判断函数
-- param: h,m必填, s可以不填,默认=0
-- return: true(hms1 >= hms2)/ false反之
--
-- eg: 判断17:50:30与21:30:30哪个时间点更大
--	   Timer.check_hms_greater_equal(17, 50, 30, 21, 30, 30)
function Timer.check_hms_greater_equal( h1, m1, s1, h2, m2, s2 )
	s1 = s1 or 0
	s2 = s2 or 0
	assert(Timer.is_valid_hms(h1, m1, s1))
	assert(Timer.is_valid_hms(h2, m2, s2))

	if h1 ~= h2 then
		return h1 > h2
	elseif m1 ~= m2 then
		return m1 > m2
	elseif s1 ~= s2 then
		return s1 > s2
	else
		return true --相等
	end
end

-- brief: 计算当前时间到下一个HMS的秒数,如果此时间点已过则取至第二天此HM的秒数
-- param: int h, int m, int s
-- return: 当前时间到下一个HMS的秒数,如果此时间点已过则取至第二天此HM的秒数
function Timer.get_diff_sec_to_next_hms( h, m, s )
	s = s or 0
	assert(Timer.is_valid_hms(h, m, s))	

	local now = os.date('*t')
	if Timer.check_hms_greater_equal(now.hour, now.min, now.sec, h, m, s) then
		--时间点已过, 取当前时间到第二天hh:mm:ss的秒数
		local passed_secs = (now.hour - h) * 3600 + (now.min - m) * 60 + (now.sec - s)
		return 24 * 3600 - passed_secs
	else
		--未过
		return (h - now.hour) * 3600 + (m - now.min) * 60 + (s - now.sec)
	end
end

-- brief : 获取当前时间距离某一个整点的秒数
-- param : interval, 若干小时
-- return : secs,相差的秒数
function Timer.get_diff_sec_to_next_hour(interval)
	local now = os.date('*t')
	return (interval or 1 ) * 3600-(now.min*60+now.sec)
end


-- brief : 获取当前时间距下一天某时刻的秒数（以x点为新的一天）
-- param : x, 时刻点
-- return : secs, 相差的秒数
function Timer.get_diff_sec_to_next_day_x(x)
	local now = this.time()
	local ti = now + 3600 * 24 --获取下一天

	local nexttime = os.date('*t', ti)

	local next_day = { year = nexttime.year, month = nexttime.month, day = nexttime.day, hour = x, min = 0, sec = 0 }
	local next_day_ti = os.time(next_day)
	return next_day_ti - now
end

-- brief : 获取前一天某时刻的时间点
-- param : x, 时刻点
-- return : unix时间戳
function Timer.get_prev_day_x(x)
	local time = this.time()
	local date = os.date("*t", time)
	local next = { year = date.year, month = date.month, day = date.day - 1, hour = x, min = 0, sec = 0 }
	return os.time(next)
end

-- brief : 获取当天某时刻的时间点
-- param : x, 时刻点
-- return : unix时间戳
function Timer.get_curr_day_x(x)
	local time = this.time()
	local date = os.date("*t", time)
	local next = { year = date.year, month = date.month, day = date.day, hour = x, min = 0, sec = 0 }
	return os.time(next)
end

-- brief : 获取下一天某时刻的时间点
-- param : x, 时刻点
-- return : unix时间戳
function Timer.get_next_day_x(x)
	local now = this.time()
	local ti = now + 3600 * 24 --获取下一天

	local nexttime = os.date('*t', ti)

	local next_day = { year = nexttime.year, month = nexttime.month, day = nexttime.day, hour = x, min = 0, sec = 0 }
	return os.time(next_day)
end

-- brief  : 获取指定时间点所在自然天下某个时刻的时间
-- param  : x, 时刻点
-- return : unix时间戳
function Timer.get_spec_day_x(x, hour)
	local date = os.date("*t", x)
	local next = { year = date.year, month = date.month, day = date.day, hour = hour, min = 0, sec = 0 }
	return os.time(next)
end

-- brief  : 获取前两周某天某时刻的时间点
-- wday   : 周几（周日 = 1， 周六 = 7）
-- hour   : 时间点
-- return : unix时间戳
function Timer.get_prev_prev_week_x(wday, hour)
	local time = this.time() - 2 * 7 * 24 * 3600
	local date = os.date("*t", time)
	local next = { year = date.year, month = date.month, day = date.day, hour = hour, min = 0, sec = 0 }
	return os.time(next) + (wday - date.wday) * 24 * 3600
end

-- brief  : 获取前一周某天某时刻的时间点
-- wday   : 周几（周日 = 1， 周六 = 7）
-- hour   : 时间点
-- return : unix时间戳
function Timer.get_prev_week_x(wday, hour)
	local time = this.time() - 7 * 24 * 3600
	local date = os.date("*t", time)
	local next = { year = date.year, month = date.month, day = date.day, hour = hour, min = 0, sec = 0 }
	return os.time(next) + (wday - date.wday) * 24 * 3600
end

-- brief  : 获取本周某天某时刻的时间点
-- wday   : 周几（周日 = 1， 周六 = 7）
-- hour   : 时间点
-- return : unix时间戳
function Timer.get_curr_week_x(wday, hour)
	local time = this.time()
	local date = os.date("*t", time)
	local next = { year = date.year, month = date.month, day = date.day, hour = hour, min = 0, sec = 0 }
	return os.time(next) + (wday - date.wday) * 24 * 3600
end

-- brief  : 获取下周某天某时刻的时间点
-- wday   : 周几（周日 = 1， 周六 = 7）
-- hour   : 时间点
-- return : unix时间戳
function Timer.get_next_week_x(wday, hour)
	local time = this.time() + 7 * 24 * 3600
	local date = os.date("*t", time)
	local next = { year = date.year, month = date.month, day = date.day, hour = hour, min = 0, sec = 0 }
	return os.time(next) + (wday - date.wday) * 24 * 3600
end

-- brief  : 获取指定时间点所在自然周下某时刻的时间点
-- x      : 指定时间点
-- wday   : 周几（周日 = 1， 周六 = 7）
-- hour   : 小时
function Timer.get_spec_week_x(x, wday, hour)
	local date = os.date("*t", x)
	local next = { year = date.year, month = date.month, day = date.day, hour = hour, min = 0, sec = 0 }
	return os.time(next) + (wday - date.wday) * 24 * 3600
end

-- brief  : 获取本月某天某时刻的时间点
-- day    : 日期
-- hour   : 时间点
-- return : unix时间戳
function Timer.get_curr_month_x(day, hour)
	local time = this.time()
	local date = os.date("*t", time)
	local next = { year = date.year, month = date.month, day = date.day, hour = (hour or 0), min = 0, sec = 0 }
	return os.time(next) + (day - date.day) * 24 * 3600
end

-- brief  : 获取上月某天某时刻的时间点
-- day    : 日期
-- hour   : 时间点
-- return : unix时间戳
function Timer.get_prev_month_x(day, hour)
    local time = this.time()
    local date = os.date("*t", time)
    local next = { year = date.year, month = date.month -1, day = date.day, hour = (hour or 0), min = 0, sec = 0 }
    return os.time(next) + (day - date.day) * 24 * 3600
end

-- brief  : 获取下月某天某时刻的时间点
-- day    : 日期
-- hour   : 时间点
-- return : unix时间戳
function Timer.get_next_month_x(day, hour)
	local time = this.time()
	local date = os.date("*t", time)
	local next = { year = date.year, month = date.month + 1, day = date.day, hour = (hour or 0), min = 0, sec = 0 }
	return os.time(next) + (day - date.day) * 24 * 3600
end

-- brief  : 获取指定时间点所在自然月下某时刻的时间点
-- x      : 指定时间点
-- day    : 日期
-- hour   : 时间点
-- return : unix时间戳
function Timer.get_spec_month_x(x, day, hour)
	local date = os.date("*t", x)
	local next = { year = date.year, month = date.month, day = day, hour = (hour or 0), min = 0, sec = 0 }
	return os.time(next)
end

-- 计算两个时间戳相差天数(自然天数)
-- t1 - unix时间戳（秒）
-- t2 - unix时间戳（秒）
-- pt - 日期分界点
-- return : 两个时间相差天数
function Timer.calculate_difference_days(t1, t2, pt)
	-- 计算时间戳对应日期起始时间
	local function begin(tm)
		local date = os.date("*t", tm)
		local time = os.time({year = date.year, month = date.month, day = date.day, hour = (pt or 0), min = 0, sec = 0})
		if (time > tm) then
			time = time - (24 * 3600)
		end
		return time
	end
	-- 计算相差自然天数
	local v1 = begin(t1)
	local v2 = begin(t2)
	return math.abs(v1 - v2) / (24 * 3600)
end

-- 计算两个时间戳相差周数(自然周数，周日 = 1， 周六 = 7)
-- t1 - unix时间戳（秒）
-- t2 - unix时间戳（秒）
-- return : 两个时间相差周数
function Timer.calculate_difference_weeks(t1, t2)
	--  计算时间戳当周起始时间
	local function begin(tm)
		local date = os.date("*t", tm)
		local time = { year = date.year, month = date.month, day = date.day, hour = 0, min = 0, sec = 0}
		return os.time(time) - (date.wday - 1) * 24 * 3600
	end
	-- 计算相差自然周数
	local v1 = begin(t1)
	local v2 = begin(t2)
	return math.abs(v1 - v2) / (7 * 24 * 3600)
end

-- 计算两个时间戳相差月份（自然月份）
-- t1 - unix时间戳（秒）
-- t2 - unix时间戳（秒）
-- return : 两个时间相差月份
function Timer.calculate_difference_months(t1, t2)
	local v1 = os.date("*t", math.max(t1, t2))
	local v2 = os.date("*t", math.min(t1, t2))
	return (v1.year - v2.year) * 12 + v1.month - v2.month
end

-- brief : 根据时间戳ti格式化日期
-- param : ti,unix时间戳
-- return : time table
function Timer.get_ymd(ti)
	return os.date('%Y%m%d', ti)
end

-- brief : 根据时间戳ti格式化日期
-- param : ti,unix时间戳
-- return : time table
function Timer.get_ymdh(ti)
	return os.date('%Y%m%d%H', ti)
end

-- 根据时间戳获取对应年份
-- 1. unix时间戳
function Timer.get_year(ti)
	return tonumber(os.date('%Y', ti))
end

-- 根据时间戳获取对于月份
-- 1. unix时间戳
function Timer.get_month(ti)
	return tonumber(os.date('%m', ti))
end

-- 根据时间戳获取对应天数
function Timer.get_mday(ti)
	return tonumber(os.date('%d', ti))
end

--根据当前时间戳获取对应小时数
function Timer.get_hour(ti)
	return tonumber(os.date('%H', ti))
end

-- brief: 判断时间参数是否合法
-- param: h,m,s 三个参数至少有一个不是nil
-- return : true/false
function Timer.is_valid_hms( h, m, s )
	local ret = true
	assert(h ~= nil or m ~= nil or s ~= nil)
	if h ~= nil then
		ret = (h >= 0 and h <= 23) and ret
	end
	if m ~= nil then
		ret = (m >= 0 and m <= 59) and ret
	end
	if s ~= nil then
		ret = (s >= 0 and s <= 59) and ret
	end
	return ret
end

return Timer
