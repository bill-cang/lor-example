local pairs = pairs
local ipairs = ipairs
local lor = require("lor.index")
local users = require("app.config.config").users
local user_model = require("app.model.user_model")
local authRouter = lor:Router()
local utils_model = require "app.model.utils_model"
local public_con = require "app.config.public"


authRouter:get("/login", function(req, res, next)
    --ngx.say("进入git请求")
    res:render("login")
end)

authRouter:post("/login", function(req, res, next)
    --local params = req.body

    local username = req.body.username
    local password = req.body.password

    --ngx.log(ngx.err,"********"..username)

    local notExists = true

    user,err=user_model:query_by_name(username,password)

    if not user then
        return res:json(public_con['error']['account_exist_error'])
    end
    --req.session.set("username",username)

    local info = {}

    info.name = user.name
    info.id = user.id

    local data = utils_model:table_clone(public_con['success'])
    data.info = info

    return res:json(data)

--[[    notExists = false
    return res:redirect("/todo/index")]]


end)

authRouter:get("/logout", function(req, res, next)
    req.session.destroy()
    res:redirect("/auth/login")
end)


return authRouter

