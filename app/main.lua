local lor = require("lor.index")
local session_middleware = require("lor.lib.middleware.session")
local check_login_middleware = require("app.middleware.check_login")
local whitelist = require("app.config.config").whitelist
local router = require("app.router")
local app = lor()

app:conf("view enable", true)
app:conf("view engine", "tmpl")
app:conf("view ext", "html")
app:conf("views", "./app/views")

--[[
app:use(session_middleware())
-- 加载session插件
local session_middleware = require("lor.lib.middleware.session")
app:use(session_middleware({
    secret = "G3fu98Kor0rJrembv67fnhgl95FioRpQ", -- 加密用的盐
    timeout = 3600 -- session超时时间，默认为3600秒
}))
]]


-- filter: add response header
app:use(function(req, res, next)
    res:set_header('X-Powered-By', 'Lor Framework')
    next()
end)

-- 拦截器：检查登录状态
--app:use(check_login_middleware(whitelist))

router(app) -- business routers and routes

-- 404 error
-- app:use(function(req, res, next)
--     if req:is_found() ~= true then
--         res:status(404):send("404! sorry, page not found.")
--     end
-- end)

-- error handle middleware
app:erroruse(function(err, req, res, next)
    --ngx.log(ngx.ERR, err)
    if req:is_found() ~= true then
        res:status(404):send("404! sorry, page not found. uri:" .. req.path)
    else
        res:status(500):send("unknown error")
    end
end)


--ngx.say(app.router.trie:gen_graph())

app:run()
