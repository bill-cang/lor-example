local type = type
local pairs = pairs
local type = type
local mceil = math.ceil
local mfloor = math.floor
local mrandom = math.random
local mmodf = math.modf
local sgsub = string.gsub
local tinsert = table.insert
local date = require("app.libs.date")
local str = require "resty.string"
local http = require "resty.http"
local ngx_quote_sql_str = ngx.quote_sql_str
local os = require "os"


local _M = {}

function _M.encode(s)
    local sha256 = resty_sha256:new()
    sha256:update(s)
    local digest = sha256:final()
    return str.to_hex(digest)
end


function _M.clear_slash(s)
    s, _ = sgsub(s, "(/+)", "/")
    return s
end

function _M.is_table_empty(t)
    if t == nil or _G.next(t) == nil then
        return true
    else
        return false
    end
end

function _M.table_is_array(t)
    if type(t) ~= "table" then return false end
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

function _M.mixin(a, b)
    if a and b then
        for k, v in pairs(b) do
            a[k] = b[k]
        end
    end
    return a
end

function _M.random()
    return mrandom(0, 1000)
end


function _M.total_page(total_count, page_size)
    local total_page = 0
    if total_count % page_size == 0 then
        total_page = total_count / page_size
    else
        local tmp, _ = mmodf(total_count / page_size)
        total_page = tmp + 1
    end

    return total_page
end


function _M.days_after_registry(req)
    local diff = 0
    local diff_days = 0 -- default value, days after registry

    if req and req.session then
        local user = req.session.get("user")
        local create_time = user.create_time
        if create_time then
            local now = date() -- seconds
            create_time = date(create_time)
            diff = date.diff(now, create_time):spandays()
            diff_days = mfloor(diff)
        end
    end

    return diff_days, diff
end

function _M.now()
    local n = date()
    local result = n:fmt("%Y-%m-%d %H:%M:%S")
    return result
end

function _M.secure_str(str)
    return ngx_quote_sql_str(str)
end


function _M.string_split(str, delimiter)
    if str == nil or str == '' or delimiter == nil then
        return nil
    end

    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        tinsert(result, match)
    end
    return result
end


function _M.print_r(t)
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            ngx.print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        ngx.print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        ngx.print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        ngx.print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        ngx.print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                ngx.print(indent .. tostring(t))
            end
        end
    end

    if (type(t) == "table") then
        ngx.print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        ngx.print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end

function _M.random_string(length)
    local str_table = {
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
        "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "u", "w",
        "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
    }

    math.randomseed(os.time())

    local txt = ""

    for i = 1, length do
        local num = math.random(62)
        txt = txt .. str_table[num]
    end

    return txt
end

--function _M.paginator(pagenum,total,url)
--    if pagenum==nil or url==nil or total==nil then
--        return ""
--    end
--    return_str = '<ul class="pagination pagination-lg m-t-0" style="">'
--    if total > 1 and pagenum <= total  then
--- -        if pagenum == 1 then
---- return_str = return_str..'<li class="disabled"><a href="#"> <i class="fa fa-angle-left"></i></a></li>'
---- else
---- return_str = return_str..'<li><a href="'..url..'?page='..(pagenum - 1)..'"> <i class="fa fa-angle-left"></i></a></li>'
---- end
--
-- if pagenum <= 1 then
-- return_str = return_str..'<li class="disabled"><a href="#"> <i class="fa fa-angle-left"></i></a></li>'
-- else
-- return_str = return_str..'<li><a href="'..url..'?page='..(pagenum - 1)..'"> <i class="fa fa-angle-left"></i></a></li>'
-- end
--
-- if pagenum ~= 1 then
-- return_str = return_str..'<li><a href="'..url..'?page=1'..'"> 1</a></li>'
-- end
--
-- if (pagenum - 2) > 1 then
-- return_str = return_str..'<li><a href="'..url..'?page='..(pagenum - 2)..'">'..(pagenum - 2)..'</a></li>'
-- end
--
-- if (pagenum - 1) > 1 then
-- return_str = return_str..'<li><a href="'..url..'?page='..(pagenum - 1)..'">'..(pagenum - 1)..'</a></li>'
-- end
--
-- return_str = return_str ..'<li class="active"><a href="#">'..pagenum..'</a></li>'
--
-- if (pagenum + 1) <= total then
-- return_str = return_str..'<li><a href="'..url..'?page='..(pagenum + 1)..'">'..(pagenum + 1)..'</a></li>'
-- end
--
-- if (pagenum + 2) <= total then
-- return_str = return_str..'<li><a href="'..url..'?page='..(pagenum +2)..'">'..(pagenum + 2)..'</a></li>'
-- end
--
-- if pagenum ~= total and (pagenum + 2) < total then
-- return_str = return_str..'<li><a href="'..url..'?page='..(total)..'">'..(total)..'</a></li>'
-- end
--
-- if pagenum >= total  then
-- return_str = return_str..'<li class="disabled"><a href="#"> <i class="fa fa-angle-right"></i></a></li>'
-- else
-- return_str = return_str..'<li><a href="'..url..'?page='..(pagenum + 1)..'"> <i class="fa fa-angle-right"></i></a></li>'
-- end
-- end
-- return_str = return_str.."</ul>"
-- return return_str
-- end
function _M.dateToTimestammp(date)
    local p
    if #date == 10 then
        p = "(%d+)-(%d+)-(%d+)"
    else
        p = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    end

    local year, month, day, hour, min, sec = date:match(p)
    local time_table = { year = (year or 0), month = (month or 0), day = (day or 0), hour = (hour or 0), min = (min or 0), sec = (sec or 0) }

    return os.time(time_table)
end

function _M.timeDiff(long_time, short_time)
    local n_short_time, n_long_time, carry, diff = os.date('*t', short_time), os.date('*t', long_time), false, {}
    local colMax = { 60, 60, 24, os.date('*t', os.time { year = n_short_time.year, month = n_short_time.month + 1, day = 0 }).day, 12, 0 }
    n_long_time.hour = n_long_time.hour - (n_long_time.isdst and 1 or 0) + (n_short_time.isdst and 1 or 0) -- handle dst
    for i, v in ipairs({ 'sec', 'min', 'hour', 'day', 'month', 'year' }) do
        diff[v] = n_long_time[v] - n_short_time[v] + (carry and -1 or 0)
        carry = diff[v] < 0
        if carry then
            diff[v] = diff[v] + colMax[i]
        end
    end
    return diff
end

function _M.put_time(time)
    local text = ""

    if not time then
        return text
    end

    local ts = ngx.now() - time

    if ts <= 0 or ts < 60 then
        return "seconds ago"
    end

    if ts > 0 and ts < 120 then
        return "A minute ago"
    end

    local i = mceil(ts / 60);
    local h = mceil(ts / 3600);
    local d = mceil(ts / 86400);

    if i < 30 then
        return i .. " minutes ago"
    end

    if i > 30 and i < 60 then
        return "In one hour"
    end

    if h > 1 and h < 24 then
        return h .. " hours ago"
    end

    if d >= 1 then
        return d .. " days ago"
    end
end


function _M.get_payment(payment)
    local text = ""
    if not payment then
        return text
    end

    local arrs = _M.string_split(payment, ',')

    for _, arr in ipairs(arrs) do

        if arr == '1' then
            text = text .. "AliPay-支付宝 ,"
        elseif arr == '2' then
            text = text .. "Wechat-微信 ,"
        elseif arr == '3' then
            text = text .. "Bank-网银转账,"
        end
    end

    if text ~= "" then
        text = string.sub(text, 1, (#text - 1))
    end

    return text
end

function _M.paginator(pagenum, total, url)
    if pagenum == nil or url == nil or total == nil then
        return ""
    end

    pagenum = tonumber(pagenum)
    total = tonumber(total)

    local return_str = '<nav aria-label="Page navigation example"><ul class="pagination justify-content-center">'
    if total >= 1 and pagenum <= total then

        if pagenum <= 1 then
            return_str = return_str .. '<li class="page-item disabled"> <a class="page-link" href="#" tabindex="-1">Previous</a> </li>'
        else
            return_str = return_str .. '<li class="page-item"> <a class="page-link" href="' .. url .. '?page=' .. (pagenum - 1) .. '" tabindex="-1">Previous</a> </li>'
        end

        if pagenum ~= 1 then
            return_str = return_str .. '<li class="page-item"><a class="page-link" href="' .. url .. '?page=1' .. '"> 1</a></li>'
        end

        if (pagenum - 2) > 1 then
            return_str = return_str .. '<li class="page-item"><a class="page-link" href="' .. url .. '?page=' .. (pagenum - 2) .. '">' .. (pagenum - 2) .. '</a></li>'
        end

        if (pagenum - 1) > 1 then
            return_str = return_str .. '<li class="page-item"><a class="page-link" href="' .. url .. '?page=' .. (pagenum - 1) .. '">' .. (pagenum - 1) .. '</a></li>'
        end

        return_str = return_str .. '<li class="page-item active"><a class="page-link" href="#">' .. pagenum .. '</a></li>'

        if (pagenum + 1) <= total then
            return_str = return_str .. '<li class="page-item"><a class="page-link" href="' .. url .. '?page=' .. (pagenum + 1) .. '">' .. (pagenum + 1) .. '</a></li>'
        end

        if (pagenum + 2) <= total then
            return_str = return_str .. '<li class="page-item"><a class="page-link" href="' .. url .. '?page=' .. (pagenum + 2) .. '">' .. (pagenum + 2) .. '</a></li>'
        end

        if pagenum ~= total and (pagenum + 2) < total then
            return_str = return_str .. '<li class="page-item"><a class="page-link" href="' .. url .. '?page=' .. (total) .. '">' .. (total) .. '</a></li>'
        end

        if pagenum >= total then
            return_str = return_str .. '<li class="page-item disabled"> <a class="page-link" href="#">Next</a> </li>'
        else
            return_str = return_str .. '<li class="page-item"> <a class="page-link" href="' .. url .. '?page=' .. (pagenum + 1) .. '"> Next</a></li>'
        end
    end
    return_str = return_str .. "</ul>"
    return return_str
end



function _M.get_token_project(token_name)
    local text = ""
    if not token_name then
        return text
    end

    if token_name == 'bmx' then
        text = "BitMaxer"
    elseif token_name == 'btc' then
        text = "Bitcoin"
    elseif token_name == 'eth' then
        text = "Ethereum"
    elseif token_name == 'omg' then
        text = "OmiseGo"
    elseif token_name == 'ae' then
        text = "Aeternity"
    elseif token_name == 'bat' then
        text = "Basic Attention"
    elseif token_name == 'ltc' then
        text = "Litcoin"
    elseif token_name == 'eos' then
        text = "EOS"
    elseif token_name == 'snt' then
        text = "Status"
    elseif token_name == 'pay' then
        text = "TenX"
    elseif token_name == 'iota' then
        text = "IOTA"
    elseif token_name == 'neo' then
        text = "NEO"
    elseif token_name == 'qtum' then
        text = "Qtum"
    elseif token_name == 'usdt' then
        text = "USDT"
    elseif token_name == 'bch' then
        text = "Bitcoin Cash"
    end

    return text
end

function _M.get_avatar(avatar)
    if avatar == ngx.null or avatar == "" then
        str = " http://bm-static.oss-ap-northeast-1.aliyuncs.com/images/user.jpg"
    else
        str = avatar
    end

    return str
end

function _M.check_deposit(uid)
    local httpc = http.new()
    httpc:set_timeout(5000)
    local r, err = httpc:request_uri("http://127.0.0.1:2222/check_deposit", {
        method = "POST",
        body = "uid="..uid,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        }
    })
end


return _M


